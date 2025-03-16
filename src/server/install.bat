@echo off
echo ===============================================
echo CodeProject.AI Server Installation Script
echo ===============================================
echo.

:: Set paths
set "ROOT_DIR=%~dp0"
set "CODEPROJECT_DIR=%ROOT_DIR%\.."
set "MODULES_DIR=%CODEPROJECT_DIR%\modules"
set "CELEBRUM_MODULE=%MODULES_DIR%\CeLeBrUm_module"
set "EBAAZ_MODULE=%MODULES_DIR%\EbaAaZ_module"
set "YOLO_MODULE=%MODULES_DIR%\ObjectDetectionYOLOv5-6.2"
set "YOLONET_MODULE=%MODULES_DIR%\ObjectDetectionYOLOv5Net"
set "PREFRONTAL_MODULE=%MODULES_DIR%\PrefrontalModule"
set "SENNTI_MODULE=%MODULES_DIR%\SenNnT-i_module"

:: Check for required tools
where conda >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: Conda is not installed or not in PATH.
    echo Please install Conda and try again.
    goto error_exit
)

where git >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: Git is not installed or not in PATH.
    echo Please install Git and try again.
    goto error_exit
)

where python >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: Python is not installed or not in PATH.
    echo Please install Python and try again.
    goto error_exit
)

:: Check if IncrediBuild is installed
where BuildConsole >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo WARNING: IncrediBuild not found. Installation will proceed without build acceleration.
    set "USE_INCREDIBUILD=false"
) else (
    echo IncrediBuild found. Build acceleration will be enabled.
    set "USE_INCREDIBUILD=true"
)

:: Create and activate Conda environment
echo.
echo Creating and activating Conda environment...
call conda create -n codeproject_ai python=3.9 -y
call conda activate codeproject_ai

:: Install base requirements
echo.
echo Installing base requirements...
pip install -r "%ROOT_DIR%\requirements.txt"
if %ERRORLEVEL% neq 0 goto error_exit

:: Install module requirements
echo.
echo Installing module requirements...

:: CeLeBrUm module
if exist "%CELEBRUM_MODULE%" (
    echo Installing CeLeBrUm module requirements...
    if exist "%CELEBRUM_MODULE%\requirements.txt" (
        pip install -r "%CELEBRUM_MODULE%\requirements.txt"
    )
)

:: EbaAaZ module
if exist "%EBAAZ_MODULE%" (
    echo Installing EbaAaZ module requirements...
    if exist "%EBAAZ_MODULE%\requirements.txt" (
        pip install -r "%EBAAZ_MODULE%\requirements.txt"
    )
)

:: YOLO module
if exist "%YOLO_MODULE%" (
    echo Installing YOLO module requirements...
    if exist "%YOLO_MODULE%\requirements.txt" (
        pip install -r "%YOLO_MODULE%\requirements.txt"
    )
)

:: YOLONet module
if exist "%YOLONET_MODULE%" (
    echo Installing YOLONet module requirements...
    if exist "%YOLONET_MODULE%\requirements.txt" (
        pip install -r "%YOLONET_MODULE%\requirements.txt"
    )
)

:: Prefrontal module
if exist "%PREFRONTAL_MODULE%" (
    echo Installing Prefrontal module requirements...
    if exist "%PREFRONTAL_MODULE%\requirements.txt" (
        pip install -r "%PREFRONTAL_MODULE%\requirements.txt"
    )
)

:: SenNnT-i module
if exist "%SENNTI_MODULE%" (
    echo Installing SenNnT-i module requirements...
    if exist "%SENNTI_MODULE%\requirements.txt" (
        pip install -r "%SENNTI_MODULE%\requirements.txt"
    )
)

:: Configure module settings
echo.
echo Configuring module settings...

