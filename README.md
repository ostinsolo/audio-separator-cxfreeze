# Audio Separator + Apollo CxFreeze

Frozen standalone binary combining:
1. **Audio Separation** - UVR/VR/MDX/Demucs/Roformer models for stem separation
2. **Apollo Restoration** - Convert lossy compressed audio to higher quality

## Downloads

| Platform | CPU | CUDA (NVIDIA) | DirectML (AMD) | Python Package |
|----------|-----|---------------|----------------|----------------|
| Windows | [CPU .zip](https://github.com/ostinsolo/audio-separator-cxfreeze/releases) | [CUDA .zip](https://github.com/ostinsolo/audio-separator-cxfreeze/releases) | [DirectML .zip](https://github.com/ostinsolo/audio-separator-cxfreeze/releases) | `pip install audio-separator-cxfreeze[cuda]` |
| macOS ARM | [ARM .zip](https://github.com/ostinsolo/audio-separator-cxfreeze/releases) | MPS (built-in) | N/A | `pip install audio-separator-cxfreeze` |
| macOS Intel | [Intel .tar.gz](https://github.com/ostinsolo/audio-separator-cxfreeze/releases) | N/A | N/A | `pip install audio-separator-cxfreeze` |

## Features

### Audio Separation
- Wind instrument separation (17_HP-Wind_Inst-UVR.pth)
- Vocals/Instrumental separation
- Drum separation
- And many other UVR models

### Apollo Audio Restoration
- Convert MP3/AAC to higher quality WAV
- Reconstruct lost frequency information
- Multiple model variants for different use cases

## Usage

### Audio Separation (default)
```bash
# CPU
./audio-separator -m "17_HP-Wind_Inst-UVR.pth" --output_dir output input.wav

# CUDA (Windows with NVIDIA GPU)
./audio-separator -m "17_HP-Wind_Inst-UVR.pth" --output_dir output input.wav --use_cuda
```

### Apollo Restoration
```bash
./audio-separator --apollo input.mp3 -o restored.wav -m apollo_lew_uni.ckpt
```

## Apollo Models

| Model | Feature Dim | Best For | Download |
|-------|-------------|----------|----------|
| **Lew Universal** ⭐ | 384 | Any lossy files (RECOMMENDED) | [Download](https://github.com/deton24/Lew-s-vocal-enhancer-for-Apollo-by-JusperLee/releases/tag/uni) |
| Official | 256 | General restoration | [Download](https://huggingface.co/JusperLee/Apollo) |
| Lew V2 | 192 | Lightweight, vocal enhancement | [Download](https://github.com/deton24/Lew-s-vocal-enhancer-for-Apollo-by-JusperLee/releases/tag/2.0) |
| Big/EDM | 256 | EDM/Electronic music | [Download](https://huggingface.co/Politrees/UVR_resources/tree/main/models/Apollo) |

## GPU Support

| Platform | Separation | Apollo | Notes |
|----------|------------|--------|-------|
| macOS ARM (M1/M2/M3) | MPS (Metal) | CPU | Built-in Apple Silicon acceleration |
| macOS Intel | CPU | CPU | No GPU acceleration |
| Windows CPU | CPU | CPU | Works on Intel and AMD CPUs |
| Windows CUDA | **CUDA 12.6** ✅ | **CUDA 12.6** ✅ | NVIDIA GPUs, fastest performance |
| Windows DirectML | **DirectML** 🧪 | **DirectML** 🧪 | AMD GPUs via DirectX 12 |

## Installation Options

### Standalone Executables (Recommended for end users)
Download pre-built binaries from [Releases](https://github.com/ostinsolo/audio-separator-cxfreeze/releases):
- **Windows CPU**: `audio-separator-win-cpu.zip` - Works on any Windows PC
- **Windows CUDA**: `audio-separator-win-cuda.zip` - Requires NVIDIA GPU
- **Windows DirectML**: `audio-separator-win-dml.zip` - Requires AMD GPU

### Python Package (For developers)
```bash
# CPU only
pip install audio-separator-cxfreeze

# With CUDA support (NVIDIA)
pip install audio-separator-cxfreeze[cuda]

# With DirectML support (AMD)
pip install audio-separator-cxfreeze[directml]
```

## Requirements

- **Python Package**: Python 3.10+, pip
- **CPU build**: Windows 10/11 (Intel or AMD CPU) or macOS 10.15+
- **CUDA build**: Windows 10/11 + NVIDIA GPU with CUDA 12.6 drivers
- **DirectML build**: Windows 10/11 + AMD GPU with DirectX 12 support

Local CUDA 2.10 build script (cu126): `build\scripts\build-windows-cuda.bat`

## Credits

- [nomadkaraoke/python-audio-separator](https://github.com/nomadkaraoke/python-audio-separator) - Audio separation
- [Anjok07/ultimatevocalremovergui](https://github.com/Anjok07/ultimatevocalremovergui) - Original UVR
- [JusperLee/Apollo](https://github.com/JusperLee/Apollo) - Apollo audio restoration
- [deton24/Lew's Vocal Enhancer](https://github.com/deton24/Lew-s-vocal-enhancer-for-Apollo-by-JusperLee) - Lew model variants
