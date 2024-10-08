:: Installation script :::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
::                           .NET YOLO Object Detection
::
:: This script is only called from ..\..\..\setup.bat 
::
:: For help with install scripts, notes on variables and methods available, tips,
:: and explanations, see /src/modules/install_script_help.md

@if "%1" NEQ "install" (
    echo This script is only called from ..\..\..\setup.bat
    @pause
    @goto:eof
) 

set installBinaries=false
if /i "!executionEnvironment!" == "Production" set installBinaries=true
if /i "!launchedBy!" == "server" set installBinaries=true

:: Pull down the .NET executable of this module 
if /i "!installBinaries!" == "true" (
    set imageName=!moduleId!-!moduleVersion!.zip
    call "%utilsScript%" GetFromServer "binaries/" "!imageName!" "bin" "Downloading !imageName!..."
) else (
    :: If we're in dev-setup mode we'll build the module now so the self-test will work
    pushd "!moduleDirPath!"
    call "!utilsScript!" WriteLine "Building project..." "!color_info!"
    dotnet build -c Debug -o "!moduleDirPath!/bin/Debug/!dotNetTarget!" >NUL
    popd
)

:: Download the YOLO models and store in /assets
call "%utilsScript%" GetFromServer "models/" "objectdetection-coco-yolov8-onnx-m.zip" "assets" "Downloading YOLO ONNX models..."

REM TODO: Check assets created and has files
REM set moduleInstallErrors=...