:: Create module settings file
if not exist "%ROOT_DIR%\modulesettings.json" (
    echo Creating modulesettings.json...
    echo {> "%ROOT_DIR%\modulesettings.json"
    echo   "modules": {>> "%ROOT_DIR%\modulesettings.json"
    echo     "CeLeBrUm": {>> "%ROOT_DIR%\modulesettings.json"
    echo       "enabled": true,>> "%ROOT_DIR%\modulesettings.json"
    echo       "path": "%CELEBRUM_MODULE%">> "%ROOT_DIR%\modulesettings.json"
    echo     },>> "%ROOT_DIR%\modulesettings.json"
    echo     "EbaAaZ": {>> "%ROOT_DIR%\modulesettings.json"
    echo       "enabled": true,>> "%ROOT_DIR%\modulesettings.json"
    echo       "path": "%EBAAZ_MODULE%">> "%ROOT_DIR%\modulesettings.json"
    echo     },>> "%ROOT_DIR%\modulesettings.json"
    echo     "YOLOv5": {>> "%ROOT_DIR%\modulesettings.json"
    echo       "enabled": true,>> "%ROOT_DIR%\modulesettings.json"
    echo       "path": "%YOLO_MODULE%">> "%ROOT_DIR%\modulesettings.json"
    echo     },>> "%ROOT_DIR%\modulesettings.json"
    echo     "YOLOv5Net": {>> "%ROOT_DIR%\modulesettings.json"
    echo       "enabled": true,>> "%ROOT_DIR%\modulesettings.json"
    echo       "path": "%YOLONET_MODULE%">> "%ROOT_DIR%\modulesettings.json"
    echo     },>> "%ROOT_DIR%\modulesettings.json"
    echo     "Prefrontal": {>> "%ROOT_DIR%\modulesettings.json"
    echo       "enabled": true,>> "%ROOT_DIR%\modulesettings.json"
    echo       "path": "%PREFRONTAL_MODULE%">> "%ROOT_DIR%\modulesettings.json"
    echo     },>> "%ROOT_DIR%\modulesettings.json"
    echo     "SenNnT-i": {>> "%ROOT_DIR%\modulesettings.json"
    echo       "enabled": true,>> "%ROOT_DIR%\modulesettings.json"
    echo       "path": "%SENNTI_MODULE%">> "%ROOT_DIR%\modulesettings.json"
    echo     }>> "%ROOT_DIR%\modulesettings.json"
    echo   },>> "%ROOT_DIR%\modulesettings.json"
    echo   "build": {>> "%ROOT_DIR%\modulesettings.json"
    echo     "useIncrediBuild": %USE_INCREDIBUILD%>> "%ROOT_DIR%\modulesettings.json"
    echo   }>> "%ROOT_DIR%\modulesettings.json"
    echo }>> "%ROOT_DIR%\modulesettings.json"
)

:: Run module initialization scripts
echo.
echo Running module initialization scripts...

:: Initialize CeLeBrUm module
if exist "%CELEBRUM_MODULE%\init.bat" (
    echo Initializing CeLeBrUm module...
    call "%CELEBRUM_MODULE%\init.bat"
)

:: Initialize EbaAaZ module
if exist "%EBAAZ_MODULE%\init.bat" (
    echo Initializing EbaAaZ module...
    call "%EBAAZ_MODULE%\init.bat"
)

:: Initialize YOLO module
if exist "%YOLO_MODULE%\init.bat" (
    echo Initializing YOLO module...
    call "%YOLO_MODULE%\init.bat"
)

:: Initialize YOLONet module
if exist "%YOLONET_MODULE%\init.bat" (
    echo Initializing YOLONet module...
    call "%YOLONET_MODULE%\init.bat"
)

:: Initialize Prefrontal module
if exist "%PREFRONTAL_MODULE%\init.bat" (
    echo Initializing Prefrontal module...
    call "%PREFRONTAL_MODULE%\init.bat"
)

:: Initialize SenNnT-i module
if exist "%SENNTI_MODULE%\init.bat" (
    echo Initializing SenNnT-i module...
    call "%SENNTI_MODULE%\init.bat"
)

echo.
echo ===============================================
echo Installation Complete
echo ===============================================
echo.
echo All modules have been installed and configured.
echo To start the server, run: server.bat
echo.
goto end

:error_exit
echo.
echo Installation failed! Please check the error messages above.
echo.
pause
exit /b 1

:end
echo Press any key to exit...
pause >nul
exit /b 0
