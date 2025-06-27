#!/usr/bin/env python3
"""
===================================
Git Version Control Script
Automated commit and push for CI/CD fixes
===================================
"""

import subprocess
import sys
import os
import json
from datetime import datetime
from typing import List, Dict, Optional

class Colors:
    """ANSI color codes for terminal output"""
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    CYAN = '\033[0;36m'
    NC = '\033[0m'  # No Color

class GitVersionControl:
    """Git version control automation"""
    
    def __init__(self):
        self.version = "v1.2.1"
        self.branch = "main"
        
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
            print(f"{Colors.RED}❌ Command failed: {e}{Colors.NC}")
            return subprocess.CompletedProcess(command, 1, "", str(e))

    def print_status(self, message: str, color: str = Colors.YELLOW):
        """Print a colored status message"""
        print(f"{color}{message}{Colors.NC}")

    def check_git_status(self) -> bool:
        """Check if we're in a git repository and get status"""
        self.print_status("🔍 Checking Git status...", Colors.BLUE)
        
        # Check if we're in a git repo
        result = self.run_command(["git", "status", "--porcelain"])
        if result.returncode != 0:
            self.print_status("❌ Not in a Git repository", Colors.RED)
            return False
        
        # Show current branch
        branch_result = self.run_command(["git", "branch", "--show-current"])
        if branch_result.stdout:
            current_branch = branch_result.stdout.strip()
            self.print_status(f"📍 Current branch: {current_branch}", Colors.CYAN)
            self.branch = current_branch
        
        # Show status
        if result.stdout:
            self.print_status("📋 Modified files:", Colors.YELLOW)
            for line in result.stdout.strip().split('\n'):
                if line.strip():
                    status = line[:2]
                    filepath = line[3:]
                    status_symbol = "📝" if "M" in status else "➕" if "A" in status else "❓"
                    print(f"  {status_symbol} {filepath}")
        else:
            self.print_status("✅ Working directory clean", Colors.GREEN)
        
        return True

    def add_files(self) -> bool:
        """Add modified files to staging"""
        self.print_status("📦 Adding files to staging...", Colors.BLUE)
        
        # Add all modified files
        result = self.run_command(["git", "add", "."])
        if result.returncode != 0:
            self.print_status("❌ Failed to add files", Colors.RED)
            print(result.stderr)
            return False
        
        # Show what was staged
        result = self.run_command(["git", "status", "--staged", "--porcelain"])
        if result.stdout:
            self.print_status("✅ Files staged for commit:", Colors.GREEN)
            for line in result.stdout.strip().split('\n'):
                if line.strip():
                    filepath = line[3:]
                    print(f"  ✓ {filepath}")
        
        return True

    def create_commit(self) -> bool:
        """Create commit with descriptive message"""
        self.print_status("💾 Creating commit...", Colors.BLUE)
        
        commit_message = f"""🔧 Fix CI/CD: Compatibilidad con Fallback Mode

📋 Resumen de Cambios:
- ✅ Corrección de tests funcionales para modo fallback
- ✅ Lógica adaptativa: systemd vs fallback mode  
- ✅ Variables CI agregadas a todos los contenedores
- ✅ Scripts Python multiplataforma (reemplazó PowerShell)
- ✅ Documentación actualizada

🛠️ Archivos Modificados:
- .github/workflows/ci-cd.yml: Tests compatibles
- test_functional_ci.py: Script de prueba Python
- version_control.py: Control de versión Python
- docs/: Documentación actualizada

🎯 Problema Resuelto:
Los tests de GitHub Actions fallaban con timeout porque
intentaban usar systemctl en containers en fallback mode.
Ahora detectan automáticamente el modo y usan la lógica apropiada.

📈 Resultado Esperado:
- Tests pasan sin timeout en GitHub Actions
- Compatibilidad mantenida con desarrollo local
- Scripts multiplataforma con Python

Version: {self.version}
Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"""
        
        result = self.run_command(["git", "commit", "-m", commit_message])
        if result.returncode != 0:
            self.print_status("❌ Failed to create commit", Colors.RED)
            print(result.stderr)
            return False
        
        self.print_status("✅ Commit created successfully", Colors.GREEN)
        return True

    def push_changes(self) -> bool:
        """Push changes to remote repository"""
        self.print_status("🚀 Pushing changes to remote...", Colors.BLUE)
        
        result = self.run_command(["git", "push", "origin", self.branch])
        if result.returncode != 0:
            self.print_status("❌ Failed to push changes", Colors.RED)
            print(result.stderr)
            return False
        
        self.print_status("✅ Changes pushed successfully", Colors.GREEN)
        return True

    def create_tag(self) -> bool:
        """Create and push version tag"""
        self.print_status(f"🏷️ Creating version tag {self.version}...", Colors.BLUE)
        
        # Create annotated tag
        tag_message = f"CI/CD Fix: Fallback Mode Compatibility {self.version}"
        result = self.run_command(["git", "tag", "-a", self.version, "-m", tag_message])
        if result.returncode != 0:
            self.print_status("❌ Failed to create tag", Colors.RED)
            print(result.stderr)
            return False
        
        # Push tag
        result = self.run_command(["git", "push", "origin", self.version])
        if result.returncode != 0:
            self.print_status("❌ Failed to push tag", Colors.RED)
            print(result.stderr)
            return False
        
        self.print_status(f"✅ Tag {self.version} created and pushed", Colors.GREEN)
        return True

    def show_final_status(self):
        """Show final repository status"""
        self.print_status("📊 Final repository status:", Colors.BLUE)
        
        # Show last commit
        result = self.run_command(["git", "log", "--oneline", "-1"])
        if result.stdout:
            self.print_status(f"📝 Last commit: {result.stdout.strip()}", Colors.CYAN)
        
        # Show remote status
        result = self.run_command(["git", "status", "-b", "--porcelain"])
        if result.stdout:
            for line in result.stdout.strip().split('\n'):
                if line.startswith('##'):
                    branch_info = line[3:]
                    self.print_status(f"🌿 Branch status: {branch_info}", Colors.CYAN)
                    break

    def run_version_control(self) -> bool:
        """Run complete version control process"""
        try:
            self.print_status("🚀 Iniciando Control de Versión para CI/CD Fixes...", Colors.GREEN)
            
            # Check git status
            if not self.check_git_status():
                return False
            
            # Confirm with user
            response = input(f"\n{Colors.YELLOW}¿Continuar con commit y push? (y/N): {Colors.NC}")
            if response.lower() not in ['y', 'yes', 'sí', 's']:
                self.print_status("⚠️ Operación cancelada por el usuario", Colors.YELLOW)
                return True
            
            # Add files
            if not self.add_files():
                return False
            
            # Create commit
            if not self.create_commit():
                return False
            
            # Push changes
            if not self.push_changes():
                return False
            
            # Create and push tag
            if not self.create_tag():
                return False
            
            # Show final status
            self.show_final_status()
            
            self.print_status("🎉 Control de versión completado exitosamente!", Colors.GREEN)
            self.print_status("🔄 El workflow de GitHub Actions se ejecutará automáticamente", Colors.CYAN)
            
            return True
            
        except KeyboardInterrupt:
            self.print_status("⚠️ Proceso interrumpido por el usuario", Colors.YELLOW)
            return False
        except Exception as e:
            self.print_status(f"❌ Error en control de versión: {e}", Colors.RED)
            return False

def main():
    """Main entry point"""
    # Check if git is available
    try:
        result = subprocess.run(["git", "--version"], capture_output=True, text=True)
        if result.returncode != 0:
            print(f"{Colors.RED}❌ Git is not available{Colors.NC}")
            sys.exit(1)
    except FileNotFoundError:
        print(f"{Colors.RED}❌ Git is not installed{Colors.NC}")
        sys.exit(1)
    
    # Run version control
    vc = GitVersionControl()
    success = vc.run_version_control()
    
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
