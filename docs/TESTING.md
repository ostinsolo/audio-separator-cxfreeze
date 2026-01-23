# Audio Separator CxFreeze - Local Testing Guide

This guide provides comprehensive commands to test all functionality locally before pushing to GitHub Actions.

## Prerequisites

- **Python 3.10** installed
- **UV** installed: `pip install uv`
- **Test audio file**: set `AUDIO_FILE` to a local WAV file
- **Models directory**: set `MODEL_DIR` to your model folder

### Set local paths (CMD)
```batch
REM Set these before running any tests
set "REPO_ROOT=C:\path\to\audio-separator-cxfreeze"
set "AUDIO_FILE=C:\path\to\test.wav"
set "MODEL_DIR=C:\path\to\models\audio-separator"
set "APOLLO_MODEL=C:\path\to\models\apollo\apollo_lew_uni.ckpt"
```

## 1. Test UV-Based Builds (Recommended)

### Clean and Build All Variants
```batch
cd /d "%REPO_ROOT%"

# Remove any existing venvs and builds
rmdir /s /q .venv-cpu .venv-cuda .venv-dml audio-separator-win-* 2>nul

# Run the automated UV build script
build\scripts\build-with-uv.bat
```

### Expected Output
- `audio-separator-win-cpu\` (CPU build)
- `audio-separator-win-cuda\` (CUDA build)
- `audio-separator-win-dml\` (DirectML build)

## 2. Test Individual Builds

### CPU Build Only
```batch
cd /d "%REPO_ROOT%"

# Clean
rmdir /s /q .venv-cpu audio-separator-win-cpu 2>nul

# Create venv and install
uv venv .venv-cpu --python 3.10
uv pip install -r build\requirements\requirements-cpu.txt --python .venv-cpu\Scripts\python.exe --index-strategy unsafe-best-match

# Build
.venv-cpu\Scripts\cxfreeze.exe main.py --target-dir=audio-separator-win-cpu --target-name=audio-separator --packages=audio_separator,onnxruntime,samplerate,apollo,apollo.look2hear,apollo.look2hear.models,soundfile,omegaconf,scipy,requests,librosa,pydub,einops,julius,diffq,resampy,torch,torch.nn,torch.utils,torchaudio,urllib,urllib.request,urllib.parse,urllib.error,http,http.client,email,importlib,importlib.metadata --include-files=apollo

# Copy llvmlite
xcopy /E /I /Y ".venv-cpu\Lib\site-packages\llvmlite" "audio-separator-win-cpu\lib\llvmlite\"
xcopy /E /I /Y ".venv-cpu\Lib\site-packages\llvmlite.libs" "audio-separator-win-cpu\lib\llvmlite.libs\"
```

### CUDA Build Only
```batch
cd /d "%REPO_ROOT%"

# Clean
rmdir /s /q .venv-cuda audio-separator-win-cuda 2>nul

# Create venv and install
uv venv .venv-cuda --python 3.10
uv pip install -r build\requirements\requirements-cuda.txt --python .venv-cuda\Scripts\python.exe --index-strategy unsafe-best-match

# Build
.venv-cuda\Scripts\cxfreeze.exe main.py --target-dir=audio-separator-win-cuda --target-name=audio-separator --packages=audio_separator,onnxruntime,samplerate,apollo,apollo.look2hear,apollo.look2hear.models,soundfile,omegaconf,scipy,requests,librosa,pydub,einops,julius,diffq,resampy,torch,torch.nn,torch.nn.utils,torch.utils,torch.cuda,torch.cuda.amp,torch.backends,torch.backends.cuda,torch.backends.cudnn,torch.autograd,torch.jit,torch.fft,torch.linalg,torch.amp,torchaudio --include-files=apollo

# Copy llvmlite
xcopy /E /I /Y ".venv-cuda\Lib\site-packages\llvmlite" "audio-separator-win-cuda\lib\llvmlite\"
xcopy /E /I /Y ".venv-cuda\Lib\site-packages\llvmlite.libs" "audio-separator-win-cuda\lib\llvmlite.libs\"
```

### CUDA 2.10.0 (cu126) Build Script
This script builds **CUDA + CPU** using PyTorch 2.10.0 + CUDA 12.6:
```batch
cd /d "%REPO_ROOT%"
build\scripts\build-windows-cuda.bat
```

### CUDA Build From Source (Full PyTorch Control)
```batch
cd /d "%REPO_ROOT%"

