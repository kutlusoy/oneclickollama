@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

:: ============================================================================
:: Oneclickollama the custom Ollama Model Creator - Complete One-Click Solution
:: ============================================================================
:: This batch file creates a custom Ollama model from documents
:: Supports: PDF (with images), Word, Excel, PowerPoint, text files, SQL, etc.
:: Author: Ali Kutlusoy
:: Version: 1.2 - Enhanced with Model Selection
:: ============================================================================

title Custom Ollama Model Creator

:: Get current directory as base directory
set "BASE_DIR=%~dp0"

:: Color definitions for better UI
for /f %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"
set "GREEN=%ESC%[92m"
set "YELLOW=%ESC%[93m" 
set "RED=%ESC%[91m"
set "BLUE=%ESC%[94m"
set "CYAN=%ESC%[96m"
set "WHITE=%ESC%[97m"
set "RESET=%ESC%[0m"

echo %CYAN%
echo ================================================================================
echo                    CUSTOM OLLAMA MODEL CREATOR
echo ================================================================================
echo %WHITE%This tool will create a custom Ollama model from your documents
echo Supported formats: PDF, DOC/DOCX, XLS/XLSX, PPT/PPTX, TXT, SQL, CSV, and more
echo %RESET%

:: ============================================================================
:: SYSTEM CHECK - Check Ollama first to get available models
:: ============================================================================

echo.
echo %CYAN%================================================================================
echo                           SYSTEM PREPARATION
echo ================================================================================%RESET%

:: Check if Ollama is installed
echo %YELLOW%[INFO]%RESET% Checking Ollama installation...
ollama --version >nul 2>&1
if errorlevel 1 (
    echo %YELLOW%[INFO]%RESET% Ollama not found. Installing Ollama...
    call :install_ollama
    echo %YELLOW%[INFO]%RESET% Please restart this script after Ollama installation completes.
    pause
    exit /b 0
) else (
    echo %GREEN%[OK]%RESET% Ollama is already installed
)

:: ============================================================================
:: BASE MODEL SELECTION
:: ============================================================================

echo.
echo %CYAN%================================================================================
echo                              BASE MODEL SELECTION
echo ================================================================================%RESET%

echo %YELLOW%[INFO]%RESET% You can choose from popular models or enter a custom model name.

echo.
echo %CYAN%Available options:%RESET%
echo %WHITE%1) Select from popular models (will be downloaded if needed)%RESET%
echo %WHITE%2) Enter custom model name%RESET%
echo.

:get_selection_type
set /p SELECTION_TYPE="Choose option (1-2): "
if "%SELECTION_TYPE%"=="1" (
    call :select_popular_model
) else if "%SELECTION_TYPE%"=="2" (
    call :enter_custom_model
) else (
    echo %RED%[ERROR]%RESET% Invalid selection. Please choose 1 or 2.
    goto get_selection_type
)

echo.
echo %GREEN%[SELECTED]%RESET% Base model: %BASE_MODEL%

:: ============================================================================
:: USER INPUT COLLECTION
:: ============================================================================

echo.
echo %CYAN%================================================================================
echo                              MODEL CONFIGURATION
echo ================================================================================%RESET%

:get_model_name
set /p MODEL_NAME="Enter your custom model name (alphanumeric only): "
if "%MODEL_NAME%"=="" (
    echo %RED%[ERROR]%RESET% Model name cannot be empty!
    goto get_model_name
)

:: Create directory structure based on model name - FIXED PATHS
set "WORK_DIR=%BASE_DIR%%MODEL_NAME%_workspace"
set "DOCS_DIR=%WORK_DIR%\documents"
set "OUTPUT_DIR=%WORK_DIR%\processed"
set "MODELS_DIR=%WORK_DIR%\models"
set "TEMP_DIR=%WORK_DIR%\temp"
set "PYTHON_DIR=%WORK_DIR%\python_portable"
set "PYTHON_EXE=%PYTHON_DIR%\python.exe"
set "PIP_EXE=%PYTHON_DIR%\Scripts\pip.exe"

:: Debug: Show paths being created
echo %YELLOW%[DEBUG]%RESET% BASE_DIR: %BASE_DIR%
echo %YELLOW%[DEBUG]%RESET% WORK_DIR: %WORK_DIR%

