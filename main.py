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

# =============================================================================
# CRITICAL FIX for cx_Freeze + PyTorch 2.x compatibility
# =============================================================================
# PyTorch 2.x's torch.compiler.config module uses inspect.getsourcelines()
# during import, which fails in frozen executables because source code
# isn't available. This monkey-patch must run BEFORE any torch imports.
# =============================================================================
if getattr(sys, 'frozen', False):
    sys._MEIPASS = os.path.dirname(sys.executable)
    
    # Monkey-patch inspect to handle frozen modules gracefully
    import inspect
    _original_getsourcelines = inspect.getsourcelines
    _original_getsource = inspect.getsource
    _original_findsource = inspect.findsource
    
    def _safe_getsourcelines(obj):
        try:
            return _original_getsourcelines(obj)
        except OSError:
            # Return empty source for frozen modules
            return ([''], 0)
    
    def _safe_getsource(obj):
        try:
            return _original_getsource(obj)
        except OSError:
            return ''
    
    def _safe_findsource(obj):
        try:
            return _original_findsource(obj)
        except OSError:
            return ([''], 0)
    
    inspect.getsourcelines = _safe_getsourcelines
    inspect.getsource = _safe_getsource
    inspect.findsource = _safe_findsource

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
