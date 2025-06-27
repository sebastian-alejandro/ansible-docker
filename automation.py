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
import importlib.util
from typing import List, Optional

class Colors:
    """ANSI color codes for terminal output"""
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    CYAN = '\033[0;36m'
    NC = '\033[0m'  # No Color

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
    
    def check_dependencies(self) -> bool:
        """Check if required dependencies are available"""
        self.print_status("🔍 Checking dependencies...", Colors.BLUE)
        
        # Check Python version
        if sys.version_info < (3, 6):
            self.print_status("❌ Python 3.6+ is required", Colors.RED)
            return False
        
        self.print_status(f"✅ Python {sys.version.split()[0]} detected", Colors.GREEN)
        
        # Check if PyYAML is available (optional)
        try:
            import yaml
            self.print_status("✅ PyYAML available for advanced validation", Colors.GREEN)
        except ImportError:
            self.print_status("⚠️ PyYAML not available - some validations will be skipped", Colors.YELLOW)
            self.print_status("  Install with: pip install pyyaml", Colors.CYAN)
        
        # Check Git
        try:
            result = subprocess.run(["git", "--version"], capture_output=True, text=True)
            if result.returncode == 0:
                git_version = result.stdout.strip()
                self.print_status(f"✅ {git_version} detected", Colors.GREEN)
            else:
                self.print_status("❌ Git not available", Colors.RED)
                return False
        except FileNotFoundError:
            self.print_status("❌ Git not installed", Colors.RED)
            return False
        
        # Check Docker
        try:
            result = subprocess.run(["docker", "--version"], capture_output=True, text=True)
            if result.returncode == 0:
                docker_version = result.stdout.strip()
                self.print_status(f"✅ {docker_version} detected", Colors.GREEN)
            else:
                self.print_status("❌ Docker not available", Colors.RED)
                return False
        except FileNotFoundError:
            self.print_status("❌ Docker not installed", Colors.RED)
            return False
        
        return True
    
    def run_script(self, script_name: str) -> bool:
        """Run a specific Python script"""
        if script_name not in self.scripts:
            self.print_status(f"❌ Unknown script: {script_name}", Colors.RED)
            return False
        
        script_file = self.scripts[script_name]
        
        if not os.path.exists(script_file):
            self.print_status(f"❌ Script not found: {script_file}", Colors.RED)
            return False
        
        self.print_status(f"🚀 Running {script_file}...", Colors.BLUE)
        
        try:
            result = subprocess.run([sys.executable, script_file], check=False)
            return result.returncode == 0
        except Exception as e:
            self.print_status(f"❌ Error running script: {e}", Colors.RED)
            return False
    
    def show_menu(self):
        """Show interactive menu"""
        print(f"\n{Colors.CYAN}🔧 Ansible Docker CI/CD Automation{Colors.NC}")
        print(f"{Colors.BLUE}{'='*50}{Colors.NC}")
        print(f"{Colors.GREEN}1.{Colors.NC} 🧪 Run Functional Tests (CI Mode)")
        print(f"{Colors.GREEN}2.{Colors.NC} 🔍 Run Pre-commit Validation")
        print(f"{Colors.GREEN}3.{Colors.NC} 🚀 Commit and Push Changes")
        print(f"{Colors.GREEN}4.{Colors.NC} 🎯 Full Pipeline (Validate → Test → Commit)")
        print(f"{Colors.GREEN}5.{Colors.NC} ❓ Show Help")
        print(f"{Colors.GREEN}0.{Colors.NC} 🚪 Exit")
        print()
    
    def run_full_pipeline(self) -> bool:
        """Run the complete pipeline"""
        self.print_status("🎯 Running Full CI/CD Pipeline...", Colors.GREEN)
        print()
        
        # Step 1: Validation
        self.print_status("Step 1/3: Pre-commit Validation", Colors.CYAN)
        if not self.run_script('validate'):
            self.print_status("❌ Validation failed - stopping pipeline", Colors.RED)
            return False
        
        print()
        
        # Step 2: Functional Tests
        self.print_status("Step 2/3: Functional Tests", Colors.CYAN)
        if not self.run_script('test'):
            self.print_status("❌ Tests failed - stopping pipeline", Colors.RED)
            return False
        
        print()
        
        # Step 3: Commit and Push
        self.print_status("Step 3/3: Version Control", Colors.CYAN)
        if not self.run_script('commit'):
            self.print_status("❌ Commit failed - stopping pipeline", Colors.RED)
            return False
        
        print()
        self.print_status("🎉 Full pipeline completed successfully!", Colors.GREEN)
        return True
    
    def show_help(self):
        """Show help information"""
        print(f"\n{Colors.CYAN}📚 Help - Ansible Docker CI/CD Automation{Colors.NC}")
        print(f"{Colors.BLUE}{'='*60}{Colors.NC}")
        print()
        print(f"{Colors.YELLOW}🧪 Functional Tests:{Colors.NC}")
        print("  - Builds Docker image in CI mode")
        print("  - Tests container initialization and SSH service")
        print("  - Validates fallback mode compatibility")
        print()
        print(f"{Colors.YELLOW}🔍 Pre-commit Validation:{Colors.NC}")
        print("  - Checks YAML syntax (workflows, docker-compose)")
        print("  - Validates Python syntax")
        print("  - Verifies required files exist")
        print("  - Checks Git repository status")
        print()
        print(f"{Colors.YELLOW}🚀 Version Control:{Colors.NC}")
        print("  - Creates descriptive commit message")
        print("  - Pushes changes to remote repository")
        print("  - Creates version tag")
        print("  - Triggers GitHub Actions workflow")
        print()
        print(f"{Colors.YELLOW}🎯 Full Pipeline:{Colors.NC}")
        print("  - Runs all steps in sequence")
        print("  - Stops on first failure")
        print("  - Ensures code quality before deployment")
        print()
        print(f"{Colors.YELLOW}📋 Available Scripts:{Colors.NC}")
        for action, script in self.scripts.items():
            print(f"  - {action}: {script}")
        print()
        print(f"{Colors.YELLOW}💡 Usage Tips:{Colors.NC}")
        print("  - Run validation before making changes")
        print("  - Test locally before committing")
        print("  - Use full pipeline for complete automation")
        print()
    
    def run_interactive(self):
        """Run interactive mode"""
        if not self.check_dependencies():
            self.print_status("❌ Dependency check failed", Colors.RED)
            return False
        
        while True:
            self.show_menu()
            
            try:
                choice = input(f"{Colors.YELLOW}Select option (0-5): {Colors.NC}").strip()
                
                if choice == '0':
                    self.print_status("👋 Goodbye!", Colors.CYAN)
                    break
                elif choice == '1':
                    self.run_script('test')
                elif choice == '2':
                    self.run_script('validate')
                elif choice == '3':
                    self.run_script('commit')
                elif choice == '4':
                    self.run_full_pipeline()
                elif choice == '5':
                    self.show_help()
                else:
                    self.print_status("❌ Invalid option", Colors.RED)
                
                if choice != '5':  # Don't pause after help
                    input(f"\n{Colors.CYAN}Press Enter to continue...{Colors.NC}")
                
            except KeyboardInterrupt:
                print()
                self.print_status("👋 Goodbye!", Colors.CYAN)
                break
            except EOFError:
                print()
                self.print_status("👋 Goodbye!", Colors.CYAN)
                break
    
    def run_command_line(self, args: List[str]):
        """Run command line mode"""
        if not self.check_dependencies():
            self.print_status("❌ Dependency check failed", Colors.RED)
            return False
        
        if len(args) < 2:
            self.print_status("❌ No command specified", Colors.RED)
            self.show_usage()
            return False
        
        command = args[1].lower()
        
        if command in self.scripts:
            return self.run_script(command)
        elif command == 'full' or command == 'pipeline':
            return self.run_full_pipeline()
        elif command == 'help' or command == '--help' or command == '-h':
            self.show_help()
            return True
        else:
            self.print_status(f"❌ Unknown command: {command}", Colors.RED)
            self.show_usage()
            return False
    
    def show_usage(self):
        """Show command line usage"""
        print(f"\n{Colors.CYAN}Usage:{Colors.NC}")
        print(f"  python {sys.argv[0]} <command>")
        print()
        print(f"{Colors.YELLOW}Commands:{Colors.NC}")
        print(f"  test      - Run functional tests")
        print(f"  validate  - Run pre-commit validation")
        print(f"  commit    - Commit and push changes")
        print(f"  full      - Run full pipeline")
        print(f"  help      - Show help information")
        print()
        print(f"{Colors.YELLOW}Examples:{Colors.NC}")
        print(f"  python {sys.argv[0]} test")
        print(f"  python {sys.argv[0]} full")
        print(f"  python {sys.argv[0]} help")
        print()

def main():
    """Main entry point"""
    runner = AutomationRunner()
    
    if len(sys.argv) > 1:
        # Command line mode
        success = runner.run_command_line(sys.argv)
        sys.exit(0 if success else 1)
    else:
        # Interactive mode
        runner.run_interactive()

if __name__ == "__main__":
    main()
