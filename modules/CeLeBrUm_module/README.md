# CeLeBrUm Module

A neural network processing module for the CodeProject.AI Server, designed for advanced neural processing tasks within the SeCuReDmE project.

## Overview

The CeLeBrUm module provides neural network processing capabilities within the CodeProject.AI Server. It's designed to work within the mesh network architecture, allowing it to communicate with other modules and distribute neural processing workloads.

## Files and Structure

- **cerebrum_adapter.py**: The main adapter script that handles requests from the server
- **install.bat**: Windows installation script
- **install.sh**: Linux/macOS installation script
- **modulesettings.json**: Module configuration file
- **requirements.txt**: Python package dependencies
- **models/**: Directory for storing neural network model files (created during installation)

## API Endpoint

The module exposes the following API endpoint through the CodeProject.AI Server:

- **Route**: `/neural/cerebrum-process`
- **Method**: POST
- **Input Parameters**:
  - `input_data` (Text): The input data to process
  - `parameters` (JSON): Optional JSON string containing processing parameters

- **Output**:
  - `success` (Boolean): Whether the operation was successful
  - `result` (Text): The processing result
  - `inferenceMs` (Integer): The AI inference time in milliseconds
  - `processMs` (Integer): The total processing time in milliseconds

## Usage Example

```bash
curl -X POST http://localhost:32168/neural/cerebrum-process \
  -H "Content-Type: application/json" \
  -d '{
    "input_data": "Sample neural data for processing",
    "parameters": "{\"param1\": \"value1\", \"param2\": 123}"
  }'
```

Expected response:

```json
{
  "success": true,
  "result": "CeLeBrUm neural processing result: Sample neural data for processing",
  "inferenceMs": 200,
  "processMs": 205
}
```

## Installation

The module is automatically installed when setting up the CodeProject.AI Server. If you need to install it manually:

1. Ensure you're in the module's directory
2. Run the appropriate installation script:
   - Windows: `install.bat`
   - Linux/macOS: `./install.sh`

## Configuration

The module's behavior can be configured through the `modulesettings.json` file. Key settings include:

- **AutoStart**: Whether the module should start automatically with the server
- **EnableGPU**: Whether to enable GPU acceleration (if available)
- **MeshEnabled**: Whether the module participates in the mesh network
- **CPAI_MODULE_CEREBRUM_MODEL_DIR**: Path to the directory containing neural network models

## Mesh Network Integration

This module is configured to participate in the CodeProject.AI mesh network, allowing it to:
- Receive requests from other instances of the server
- Distribute neural processing workload across multiple server instances
- Scale processing across multiple machines

## Dependencies

- Python 3.10+
- numpy
- requests
- scipy

## Extending the Module

To extend the functionality of this module:

1. Modify the `process` function in `cerebrum_adapter.py` to implement your custom neural processing logic
2. Update the `requirements.txt` file if you need additional Python packages
3. Update the `modulesettings.json` file if you need to change the module configuration or API endpoints
4. Add your neural network models to the `models/` directory

## Integration with Other Modules

The CeLeBrUm module can be used in conjunction with other modules in the SeCuReDmE project:

- **EbaAaZ_module**: For custom AI processing
- **SenNnT-i_module**: For sensory neural network interface
- **NeuUuR-o**: For TensorZero middleware integration