:: Create directory structure
echo %YELLOW%[INFO]%RESET% Creating directory structure for model: %MODEL_NAME%
if not exist "%WORK_DIR%" (
    mkdir "%WORK_DIR%"
    echo %GREEN%[OK]%RESET% Created: %WORK_DIR%
)
if not exist "%DOCS_DIR%" (
    mkdir "%DOCS_DIR%"
    echo %GREEN%[OK]%RESET% Created: %DOCS_DIR%
)
if not exist "%OUTPUT_DIR%" (
    mkdir "%OUTPUT_DIR%"
    echo %GREEN%[OK]%RESET% Created: %OUTPUT_DIR%
)
if not exist "%MODELS_DIR%" (
    mkdir "%MODELS_DIR%"
    echo %GREEN%[OK]%RESET% Created: %MODELS_DIR%
)
if not exist "%TEMP_DIR%" (
    mkdir "%TEMP_DIR%"
    echo %GREEN%[OK]%RESET% Created: %TEMP_DIR%
)
if not exist "%PYTHON_DIR%" (
    mkdir "%PYTHON_DIR%"
    echo %GREEN%[OK]%RESET% Created: %PYTHON_DIR%
)

:get_model_description
echo.
set /p MODEL_PURPOSE="Enter model purpose/description: "
if "%MODEL_PURPOSE%"=="" (
    echo %RED%[ERROR]%RESET% Model description cannot be empty!
    goto get_model_description
)

:get_agent_instructions
echo.
echo Agent behavior instructions (describe how your AI should behave):
echo Examples: "Be professional and formal" or "Be creative and casual" or "Focus on technical accuracy"
set /p AGENT_INSTRUCTIONS="Enter instructions: "
if "%AGENT_INSTRUCTIONS%"=="" set "AGENT_INSTRUCTIONS=Be helpful, accurate, and professional in all responses."

:: ============================================================================
:: PARAMETER CONFIGURATION
:: ============================================================================

echo.
echo %CYAN%================================================================================
echo                            MODEL PARAMETERS
echo ================================================================================%RESET%

:get_temperature
echo.
echo Temperature controls randomness (0.0 = deterministic, 1.0 = very creative)
set /p TEMPERATURE="Enter temperature (0.0-1.0, default 0.7): "
if "%TEMPERATURE%"=="" set "TEMPERATURE=0.7"

:get_top_p
echo.
echo Top-p controls diversity (0.1-1.0, default 0.9)
set /p TOP_P="Enter top-p value (0.1-1.0, default 0.9): "
if "%TOP_P%"=="" set "TOP_P=0.9"

:get_context_length
echo.
echo Context length (1024-4096, default 2048)
set /p CONTEXT_LENGTH="Enter context length (1024-4096, default 2048): "
if "%CONTEXT_LENGTH%"=="" set "CONTEXT_LENGTH=2048"

:: ============================================================================
:: SYSTEM INSTALLATION
:: ============================================================================

echo.
echo %CYAN%================================================================================
echo                           SYSTEM PREPARATION
echo ================================================================================%RESET%

:: Check if portable Python is installed
echo %YELLOW%[1/10]%RESET% Checking portable Python installation...
if not exist "%PYTHON_EXE%" (
    echo %YELLOW%[INFO]%RESET% Portable Python not found. Installing Python locally...
    call :install_portable_python
) else (
    echo %GREEN%[OK]%RESET% Portable Python is already installed
)

:: Install Python dependencies
echo %YELLOW%[2/10]%RESET% Installing Python dependencies...
call :install_python_deps

:: Create Python processing script
echo %YELLOW%[3/10]%RESET% Creating document processing script...
call :create_processing_script

:: ============================================================================
:: DOCUMENT PROCESSING (MOVED BEFORE MODEL CREATION)
:: ============================================================================

echo %YELLOW%[4/10]%RESET% Checking for documents...
set "doc_count=0"
for %%f in ("%DOCS_DIR%\*.*") do (
    set /a doc_count+=1
)

