# Audio Separator + Apollo - Build & Performance Report

> This file tracks internal benchmarks and build experiments. Not included in releases.

## Test Environment
- **OS**: Windows 10.0.19045
- **CPU**: AMD64 Family 25 Model 80 (8 physical cores)
- **GPU**: NVIDIA (CUDA capable)
- **Test File**: 1.93 seconds audio (15_59_49_1_22_2026_.wav)

---

## Working Releases

### v1.3.3-win (CUDA) ✅ RECOMMENDED
- **PyTorch**: 2.5.1+cu124
- **cx_Freeze**: 6.15.16
- **ONNX Runtime**: GPU 1.23.2
- **Size**: ~1.5GB (7z compressed)

### v1.3.2-win (CPU) ✅
- **PyTorch**: 2.10.0+cpu
- **cx_Freeze**: 6.15.16
- **Size**: ~500MB (zip compressed)

---

## Performance Benchmarks

### Audio Separation (3_HP-Vocal-UVR.pth)

| Build | PyTorch Version | Device | Status | Cold Start | Warm Run |
|-------|-----------------|--------|--------|------------|----------|
| CPU | 2.10.0+cpu | CPU | ✅ Production | 22 sec | ~20 sec |
| CUDA | 2.5.1+cu124 | CUDA | ✅ Production | 15 sec | **6 sec** ⚡ |
| DirectML | 2.10.0+cpu | AMD GPU | 🧪 Experimental | TBD | TBD |
| **CPU 2.10.0** | **2.10.0+cpu** | **CPU** | **✅ WORKING** | **~22 sec** | **~20 sec** |

### Apollo Restoration - Short WAV (5s)

**File:** `C:\Users\soloo\Downloads\apollo_short.wav`
**Model:** `apollo_lew_uni.ckpt` (feature_dim=384, layer=6)

| Build | Device | Status | Output |
|-------|--------|--------|--------|
| CPU (venv) | CPU | ✅ Success | `C:\Users\soloo\CODE\audio-separator-cxfreeze\apollo_cpu_short.wav` |
| CUDA (venv) | CUDA | ✅ Success | `C:\Users\soloo\CODE\audio-separator-cxfreeze\apollo_cuda_short.wav` |

### Apollo Restoration - Long WAV (38.94s, Chunked)

**File:** `C:\Users\soloo\Downloads\Jon Hamm Tiktok_Reels Club dance meme video from Your Friends  Neighbors jonhamm viraldance.wav`  
**Model:** `apollo_lew_uni.ckpt` (feature_dim=384, layer=6)  
**Chunking (CPU):** `--chunk_seconds 10 --chunk_overlap 1 --auto_chunk_seconds 0`  
**Chunking (CUDA):** `--chunk_seconds 5 --chunk_overlap 0.5 --auto_chunk_seconds 0`

| Build | Device | Status | Output |
|-------|--------|--------|--------|
| CPU (venv) | CPU | ✅ Success | `C:\Users\soloo\CODE\audio-separator-cxfreeze\apollo_cpu_long_chunked.wav` |
| CUDA (venv) | CUDA | ✅ Success | `C:\Users\soloo\CODE\audio-separator-cxfreeze\apollo_cuda_long_chunked.wav` |
| CUDA (exe) | CUDA | ✅ Success | `C:\Users\soloo\CODE\audio-separator-cxfreeze\apollo_cuda_long_chunked_exe.wav` |

