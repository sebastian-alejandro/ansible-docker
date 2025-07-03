#!/usr/bin/env python3
"""
==================================
Utility Functions and Classes
Shared resources for automation scripts
==================================
"""

import platform

class Colors:
    """ANSI color codes for terminal output"""
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    CYAN = '\033[0;36m'
    NC = '\033[0m'  # No Color

    @staticmethod
    def init():
        """Initialize colorama for Windows if available"""
        if platform.system() == "Windows":
            try:
                import colorama
                colorama.init()
            except ImportError:
                # If colorama is not available, disable colors
                for attr in dir(Colors):
                    if not attr.startswith("__") and isinstance(getattr(Colors, attr), str):
                        setattr(Colors, attr, "")
