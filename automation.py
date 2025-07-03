#!/usr/bin/env python3
"""
===================================
Main Automation Script
Unified CI/CD automation and testing
===================================
"""

import subprocess
import sys
import os
import argparse
from typing import List, Optional, Tuple

from utils import Colors

class AutomationRunner:
    """Main automation runner"""
    
    def __init__(self):
        self.scripts = {
            'test': 'test_functional_ci.py',
            'validate': 'pre_commit_check.py', 
            'commit': 'version_control.py'
        }
    
    def print_status(self, message: str, color: str = Colors.YELLOW):
        """Print a colored status message"""
        print(f"{color}{message}{Colors.NC}")

    def _check_command_exists(self, command: str) -> Tuple[bool, str]:
        """Check if a command exists and return its version."""
        try:
            result = subprocess.run([command, "--version"], capture_output=True, text=True, check=True)
            return True, result.stdout.strip()
        except (subprocess.CalledProcessError, FileNotFoundError):
            return False, ""

    def check_dependencies(self) -> bool:
        """Check if required dependencies are available"""
        self.print_status("🔍 Checking dependencies...", Colors.BLUE)
        
        if sys.version_info < (3, 6):
            self.print_status("❌ Python 3.6+ is required", Colors.RED)
            return False
        self.print_status(f"✅ Python {sys.version.split()[0]} detected", Colors.GREEN)

        deps_to_check = ["git", "docker"]
        all_deps_ok = True
        for dep in deps_to_check:
            exists, version = self._check_command_exists(dep)
            if exists:
                self.print_status(f"✅ {version} detected", Colors.GREEN)
            else:
                self.print_status(f"❌ {dep.capitalize()} not available", Colors.RED)
                all_deps_ok = False

        try:
            import yaml
            self.print_status("✅ PyYAML available for advanced validation", Colors.GREEN)
        except ImportError:
            self.print_status("⚠️ PyYAML not available - some validations will be skipped", Colors.YELLOW)
            self.print_status("  Install with: pip install pyyaml", Colors.CYAN)

        return all_deps_ok
    
    def run_script(self, script_name: str, args: List[str]) -> bool:
        """Run a specific Python script with arguments"""
        if script_name not in self.scripts:
            self.print_status(f"❌ Unknown script: {script_name}", Colors.RED)
            return False
        
        script_file = self.scripts[script_name]
        
        if not os.path.exists(script_file):
            self.print_status(f"❌ Script not found: {script_file}", Colors.RED)
            return False
        
        self.print_status(f"🚀 Running {script_file} with args: {args}...", Colors.BLUE)
        
        try:
            cmd = [sys.executable, script_file] + args
            result = subprocess.run(cmd, check=True)
            return result.returncode == 0
        except subprocess.CalledProcessError as e:
            self.print_status(f"❌ Error running {script_file}: {e}", Colors.RED)
            return False

def main():
    """Main function to drive the automation"""
    Colors.init()
    runner = AutomationRunner()

    parser = argparse.ArgumentParser(description="Unified CI/CD Automation Script")
    parser.add_argument("action", choices=runner.scripts.keys(), help="The action to perform")
    parser.add_argument("action_args", nargs=argparse.REMAINDER, help="Arguments for the action script")

    args = parser.parse_args()

    if not runner.check_dependencies():
        sys.exit(1)

    if not runner.run_script(args.action, args.action_args):
        sys.exit(1)

    runner.print_status(f"✅ Action '{args.action}' completed successfully.", Colors.GREEN)

if __name__ == "__main__":
    main()
