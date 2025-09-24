# OneClickOllama - Custom Ollama Model Creator

A complete one-click solution for creating custom Ollama models from your documents on Windows. Transform your PDFs, Word documents, Excel files, and other documents into specialized AI models with embedded knowledge.

## 🚀 Features

- **One-Click Setup**: Automatically installs all dependencies including Ollama and Python
- **Multi-Format Support**: Process PDF (with images), Word, Excel, PowerPoint, text files, SQL, CSV, and more
- **Intelligent Document Processing**: Advanced text extraction from complex documents including tables
- **Model Customization**: Configure temperature, top-p, context length, and behavior instructions
- **Popular Model Support**: Choose from 10+ pre-configured popular models or use custom models
- **Embedded Knowledge**: Training data is directly embedded into the Modelfile for persistent knowledge
- **Portable Installation**: Self-contained portable Python environment

## 📋 Requirements

- Windows 10/11
- Internet connection (for initial setup and model downloads)
- Sufficient disk space for models and documents

## 🛠️ Supported File Formats

| Format | Extensions | Features |
|--------|------------|----------|
| PDF | `.pdf` | Text extraction, table detection, multi-page support |
| Microsoft Word | `.doc`, `.docx` | Full text extraction |
| Microsoft Excel | `.xls`, `.xlsx` | Spreadsheet data processing |
| Microsoft PowerPoint | `.ppt`, `.pptx` | Presentation content extraction |
| Text Files | `.txt`, `.md` | Direct text processing |
| Code Files | `.py`, `.js`, `.html`, `.css`, `.json`, `.xml` | Source code integration |
| Data Files | `.sql`, `.csv` | Database and data processing |

## 🚀 Quick Start

1. **Download** the `oneclickollama.bat` file
2. **Run** the batch file as Administrator
3. **Follow** the interactive prompts:
   - Choose your base model (or select from popular options)
   - Enter your custom model name
   - Provide model description and behavior instructions
   - Configure model parameters
4. **Add Documents** to the generated documents folder when prompted
5. **Wait** for processing and model creation
6. **Test** your new custom model!

## 📖 Usage Example

```cmd
# After running the script and creating a model named "my-docs"
ollama run my-docs "What information do you have about our quarterly reports?"
```

## 🎯 Popular Base Models

The script offers these popular models out of the box:

| Model | Size | Description |
|-------|------|-------------|
| llama3.2:latest | ~4.7GB | Meta's latest Llama model |
| llama3.2:3b | ~1.9GB | Smaller, faster Llama variant |
| gemma2:latest | ~5.4GB | Google's Gemma 2 |
| phi3:latest | ~2.3GB | Microsoft's Phi-3 |
| mistral:latest | ~4.1GB | Mistral AI model |
| codellama:latest | ~3.8GB | Specialized for code |

## ⚙️ Configuration Options

### Model Parameters

- **Temperature** (0.0-1.0): Controls randomness in responses
- **Top-p** (0.1-1.0): Controls diversity of word selection  
- **Context Length** (1024-4096): Maximum conversation memory
- **Agent Instructions**: Define personality and behavior

### Directory Structure

After running, the script creates:

```
[MODEL_NAME]_workspace/
├── documents/          # Place your source documents here
├── processed/          # Processed document outputs
├── models/            # Generated Modelfile
├── temp/              # Temporary processing files
└── python_portable/   # Portable Python installation
```

## 🔧 Advanced Usage

### Custom Model Names

You can specify any model available from the [Ollama library](https://ollama.com/library):

```
Examples:
- mistral:7b-instruct
- llama3.2:1b  
- gemma2:9b
- codellama:13b
```

### Document Processing

The script intelligently processes different document types:

- **PDFs**: Extracts text and tables using multiple extraction methods
- **Office Documents**: Native format processing for accurate content extraction
- **Text Files**: Smart encoding detection for international character support
- **Code Files**: Preserves formatting and syntax

## 🛠️ Troubleshooting

### Common Issues

**Ollama Installation Failed**
- Run the script as Administrator
- Check internet connection
- Manually download Ollama from https://ollama.com/download

**Python Dependencies Error**
- The script uses portable Python - no system Python required
- If issues persist, delete the `python_portable` folder and re-run

**Model Creation Failed**
- Verify the base model name is correct
- Check available space (models can be several GB)
- Ensure documents are in the correct folder

**Document Processing Issues**
- Check file permissions
- Ensure documents aren't password-protected
- Try with simpler file formats first (TXT, PDF)

## 📁 Project Structure

```
oneclickollama.bat          # Main script
├── Auto-installs Ollama
├── Sets up portable Python
├── Creates document processor
├── Processes your documents  
├── Generates custom Modelfile
└── Creates and tests model
```

## 🤝 Contributing

Contributions are welcome! Please feel free to:

- Report bugs
- Suggest new features
- Submit pull requests
- Improve documentation

## 📝 License

This project is open source. Please check the repository for license details.

## 🙏 Acknowledgments

- **Ollama Team** - For the excellent local LLM platform
- **Python Community** - For the powerful document processing libraries
- **Contributors** - Everyone who helps improve this project

## 📞 Support

If you encounter issues:

1. Check the troubleshooting section above
2. Create an issue on GitHub with:
   - Your Windows version
   - Error messages
   - Steps to reproduce

## 🔮 Roadmap

- [ ] Support for additional document formats (RTF, ODT)
- [ ] Batch processing for multiple models
- [ ] Web interface option
- [ ] Docker container support
- [ ] Integration with cloud storage services

---

**Made with ❤️ by Ali Kutlusoy**

*Transform your documents into intelligent AI assistants with just one click!*