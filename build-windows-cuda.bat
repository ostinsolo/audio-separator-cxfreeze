@echo off
REM ============================================================================
REM Audio Separator + Apollo - Windows CUDA Build Script
REM ============================================================================
REM This script builds both CPU and CUDA versions locally for testing
REM before pushing to GitHub Actions.
REM ============================================================================

setlocal enabledelayedexpansion

echo ============================================================================
echo AUDIO SEPARATOR + APOLLO - LOCAL WINDOWS BUILD
echo ============================================================================
echo.

REM Check Python version
python --version 2>nul || (
    echo ERROR: Python not found. Please install Python 3.10
    exit /b 1
)

REM Set build directory
set BUILD_DIR=%~dp0
cd /d "%BUILD_DIR%"

echo Build directory: %BUILD_DIR%
echo.

REM ============================================================================
REM CUDA BUILD
REM ============================================================================
echo.
echo ============================================================================
echo BUILDING CUDA VERSION
echo ============================================================================

REM Create/activate venv
if exist build_venv_cuda rmdir /s /q build_venv_cuda
python -m venv build_venv_cuda
call build_venv_cuda\Scripts\activate.bat

echo Installing dependencies (CUDA)...

REM Install cx_Freeze (use stable version)
pip install cx-Freeze==6.15.16

REM PyTorch CUDA 12.4 for Windows
echo Installing PyTorch with CUDA 12.4...
pip install "numpy<2" torch==2.5.1+cu124 torchaudio==2.5.1+cu124 --index-url https://download.pytorch.org/whl/cu124

REM Audio separator (no-deps to control versions)
pip install --no-deps audio-separator

REM All dependencies from python-audio-separator
pip install requests librosa samplerate six tqdm pydub
pip install onnx onnx2torch onnxruntime-gpu
pip install julius diffq einops pyyaml ml_collections
pip install resampy beartype rotary-embedding-torch
pip install scipy soundfile

REM Additional for cx_Freeze bundling
pip install torchvision==0.20.1+cu124 --index-url https://download.pytorch.org/whl/cu124
pip install pytorch-lightning huggingface_hub omegaconf

echo.
echo Building frozen binary (CUDA)...

REM Clean previous build
if exist audio-separator-win-cuda rmdir /s /q audio-separator-win-cuda

REM Build with cxfreeze
cxfreeze main.py --target-dir=audio-separator-win-cuda --target-name=audio-separator --packages=audio_separator,onnxruntime,samplerate,apollo,apollo.look2hear,apollo.look2hear.models,soundfile,omegaconf,scipy,requests,librosa,pydub,einops,julius,diffq,resampy,torch,torch.nn,torch.utils,torch.cuda,torchaudio --include-files=apollo

if errorlevel 1 (
    echo ERROR: CUDA build failed!
    exit /b 1
)

echo.
echo Copying llvmlite.libs (MSVC runtime DLLs)...
xcopy /E /I /Y "build_venv_cuda\Lib\site-packages\llvmlite" "audio-separator-win-cuda\lib\llvmlite\"
xcopy /E /I /Y "build_venv_cuda\Lib\site-packages\llvmlite.libs" "audio-separator-win-cuda\lib\llvmlite.libs\"
echo llvmlite.libs copied!

echo.
echo ============================================================================
echo TESTING CUDA BUILD
echo ============================================================================

