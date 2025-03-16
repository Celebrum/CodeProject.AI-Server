@echo off
echo Initializing Prefrontal module...

:: Set paths
set "MODULE_DIR=%~dp0"
set "MODELS_DIR=%MODULE_DIR%models"
set "CACHE_DIR=%MODULE_DIR%cache"
set "DATA_DIR=%MODULE_DIR%data"

:: Create required directories
if not exist "%MODELS_DIR%" mkdir "%MODELS_DIR%"
if not exist "%CACHE_DIR%" mkdir "%CACHE_DIR%"
if not exist "%DATA_DIR%" mkdir "%DATA_DIR%"

:: Install specific requirements
pip install -r "%MODULE_DIR%requirements.txt"

:: Initialize module configuration
if not exist "%MODULE_DIR%config.json" (
    echo Creating default configuration...
    echo {> "%MODULE_DIR%config.json"
    echo     "model_settings": {>> "%MODULE_DIR%config.json"
    echo         "use_gpu": true,>> "%MODULE_DIR%config.json"
    echo         "batch_size": 32,>> "%MODULE_DIR%config.json"
    echo         "learning_rate": 0.001,>> "%MODULE_DIR%config.json"
    echo         "max_tokens": 512>> "%MODULE_DIR%config.json"
    echo     },>> "%MODULE_DIR%config.json"
    echo     "paths": {>> "%MODULE_DIR%config.json"
    echo         "models": "models/",>> "%MODULE_DIR%config.json"
    echo         "cache": "cache/",>> "%MODULE_DIR%config.json"
    echo         "data": "data/">> "%MODULE_DIR%config.json"
    echo     },>> "%MODULE_DIR%config.json"
    echo     "inference": {>> "%MODULE_DIR%config.json"
    echo         "temperature": 0.7,>> "%MODULE_DIR%config.json"
    echo         "top_p": 0.9,>> "%MODULE_DIR%config.json"
    echo         "max_new_tokens": 128>> "%MODULE_DIR%config.json"
    echo     }>> "%MODULE_DIR%config.json"
    echo }>> "%MODULE_DIR%config.json"
)

:: Download and set up neural models
python "%MODULE_DIR%setup_models.py"

echo Prefrontal module initialized successfully.
exit /b 0