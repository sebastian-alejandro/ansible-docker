#!/usr/bin/env python3
"""
===================================
Pre-commit Verification Script
Validates changes before committing
===================================
"""

import subprocess
import sys
import os
import json
from pathlib import Path
from typing import List, Dict, Optional, Tuple

# Try to import yaml, but make it optional
try:
    import yaml
    HAS_YAML = True
except ImportError:
    HAS_YAML = False

class Colors:
    """ANSI color codes for terminal output"""
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    CYAN = '\033[0;36m'
    NC = '\033[0m'  # No Color

class PreCommitValidator:
    """Pre-commit validation checks"""
    
    def __init__(self):
        self.errors = []
        self.warnings = []
        self.passed_checks = []
        
    def run_command(self, command: List[str], capture_output: bool = True) -> subprocess.CompletedProcess:
        """Run a shell command and return the result"""
        try:
            result = subprocess.run(
                command,
                capture_output=capture_output,
                text=True,
                check=False,
                cwd=os.getcwd()
            )
            return result
        except Exception as e:
            return subprocess.CompletedProcess(command, 1, "", str(e))

    def print_status(self, message: str, color: str = Colors.YELLOW):
        """Print a colored status message"""
        print(f"{color}{message}{Colors.NC}")

    def check_yaml_syntax(self) -> bool:
        """Validate YAML files syntax"""
        self.print_status("🔍 Validating YAML files...", Colors.BLUE)
        
        yaml_files = [
            ".github/workflows/ci-cd.yml",
            "docker-compose.yml"
        ]
        
        if not HAS_YAML:
            self.warnings.append("⚠️ PyYAML not available - skipping YAML validation")
            self.warnings.append("  Install with: pip install pyyaml")
            return True
        
        all_valid = True
        for yaml_file in yaml_files:
            if os.path.exists(yaml_file):
                try:
                    with open(yaml_file, 'r', encoding='utf-8') as f:
                        yaml.safe_load(f)  # type: ignore
                    self.passed_checks.append(f"✅ {yaml_file}: Valid YAML syntax")
                except Exception as e:
                    self.errors.append(f"❌ {yaml_file}: Invalid YAML - {e}")
                    all_valid = False
            else:
                self.warnings.append(f"⚠️ {yaml_file}: File not found")
        
        return all_valid

    def check_docker_files(self) -> bool:
        """Validate Docker-related files"""
        self.print_status("🐳 Validating Docker files...", Colors.BLUE)
        
        # Check Dockerfile exists
        dockerfile_path = "centos9/Dockerfile"
        if os.path.exists(dockerfile_path):
            self.passed_checks.append(f"✅ {dockerfile_path}: Exists")
            
            # Basic Dockerfile validation
            try:
                with open(dockerfile_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    if "FROM" in content:
                        self.passed_checks.append("✅ Dockerfile: Has FROM instruction")
                    else:
                        self.errors.append("❌ Dockerfile: Missing FROM instruction")
                        return False
            except Exception as e:
                self.errors.append(f"❌ Dockerfile: Error reading - {e}")
                return False
        else:
            self.errors.append(f"❌ {dockerfile_path}: File not found")
            return False
        
        # Check docker-compose.yml
        compose_path = "docker-compose.yml"
        if os.path.exists(compose_path):
            try:
                with open(compose_path, 'r', encoding='utf-8') as f:
                    if HAS_YAML:
                        compose_data = yaml.safe_load(f)  # type: ignore
                        if 'services' in compose_data:
                            self.passed_checks.append("✅ docker-compose.yml: Has services section")
                        else:
                            self.warnings.append("⚠️ docker-compose.yml: No services section")
                    else:
                        # Basic text validation without yaml parsing
                        content = f.read()
                        if 'services:' in content:
                            self.passed_checks.append("✅ docker-compose.yml: Has services section")
                        else:
                            self.warnings.append("⚠️ docker-compose.yml: No services section found")
            except Exception as e:
                self.errors.append(f"❌ docker-compose.yml: Error parsing - {e}")
                return False
        
        return True

    def check_python_syntax(self) -> bool:
        """Validate Python files syntax"""
        self.print_status("🐍 Validating Python files...", Colors.BLUE)
        
        python_files = []
        for root, dirs, files in os.walk("."):
            # Skip hidden directories and common non-source directories
            dirs[:] = [d for d in dirs if not d.startswith('.') and d not in ['__pycache__', 'node_modules']]
            
            for file in files:
                if file.endswith('.py'):
                    python_files.append(os.path.join(root, file))
        
        all_valid = True
        for py_file in python_files:
            try:
                # Check syntax by compiling
                with open(py_file, 'r', encoding='utf-8') as f:
                    compile(f.read(), py_file, 'exec')
                self.passed_checks.append(f"✅ {py_file}: Valid Python syntax")
            except SyntaxError as e:
                self.errors.append(f"❌ {py_file}: Syntax error at line {e.lineno} - {e.msg}")
                all_valid = False
            except Exception as e:
                self.errors.append(f"❌ {py_file}: Error reading file - {e}")
                all_valid = False
        
        return all_valid

    def check_git_status(self) -> bool:
        """Check git repository status"""
        self.print_status("📋 Checking Git status...", Colors.BLUE)
        
        # Check if we're in a git repo
        result = self.run_command(["git", "status", "--porcelain"])
        if result.returncode != 0:
            self.errors.append("❌ Not in a Git repository")
            return False
        
        # Check for modified files
        if result.stdout.strip():
            modified_files = len(result.stdout.strip().split('\n'))
            self.passed_checks.append(f"✅ Git: {modified_files} modified files ready for commit")
        else:
            self.warnings.append("⚠️ Git: No modified files to commit")
        
        # Check current branch
        branch_result = self.run_command(["git", "branch", "--show-current"])
        if branch_result.stdout:
            branch = branch_result.stdout.strip()
            self.passed_checks.append(f"✅ Git: Current branch is '{branch}'")
        
        return True

    def check_required_files(self) -> bool:
        """Check for required project files"""
        self.print_status("📁 Checking required files...", Colors.BLUE)
        
        required_files = [
            "README.md",
            "CHANGELOG.md", 
            "LICENSE",
            "CONTRIBUTING.md",
            ".gitignore"
        ]
        
        all_present = True
        for file_path in required_files:
            if os.path.exists(file_path):
                self.passed_checks.append(f"✅ {file_path}: Exists")
            else:
                self.warnings.append(f"⚠️ {file_path}: Missing (recommended)")
        
        # Check for critical files
        critical_files = [
            ".github/workflows/ci-cd.yml",
            "centos9/Dockerfile",
            "docker-compose.yml"
        ]
        
        for file_path in critical_files:
            if os.path.exists(file_path):
                self.passed_checks.append(f"✅ {file_path}: Critical file exists")
            else:
                self.errors.append(f"❌ {file_path}: Critical file missing")
                all_present = False
        
        return all_present

    def check_workflow_syntax(self) -> bool:
        """Validate GitHub Actions workflow"""
        self.print_status("⚙️ Validating GitHub Actions workflow...", Colors.BLUE)
        
        workflow_file = ".github/workflows/ci-cd.yml"
        if not os.path.exists(workflow_file):
            self.errors.append(f"❌ {workflow_file}: Workflow file not found")
            return False
        
        try:
            with open(workflow_file, 'r', encoding='utf-8') as f:
                if HAS_YAML:
                    workflow = yaml.safe_load(f)  # type: ignore
                else:
                    # Basic text validation without yaml parsing
                    content = f.read()
                    workflow = {
                        'name': 'name:' in content,
                        'on': 'on:' in content,
                        'jobs': 'jobs:' in content
                    }
            
            # Check required sections
            required_sections = ['name', 'on', 'jobs']
            for section in required_sections:
                if HAS_YAML:
                    section_exists = section in workflow
                else:
                    section_exists = workflow.get(section, False)
                
                if section_exists:
                    self.passed_checks.append(f"✅ Workflow: Has '{section}' section")
                else:
                    self.errors.append(f"❌ Workflow: Missing '{section}' section")
                    return False
            
            # Check for our specific jobs (only if yaml is available)
            if HAS_YAML:
                expected_jobs = ['build-tests', 'functional-tests', 'ssh-tests', 'security-tests', 'integration-tests']
                if 'jobs' in workflow and isinstance(workflow['jobs'], dict):
                    actual_jobs = list(workflow['jobs'].keys())
                    for job in expected_jobs:
                        if job in actual_jobs:
                            self.passed_checks.append(f"✅ Workflow: Has '{job}' job")
                        else:
                            self.warnings.append(f"⚠️ Workflow: Missing '{job}' job")
            else:
                self.warnings.append("⚠️ Workflow: Job validation skipped (PyYAML not available)")
            
            return True
            
        except Exception as e:
            self.errors.append(f"❌ Workflow: Error parsing - {e}")
            return False

    def run_all_checks(self) -> bool:
        """Run all validation checks"""
        self.print_status("🔍 Running pre-commit validation checks...", Colors.GREEN)
        print()
        
        checks = [
            ("Git Status", self.check_git_status),
            ("Required Files", self.check_required_files),
            ("YAML Syntax", self.check_yaml_syntax),
            ("Docker Files", self.check_docker_files),
            ("Python Syntax", self.check_python_syntax),
            ("GitHub Actions Workflow", self.check_workflow_syntax),
        ]
        
        all_passed = True
        for check_name, check_func in checks:
            if not check_func():
                all_passed = False
        
        # Print summary
        print()
        self.print_summary()
        
        return all_passed

    def print_summary(self):
        """Print validation summary"""
        self.print_status("📊 Validation Summary", Colors.BLUE)
        print()
        
        # Passed checks
        if self.passed_checks:
            self.print_status("✅ PASSED CHECKS:", Colors.GREEN)
            for check in self.passed_checks:
                print(f"  {check}")
            print()
        
        # Warnings
        if self.warnings:
            self.print_status("⚠️ WARNINGS:", Colors.YELLOW)
            for warning in self.warnings:
                print(f"  {warning}")
            print()
        
        # Errors
        if self.errors:
            self.print_status("❌ ERRORS:", Colors.RED)
            for error in self.errors:
                print(f"  {error}")
            print()
        
        # Final status
        if self.errors:
            self.print_status("❌ VALIDATION FAILED - Please fix errors before committing", Colors.RED)
        elif self.warnings:
            self.print_status("⚠️ VALIDATION PASSED WITH WARNINGS - Consider addressing warnings", Colors.YELLOW)
        else:
            self.print_status("✅ ALL VALIDATION CHECKS PASSED", Colors.GREEN)

def main():
    """Main entry point"""
    validator = PreCommitValidator()
    success = validator.run_all_checks()
    
    if success:
        print()
        print(f"{Colors.GREEN}🎉 Ready for commit and push!{Colors.NC}")
    else:
        print()
        print(f"{Colors.RED}❌ Please fix errors before proceeding{Colors.NC}")
    
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