# Clean
rmdir /s /q build_venv_cuda_source audio-separator-win-cuda-source 2>nul

# This approach clones audio-separator and builds from source
# giving us complete control over PyTorch versions
build\scripts\build-cuda-from-source.bat
```

### DirectML Build Only
```batch
cd /d "%REPO_ROOT%"

# Clean
rmdir /s /q .venv-dml audio-separator-win-dml 2>nul

# Create venv and install
uv venv .venv-dml --python 3.10
uv pip install -r build\requirements\requirements-dml.txt --python .venv-dml\Scripts\python.exe --index-strategy unsafe-best-match

# Build
.venv-dml\Scripts\cxfreeze.exe main.py --target-dir=audio-separator-win-dml --target-name=audio-separator --packages=audio_separator,onnxruntime,samplerate,apollo,apollo.look2hear,apollo.look2hear.models,soundfile,omegaconf,scipy,requests,librosa,pydub,einops,julius,diffq,resampy,torch,torch.nn,torch.utils,torchaudio --include-files=apollo

# Copy llvmlite
xcopy /E /I /Y ".venv-dml\Lib\site-packages\llvmlite" "audio-separator-win-dml\lib\llvmlite\"
xcopy /E /I /Y ".venv-dml\Lib\site-packages\llvmlite.libs" "audio-separator-win-dml\lib\llvmlite.libs\"
```

## 3. Test Frozen Executables

### Basic Functionality Tests
```batch
cd /d "%REPO_ROOT%"

# Test CPU build
echo === TESTING CPU BUILD ===
cd audio-separator-win-cpu
audio-separator.exe --version
audio-separator.exe --help
audio-separator.exe --list-models

# Test CUDA build
echo === TESTING CUDA BUILD ===
cd ../audio-separator-win-cuda
audio-separator.exe --version
audio-separator.exe --env_info | findstr /i cuda

# Test DirectML build
echo === TESTING DIRECTML BUILD ===
cd ../audio-separator-win-dml
audio-separator.exe --version
```

### Audio Separation Tests
```batch
# CPU Build Test
cd /d "%REPO_ROOT%\audio-separator-win-cpu"
audio-separator.exe -m 3_HP-Vocal-UVR.pth --model_file_dir "%MODEL_DIR%" "%AUDIO_FILE%" --output_dir test_cpu_output

# CUDA Build Test
cd /d "%REPO_ROOT%\audio-separator-win-cuda"
audio-separator.exe -m 3_HP-Vocal-UVR.pth --model_file_dir "%MODEL_DIR%" "%AUDIO_FILE%" --output_dir test_cuda_output --use_cuda

# DirectML Build Test
cd /d "%REPO_ROOT%\audio-separator-win-dml"
audio-separator.exe -m 3_HP-Vocal-UVR.pth --model_file_dir "%MODEL_DIR%" "%AUDIO_FILE%" --output_dir test_dml_output --use_cuda
```

### Apollo Restoration Tests
```batch
# CPU Apollo Test
cd /d "%REPO_ROOT%\audio-separator-win-cpu"
audio-separator.exe --apollo "%AUDIO_FILE%" -m "%APOLLO_MODEL%" -o test_apollo_cpu.wav

# CUDA Apollo Test
cd /d "%REPO_ROOT%\audio-separator-win-cuda"
audio-separator.exe --apollo "%AUDIO_FILE%" -m "%APOLLO_MODEL%" -o test_apollo_cuda.wav
```
### Apollo Venv Smoke Test (Short WAV)
Used to confirm Apollo runs without cx-Freeze.

```batch
REM Create a 5s WAV clip
ffmpeg -y -i "C:\Users\soloo\Downloads\Jon Hamm Tiktok_Reels Club dance meme video from Your Friends  Neighbors jonhamm viraldance.mp3" -t 5 "C:\Users\soloo\Downloads\apollo_short.wav"

REM CPU venv test
C:\Users\soloo\CODE\audio-separator-cxfreeze\build_venv_cpu\Scripts\python.exe C:\Users\soloo\CODE\audio-separator-cxfreeze\main.py --apollo "C:\Users\soloo\Downloads\apollo_short.wav" -m "C:\Users\soloo\Documents\Max 9\SplitWizard\ThirdPartyApps\Models\apollo\apollo_lew_uni.ckpt" -c "C:\Users\soloo\Documents\Max 9\SplitWizard\ThirdPartyApps\Models\apollo\apollo_lew_uni.yaml" -o "C:\Users\soloo\CODE\audio-separator-cxfreeze\apollo_cpu_short.wav"

