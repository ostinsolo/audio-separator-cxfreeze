#!/usr/bin/env python3
"""
Audio Separator frozen executable entry point.
Supports UVR/VR/MDX models for wind instrument and other separations.

GPU Support:
- CUDA (NVIDIA) on Windows/Linux
- MPS (Metal) on Apple Silicon
- CPU fallback everywhere

Based on: https://github.com/karaokenerds/python-audio-separator
"""
import sys
import os

# Fix for cx_Freeze - must be before other imports
if getattr(sys, 'frozen', False):
    sys._MEIPASS = os.path.dirname(sys.executable)

from audio_separator.utils.cli import main

if __name__ == "__main__":
    main()
