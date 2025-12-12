# Audio Separator + Apollo CxFreeze

Frozen standalone binary combining:
1. **Audio Separation** - UVR/VR/MDX/Demucs/Roformer models for stem separation
2. **Apollo Restoration** - Convert lossy compressed audio to higher quality

## Features

### Audio Separation
- Wind instrument separation (17_HP-Wind_Inst-UVR.pth)
- Vocals/Instrumental separation
- Drum separation
- And many other UVR models

### Apollo Audio Restoration (NEW)
- Convert MP3/AAC to higher quality WAV
- Reconstruct lost frequency information
- Multiple model variants for different use cases

## Usage

### Audio Separation (default)
```bash
./audio-separator -m "17_HP-Wind_Inst-UVR.pth" --output_dir output input.wav
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

| Platform | Separation | Apollo |
|----------|------------|--------|
| macOS ARM (M1/M2/M3) | MPS (Metal) | CPU |
| macOS Intel | CPU | CPU |
| Windows | CPU* | CPU |

*CUDA build exceeds GitHub's 2GB limit

## Credits

- [karaokenerds/python-audio-separator](https://github.com/karaokenerds/python-audio-separator) - Audio separation
- [Anjok07/ultimatevocalremovergui](https://github.com/Anjok07/ultimatevocalremovergui) - Original UVR
- [JusperLee/Apollo](https://github.com/JusperLee/Apollo) - Apollo audio restoration
- [deton24/Lew's Vocal Enhancer](https://github.com/deton24/Lew-s-vocal-enhancer-for-Apollo-by-JusperLee) - Lew model variants