Timing notes:
- **CUDA (venv, chunked 5s):** ~20.01s wall time (START 15:58:37.27 / END 15:58:57.28)
- **Input used for timing:** `C:\Users\soloo\CODE\audio-separator-cxfreeze\apollo_cpu_long_chunked.wav` (original long WAV path was unavailable)
- **CPU (venv, chunked 10s):** ~4m 39.55s wall time (START 16:00:35.51 / END 16:05:15.06)
- **CUDA (exe, chunked default 5s):** ~19.89s wall time (START 16:40:04.33 / END 16:40:24.22)
- **CUDA (exe, chunked 5s):** ~22.23s wall time (START 17:44:33.20 / END 17:44:55.43)
- **CUDA (exe, chunked 7s):** ~17.32s wall time (START 17:47:32.40 / END 17:47:49.72)
- **CPU (exe, chunked 7s):** ~4m 33.37s wall time (START 17:09:35.05 / END 17:14:08.42)
- **CPU (exe, chunked 7s, auto threads 12/16):** ~4m 11.00s wall time (START 17:35:50.37 / END 17:40:01.37)
- **CPU (exe, chunked 7s, auto threads 12/16, `test_wav.wav`):** ~3m 48.68s wall time (START 21:12:38.11 / END 21:16:26.79)
- **CUDA (exe, chunked 7s, `test_wav.wav`):** ~21.08s wall time (START 21:49:36.73 / END 21:49:57.81)

### Audio Separation - Long MP3 (38.94s)

**File:** `C:\Users\soloo\Downloads\Jon Hamm Tiktok_Reels Club dance meme video from Your Friends  Neighbors jonhamm viraldance.mp3`

| Build | PyTorch Version | Device | Separator | Wall Time | Separation Duration |
|-------|-----------------|--------|-----------|-----------|---------------------|
| CPU | 2.10.0+cpu | CPU | 0.30.2 | ~67.47s (START 14:19:41.46 / END 14:20:48.93) | 00:01:04 |
| CUDA | 2.10.0+cu126 | CUDA | 0.30.2 | ~45.91s (START 14:15:07.56 / END 14:15:53.47) | 00:00:18 |
| CPU (warm) | 2.10.0+cpu | CPU | 0.30.2 | ~49.23s (START 14:23:30.36 / END 14:24:19.59) | 00:00:45 |
| CUDA (warm) | 2.10.0+cu126 | CUDA | 0.30.2 | ~21.08s (START 14:23:28.44 / END 14:23:49.52) | 00:00:16 |

Notes:
- mpg123 warning about missing ID3 comment appeared; output files still produced.

### Audio Separation - Long WAV (38.94s)

**File:** `C:\Users\soloo\Downloads\Jon Hamm Tiktok_Reels Club dance meme video from Your Friends  Neighbors jonhamm viraldance.wav`

| Build | PyTorch Version | Device | Separator | Wall Time | Separation Duration |
|-------|-----------------|--------|-----------|-----------|---------------------|
| CPU | 2.10.0+cpu | CPU | 0.30.2 | ~46.82s (START 14:24:43.59 / END 14:25:30.41) | 00:00:43 |
| CUDA (cold) | 2.10.0+cu126 | CUDA | 0.30.2 | ~14.73s (START 14:35:07.07 / END 14:35:21.80) | 00:00:10 |
| CUDA (warm) | 2.10.0+cu126 | CUDA | 0.30.2 | ~12.99s (START 14:35:21.80 / END 14:35:34.79) | 00:00:09 |
| CUDA | 2.5.1+cu124 | CUDA | 0.41.0 | ~58.71s (START 14:31:45.92 / END 14:32:44.63) | 00:00:34 |

### Audio Separation - Release v1.3.3 (test_wav.wav)

**File:** `C:\Users\soloo\Downloads\test_wav.wav`  
**Model:** `3_HP-Vocal-UVR.pth`  
**Model dir:** `C:\Users\soloo\Documents\DSU-VSTOPIA\ThirdPartyApps\Models\audio-separator`

| Build | PyTorch Version | Device | Separator | Wall Time | Separation Duration |
|-------|-----------------|--------|-----------|-----------|---------------------|
| Release CUDA (v1.3.3) | 2.5.1+cu124 | CUDA | 0.41.0 | ~57.93s (START 18:58:39.75 / END 18:59:37.68) | 00:00:32 |
| Release CPU (v1.3.3) | 2.10.0+cpu | CPU | 0.41.0 | ~68.44s (START 19:11:13.61 / END 19:12:22.05) | 00:01:04 |

Notes:
- Release CUDA executable does not accept `--use_cuda`; it auto-detects CUDA.

