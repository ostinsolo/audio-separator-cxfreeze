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

REM Set build directory and repo root
set BUILD_DIR=%~dp0
set REPO_ROOT=%BUILD_DIR%..\..
cd /d "%REPO_ROOT%"

echo Build directory: %BUILD_DIR%
echo Repo root: %REPO_ROOT%
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

REM Install all dependencies from requirements file (CUDA 2.10.0 + cu126)
pip install -r build\requirements\requirements-cuda.txt

echo.
echo Building frozen binary (CUDA)...

REM Clean previous build
if exist audio-separator-win-cuda rmdir /s /q audio-separator-win-cuda

REM Build with cxfreeze (including full torch CUDA subpackages for optimization)
cxfreeze main.py --target-dir=audio-separator-win-cuda --target-name=audio-separator --packages=audio_separator,onnxruntime,samplerate,apollo,apollo.look2hear,apollo.look2hear.models,soundfile,omegaconf,scipy,requests,librosa,pydub,einops,julius,diffq,resampy,torch,torch.nn,torch.nn.utils,torch.utils,torch.cuda,torch.cuda.amp,torch.backends,torch.backends.cuda,torch.backends.cudnn,torch.autograd,torch.jit,torch.fft,torch.linalg,torch.amp,torchaudio --include-files=apollo

if errorlevel 1 (
    echo ERROR: CUDA build failed!
    exit /b 1
)

echo.
echo Copying llvmlite + llvmlite.libs (MSVC runtime DLLs)...
for /f "delims=" %%i in ('python -c "import llvmlite, os; print(os.path.dirname(llvmlite.__file__))"') do set LLVMLITE_DIR=%%i
for /f "delims=" %%i in ('python -c "import llvmlite, os; print(os.path.join(os.path.dirname(os.path.dirname(llvmlite.__file__)), \"llvmlite.libs\"))"') do set LLVMLITE_LIBS=%%i
if not exist "audio-separator-win-cuda\lib" mkdir "audio-separator-win-cuda\lib"
if exist "%LLVMLITE_DIR%" (
    xcopy /E /I /Y "%LLVMLITE_DIR%" "audio-separator-win-cuda\lib\llvmlite\" >nul
    echo llvmlite copied!
)
if exist "%LLVMLITE_LIBS%" (
    xcopy /E /I /Y "%LLVMLITE_LIBS%" "audio-separator-win-cuda\lib\llvmlite.libs\" >nul
    echo llvmlite.libs copied!
)

REM Verify required DLLs are present for distribution
if not exist "audio-separator-win-cuda\lib\llvmlite\binding\llvmlite.dll" (
    echo ERROR: llvmlite.dll missing in CUDA build output
    exit /b 1
)
dir /b "audio-separator-win-cuda\lib\llvmlite.libs\*.dll" >nul 2>&1
if errorlevel 1 (
    echo ERROR: llvmlite runtime DLLs missing in CUDA build output
    exit /b 1
)

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
echo CUDA BUILD COMPLETE
echo ============================================================================
echo.
echo CUDA build: audio-separator-win-cuda\
echo.
echo To create release archive:
echo   7z a -mx=9 audio-separator-win-cuda.7z audio-separator-win-cuda
echo.
echo To test with an audio file:
echo   audio-separator-win-cuda\audio-separator.exe -m MODEL.pth "input.wav" --output_dir output
echo.

pause
