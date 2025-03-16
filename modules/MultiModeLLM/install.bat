:: Installation script :::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
::                        Multi-mode LLM
::
:: This script is only called from ..\..\CodeProject.AI-Server\src\setup.bat in
:: Dev setup, or ..\..\src\setup.bat in production
::
:: For help with install scripts, notes on variables and methods available, tips,
:: and explanations, see /src/modules/install_script_help.md

@if "%1" NEQ "install" (
    echo This script is only called from ..\..\src\setup.bat
    @pause
    @goto:eof
)

set oneStepPIP=false

set useCUDA=false
if "!cuda_major_version!" == "12" set useCUDA=true
if "!cuda_version!" == "11.8"     set useCUDA=true

if "!useCUDA!" == "true" (
    call "!utilsScript!" Write "Checking for the CUDA Toolkit..." 
    if "!hasCUDAToolkit!" == "false" (
        call "!utilsScript!" WriteLine
        call "!utilsScript!" WriteLine "** WARNING: This module requires the CUDA Toolkit to be installed." !color_error!
        call "!utilsScript!" WriteLine "            The toolkit can be downloaded and installed from NVIDIA:" !color_error!
        call "!utilsScript!" WriteLine "            https://developer.nvidia.com/cuda-downloads?target_os=Windows " !color_error!
        call "!utilsScript!" WriteLine
        set useCUDA=false
    ) else (
        call "!utilsScript!" WriteLine "All good" !color_success!
    )
)

if "!useCUDA!" == "true" (

    call "!utilsScript!" WriteLine "Confirming VC++ Redist package installation"
    
    set "RequiredVCRedistVersion=14.40.33810.00"
    call "!utilsScript!" GetVCredistVersion "64-bit"
    call :compareVersions "!VCredistVersion!" "!RequiredVCRedistVersion!"
    if !compareResult! LSS 0 (
        set moduleInstallErrors=VC++ redist !RequiredVCRedistVersion! is not installed. Please download and install from https://aka.ms/vs/17/release/vc_redist.x64.exe
    )
    
    set "phi3_folder=cuda-int4-rtn-block-32"
    set "phi3_fileId=microsoft/Phi-3-vision-128k-instruct-onnx-cuda"
) else (
    set "phi3_fileId=microsoft/Phi-3-vision-128k-instruct-onnx-cpu"
    set "phi3_folder=cpu-int4-rtn-block-32-acc-level-4"
)

REM Ensure Git LFS is installed
git lfs --version >nul 2>&1
if errorlevel 1 winget install -e --id GitHub.GitLFS

set HF_HUB_DISABLE_SYMLINKS_WARNING=1

rem call "!utilsScript!" Write "Looking for model !phi3_fileId! in !moduleDirPath!\!phi3_folder!..."
call "!utilsScript!" Write "Looking for model !phi3_fileId! in .\!phi3_folder!..."

if exist "!moduleDirPath!\!phi3_folder!" (
    call "!utilsScript!" WriteLine "Already downloaded." "!color_success!"
) else (
    call "!utilsScript!" Write "downloading..."
    call "!utilsScript!" InstallPythonPackagesByName "huggingface-hub[cli]"
    !venvPythonCmdPath! !packagesDirPath!\huggingface_hub\commands\huggingface_cli.py download !phi3_fileId! --include !phi3_folder!\* --local-dir "!moduleDirPath!"
    call "!utilsScript!" WriteLine "Done." "!color_success!"
)