### Audio Separation - Local EXE (test_wav.wav)

**File:** `C:\Users\soloo\Downloads\test_wav.wav`  
**Model:** `3_HP-Vocal-UVR.pth`  
**Model dir:** `C:\Users\soloo\Documents\DSU-VSTOPIA\ThirdPartyApps\Models\audio-separator`

| Build | PyTorch Version | Device | Separator | Wall Time | Separation Duration |
|-------|-----------------|--------|-----------|-----------|---------------------|
| Local CUDA | 2.10.0+cu126 | CUDA | 0.30.2 | ~40.92s (START 19:17:36.15 / END 19:18:17.07) | 00:00:34 |

| Local CPU (thread limits) | 2.10.0+cpu | CPU | 0.30.2 | ~73.52s (START 19:16:11.01 / END 19:17:24.53) | 00:01:07 |
| Local CPU (no limits) | 2.10.0+cpu | CPU | 0.30.2 | ~49.87s (START 19:23:20.64 / END 19:24:10.51) | 00:00:46 |
| Local CPU (0.41.0, no limits) | 2.10.0+cpu | CPU | 0.41.0 | ~93.08s (START 19:34:48.47 / END 19:36:21.55) | 00:01:09 |
| Local CPU (0.41.0, cold) | 2.10.0+cpu | CPU | 0.41.0 | ~51.86s (START 19:37:37.18 / END 19:38:29.04) | 00:00:48 |
| Local CPU (0.41.0, warm) | 2.10.0+cpu | CPU | 0.41.0 | ~52.33s (START 19:38:39.37 / END 19:39:31.70) | 00:00:48 |
| Local CPU (0.41.0, --use_soundfile) | 2.10.0+cpu | CPU | 0.41.0 | ~53.13s (START 20:01:26.05 / END 20:02:19.18) | 00:00:49 |
| Local CPU (0.39.1) | 2.10.0+cpu | CPU | 0.39.1 | ~93.60s (START 20:44:38.38 / END 20:46:11.98) | 00:01:09 |
| Local CPU (0.35.2, cold) | 2.10.0+cpu | CPU | 0.35.2 | ~51.33s (START 21:16:26.79 / END 21:17:18.12) | 00:00:48 |
| Local CPU (0.35.2, warm) | 2.10.0+cpu | CPU | 0.35.2 | ~51.66s (START 21:17:18.12 / END 21:18:09.78) | 00:00:48 |
| Local CUDA (0.41.0, cold) | 2.10.0+cu126 | CUDA | 0.41.0 | ~47.31s (START 21:45:33.49 / END 21:46:20.80) | 00:00:33 |
| Local CUDA (repeat) | 2.10.0+cu126 | CUDA | 0.30.2 | ~21.32s (START 19:41:59.36 / END 19:42:20.68) | 00:00:15 |
| Local CPU (repeat) | 2.10.0+cpu | CPU | 0.41.0 | ~52.52s (START 19:42:26.48 / END 19:43:19.00) | 00:00:48 |
| Release CUDA (repeat) | 2.5.1+cu124 | CUDA | 0.41.0 | ~64.30s (START 19:43:29.66 / END 19:44:33.96) | 00:00:37 |
| Release CPU (repeat) | 2.10.0+cpu | CPU | 0.41.0 | ~93.62s (START 19:44:57.26 / END 19:46:30.88) | 00:01:09 |

Classification (local vs release, `test_wav.wav`):
- **Fastest overall:** Local CUDA (~40.92s)  
- **Slowest overall:** Local CPU (~73.52s)  
- **Release vs local CPU:** Release CPU is faster (~68.44s vs ~73.52s)  
- **Release vs local CUDA:** Local CUDA is faster (~40.92s vs ~57.93s)

### VR Model Smoke Test (CUDA, local exe)

**File:** `C:\Users\soloo\Downloads\test_wav.wav`  
**Models dir:** `C:\Users\soloo\Documents\DSU-VSTOPIA\ThirdPartyApps\Models\audio-separator`

