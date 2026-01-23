@echo off
REM ============================================================================
REM Audio Separator + Apollo - Windows CPU Build Only
REM ============================================================================
REM Based on the original build-windows-cuda.bat CPU section
REM Uses PyTorch 2.10.0 for consistency
REM ============================================================================

setlocal enabledelayedexpansion

echo ============================================================================
echo AUDIO SEPARATOR + APOLLO - CPU BUILD ONLY (PyTorch 2.10.0)
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
REM CPU BUILD (PyTorch 2.10.0)
REM ============================================================================
echo ============================================================================
echo BUILDING CPU VERSION (PyTorch 2.10.0)
echo ============================================================================

REM Create/activate venv
if exist build_venv_cpu rmdir /s /q build_venv_cpu
python -m venv build_venv_cpu
call build_venv_cpu\Scripts\activate.bat

echo Installing dependencies (CPU)...

REM Install cx_Freeze first (use stable version)
pip install cx-Freeze==6.15.16

REM Install all dependencies from requirements file
pip install -r build\requirements\requirements-cpu.txt

echo.
echo Building frozen binary (CPU)...

REM Clean previous build
if exist audio-separator-win-cpu rmdir /s /q audio-separator-win-cpu

REM Build with cxfreeze (run as python module)
python -m cx_Freeze main.py --target-dir=audio-separator-win-cpu --target-name=audio-separator --packages=audio_separator,onnxruntime,samplerate,apollo,apollo.look2hear,apollo.look2hear.models,soundfile,omegaconf,scipy,requests,librosa,pydub,einops,julius,diffq,resampy,torch,torch.nn,torch.utils,torchaudio,urllib,urllib.request,urllib.parse,urllib.error,http,http.client,email,importlib,importlib.metadata --include-files=apollo

if errorlevel 1 (
    echo ERROR: CPU build failed!
    exit /b 1
)

echo.
echo Copying llvmlite.libs (MSVC runtime DLLs)...

REM Copy llvmlite + llvmlite.libs (required by numba/librosa)
for /f "delims=" %%i in ('python -c "import llvmlite, os; print(os.path.dirname(llvmlite.__file__))"') do set LLVMLITE_DIR=%%i
for /f "delims=" %%i in ('python -c "import llvmlite, os; print(os.path.join(os.path.dirname(os.path.dirname(llvmlite.__file__)), \"llvmlite.libs\"))"') do set LLVMLITE_LIBS=%%i
if not exist "audio-separator-win-cpu\lib" mkdir "audio-separator-win-cpu\lib"
if exist "%LLVMLITE_DIR%" (
    xcopy /E /I /Y "%LLVMLITE_DIR%" "audio-separator-win-cpu\lib\llvmlite\" >nul
    echo llvmlite copied!
)
if exist "%LLVMLITE_LIBS%" (
    xcopy /E /I /Y "%LLVMLITE_LIBS%" "audio-separator-win-cpu\lib\llvmlite.libs\" >nul
    echo llvmlite.libs copied!
)

REM Verify required DLLs are present for distribution
if not exist "audio-separator-win-cpu\lib\llvmlite\binding\llvmlite.dll" (
    echo ERROR: llvmlite.dll missing in build output
    exit /b 1
)
if not exist "audio-separator-win-cpu\lib\llvmlite.libs\msvcp140-8f141b4454fa78db34bc1f28c571b4da.dll" (
    echo ERROR: msvcp140 runtime DLL missing in build output
    exit /b 1
)

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
echo CPU BUILD COMPLETE
echo ============================================================================
echo.
echo Build location: audio-separator-win-cpu\
echo PyTorch version: 2.10.0+cpu
echo.

pause