if %doc_count% equ 0 (
    echo %YELLOW%[INFO]%RESET% No documents found in %DOCS_DIR%
    echo Please place your documents in: %DOCS_DIR%
    echo Supported formats: PDF, DOC/DOCX, XLS/XLSX, PPT/PPTX, TXT, SQL, CSV
    echo.
    pause
    explorer "%DOCS_DIR%"
    echo Press any key after placing your documents...
    pause >nul
)

echo %YELLOW%[5/10]%RESET% Processing documents...
call :process_documents

:: Create Modelfile with embedded training data
echo %YELLOW%[6/10]%RESET% Creating Modelfile with embedded knowledge...
call :create_modelfile_with_knowledge

:: ============================================================================
:: MODEL CREATION
:: ============================================================================

echo %YELLOW%[7/10]%RESET% Checking if base model is available...
echo %YELLOW%[DEBUG]%RESET% Base model variable: [!BASE_MODEL!]

if not defined BASE_MODEL (
    echo %RED%[ERROR]%RESET% BASE_MODEL variable is not set!
    pause
    exit /b 1
)

:: Clean the BASE_MODEL variable of any problematic characters for file operations
set "CLEAN_MODEL=!BASE_MODEL!"
set "CLEAN_MODEL=!CLEAN_MODEL::=_!"

echo %YELLOW%[INFO]%RESET% Checking for model: !BASE_MODEL!
ollama list > "%TEMP_DIR%\current_models_!CLEAN_MODEL!.txt" 2>nul

:: Use a more reliable method to check if model exists
set "MODEL_FOUND=0"
for /f "tokens=1" %%a in ('ollama list 2^>nul ^| findstr /v "NAME"') do (
    if /i "%%a"=="!BASE_MODEL!" set "MODEL_FOUND=1"
)

if !MODEL_FOUND! equ 0 (
    echo %YELLOW%[8/10]%RESET% Model !BASE_MODEL! not found locally. Pulling...
    echo %YELLOW%[INFO]%RESET% This may take several minutes depending on model size...
    ollama pull "!BASE_MODEL!"
    if errorlevel 1 (
        echo %RED%[ERROR]%RESET% Failed to pull base model: !BASE_MODEL!
        echo Please check if the model name is correct and you have internet access.
        echo You can verify available models at: https://ollama.com/library
        pause
        exit /b 1
    ) else (
        echo %GREEN%[OK]%RESET% Successfully pulled !BASE_MODEL!
    )
) else (
    echo %GREEN%[OK]%RESET% Base model !BASE_MODEL! is already available
)

echo %YELLOW%[9/10]%RESET% Creating custom model...
cd /d "%MODELS_DIR%"
if exist "Modelfile" (
    ollama create %MODEL_NAME% -f Modelfile
    if errorlevel 1 (
        echo %RED%[ERROR]%RESET% Failed to create model. Check Modelfile.
        echo %YELLOW%[DEBUG]%RESET% Current directory: %CD%
        echo %YELLOW%[DEBUG]%RESET% Modelfile contents:
        type Modelfile
        pause
    ) else (
        echo %GREEN%[OK]%RESET% Model created successfully!
    )
) else (
    echo %RED%[ERROR]%RESET% Modelfile not found in %MODELS_DIR%
    pause
)

echo %YELLOW%[10/10]%RESET% Testing model...
echo Testing your new model: %MODEL_NAME%
ollama run %MODEL_NAME% "Hello, please introduce yourself and describe your purpose."

echo.
echo %GREEN%================================================================================
echo                              SUCCESS!
echo ================================================================================%RESET%
echo %GREEN%Your custom model '%MODEL_NAME%' has been created successfully!%RESET%
echo %CYAN%Base Model:%RESET% %BASE_MODEL%
echo.
echo %CYAN%Usage:%RESET%
echo   ollama run %MODEL_NAME%
echo.
echo %CYAN%Model Location:%RESET%
echo   %WORK_DIR%
echo.
echo %CYAN%Documents Folder:%RESET%
echo   %DOCS_DIR%
echo.
echo %CYAN%Processed Documents:%RESET%
echo   %OUTPUT_DIR%
echo.
pause
exit /b 0

:: ============================================================================
:: MODEL SELECTION FUNCTIONS
:: ============================================================================