REM Deactivate venv for testing (so we don't mix modules)
call build_venv_cuda\Scripts\deactivate.bat

echo Testing --version...
audio-separator-win-cuda\audio-separator.exe --version
if errorlevel 1 (
    echo WARNING: --version test failed
) else (
    echo OK: --version works
)

echo.
echo Testing --help...
audio-separator-win-cuda\audio-separator.exe --help >nul 2>&1
if errorlevel 1 (
    echo WARNING: --help test failed
) else (
    echo OK: --help works
)

echo.
echo Testing CUDA availability...
audio-separator-win-cuda\audio-separator.exe --env_info 2>nul | findstr /i "cuda"
if errorlevel 1 (
    echo WARNING: Could not detect CUDA in env_info
) else (
    echo OK: CUDA detected
)

echo.
echo ============================================================================
echo CUDA BUILD COMPLETE - Now building CPU version
echo ============================================================================

REM ============================================================================
REM CPU BUILD
REM ============================================================================
echo.
echo ============================================================================
echo BUILDING CPU VERSION
echo ============================================================================

REM Create/activate venv
if exist build_venv_cpu rmdir /s /q build_venv_cpu
python -m venv build_venv_cpu
call build_venv_cpu\Scripts\activate.bat

echo Installing dependencies (CPU)...

REM Install cx_Freeze (use stable version)
pip install cx-Freeze==6.15.16

REM PyTorch CPU for Windows
echo Installing PyTorch (CPU only)...
pip install "numpy<2" torch==2.5.1 torchaudio==2.5.1 --index-url https://download.pytorch.org/whl/cpu

REM Audio separator (no-deps to control versions)
pip install --no-deps audio-separator

REM All dependencies from python-audio-separator
pip install requests librosa samplerate six tqdm pydub
pip install onnx onnx2torch onnxruntime
pip install julius diffq einops pyyaml ml_collections
pip install resampy beartype rotary-embedding-torch
pip install scipy soundfile

REM Additional for cx_Freeze bundling
pip install torchvision pytorch-lightning huggingface_hub omegaconf

echo.
echo Building frozen binary (CPU)...

REM Clean previous build
if exist audio-separator-win-cpu rmdir /s /q audio-separator-win-cpu

REM Build with cxfreeze
cxfreeze main.py --target-dir=audio-separator-win-cpu --target-name=audio-separator --packages=audio_separator,onnxruntime,samplerate,apollo,apollo.look2hear,apollo.look2hear.models,soundfile,omegaconf,scipy,requests,librosa,pydub,einops,julius,diffq,resampy,torch,torch.nn,torch.utils,torchaudio --include-files=apollo

if errorlevel 1 (
    echo ERROR: CPU build failed!
    exit /b 1
)

echo.
echo Copying llvmlite.libs (MSVC runtime DLLs)...
xcopy /E /I /Y "build_venv_cpu\Lib\site-packages\llvmlite" "audio-separator-win-cpu\lib\llvmlite\"
xcopy /E /I /Y "build_venv_cpu\Lib\site-packages\llvmlite.libs" "audio-separator-win-cpu\lib\llvmlite.libs\"
echo llvmlite.libs copied!

REM Deactivate venv
call build_venv_cpu\Scripts\deactivate.bat

echo.
echo ============================================================================
echo TESTING CPU BUILD
echo ============================================================================

echo Testing --version...
audio-separator-win-cpu\audio-separator.exe --version
if errorlevel 1 (
    echo WARNING: --version test failed
) else (
    echo OK: --version works
)

echo.
echo Testing --help...
audio-separator-win-cpu\audio-separator.exe --help >nul 2>&1
if errorlevel 1 (
    echo WARNING: --help test failed
) else (
    echo OK: --help works
)

echo.
echo ============================================================================
echo ALL BUILDS COMPLETE
echo ============================================================================
echo.
echo CUDA build: audio-separator-win-cuda\
echo CPU build:  audio-separator-win-cpu\
echo.
echo To create release archives:
echo   7z a -mx=9 audio-separator-win-cuda.7z audio-separator-win-cuda
echo   Compress-Archive -Path audio-separator-win-cpu -DestinationPath audio-separator-win-cpu.zip
echo.
echo To test with an audio file:
echo   audio-separator-win-cuda\audio-separator.exe -m MODEL.pth "input.wav" --output_dir output
echo   audio-separator-win-cpu\audio-separator.exe -m MODEL.pth "input.wav" --output_dir output
echo.

pause
