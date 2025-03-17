#!/usr/bin/env python
# Python module adapter for CeLeBrUm neural network processing

import os
import sys
import time
import json

# Add the common packages in the sdk common directory to the path
common_pkg_path = os.path.join(os.path.dirname(os.path.realpath(__file__)), "..", "..", "SDK", "Python", "common")
if os.path.isdir(common_pkg_path):
    sys.path.append(common_pkg_path)

from p import LogMethod, setup_logging
from module_options import ModuleOptions

# Setup logging
setup_logging()

# Process the command line arguments for the module
options = ModuleOptions()

# Get the model directory from environment variables
MODEL_DIR = os.environ.get("CPAI_MODULE_CEREBRUM_MODEL_DIR", "./models")

def log_msg(msg, log_type="INFO"):
    """
    Logs a message to the console for the server to pick up
    """
    if log_type == "ERROR":
        LogMethod.LogError(msg)
    elif log_type == "WARNING":
        LogMethod.LogWarning(msg)
    else:
        LogMethod.LogInfo(msg)


def process(request_json):
    """
    Main processing function for the CeLeBrUm neural network module
    """
    start_time = time.time()
    inference_start = time.time()
    success = False
    
    try:
        # Extract the input data and parameters from the request
        input_data = request_json.get('input_data', '')
        parameters = json.loads(request_json.get('parameters', '{}'))
        
        if not input_data:
            return {
                "success": False,
                "error": "No input data provided",
                "inferenceMs": 0,
                "processMs": int((time.time() - start_time) * 1000)
            }
        
        # Check if the model directory exists
        if not os.path.exists(MODEL_DIR):
            os.makedirs(MODEL_DIR)
            log_msg(f"Created model directory at {MODEL_DIR}")
        
        # Here you would typically load and use your neural network model
        # For now, we'll just simulate processing
        log_msg(f"Processing input with parameters: {parameters}")
        
        # Simulate neural network inference
        time.sleep(0.2)  # Simulate processing time
        inference_time = int((time.time() - inference_start) * 1000)
        
        # Process the input data (replace this with your actual neural network logic)
        processed_result = f"CeLeBrUm neural processing result: {input_data}"
        
        success = True
        
        return {
            "success": success,
            "result": processed_result,
            "inferenceMs": inference_time,
            "processMs": int((time.time() - start_time) * 1000)
        }
        
    except Exception as ex:
        log_msg(f"Error in CeLeBrUm processing: {str(ex)}", "ERROR")
        return {
            "success": False,
            "error": str(ex),
            "inferenceMs": int((time.time() - inference_start) * 1000),
            "processMs": int((time.time() - start_time) * 1000)
        }


def get_module_info():
    """
    Returns information about this module
    """
    return {
        "name": "CeLeBrUm Module",
        "version": "1.0.0",
        "description": "Neural network processing using CeLeBrUm technology"
    }


# Main entry point for the module
def main():
    log_msg("CeLeBrUm module initialized and ready for neural processing")
    
    # Process commands coming in from the server
    while True:
        try:
            command = input()
            if command == "":
                continue
                
            request = json.loads(command)
            
            if request["command"] == "info":
                print(json.dumps(get_module_info()))
            elif request["command"] == "process":
                result = process(request)
                print(json.dumps(result))
            else:
                log_msg(f"Unknown command: {request['command']}", "ERROR")
                print(json.dumps({"success": False, "error": "Unknown command", "inferenceMs": 0, "processMs": 0}))
                
        except Exception as ex:
            log_msg(f"Error in command processing: {str(ex)}", "ERROR")
            print(json.dumps({"success": False, "error": str(ex), "inferenceMs": 0, "processMs": 0}))

if __name__ == "__main__":
    main()