:select_popular_model
echo.
echo %CYAN%Popular Models:%RESET%
echo %WHITE%1) llama3.2:latest        - Meta's Llama 3.2 (Latest)%RESET%
echo %WHITE%2) llama3.2:3b            - Meta's Llama 3.2 3B (Smaller, faster)%RESET%
echo %WHITE%3) llama3.1:latest        - Meta's Llama 3.1 (Previous version)%RESET%
echo %WHITE%4) gemma2:latest          - Google's Gemma 2%RESET%
echo %WHITE%5) phi3:latest            - Microsoft's Phi-3%RESET%
echo %WHITE%6) mistral:latest         - Mistral AI%RESET%
echo %WHITE%7) codellama:latest       - Meta's Code Llama (Good for code)%RESET%
echo %WHITE%8) neural-chat:latest     - Intel's Neural Chat%RESET%
echo %WHITE%9) openchat:latest        - OpenChat%RESET%
echo %WHITE%10) qwen2:latest          - Alibaba's Qwen2%RESET%
echo.

:get_popular_selection
set /p POPULAR_CHOICE="Select model number (1-10): "
if "%POPULAR_CHOICE%"=="1" set "BASE_MODEL=llama3.2:latest"
if "%POPULAR_CHOICE%"=="2" set "BASE_MODEL=llama3.2:3b"
if "%POPULAR_CHOICE%"=="3" set "BASE_MODEL=llama3.1:latest"
if "%POPULAR_CHOICE%"=="4" set "BASE_MODEL=gemma2:latest"
if "%POPULAR_CHOICE%"=="5" set "BASE_MODEL=phi3:latest"
if "%POPULAR_CHOICE%"=="6" set "BASE_MODEL=mistral:latest"
if "%POPULAR_CHOICE%"=="7" set "BASE_MODEL=codellama:latest"
if "%POPULAR_CHOICE%"=="8" set "BASE_MODEL=neural-chat:latest"
if "%POPULAR_CHOICE%"=="9" set "BASE_MODEL=openchat:latest"
if "%POPULAR_CHOICE%"=="10" set "BASE_MODEL=qwen2:latest"

if not defined BASE_MODEL (
    echo %RED%[ERROR]%RESET% Invalid selection. Please choose between 1 and 10.
    goto get_popular_selection
)
goto :eof

:enter_custom_model
echo.
echo %YELLOW%Examples of custom models:%RESET%
echo - mistral:7b-instruct
echo - llama3.2:1b
echo - gemma2:9b
echo - any model from https://ollama.com/library
echo.

:get_custom_model
set /p BASE_MODEL="Enter model name (with tag, e.g., 'llama3.2:3b'): "
if "%BASE_MODEL%"=="" (
    echo %RED%[ERROR]%RESET% Model name cannot be empty!
    goto get_custom_model
)

echo %YELLOW%[INFO]%RESET% You entered: %BASE_MODEL%
set /p CONFIRM="Is this correct? (y/n): "
if /i not "%CONFIRM%"=="y" goto get_custom_model
goto :eof

:: ============================================================================
:: ORIGINAL FUNCTIONS (unchanged)
:: ============================================================================

:install_ollama
echo %YELLOW%[INFO]%RESET% Downloading Ollama installer...
powershell -Command "try { Invoke-WebRequest -Uri 'https://ollama.com/download/OllamaSetup.exe' -OutFile 'OllamaSetup.exe' -ErrorAction Stop } catch { exit 1 }"
if %ERRORLEVEL% neq 0 (
    echo %RED%[ERROR]%RESET% Download failed! Please check your internet connection.
    pause
    goto :eof
)
echo %YELLOW%[INFO]%RESET% Installing Ollama...
start /wait "OllamaSetup.exe"
if %ERRORLEVEL% equ 0 (
    echo %GREEN%[SUCCESS]%RESET% Ollama installed successfully!
) else (
    echo %RED%[ERROR]%RESET% Installation failed!
)
goto :eof

:install_portable_python
echo %YELLOW%[INFO]%RESET% Downloading portable Python...
powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.11.7/python-3.11.7-embed-amd64.zip' -OutFile '%TEMP_DIR%\python-portable.zip'"
if errorlevel 1 (
    echo %RED%[ERROR]%RESET% Failed to download Python. Check internet connection.
    pause
    exit /b 1
)

