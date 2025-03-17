@echo off
SETLOCAL EnableDelayedExpansion

:: Setup Conda / Python paths from the parameters set in the caller
SET scriptPath=%~dp0
SET scriptPath=%scriptPath:~0,-1%

CALL "%sdkScriptsDirPath%\utils.bat" WriteLine "Installing CeLeBrUm neural network module..."

:: Make sure Python environment is setup
CALL "%sdkScriptsDirPath%\utils.bat" WriteLine "Setting up Python %pythonVersion% virtual environment..." "Green"
CALL "%sdkScriptsDirPath%\utils.bat" SetupPython
if ERRORLEVEL 1 (
    CALL "%sdkScriptsDirPath%\utils.bat" WriteLine "Error setting up Python environment" "Red"
    exit /b 1
)

:: Create models directory if it doesn't exist
IF NOT EXIST "%scriptPath%\models" (
    mkdir "%scriptPath%\models"
    CALL "%sdkScriptsDirPath%\utils.bat" WriteLine "Created models directory." "Green"
)

CALL "%sdkScriptsDirPath%\utils.bat" WriteLine "Installing required Python packages..." "Green"
CALL "%sdkScriptsDirPath%\utils.bat" InstallRequiredPythonPackages

CALL "%sdkScriptsDirPath%\utils.bat" WriteLine "CeLeBrUm module installed successfully." "Green"

exit /b 0