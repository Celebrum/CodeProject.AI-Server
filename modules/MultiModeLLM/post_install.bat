:: Post-Installation script ::::::::::::::::::::::::::::::::::::::::::::::::::::
::
::                        Multi-mode LLM
::
:: The setup.bat file will find this post_install.bat file and execute it.
::
:: For help with install scripts, notes on variables and methods available, tips,
:: and explanations, see /src/modules/install_script_help.md

@if "%1" NEQ "post-install" (
    echo This script is only called from ..\..\CodeProject.AI-Server\src\setup.bat
    @pause
    @goto:eof
)

REM This is a woeful HACK to work around cuDNN issues. The onnxruntime CUDA
REM provider needs to be able to load the cuDNN DLLs, but if the path to the
REM cuDNN files isn't in the PATH env variable then it won't be found. This can
REM happen because installing cuDNN is not a neat operation: it's DIY. SO, to
REM work around the issues we're going to take the stand that if the DLLs can't
REM be found, then we're just going to copy the damn things over and throw them
REM into the same put that the CUDA provider lurks in.
if "!hasCUDA!" == "true" (
    if /i "!PATH:C:\Program Files\NVIDIA\CUDNN\v!cuDNN_version!\bin\!cuda_version!=!" == "!PATH!" (
        if exist "C:\Program Files\NVIDIA\CUDNN\v!cuDNN_version!\bin\!cuda_version!" (
            call "%utilsScript%" WriteLine "Pulling cuDNN libs into the CUDA provider onnxruntime folder"
            copy "C:\Program Files\NVIDIA\CUDNN\v!cuDNN_version!\bin\!cuda_version!\cudnn64_9.dll" "!packagesDirPath!\onnxruntime\capi\."
            copy "C:\Program Files\NVIDIA\CUDNN\v!cuDNN_version!\bin\!cuda_version!\cudnn_graph64_9.dll" "!packagesDirPath!\onnxruntime\capi\."
        )
    )
)

REM TODO: Check assets created and has files
REM set moduleInstallErrors=...
