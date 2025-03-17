#!/bin/bash

# Setup paths
scriptPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Write out a message
writeLine "Installing CeLeBrUm neural network module..." "Green"

# Make sure Python environment is setup
writeLine "Setting up Python $pythonVersion virtual environment..." "Green"
setupPython
if [ $? -ne 0 ]; then
    writeLine "Error setting up Python environment" "Red"
    exit 1
fi

# Create models directory if it doesn't exist
if [ ! -d "$scriptPath/models" ]; then
    mkdir -p "$scriptPath/models"
    writeLine "Created models directory." "Green"
fi

writeLine "Installing required Python packages..." "Green"
installRequiredPythonPackages

writeLine "CeLeBrUm module installed successfully." "Green"

exit 0