REM CUDA venv test (run after closing GPU-heavy apps)
start "" /b C:\Users\soloo\CODE\audio-separator-cxfreeze\build_venv_cuda\Scripts\python.exe C:\Users\soloo\CODE\audio-separator-cxfreeze\main.py --apollo "C:\Users\soloo\Downloads\apollo_short.wav" -m "C:\Users\soloo\Documents\Max 9\SplitWizard\ThirdPartyApps\Models\apollo\apollo_lew_uni.ckpt" -c "C:\Users\soloo\Documents\Max 9\SplitWizard\ThirdPartyApps\Models\apollo\apollo_lew_uni.yaml" -o "C:\Users\soloo\CODE\audio-separator-cxfreeze\apollo_cuda_short.wav"
```

Recorded results:
- CPU venv: ✅ Saved `C:\Users\soloo\CODE\audio-separator-cxfreeze\apollo_cpu_short.wav`
- CUDA venv: ✅ Saved `C:\Users\soloo\CODE\audio-separator-cxfreeze\apollo_cuda_short.wav`

### Apollo Venv Test (Long WAV, Chunked)
Used to avoid Apollo memory spikes on long files by chunking.

```batch
REM CPU venv test (chunked)
cmd /c ""C:\Users\soloo\CODE\audio-separator-cxfreeze\build_venv_cpu\Scripts\activate.bat" && python "C:\Users\soloo\CODE\audio-separator-cxfreeze\apollo\apollo_separator.py" "C:\Users\soloo\Downloads\Jon Hamm Tiktok_Reels Club dance meme video from Your Friends  Neighbors jonhamm viraldance.wav" -m "C:\Users\soloo\Documents\Max 9\SplitWizard\ThirdPartyApps\Models\apollo\apollo_lew_uni.ckpt" -c "C:\Users\soloo\Documents\Max 9\SplitWizard\ThirdPartyApps\Models\apollo\apollo_lew_uni.yaml" -o "C:\Users\soloo\CODE\audio-separator-cxfreeze\apollo_cpu_long_chunked.wav" --chunk_seconds 10 --chunk_overlap 1 --auto_chunk_seconds 0"

REM CUDA venv test (chunked, smaller window)
cmd /c ""C:\Users\soloo\CODE\audio-separator-cxfreeze\build_venv_cuda\Scripts\activate.bat" && python "C:\Users\soloo\CODE\audio-separator-cxfreeze\apollo\apollo_separator.py" "C:\Users\soloo\Downloads\Jon Hamm Tiktok_Reels Club dance meme video from Your Friends  Neighbors jonhamm viraldance.wav" -m "C:\Users\soloo\Documents\Max 9\SplitWizard\ThirdPartyApps\Models\apollo\apollo_lew_uni.ckpt" -c "C:\Users\soloo\Documents\Max 9\SplitWizard\ThirdPartyApps\Models\apollo\apollo_lew_uni.yaml" -o "C:\Users\soloo\CODE\audio-separator-cxfreeze\apollo_cuda_long_chunked.wav" --chunk_seconds 5 --chunk_overlap 0.5 --auto_chunk_seconds 0"
```

Recorded results:
- CPU venv (chunked): ✅ Saved `C:\Users\soloo\CODE\audio-separator-cxfreeze\apollo_cpu_long_chunked.wav`
- CUDA venv (chunked): ✅ Saved `C:\Users\soloo\CODE\audio-separator-cxfreeze\apollo_cuda_long_chunked.wav`

### Apollo EXE Test (Long WAV, Chunked Default)
Confirmed the frozen CUDA executable uses the default CUDA chunking (5s/0.5s).

```batch
cmd /c ""C:\Users\soloo\CODE\audio-separator-cxfreeze\audio-separator-win-cuda\audio-separator.exe" --apollo "C:\Users\soloo\CODE\audio-separator-cxfreeze\apollo_cpu_long_chunked.wav" -m "C:\Users\soloo\Documents\Max 9\SplitWizard\ThirdPartyApps\Models\apollo\apollo_lew_uni.ckpt" -c "C:\Users\soloo\Documents\Max 9\SplitWizard\ThirdPartyApps\Models\apollo\apollo_lew_uni.yaml" -o "C:\Users\soloo\CODE\audio-separator-cxfreeze\apollo_cuda_long_chunked_exe.wav""
```

Recorded results:
- CUDA exe (chunked default): ✅ Saved `C:\Users\soloo\CODE\audio-separator-cxfreeze\apollo_cuda_long_chunked_exe.wav`

#### Apollo MP3 ID3 Warning (mpg123)
If your input is an MP3 with empty ID3 comments, you may see:
```
[C:\vcpkg\buildtrees\mpg123\src\-66150af195.clean\src\libmpg123\id3.c:process_comment():587] error: No comment text / valid description?
```
This is a **decode warning** and does not block output. If you want a clean log, convert MP3 → WAV first:
```batch
ffmpeg -y -i "%AUDIO_FILE%" "%AUDIO_FILE%.wav"
```
Then run Apollo against the WAV file.

## 4. Performance Benchmarking

### Time Comparison Script
```batch
@echo off
cd /d "%REPO_ROOT%"

