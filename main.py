#!/usr/bin/env python3
"""
Audio Separator frozen executable entry point.
Supports UVR/VR/MDX models for wind instrument and other separations.

Patches sys._MEIPASS for cx_Freeze compatibility.
"""
import sys
import os

# cx_Freeze sets sys.frozen but doesn't set _MEIPASS (PyInstaller does)
# Patch it for compatibility with audio_separator's pyrb.py
if getattr(sys, 'frozen', False):
    # For cx_Freeze, use the directory of the executable
    sys._MEIPASS = os.path.dirname(sys.executable)

from audio_separator.utils.cli import main

if __name__ == "__main__":
    main()