echo %YELLOW%[INFO]%RESET% Extracting portable Python...
powershell -Command "Expand-Archive -Path '%TEMP_DIR%\python-portable.zip' -DestinationPath '%PYTHON_DIR%' -Force"

:: Download and install pip for portable Python
echo %YELLOW%[INFO]%RESET% Setting up pip for portable Python...
powershell -Command "Invoke-WebRequest -Uri 'https://bootstrap.pypa.io/get-pip.py' -OutFile '%TEMP_DIR%\get-pip.py'"

:: Create pth file to enable pip
echo import site >> "%PYTHON_DIR%\python311._pth"

:: Install pip
"%PYTHON_EXE%" "%TEMP_DIR%\get-pip.py" --no-warn-script-location

:: Verify installation
"%PYTHON_EXE%" --version
if errorlevel 1 (
    echo %RED%[ERROR]%RESET% Portable Python installation failed!
    pause
    exit /b 1
)
echo %GREEN%[OK]%RESET% Portable Python installed successfully
goto :eof

:install_python_deps
if not exist "%PYTHON_EXE%" (
    echo %RED%[ERROR]%RESET% Python executable not found: %PYTHON_EXE%
    goto :eof
)

echo %YELLOW%[INFO]%RESET% Installing required Python packages (portable)...
"%PIP_EXE%" install --upgrade pip --no-warn-script-location
"%PIP_EXE%" install PyPDF2 pdfplumber python-docx openpyxl python-pptx pandas sqlparse chardet pillow --no-warn-script-location
"%PIP_EXE%" install PyMuPDF pytesseract beautifulsoup4 --no-warn-script-location
echo %GREEN%[OK]%RESET% Python dependencies installed
goto :eof

:process_documents
echo %YELLOW%[INFO]%RESET% Processing documents with portable Python...
echo %YELLOW%[DEBUG]%RESET% Python path: %PYTHON_EXE%
echo %YELLOW%[DEBUG]%RESET% Script path: %WORK_DIR%\document_processor.py
echo %YELLOW%[DEBUG]%RESET% Docs dir: %DOCS_DIR%
echo %YELLOW%[DEBUG]%RESET% Output dir: %OUTPUT_DIR%

cd /d "%WORK_DIR%"
if exist "document_processor.py" (
    if exist "%PYTHON_EXE%" (
        "%PYTHON_EXE%" document_processor.py "%DOCS_DIR%" "%OUTPUT_DIR%"
        if errorlevel 1 (
            echo %RED%[ERROR]%RESET% Document processing failed
            pause
        ) else (
            echo %GREEN%[OK]%RESET% Documents processed successfully
        )
    ) else (
        echo %RED%[ERROR]%RESET% Python executable not found: %PYTHON_EXE%
        pause
    )
) else (
    echo %RED%[ERROR]%RESET% Document processor script not found
    pause
)
goto :eof

:create_processing_script
echo %YELLOW%[INFO]%RESET% Creating document processor at: %WORK_DIR%\document_processor.py

