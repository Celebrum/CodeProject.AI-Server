@echo off
echo Initializing CeLeBrUm module...

:: Set paths
set "MODULE_DIR=%~dp0"
set "MODELS_DIR=%MODULE_DIR%models"
set "TEMP_DIR=%MODULE_DIR%temp"

:: Create required directories
if not exist "%MODELS_DIR%" mkdir "%MODELS_DIR%"
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

:: Install specific requirements if needed
pip install -r "%MODULE_DIR%requirements.txt"

:: Download required models
python "%MODULE_DIR%download_models.py"

echo CeLeBrUm module initialized successfully.
exit /b 0