@echo off
echo Initializing YOLOv5 6.2 module...

:: Set paths
set "MODULE_DIR=%~dp0"
set "MODELS_DIR=%MODULE_DIR%models"
set "CACHE_DIR=%MODULE_DIR%cache"

:: Create required directories
if not exist "%MODELS_DIR%" mkdir "%MODELS_DIR%"
if not exist "%CACHE_DIR%" mkdir "%CACHE_DIR%"

:: Install requirements
pip install -r "%MODULE_DIR%requirements.txt"

:: Download YOLOv5 model weights
python "%MODULE_DIR%download_weights.py"

echo YOLOv5 module initialized successfully
exit /b 0