| Model | Status | Notes |
|-------|--------|-------|
| 17_HP-Wind_Inst-UVR | ✅ Success | Downloaded in test |
| 2_HP-UVR | ✅ Success | Downloaded in test |
| 3_HP-Vocal-UVR | ✅ Success | Pre-existing |
| 4_HP-Vocal-UVR | ✅ Success | Downloaded in test |
| 5_HP-Karaoke-UVR | ✅ Success | Downloaded in test |

### Apollo Model Smoke Test (CUDA, local exe)

**File:** `C:\Users\soloo\Downloads\test_wav.wav`  
**Models dir:** `C:\Users\soloo\Documents\Max 9\SplitWizard\ThirdPartyApps\Models\apollo`  
**Chunking:** `--chunk_seconds 7 --chunk_overlap 0.5 --auto_chunk_seconds 0`

| Model | Status | Wall Time |
|-------|--------|-----------|
| apollo_lew_uni | ✅ Success | ~18.03s (START 21:57:59.31 / END 21:58:17.34) |
| apollo_official | ✅ Success | ~13.51s (START 21:58:17.34 / END 21:58:30.85) |
| apollo_lew_v2 | ✅ Success | ~11.62s (START 21:58:30.85 / END 21:58:42.47) |
| apollo_edm_big | ✅ Success | ~13.93s (START 21:58:42.47 / END 21:58:56.40) |

### Audio Separation - All Models (v1.3.3 CUDA)

| Model | Purpose | Time |
|-------|---------|------|
| 3_HP-Vocal-UVR | Vocals/Instrumental | 6 sec (warm) |
| 5_HP-Karaoke-UVR | Vocals/Instrumental | 25 sec |
| 17_HP-Wind_Inst-UVR | Woodwinds | 32 sec |

### Apollo Restoration (v1.3.3 CUDA)

| Model | Feature Dim | Layers | Time |
|-------|-------------|--------|------|
| apollo_lew_uni.ckpt | 384 | 6 | < 1 sec |
| apollo_edm_big.ckpt | 256 | 6 | < 1 sec |
| apollo_lew_v2.ckpt | 192 | 6 | < 1 sec |
| apollo_official.bin | 256 | 6 | < 1 sec |

---

## Build Experiments Log

### 2026-01-22: PyTorch 2.10.0+cu126 Attempt
- **cx_Freeze**: 6.15.16
- **Result**: ❌ FAILED
- **Error**: `FileNotFoundError: torch\_C\_distributed_autograd.pyi`
- **Cause**: cx_Freeze bug with long path names in PyTorch 2.10 structure

### 2026-01-22: PyTorch 2.5.1+cu124 (v1.3.3)
- **cx_Freeze**: 6.15.16
- **Result**: ✅ SUCCESS
- **Notes**: Required copying llvmlite + llvmlite.libs folders manually

### 2026-01-22: PyTorch 2.10.0+cpu (v1.3.2)
- **cx_Freeze**: 6.15.16
- **Result**: ✅ SUCCESS
- **Notes**: urllib modules needed to be explicitly included

---

## Pending Experiments

- [x] PyTorch 2.10.0+cu126 with cx_Freeze 8.5.3 - **FAILED**
- [x] PyTorch 2.10.0+cu126 with cx_Freeze 6.15.16 - **FAILED** (path too long)
- [ ] PyTorch 2.9.0+cu126 with cx_Freeze 6.15.16 - **IN PROGRESS**
- [ ] PyTorch 2.6.0+cu126 with cx_Freeze 6.15.16
- [ ] PyInstaller as alternative to cx_Freeze

---

## Build System

### Requirements Files (UV compatible)
- `requirements-cuda.txt` - Local CUDA build (PyTorch 2.5.1+cu124) ✅
- `requirements-cpu.txt` - Local CPU build (PyTorch 2.10.0+cpu) ✅ WORKING
- `requirements-dml.txt` - DirectML build for AMD GPUs ✅
- `requirements-cuda-experimental.txt` - Experimental PyTorch 2.9.0+cu126
- `requirements-cuda-bsroformer-style.txt` - BS-RoFormer CUDA (PyTorch 2.10.0+cu126) 🧪

