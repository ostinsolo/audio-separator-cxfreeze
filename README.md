# Audio Separator CxFreeze

Frozen standalone binary of [python-audio-separator](https://github.com/karaokenerds/python-audio-separator).

## GPU Support

| Platform | Variant | GPU Acceleration |
|----------|---------|------------------|
| **macOS ARM** | `audio-separator-mac-arm.zip` | ✅ MPS (Metal) |
| **macOS Intel** | `audio-separator-mac-intel.zip` | ❌ CPU only |
| **Windows** | `audio-separator-win-cuda.zip` | ✅ CUDA 12.1 |
| **Windows** | `audio-separator-win-cpu.zip` | ❌ CPU only |

## Supported Models

- **VR Architecture**: Wind instruments, vocals, HP models
  - `17_HP-Wind_Inst-UVR.pth` - Wind instrument separation
  - `2_HP-UVR.pth` - Vocals/Instrumental
- **MDX Architecture**: Various vocal/instrumental models
- **MDXC Architecture**: BS-Roformer models
- **Demucs**: Multi-stem separation

## Usage

```bash
# Wind instrument separation
./audio-separator -m "17_HP-Wind_Inst-UVR.pth" --output_dir output input.wav

# Vocals separation
./audio-separator -m "2_HP-UVR.pth" --output_dir output input.wav

# List available models
./audio-separator -l
```

## Credits

- [karaokenerds/python-audio-separator](https://github.com/karaokenerds/python-audio-separator)
- [Anjok07/ultimatevocalremovergui](https://github.com/Anjok07/ultimatevocalremovergui) - Original UVR
