@echo off
setlocal EnableDelayedExpansion

:: Check Conda
where conda >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: Conda is not installed or not in PATH.
    exit /b 1
)

:: Check Python
where python >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: Python is not installed or not in PATH.
    exit /b 1
)

:: Check pip
python -m pip --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: pip is not installed or not functioning.
    exit /b 1
)

:: Check .NET SDK
dotnet --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: .NET SDK is not installed or not in PATH.
    exit /b 1
)

:: Check IncrediBuild
where BuildConsole >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo WARNING: IncrediBuild not found. Build acceleration will be disabled.
    set "USE_INCREDIBUILD=false"
) else (
    echo IncrediBuild found. Build acceleration enabled.
    set "USE_INCREDIBUILD=true"
)

:: Check CUDA for GPU support
nvidia-smi >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo CUDA GPU detected, GPU acceleration will be enabled.
    set "USE_GPU=true"
) else (
    echo No CUDA GPU detected, using CPU only.
    set "USE_GPU=false"
)

:: Check Git
where git >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: Git is not installed or not in PATH.
    exit /b 1
)

:: All checks passed
exit /b 0