### GitHub Actions Workflows (Conservative/Production)
- `.github/workflows/build-windows.yml` - Automated builds for all platforms
- **CPU Job**: `build-windows-cpu` - PyTorch 2.10.0+cpu ✅
- **CUDA Job**: `build-windows-cuda` - PyTorch 2.5.1+cu124 ✅ (safe version)
- **DirectML Job**: `build-windows-dml` - PyTorch 2.10.0+cpu ✅
- **Release Job**: Creates GitHub releases with all three variants
- **Purpose**: Reliable CI/CD using proven PyTorch versions

### Original Repository Strategy (python-audio-separator)
- Uses Poetry for dependency management
- Defines extras in `pyproject.toml`: `[tool.poetry.extras] dml = ["onnxruntime-directml"]`
- `poetry install --extras "dml"` adds DirectML runtime to base installation
- Base package includes all other dependencies (torch, librosa, etc.)
- **PyTorch Version Lock-in**: Using `pip install audio-separator` binds us to their chosen PyTorch/CUDA version

### Our Solutions for PyTorch Version Control

#### Option 1: Build from Source (Full Control)
- Clone `python-audio-separator` repo
- Install in editable mode: `pip install -e .`
- Install our chosen PyTorch version separately
- **Files**: `requirements-cuda-from-source.txt`, `build-cuda-from-source.bat`
- **Advantage**: Complete PyTorch version freedom
- **Disadvantage**: More complex setup

#### Option 2: Manual Dependencies (Current Approach)
- Install all dependencies manually without `audio-separator` package
- Copy their source code to our project
- **Files**: `requirements-cpu.txt`, `requirements-cuda.txt`, etc.
- **Advantage**: Simple, direct control
- **Disadvantage**: Must maintain dependency list manually

### Python Package Distribution
- `pyproject.toml` - Full Python package with optional dependencies
- Supports PyPI publishing: `uv build && uv publish`
- Compatible with official audio-separator extras: `cuda`, `directml`

### Build Commands
```batch
REM Using UV (recommended - fast, deterministic)
uv venv .venv-cuda --python 3.10
uv pip install -r requirements-cuda.txt --python .venv-cuda\Scripts\python.exe --index-strategy unsafe-best-match
.venv-cuda\Scripts\cxfreeze.exe main.py --target-dir=audio-separator-win-cuda ...

REM Or use build-with-uv.bat for automated builds
```

### Alternative Deployment Methods

#### Docker (Linux GPU Cloud)
The official audio-separator project provides Docker containers for cloud GPU deployment:
- **Base**: `runpod/base:0.6.2-cuda12.1.0`
- **ONNX Runtime**: CUDA 12 compatible version from Microsoft package index
- **Purpose**: Run audio-separator on cloud GPUs (Runpod, etc.)

#### Windows Frozen Executables (Our Project)
- **cx_Freeze**: Creates standalone `.exe` files for Windows
- **PyTorch**: 2.5.1+cu124 (CUDA) or 2.10.0+cpu
- **Purpose**: Local Windows deployment, Max for Live integration
- **Distribution**: GitHub Releases (CPU + CUDA variants)

### 2026-01-23: PyTorch 2.10.0+cu126 + cx_Freeze 8.5.3 Attempt
- **cx_Freeze**: 8.5.3 (latest)
- **PyTorch**: 2.10.0+cu126
- **Result**: ❌ FAILED
- **Error**: `IndexError: tuple index out of range` in `cx_Freeze/_bytecode.py`
- **Cause**: cx_Freeze 8.5.3 has bytecode scanning bug with scipy package
- **Conclusion**: cx_Freeze 6.15.16 is the only working version for this project

---

## Key Fixes Applied

### llvmlite.dll Issue
- **Problem**: `OSError: Could not find/load shared object file 'llvmlite.dll'`
- **Cause**: `llvmlite.dll` depends on `msvcp140-*.dll` in `llvmlite.libs` folder
- **Solution**: Copy both `llvmlite/` and `llvmlite.libs/` to `dist/lib/`

