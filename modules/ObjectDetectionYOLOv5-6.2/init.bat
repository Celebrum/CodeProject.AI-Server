@echo off
echo Initializing YOLOv5 module...

:: Set paths
set "MODULE_DIR=%~dp0"
set "WEIGHTS_DIR=%MODULE_DIR%weights"
set "TEMP_DIR=%MODULE_DIR%temp"

:: Create required directories
if not exist "%WEIGHTS_DIR%" mkdir "%WEIGHTS_DIR%"
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

:: Install pytorch and other dependencies
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
pip install -r "%MODULE_DIR%requirements.txt"

:: Download YOLOv5 weights
if not exist "%WEIGHTS_DIR%\yolov5s.pt" (
    echo Downloading YOLOv5 weights...
    python -c "from utils.downloads import attempt_download; attempt_download('yolov5s.pt', '%WEIGHTS_DIR%')"
)

:: Configure CUDA settings if available
nvidia-smi >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo CUDA GPU detected, configuring for GPU acceleration...
    echo {> "%MODULE_DIR%config.json"
    echo     "device": "cuda:0",>> "%MODULE_DIR%config.json"
    echo     "batch_size": 32,>> "%MODULE_DIR%config.json"
    echo     "img_size": 640>> "%MODULE_DIR%config.json"
    echo }>> "%MODULE_DIR%config.json"
) else (
    echo No CUDA GPU detected, using CPU...
    echo {> "%MODULE_DIR%config.json"
    echo     "device": "cpu",>> "%MODULE_DIR%config.json"
    echo     "batch_size": 8,>> "%MODULE_DIR%config.json"
    echo     "img_size": 640>> "%MODULE_DIR%config.json"
    echo }>> "%MODULE_DIR%config.json"
)

echo YOLOv5 module initialized successfully.
exit /b 0