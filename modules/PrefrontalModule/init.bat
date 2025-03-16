@echo off
echo Initializing Prefrontal module...

:: Set paths
set "MODULE_DIR=%~dp0"
set "CONFIG_DIR=%MODULE_DIR%config"
set "MODELS_DIR=%MODULE_DIR%models"

:: Create required directories
if not exist "%CONFIG_DIR%" mkdir "%CONFIG_DIR%"
if not exist "%MODELS_DIR%" mkdir "%MODELS_DIR%"

:: Install requirements
pip install -r "%MODULE_DIR%requirements.txt"

:: Initialize configuration
if not exist "%CONFIG_DIR%\config.json" (
    echo Creating default configuration...
    echo {> "%CONFIG_DIR%\config.json"
    echo   "model_path": "models/",>> "%CONFIG_DIR%\config.json"
    echo   "batch_size": 32,>> "%CONFIG_DIR%\config.json"
    echo   "learning_rate": 0.001,>> "%CONFIG_DIR%\config.json"
    echo   "epochs": 100>> "%CONFIG_DIR%\config.json"
    echo }>> "%CONFIG_DIR%\config.json"
)

echo Prefrontal module initialized successfully
exit /b 0