echo ============================================================================
echo PERFORMANCE BENCHMARK: CPU vs CUDA vs DirectML
echo ============================================================================

set "AUDIO_FILE=%AUDIO_FILE%"
set "MODEL_DIR=%MODEL_DIR%"

echo.
echo === CPU BUILD ===
cd audio-separator-win-cpu
echo Start: %time%
audio-separator.exe -m 3_HP-Vocal-UVR.pth --model_file_dir "%MODEL_DIR%" "%AUDIO_FILE%" --output_dir bench_cpu
echo End: %time%

echo.
echo === CUDA BUILD ===
cd ../audio-separator-win-cuda
echo Start: %time%
audio-separator.exe -m 3_HP-Vocal-UVR.pth --model_file_dir "%MODEL_DIR%" "%AUDIO_FILE%" --output_dir bench_cuda --use_cuda
echo End: %time%

echo.
echo === DIRECTML BUILD ===
cd ../audio-separator-win-dml
echo Start: %time%
audio-separator.exe -m 3_HP-Vocal-UVR.pth --model_file_dir "%MODEL_DIR%" "%AUDIO_FILE%" --output_dir bench_dml --use_cuda
echo End: %time%

echo.
echo ============================================================================
echo BENCHMARK COMPLETE - Check output directories for results
echo ============================================================================
```

### Recorded Benchmarks (Local)
- **Date:** 2026-01-23
- **Build:** `audio-separator-win-cpu` (frozen)
- **PyTorch:** 2.10.0+cpu
- **Separator version:** 0.30.2
- **Model:** `3_HP-Vocal-UVR.pth`
- **Audio:** `C:\Users\soloo\Documents\15_59_49_1_22_2026_.wav` (1.93s)
- **Output:** `C:\Users\soloo\CODE\audio-separator-cxfreeze\bench_cpu_210`
- **Wall time:** ~25.78s (START 13:22:07.67 / END 13:22:33.45)
- **Reported separation duration:** 00:00:22
- **Runtime:** Windows 10 (AMD64), Python 3.10.0rc2, ONNX Runtime 1.23.2

- **Date:** 2026-01-23
- **Build:** `audio-separator-win-cuda` (frozen)
- **PyTorch:** 2.10.0+cu126
- **Separator version:** 0.30.2
- **Model:** `3_HP-Vocal-UVR.pth`
- **Audio:** `C:\Users\soloo\Documents\15_59_49_1_22_2026_.wav` (1.93s)
- **Output:** `C:\Users\soloo\CODE\audio-separator-cxfreeze\bench_cuda_210`
- **Wall time:** ~46.18s (START 13:50:10.33 / END 13:50:56.51)
- **Reported separation duration:** 00:00:29
- **Runtime:** Windows 10 (AMD64), Python 3.10.0rc2, ONNX Runtime GPU 1.23.2, CUDA enabled

- **Date:** 2026-01-23
- **Build:** `audio-separator-win-cuda` (frozen)
- **PyTorch:** 2.10.0+cu126
- **Separator version:** 0.30.2
- **Model:** `3_HP-Vocal-UVR.pth`
- **Audio:** `C:\Users\soloo\Downloads\Jon Hamm Tiktok_Reels Club dance meme video from Your Friends  Neighbors jonhamm viraldance.mp3` (38.94s)
- **Output:** `C:\Users\soloo\CODE\audio-separator-cxfreeze\bench_cuda_210_long`
- **Wall time:** ~45.91s (START 14:15:07.56 / END 14:15:53.47)
- **Reported separation duration:** 00:00:18
- **Runtime:** Windows 10 (AMD64), Python 3.10.0rc2, ONNX Runtime GPU 1.23.2, CUDA enabled

- **Date:** 2026-01-23
- **Build:** `audio-separator-win-cpu` (frozen)
- **PyTorch:** 2.10.0+cpu
- **Separator version:** 0.30.2
- **Model:** `3_HP-Vocal-UVR.pth`
- **Audio:** `C:\Users\soloo\Downloads\Jon Hamm Tiktok_Reels Club dance meme video from Your Friends  Neighbors jonhamm viraldance.mp3` (38.94s)
- **Output:** `C:\Users\soloo\CODE\audio-separator-cxfreeze\bench_cpu_210_long`
- **Wall time:** ~67.47s (START 14:19:41.46 / END 14:20:48.93)
- **Reported separation duration:** 00:01:04
- **Runtime:** Windows 10 (AMD64), Python 3.10.0rc2, ONNX Runtime 1.23.2

- **Date:** 2026-01-23
- **Build:** `audio-separator-win-cuda` (frozen, warm run)
- **PyTorch:** 2.10.0+cu126
- **Separator version:** 0.30.2
- **Model:** `3_HP-Vocal-UVR.pth`
- **Audio:** `C:\Users\soloo\Downloads\Jon Hamm Tiktok_Reels Club dance meme video from Your Friends  Neighbors jonhamm viraldance.mp3` (38.94s)
- **Output:** `C:\Users\soloo\CODE\audio-separator-cxfreeze\bench_cuda_210_long_warm`
- **Wall time:** ~21.08s (START 14:23:28.44 / END 14:23:49.52)
- **Reported separation duration:** 00:00:16
- **Runtime:** Windows 10 (AMD64), Python 3.10.0rc2, ONNX Runtime GPU 1.23.2, CUDA enabled

- **Date:** 2026-01-23
- **Build:** `audio-separator-win-cpu` (frozen, warm run)
- **PyTorch:** 2.10.0+cpu
- **Separator version:** 0.30.2
- **Model:** `3_HP-Vocal-UVR.pth`
- **Audio:** `C:\Users\soloo\Downloads\Jon Hamm Tiktok_Reels Club dance meme video from Your Friends  Neighbors jonhamm viraldance.mp3` (38.94s)
- **Output:** `C:\Users\soloo\CODE\audio-separator-cxfreeze\bench_cpu_210_long_warm`
- **Wall time:** ~49.23s (START 14:23:30.36 / END 14:24:19.59)
- **Reported separation duration:** 00:00:45
- **Runtime:** Windows 10 (AMD64), Python 3.10.0rc2, ONNX Runtime 1.23.2

- **Date:** 2026-01-23
- **Build:** `audio-separator-win-cuda` (frozen, WAV, cold)
- **PyTorch:** 2.10.0+cu126
- **Separator version:** 0.30.2
- **Model:** `3_HP-Vocal-UVR.pth`
- **Audio:** `C:\Users\soloo\Downloads\Jon Hamm Tiktok_Reels Club dance meme video from Your Friends  Neighbors jonhamm viraldance.wav` (38.94s)
- **Output:** `C:\Users\soloo\CODE\audio-separator-cxfreeze\bench_cuda_210_long_wav_cold2`
- **Wall time:** ~14.73s (START 14:35:07.07 / END 14:35:21.80)
- **Reported separation duration:** 00:00:10
- **Runtime:** Windows 10 (AMD64), Python 3.10.0rc2, ONNX Runtime GPU 1.23.2, CUDA enabled

- **Date:** 2026-01-23
- **Build:** `audio-separator-win-cuda` (frozen, WAV, warm)
- **PyTorch:** 2.10.0+cu126
- **Separator version:** 0.30.2
- **Model:** `3_HP-Vocal-UVR.pth`
- **Audio:** `C:\Users\soloo\Downloads\Jon Hamm Tiktok_Reels Club dance meme video from Your Friends  Neighbors jonhamm viraldance.wav` (38.94s)
- **Output:** `C:\Users\soloo\CODE\audio-separator-cxfreeze\bench_cuda_210_long_wav_warm2`
- **Wall time:** ~12.99s (START 14:35:21.80 / END 14:35:34.79)
- **Reported separation duration:** 00:00:09
- **Runtime:** Windows 10 (AMD64), Python 3.10.0rc2, ONNX Runtime GPU 1.23.2, CUDA enabled

- **Date:** 2026-01-23
- **Build:** `audio-separator-win-cpu` (frozen, WAV)
- **PyTorch:** 2.10.0+cpu
- **Separator version:** 0.30.2
- **Model:** `3_HP-Vocal-UVR.pth`
- **Audio:** `C:\Users\soloo\Downloads\Jon Hamm Tiktok_Reels Club dance meme video from Your Friends  Neighbors jonhamm viraldance.wav` (38.94s)
- **Output:** `C:\Users\soloo\CODE\audio-separator-cxfreeze\bench_cpu_210_long_wav`
- **Wall time:** ~46.82s (START 14:24:43.59 / END 14:25:30.41)
- **Reported separation duration:** 00:00:43
- **Runtime:** Windows 10 (AMD64), Python 3.10.0rc2, ONNX Runtime 1.23.2

- **Date:** 2026-01-23
- **Build:** `audio-separator-win-cuda` (v1.3.3 release, WAV)
- **PyTorch:** 2.5.1+cu124
- **Separator version:** 0.41.0
- **Model:** `3_HP-Vocal-UVR.pth`
- **Audio:** `C:\Users\soloo\Downloads\Jon Hamm Tiktok_Reels Club dance meme video from Your Friends  Neighbors jonhamm viraldance.wav` (38.94s)
- **Output:** `C:\Users\soloo\CODE\audio-separator-cxfreeze\bench_cuda_251_long_wav`
- **Wall time:** ~58.71s (START 14:31:45.92 / END 14:32:44.63)
- **Reported separation duration:** 00:00:34
- **Runtime:** Windows 10 (AMD64), Python 3.10.11, ONNX Runtime GPU 1.23.2, CUDA enabled

## 5. Test Python Package Distribution

### Build and Test Local Package
```batch
cd /d "%REPO_ROOT%"

