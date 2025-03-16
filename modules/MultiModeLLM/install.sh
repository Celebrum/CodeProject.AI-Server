#!/bin/bash

# Development mode setup script ::::::::::::::::::::::::::::::::::::::::::::::
#
#                           Multi-mode LLM
#
# This script is called from the Multi-mode LLM directory using: 
#
#    bash ../../CodeProject.AI-Server/src/setup.sh
#
# The setup.sh script will find this install.sh file and execute it.
#
# For help with install scripts, notes on variables and methods available, tips,
# and explanations, see /src/modules/install_script_help.md

if [ "$1" != "install" ]; then
    read -t 3 -p "This script is only called from: bash ../../CodeProject.AI-Server/src/setup.sh"
    echo
    exit 1 
fi

if [ "${edgeDevice}" = "Raspberry Pi" ] || [ "${edgeDevice}" = "Orange Pi" ] || 
   [ "${edgeDevice}" = "Radxa ROCK" ]   || [ "${edgeDevice}" = "Jetson" ]; then
    moduleInstallErrors="Unable to install on Pi, ROCK or Jetson hardware."
fi

if [ "$moduleInstallErrors" = "" ]; then

    oneStepPIP=true  # Makes dealing with Numpy so much easier.

    if [ "$os" = "macos" ]; then

        if [ "${platform}" = "macos-arm64" ]; then
            # Safer, since a fail in a bizarre dependency won't skuttle the lot.
            oneStepPIP=false
        fi
        
        phi3_sourceUrl="..."
        phi3_fileToGet="..."
        # brew install git-lfs

    else
        if [ "${hasCUDA}" = true ]; then

            # Linux CUDA
            
            # Safer, since a fail in a bizarre dependency won't skuttle the lot.
            oneStepPIP=false
            
            phi3_folder="cuda-int4-rtn-block-32"
            phi3_fileId="microsoft/Phi-3-vision-128k-instruct-onnx-cuda"

            # We need libcublasLt.so.11, but CUDA 12 comes standard with libcublasLt.so.12
            # installAptPackages "libcublas11"
        else

            # Linux CPU
            phi3_fileId="microsoft/Phi-3-vision-128k-instruct-onnx-cpu"
            phi3_folder="cpu-int4-rtn-block-32-acc-level-4"
        fi

        sudo apt-get install git-lfs

        HF_HUB_DISABLE_SYMLINKS_WARNING=1

        write "Looking for model: ${phi3_fileId} in ${phi3_folder}..."
        if [ ! -d "${moduleDirPath}/${phi3_folder}/" ]; then
            write "downloading..."
            installPythonPackagesByName "huggingface-hub[cli]"
            ${venvPythonCmdPath} ${packagesDirPath}/huggingface_hub/commands/huggingface_cli.py download ${phi3_fileId} --include ${phi3_folder}\* --local-dir "${moduleDirPath}"
            # huggingface-cli download ${phi3_fileId} --include ${phi3_folder}/* --local-dir .
            writeLine "Done." "$color_success"
        else
            writeLine "${fileToGet} already downloaded." "$color_success"
        fi    
    fi

fi