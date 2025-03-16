# LLM Chat Module for CodeProject.AI Server with MindsDB Integration

This is an LLM Chat module for [CodeProject.AI Server](https://www.codeproject.com/Articles/5322557/CodeProject-AI-Server-AI-the-easy-way) that leverages MindsDB's Bring Your Own Model (BYOM) capabilities for simplified LLM integration.

## Quick Start

1. Clone the main [server repo](https://github.com/codeproject/CodeProject.AI-Server)
2. Ensure MindsDB is installed and running
3. Set up your MindsDB model handler
4. Configure the module settings to point to your MindsDB instance

## MindsDB BYOM Integration

This module uses MindsDB's BYOM feature to:
- Simplify LLM deployment and management
- Reduce setup complexity
- Enable easy model switching and updates
- Provide built-in monitoring and optimization

## Configuration

1. In your MindsDB instance, create a model handler:
```sql
CREATE MODEL llm_handler
PREDICT response
USING
    engine = 'byom',
    handler = 'llm'
```

2. Update the module settings in `modulesettings.json`:
```json
{
    "mindsdb": {
        "host": "127.0.0.1",
        "port": 47334,
        "model_name": "llm_handler"
    }
}
```

## Development Setup

1. Clone the server repo into `CodeProject/CodeProject.AI-Server`
2. Clone this module repo into `CodeProject/CodeProject.AI-Modules`
3. Run the setup scripts:

For Windows:
```bat
..\..\CodeProject.AI-Server\src\setup.bat
```

For Linux/macOS:
```bash
bash ../../CodeProject.AI-Server/src/setup.sh
```

4. Launch the server through Visual Studio Code or the dashboard

## Creating Module Package

From the module directory, run:

Windows:
```bat
..\..\CodeProject.AI-Server\devops\build\create_packages.bat
```

Linux/macOS:
```bash
bash ../../CodeProject.AI-Server/devops/build/create_packages.sh
```

## Benefits of MindsDB Integration

- Reduced setup time (from ~10 days to ~1 day)
- Simplified model management
- Built-in monitoring and optimization
- Easy model switching and A/B testing
- Scalable deployment options

## Requirements

- CodeProject.AI Server
- MindsDB instance (local or cloud)
- Python 3.8+
