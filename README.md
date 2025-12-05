# Audio Separator CxFreeze

Frozen standalone binary of [python-audio-separator](https://github.com/karaokenerds/python-audio-separator).

Supports:
- Wind instrument separation (17_HP-Wind_Inst-UVR.pth)
- And many other UVR/VR/MDX models

## Usage

```bash
./audio-separator -m "17_HP-Wind_Inst-UVR.pth" -o output_dir input.wav
```

## Credits
- [karaokenerds/python-audio-separator](https://github.com/karaokenerds/python-audio-separator)
- [Anjok07/ultimatevocalremovergui](https://github.com/Anjok07/ultimatevocalremovergui) - Original UVR