# Build package
uv build

# Test CPU installation
python -m venv test-package-cpu
test-package-cpu\Scripts\pip install dist\audio_separator_cxfreeze-1.3.4-py3-none-any.whl
test-package-cpu\Scripts\audio-separator --version

# Test CUDA installation
python -m venv test-package-cuda
test-package-cuda\Scripts\pip install dist\audio_separator_cxfreeze-1.3.4-py3-none-any.whl[cuda]
test-package-cuda\Scripts\audio-separator --version

# Test DirectML installation
python -m venv test-package-dml
test-package-dml\Scripts\pip install dist\audio_separator_cxfreeze-1.3.4-py3-none-any.whl[directml]
test-package-dml\Scripts\audio-separator --version
```

## 6. Prepare for GitHub Release

### Create Release Archives
```batch
cd /d "%REPO_ROOT%"

# Create archives like GitHub Actions
tar -a -c -f audio-separator-win-cpu.zip audio-separator-win-cpu
tar -a -c -f audio-separator-win-cuda.zip audio-separator-win-cuda
tar -a -c -f audio-separator-win-dml.zip audio-separator-win-dml

# List files
dir *.zip
```

### Push and Tag for GitHub Actions
```batch
cd /d "%REPO_ROOT%"

# Commit changes
git add .
git commit -m "Add DirectML support and complete multi-GPU builds"