(
echo import os
echo import sys
echo import json
echo from pathlib import Path
echo import chardet
echo import re
echo.
echo try:
echo     import pdfplumber
echo     from docx import Document
echo     import openpyxl
echo     import pandas as pd
echo     from bs4 import BeautifulSoup
echo except ImportError as e:
echo     print("Missing dependency:", e^)
echo     sys.exit(1^)
echo.
echo class DocumentProcessor:
echo     def __init__(self, docs_dir, output_dir^):
echo         self.docs_dir = Path(docs_dir^)
echo         self.output_dir = Path(output_dir^)
echo         self.output_dir.mkdir(exist_ok=True^)
echo         self.processed_content = []
echo.
echo     def detect_encoding(self, file_path^):
echo         with open(file_path, "rb"^) as f:
echo             raw_data = f.read(^)
echo             result = chardet.detect(raw_data^)
echo             return result.get("encoding", "utf-8"^)
echo.
echo     def process_pdf(self, file_path^):
echo         content = ""
echo         print("    Attempting PDF extraction with multiple methods..."^)
echo         try:
echo             with pdfplumber.open(file_path^) as pdf:
echo                 for page_num, page in enumerate(pdf.pages^):
echo                     try:
echo                         text = page.extract_text(^)
echo                         if text and text.strip(^):
echo                             content += f"[Page {page_num + 1}]\n" + text + "\n\n"
echo                         tables = page.extract_tables(^)
echo                         for table in tables:
echo                             if table:
echo                                 content += "[Table found]\n"
echo                                 for row in table:
echo                                     if row:
echo                                         clean_row = [str(cell^) if cell else "" for cell in row]
echo                                         content += " | ".join(clean_row^) + "\n"
echo                                 content += "\n"
echo                     except Exception as e:
echo                         print(f"    Error on page {page_num + 1}: {e}"^)
echo                         continue
echo             if content.strip(^):
echo                 print("    pdfplumber extraction successful"^)
echo                 return content
echo         except Exception as e:
echo             print("    pdfplumber failed:", e^)
echo         return content
echo.
echo     def process_docx(self, file_path^):
echo         try:
echo             doc = Document(file_path^)
echo             content = ""
echo             for paragraph in doc.paragraphs:
echo                 content += paragraph.text + "\n"
echo             return content
echo         except Exception as e:
echo             print("Error processing DOCX:", file_path, ":", e^)
echo             return ""
echo.
echo     def process_html(self, file_path^):
echo         try:
echo             encoding = self.detect_encoding(file_path^)
echo             with open(file_path, "r", encoding=encoding^) as f:
echo                 html_content = f.read(^)
echo             # Parse HTML and extract text content
echo             soup = BeautifulSoup(html_content, 'html.parser'^)
echo             # Remove script and style elements
echo             for script in soup(["script", "style"]^):
echo                 script.extract(^)
echo             # Get text content
echo             text = soup.get_text(^)
echo             # Clean up whitespace
echo             lines = (line.strip(^) for line in text.splitlines(^)^)
echo             chunks = (phrase.strip(^) for line in lines for phrase in line.split("  "^)^)
echo             text = '\n'.join(chunk for chunk in chunks if chunk^)
echo             return text
echo         except Exception as e:
echo             print("Error processing HTML file:", file_path, ":", e^)
echo             return ""
echo.
echo     def process_text_file(self, file_path^):
echo         try:
echo             encoding = self.detect_encoding(file_path^)
echo             with open(file_path, "r", encoding=encoding^) as f:
echo                 return f.read(^)
echo         except Exception as e:
echo             print("Error processing text file:", file_path, ":", e^)
echo             return ""
echo.
echo     def process_all_documents(self^):
echo         total_files = list(self.docs_dir.rglob("*"^)^)
echo         total_files = [f for f in total_files if f.is_file(^)]
echo         print("Found", len(total_files^), "files to process"^)
echo         for i, file_path in enumerate(total_files^):
echo             print("Processing", i+1, "of", len(total_files^), ":", file_path.name^)
echo             content = ""
echo             suffix = file_path.suffix.lower(^)
echo             if suffix == ".pdf":
echo                 content = self.process_pdf(file_path^)
echo             elif suffix in [".docx", ".doc"]:
echo                 content = self.process_docx(file_path^)
echo             elif suffix in [".html", ".htm"]:
echo                 content = self.process_html(file_path^)
echo             elif suffix in [".txt", ".md", ".py", ".js", ".css", ".json", ".xml", ".sql", ".csv"]:
echo                 content = self.process_text_file(file_path^)
echo             else:
echo                 print("Unsupported file type:", suffix^)
echo                 continue
echo             if content:
echo                 self.processed_content.append({"filename": file_path.name, "content": content, "file_type": suffix}^)
echo         output_file = self.output_dir / "processed_documents.json"
echo         with open(output_file, "w", encoding="utf-8"^) as f:
echo             json.dump(self.processed_content, f, ensure_ascii=False, indent=2^)
echo         training_file = self.output_dir / "training_data.txt"
echo         with open(training_file, "w", encoding="utf-8"^) as f:
echo             for doc in self.processed_content:
echo                 f.write("\n=== " + doc["filename"] + " ===\n"^)
echo                 f.write(doc["content"]^)
echo                 f.write("\n\n"^)
echo         print("Processed", len(self.processed_content^), "documents"^)
echo         print("Output saved to:", output_file^)
echo         print("Training data saved to:", training_file^)
echo.
echo if __name__ == "__main__":
echo     docs_dir = sys.argv[1]
echo     output_dir = sys.argv[2]
echo     processor = DocumentProcessor(docs_dir, output_dir^)
echo     processor.process_all_documents(^)
) > "%WORK_DIR%\document_processor.py"

