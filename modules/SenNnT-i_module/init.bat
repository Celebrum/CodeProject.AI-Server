@echo off
echo Initializing SenNnT-i module...

:: Set paths
set "MODULE_DIR=%~dp0"
set "MODELS_DIR=%MODULE_DIR%models"
set "CACHE_DIR=%MODULE_DIR%cache"
set "WEIGHTS_DIR=%MODULE_DIR%weights"

:: Create required directories
if not exist "%MODELS_DIR%" mkdir "%MODELS_DIR%"
if not exist "%CACHE_DIR%" mkdir "%CACHE_DIR%"
if not exist "%WEIGHTS_DIR%" mkdir "%WEIGHTS_DIR%"

:: Install specific requirements
pip install -r "%MODULE_DIR%requirements.txt"

:: Initialize module configuration
if not exist "%MODULE_DIR%config.json" (
    echo Creating default configuration...
    echo {> "%MODULE_DIR%config.json"
    echo     "model_settings": {>> "%MODULE_DIR%config.json"
    echo         "use_gpu": true,>> "%MODULE_DIR%config.json"
    echo         "batch_size": 16,>> "%MODULE_DIR%config.json"
    echo         "sequence_length": 256,>> "%MODULE_DIR%config.json"
    echo         "num_heads": 8,>> "%MODULE_DIR%config.json"
    echo         "embedding_dim": 512>> "%MODULE_DIR%config.json"
    echo     },>> "%MODULE_DIR%config.json"
    echo     "training": {>> "%MODULE_DIR%config.json"
    echo         "learning_rate": 0.0001,>> "%MODULE_DIR%config.json"
    echo         "epochs": 100,>> "%MODULE_DIR%config.json"
    echo         "warmup_steps": 1000,>> "%MODULE_DIR%config.json"
    echo         "gradient_clip": 1.0>> "%MODULE_DIR%config.json"
    echo     },>> "%MODULE_DIR%config.json"
    echo     "paths": {>> "%MODULE_DIR%config.json"
    echo         "models": "models/",>> "%MODULE_DIR%config.json"
    echo         "cache": "cache/",>> "%MODULE_DIR%config.json"
    echo         "weights": "weights/">> "%MODULE_DIR%config.json"
    echo     }>> "%MODULE_DIR%config.json"
    echo }>> "%MODULE_DIR%config.json"
)

:: Download pre-trained models
python "%MODULE_DIR%download_models.py"

:: Initialize neural components
python "%MODULE_DIR%init_neural.py"

echo SenNnT-i module initialized successfully.
exit /b 0