# Push to main branch
git push origin main

# Create and push tag to trigger GitHub Actions
git tag v1.3.4-win
git push origin v1.3.4-win
```

## Expected Results

### Build Sizes
- **CPU**: ~500MB (zip)
- **CUDA**: ~1.5GB (zip)
- **DirectML**: ~500MB (zip)

### Performance (Approximate)
- **CPU**: 20-25 seconds per separation
- **CUDA**: 5-8 seconds per separation (3-4x faster)
- **DirectML**: 8-12 seconds per separation (AMD GPUs)

### Test Output Directories
- `test_cpu_output/` - CPU separation results
- `test_cuda_output/` - CUDA separation results
- `test_dml_output/` - DirectML separation results
- `test_apollo_cpu.wav` - CPU Apollo restoration
- `test_apollo_cuda.wav` - CUDA Apollo restoration

## Troubleshooting

### Common Issues
1. **"UV not found"**: `pip install uv`
2. **"Python not found"**: Install Python 3.10
3. **Build fails**: Check if venvs are cleaned: `rmdir /s /q .venv-*`
4. **Missing models**: Verify model paths exist
5. **GPU not detected**: Check `audio-separator.exe --env_info`

## 7. Test BS-RoFormer Style PyTorch 2.10.0 Build

### Why Test BS-RoFormer Style?
- **Discovery**: BS-RoFormer project uses PyTorch 2.10.0+cu126 successfully
- **Key Difference**: They use comprehensive torch subpackages in cxfreeze
- **Pure pip**: Uses pip directly to avoid UV configuration conflicts
- **Hypothesis**: Missing torch packages + UV config conflicts caused our failures
- **Goal**: Determine if their methodology fixes the path length issues

### BS-RoFormer Style Build
```batch
cd /d "%REPO_ROOT%"