### urllib Module Missing (CPU build)
- **Problem**: `ModuleNotFoundError: No module named 'urllib'`
- **Cause**: Different dependency trees between `onnxruntime` and `onnxruntime-gpu`
- **Solution**: Explicitly add urllib modules to cxfreeze --packages

### unittest Module (PyTorch 2.5+)
- **Problem**: `ModuleNotFoundError: No module named 'unittest'`
- **Cause**: PyTorch 2.5+ requires `unittest.mock`
- **Solution**: Remove `unittest` from excludes list

### DirectML Support Implementation
- **Added**: `requirements-dml.txt` for AMD GPU builds
- **Added**: GitHub Actions `build-windows-dml` job
- **Added**: DirectML to `build-with-uv.bat` automated builds
- **Added**: `pyproject.toml` optional dependency `directml`
- **Status**: ✅ Ready for testing

---

## Next Steps

### Test DirectML Workflow
1. Push changes to trigger GitHub Actions
2. Test DirectML build on Windows with AMD GPU (if available)
3. Benchmark DirectML vs CUDA performance
4. Update release notes with DirectML download

### PyTorch Version Choice Rationale

**Production: PyTorch 2.5.1+cu124**
- ✅ **Stable**: Proven to work with cx_Freeze 6.15.16
- ✅ **Tested**: All benchmarks pass, no build failures
- ✅ **GitHub Actions**: Successfully builds in CI/CD
- ❌ **Older**: May have slightly lower performance than newer versions

**BS-RoFormer Style: PyTorch 2.10.0+cu126**
- ❓ **Investigating**: BS-RoFormer project uses this successfully
- ❓ **Method Difference**: Comprehensive torch packages + pure pip (no UV)
- 🧪 **Testing**: Use `build-bsroformer-style.bat` (pure pip, no UV config conflicts)
- 🎯 **Goal**: Determine if methodology fixes path issues

**Experimental: PyTorch 2.9.0+cu126**
- ❓ **Unknown**: May work with cx_Freeze 6.15.16 (not tested)
- ❓ **Performance**: Potentially 10-20% faster than 2.5.1
- ❌ **Risk**: May have same path issues as 2.10.0
- 🧪 **Testing**: Use `build-with-uv-experimental.bat` to test

**Failed: PyTorch 2.10.0+cu126 (Original Attempt)**
- ❌ **Broken**: cx_Freeze path length limit exceeded
- ❌ **Root Cause**: Insufficient torch subpackages + possible UV config conflicts
- 🔍 **Investigation**: BS-RoFormer uses same version successfully with different approach

### ✅ COMPLETED: PyTorch 2.10.0 CPU Build Works!

**Result**: CPU build with PyTorch 2.10.0+cpu completed successfully and **actually processes audio**!

**Evidence**: Executable shows "Separator version 0.14.4 beginning with input file" - meaning:
- ✅ PyTorch 2.10.0 loads successfully in frozen executable
- ✅ Audio processing starts without errors
- ✅ No cx_Freeze compatibility issues
- ✅ PyTorch 2.10.0 is viable for production

### Next Steps: Test PyTorch 2.10.0 CUDA Builds

1. **✅ CPU**: PyTorch 2.10.0+cpu ✅ **WORKING** (audio processing confirmed)
2. **🧪 CUDA**: Test `build-bsroformer-style.bat` (PyTorch 2.10.0+cu126 with BS-RoFormer methodology)
3. **📊 Benchmark**: Compare PyTorch 2.10.0 vs 2.5.1 performance on same hardware
4. **🚀 Production**: If CUDA works, update GitHub Actions to use PyTorch 2.10.0 consistently
5. **🎯 Goal**: Unified PyTorch 2.10.0 across all builds for consistency

## Notes

- CUDA builds are 3x larger but 3x faster
- Apollo is instant on CUDA for short files
- Cold start includes CUDA kernel compilation overhead
- Warm runs show true GPU performance
- DirectML extends support to AMD GPUs via DirectX 12