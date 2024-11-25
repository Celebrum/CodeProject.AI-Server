@echo off
CALL ..\..\..\scripts\utils.bat

:: Install the core model
call %utilsScript% getFromServer "assets" "sennnti-core-model.zip" "assets" "Installing SenNnT-i core model"

:: Install required Python packages
call %utilsScript% installPythonPackagesByName "torch transformers numpy pandas ray[serve]"

:: Setup Ray Serve configuration
xcopy /Y Models\ray_serve_config.py %virtualEnvDirPath%\Lib\site-packages\