echo %GREEN%[OK]%RESET% Document processor created
goto :eof

:process_documents
echo %YELLOW%[INFO]%RESET% Processing documents with portable Python...
echo %YELLOW%[DEBUG]%RESET% Python path: %PYTHON_EXE%
echo %YELLOW%[DEBUG]%RESET% Script path: %WORK_DIR%\document_processor.py
echo %YELLOW%[DEBUG]%RESET% Docs dir: %DOCS_DIR%
echo %YELLOW%[DEBUG]%RESET% Output dir: %OUTPUT_DIR%

cd /d "%WORK_DIR%"
if exist "document_processor.py" (
    if exist "%PYTHON_EXE%" (
        "%PYTHON_EXE%" document_processor.py "%DOCS_DIR%" "%OUTPUT_DIR%"
        if errorlevel 1 (
            echo %RED%[ERROR]%RESET% Document processing failed
            pause
        ) else (
            echo %GREEN%[OK]%RESET% Documents processed successfully
        )
    ) else (
        echo %RED%[ERROR]%RESET% Python executable not found: %PYTHON_EXE%
        pause
    )
) else (
    echo %RED%[ERROR]%RESET% Document processor script not found
    pause
)
goto :eof

:create_modelfile_with_knowledge
echo %YELLOW%[INFO]%RESET% Creating Modelfile with embedded knowledge base...
echo %YELLOW%[DEBUG]%RESET% Using base model: !BASE_MODEL!

:: Start creating the Modelfile
(
echo FROM !BASE_MODEL!
echo.
echo PARAMETER temperature !TEMPERATURE!
echo PARAMETER top_p !TOP_P!
echo PARAMETER num_ctx !CONTEXT_LENGTH!
echo.
echo SYSTEM """You are !MODEL_NAME!, a specialized AI assistant created for: !MODEL_PURPOSE!
echo.
echo !AGENT_INSTRUCTIONS!
echo.
echo You have been trained on a collection of documents and have deep knowledge about their contents. 
echo Always provide accurate, helpful, and contextual responses based on the information you have learned.
echo When referencing information from documents, be specific about the source when possible.
echo If you are unsure about something, acknowledge the uncertainty rather than guessing.
echo.
echo Your responses should be:
echo - Accurate and factual
echo - Clear and well-structured  
echo - Relevant to the user's query
echo - You are helpful and kind
echo.
echo ------- Knowledge Base Begin -------
) > "%MODELS_DIR%\Modelfile"

:: Check if training data exists and append it
if exist "%OUTPUT_DIR%\training_data.txt" (
    echo %YELLOW%[INFO]%RESET% Embedding training data into Modelfile...
    type "%OUTPUT_DIR%\training_data.txt" >> "%MODELS_DIR%\Modelfile"
    echo %GREEN%[OK]%RESET% Training data embedded successfully
) else (
    echo %YELLOW%[WARNING]%RESET% No training data found. Creating Modelfile without embedded knowledge.
    echo No training data available at this time. >> "%MODELS_DIR%\Modelfile"
)

:: Finish the Modelfile
(
echo.
echo ------- Knowledge Base End -------
echo.
echo Use the knowledge from the Knowledge Base section above to answer questions accurately. 
echo Always reference the specific document when providing information from the knowledge base.
echo """
) >> "%MODELS_DIR%\Modelfile"

if exist "%MODELS_DIR%\Modelfile" (
    echo %GREEN%[OK]%RESET% Modelfile with embedded knowledge created successfully
    echo %YELLOW%[DEBUG]%RESET% Modelfile size:
    for %%A in ("%MODELS_DIR%\Modelfile") do echo File size: %%~zA bytes
) else (
    echo %RED%[ERROR]%RESET% Failed to create Modelfile
    pause
)
goto :eof