# Clean and run BS-RoFormer style build
rmdir /s /q .venv-bsroformer audio-separator-bsroformer 2>nul
build\scripts\build-bsroformer-style.bat
```

### What Makes It Different?
- **PyTorch**: 2.10.0+cu126 (same as BS-RoFormer)
- **Torch Packages**: Comprehensive list including `torch._C`, `torch._jit_internal`, etc.
- **Installation Order**: cx_Freeze first, then PyTorch, then dependencies
- **LLVMLite Copying**: Both binding directory AND libs folder

### Test the Build
```batch
# Test BS-RoFormer style build
cd /d "%REPO_ROOT%\audio-separator-bsroformer"
audio-separator.exe --version
audio-separator.exe --env_info | findstr cuda
audio-separator.exe -m 3_HP-Vocal-UVR.pth --model_file_dir "%MODEL_DIR%" "%AUDIO_FILE%" --output_dir test_bsroformer --use_cuda
```

### Expected Results
- **Success**: Proves PyTorch 2.10.0 can work with right methodology
- **Performance Gain**: Should be faster than PyTorch 2.5.1 (potentially 5-10%)
- **CI/CD Ready**: Can update GitHub Actions to use PyTorch 2.10.0

## 8. Test Experimental PyTorch 2.9 Build

### Why Test PyTorch 2.9?
- **Potential**: 10-20% performance improvement over 2.5.1
- **Risk**: May have path length issues like 2.10.0
- **Purpose**: Determine if newer PyTorch provides meaningful speedup

### Experimental Build
```batch
cd /d "%REPO_ROOT%"

# Clean and run experimental build
rmdir /s /q .venv-cuda-exp audio-separator-win-cuda-exp 2>nul
build\scripts\build-with-uv-experimental.bat
```

### Compare Performance
```batch
# Test PyTorch 2.5.1 (production)
cd /d "%REPO_ROOT%\audio-separator-win-cuda"
echo PyTorch 2.5.1: && echo %time% && audio-separator.exe -m 3_HP-Vocal-UVR.pth --model_file_dir "%MODEL_DIR%" "%AUDIO_FILE%" --output_dir bench_251 --use_cuda && echo %time%

# Test PyTorch 2.9.0 (experimental)
cd /d "%REPO_ROOT%\audio-separator-win-cuda-exp"
echo PyTorch 2.9.0: && echo %time% && audio-separator.exe -m 3_HP-Vocal-UVR.pth --model_file_dir "%MODEL_DIR%" "%AUDIO_FILE%" --output_dir bench_290 --use_cuda && echo %time%
```

### Expected Results
- **PyTorch 2.9 Success**: 10-20% faster than 2.5.1
- **PyTorch 2.9 Failure**: Path length errors during build
- **Decision**: If successful and faster, upgrade production builds

## Expected Results Summary

### Build Sizes
- **CPU**: ~500MB (zip)
- **CUDA 2.5.1**: ~1.5GB (zip)
- **DirectML**: ~500MB (zip)
- **CUDA 2.9 (exp)**: ~1.6GB (if successful)

### Performance (Approximate, PyTorch 2.5.1 baseline)
- **CPU**: 22 seconds per separation
- **CUDA**: 6 seconds per separation (3.7x faster)
- **DirectML**: 10 seconds per separation (2.2x faster)
- **CUDA 2.9 (exp)**: 5-6 seconds (potential 10-15% improvement)

### Clean Everything for Fresh Start
```batch
cd /d "%REPO_ROOT%"
rmdir /s /q .venv-* audio-separator-win-* test_* bench_* dist build 2>nul
```

This comprehensive testing suite covers all functionality: builds, frozen executables, performance benchmarking, and package distribution.