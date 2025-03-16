@echo off
echo Initializing EbaAaZ module...

:: Set paths
set "MODULE_DIR=%~dp0"
set "MODELS_DIR=%MODULE_DIR%models"
set "DATA_DIR=%MODULE_DIR%data"
set "CACHE_DIR=%MODULE_DIR%cache"

:: Create required directories
if not exist "%MODELS_DIR%" mkdir "%MODELS_DIR%"
if not exist "%DATA_DIR%" mkdir "%DATA_DIR%"
if not exist "%CACHE_DIR%" mkdir "%CACHE_DIR%"

:: Install specific requirements
pip install -r "%MODULE_DIR%requirements.txt"

:: Initialize module configuration
if not exist "%MODULE_DIR%config.json" (
    echo Creating default configuration...
    echo {> "%MODULE_DIR%config.json"
    echo     "model_path": "models/",>> "%MODULE_DIR%config.json"
    echo     "data_path": "data/",>> "%MODULE_DIR%config.json"
    echo     "cache_path": "cache/",>> "%MODULE_DIR%config.json"
    echo     "use_gpu": true,>> "%MODULE_DIR%config.json"
    echo     "batch_size": 32,>> "%MODULE_DIR%config.json"
    echo     "num_workers": 4>> "%MODULE_DIR%config.json"
    echo }>> "%MODULE_DIR%config.json"
)

:: Download required models
python "%MODULE_DIR%setup_models.py"

echo EbaAaZ module initialized successfully.
exit /b 0