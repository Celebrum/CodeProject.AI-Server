@echo off
echo Initializing YOLOv5Net module...

:: Set paths
set "MODULE_DIR=%~dp0"
set "MODELS_DIR=%MODULE_DIR%models"
set "WEIGHTS_DIR=%MODULE_DIR%weights"

:: Create required directories
if not exist "%MODELS_DIR%" mkdir "%MODELS_DIR%"
if not exist "%WEIGHTS_DIR%" mkdir "%WEIGHTS_DIR%"

:: Check for .NET SDK
dotnet --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: .NET SDK not found. Please install .NET SDK 6.0 or later.
    exit /b 1
)

:: Build the project with IncrediBuild if available
where BuildConsole >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo Building with IncrediBuild...
    BuildConsole "%MODULE_DIR%YOLOv5Net.csproj" /build /cfg="Release|Any CPU"
) else (
    echo Building with standard .NET...
    dotnet build "%MODULE_DIR%YOLOv5Net.csproj" -c Release
)

:: Download pre-trained weights if needed
if not exist "%WEIGHTS_DIR%\yolov5n.onnx" (
    echo Downloading YOLOv5 ONNX weights...
    powershell -Command "& {Invoke-WebRequest -Uri 'https://github.com/ultralytics/yolov5/releases/download/v6.2/yolov5n.onnx' -OutFile '%WEIGHTS_DIR%\yolov5n.onnx'}"
)

echo YOLOv5Net module initialized successfully.
exit /b 0