#!/usr/bin/env python3
"""
Audio Separator + Apollo frozen executable entry point.

Supports:
1. Audio Separation (UVR/VR/MDX/Demucs/Roformer models)
2. Audio Restoration with Apollo (converts lossy to higher quality)

GPU Support:
- CUDA (NVIDIA) on Windows/Linux
- MPS (Metal) on Apple Silicon (separation only, Apollo uses CPU)
- CPU fallback everywhere

Based on:
- https://github.com/karaokenerds/python-audio-separator
- https://github.com/JusperLee/Apollo
"""
import sys
import os

# Fix for cx_Freeze - must be before other imports
if getattr(sys, 'frozen', False):
    sys._MEIPASS = os.path.dirname(sys.executable)

def main():
    """Main entry point - routes to separator or Apollo based on args"""
    # Check if Apollo mode requested
    if len(sys.argv) > 1 and sys.argv[1] == '--apollo':
        # Remove --apollo flag and run Apollo
        sys.argv.pop(1)
        from apollo.apollo_separator import main as apollo_main
        apollo_main()
    else:
        # Default: audio-separator
        from audio_separator.utils.cli import main as separator_main
        separator_main()

if __name__ == "__main__":
    main()
