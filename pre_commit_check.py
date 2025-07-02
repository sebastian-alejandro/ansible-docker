#!/usr/bin/env python3
"""
==================================
Pre-commit Verification Script
Validates changes before committing
==================================
"""

import subprocess
import sys
import os
import json
from pathlib import Path
import time
import argparse
import platform
from typing import List, Dict, Optional, Tuple

# Try to import yaml, but make it optional
try:
    import yaml
    HAS_YAML = True
except ImportError:
    HAS_YAML = False

# Constantes
CRITICAL_FILES = [
    "ansible-control/Dockerfile",
    "ansible-control/config/ansible.cfg",
    "ansible-control/scripts/init-control-node.sh",
    "ansible-control/scripts/generate-ssh-keys.sh",
    "ansible-control/scripts/generate-inventory.sh",
    "ansible-control/scripts/distribute-ssh-keys.sh",
    "ansible-control/scripts/health-check-control.sh",
    "ansible-control/playbooks/ping.yml",
    "ansible-control/playbooks/setup-base.yml",
    "ansible-control/playbooks/setup-webservers.yml",
    "docker-compose.yml"
]

class Colors:
    """ANSI color codes for terminal output"""
    if platform.system() == "Windows":
        try:
            import colorama
            colorama.init()
            RED = '\033[0;31m'
            GREEN = '\033[0;32m'
            YELLOW = '\033[1;33m'
            BLUE = '\033[0;34m'
            CYAN = '\033[0;36m'
            NC = '\033[0m'
        except ImportError:
            RED = GREEN = YELLOW = BLUE = CYAN = NC = ''
    else:
        RED = '\033[0;31m'
        GREEN = '\033[0;32m'
        YELLOW = '\033[1;33m'
        BLUE = '\033[0;34m'
        CYAN = '\033[0;36m'
        NC = '\033[0m'

class Logger:
    """Clase para logging con colores"""
    
    def __init__(self, verbose: bool = False):
        self.verbose = verbose
    
    def info(self, message: str):
        print(f"{Colors.BLUE}[INFO]{Colors.NC} {message}")
    
    def success(self, message: str):
        print(f"{Colors.GREEN}[SUCCESS]{Colors.NC} {message}")
    
    def warning(self, message: str):
        print(f"{Colors.YELLOW}[WARNING]{Colors.NC} {message}")
    
    def error(self, message: str):
        print(f"{Colors.RED}[ERROR]{Colors.NC} {message}")
    
    def debug(self, message: str):
        if self.verbose:
            print(f"{Colors.CYAN}[DEBUG]{Colors.NC} {message}")

class PreCommitValidator:
    """Pre-commit validation checks"""
    
    def __init__(self, skip_performance: bool = False, verbose: bool = False, docker_compose_cmd: Optional[str] = None):
        self.errors = []
        self.warnings = []
        self.passed_checks = []
        self.logger = Logger(verbose)
        self.skip_performance = skip_performance
        self.docker_compose_cmd = docker_compose_cmd or self._detect_docker_compose()
        self.project_root = Path.cwd()

    def _detect_docker_compose(self) -> str:
        """Detectar automáticamente el comando docker-compose disponible"""
        commands_to_try = ["docker compose", "docker-compose"]
        for cmd in commands_to_try:
            try:
                subprocess.run(cmd.split() + ["--version"], capture_output=True, check=True, text=True)
                self.logger.debug(f"Comando docker-compose detectado: {cmd}")
                return cmd
            except (subprocess.CalledProcessError, FileNotFoundError):
                continue
        self.logger.warning("No se pudo encontrar un comando docker-compose funcional.")
        return "docker-compose"

    def run_command(self, command: List[str], capture_output: bool = True, **kwargs) -> subprocess.CompletedProcess:
        """Run a shell command and return the result"""
        self.logger.debug(f"Ejecutando comando: {' '.join(command)}")
        try:
            result = subprocess.run(
                command,
                capture_output=capture_output,
                text=True,
                check=False,
                cwd=kwargs.get("cwd", self.project_root),
                **kwargs
            )
            if result.stdout and capture_output:
                self.logger.debug(f"Salida del comando: {result.stdout.strip()}")
            if result.stderr and capture_output:
                self.logger.debug(f"Errores del comando: {result.stderr.strip()}")
            return result
        except Exception as e:
            self.logger.error(f"Excepción al ejecutar el comando: {e}")
            return subprocess.CompletedProcess(command, 1, "", str(e))

    def print_status(self, message: str, color: str = Colors.YELLOW):
        """Print a colored status message"""
        print(f"{color}{message}{Colors.NC}")

    def check_critical_files(self) -> bool:
        """Verificar la existencia de archivos críticos"""
        self.logger.info("Verificando la existencia de archivos críticos...")
        all_found = True
        for file_path in CRITICAL_FILES:
            if not (self.project_root / file_path).exists():
                self.errors.append(f"Archivo crítico no encontrado: {file_path}")
                all_found = False
        if all_found:
            self.logger.success("Todos los archivos críticos fueron encontrados.")
        else:
            self.logger.error("Faltan archivos críticos.")
        return all_found

    def docker_compose_up(self) -> bool:
        """Levantar el entorno con Docker Compose"""
        self.logger.info("Levantando el entorno de Docker...")
        cmd = self.docker_compose_cmd.split() + ["up", "--build", "-d"]
        result = self.run_command(cmd, capture_output=True)
        if result.returncode == 0:
            self.logger.success("Entorno Docker iniciado correctamente.")
            time.sleep(10)  # Esperar a que los servicios se inicien
            return True
        else:
            self.errors.append(f"Error al levantar el entorno Docker: {result.stderr}")
            self.logger.error("No se pudo iniciar el entorno Docker.")
            return False

    def docker_compose_down(self):
        """Detener el entorno de Docker Compose"""
        self.logger.info("Deteniendo el entorno de Docker...")
        cmd = self.docker_compose_cmd.split() + ["down", "--volumes"]
        self.run_command(cmd)
        self.logger.success("Entorno Docker detenido y volúmenes eliminados.")

    def run_playbook(self, playbook: str, inventory: str = "config/managed_nodes.yml") -> bool:
        """Ejecutar un playbook de Ansible"""
        self.logger.info(f"Ejecutando playbook: {playbook}...")
        cmd = self.docker_compose_cmd.split() + [
            "exec", "-T", "ansible-control",
            "ansible-playbook", f"playbooks/{playbook}",
            "-i", inventory
        ]
        result = self.run_command(cmd, capture_output=True)
        if result.returncode == 0:
            self.logger.success(f"Playbook {playbook} ejecutado exitosamente.")
            return True
        else:
            self.errors.append(f"Error al ejecutar el playbook {playbook}: {result.stderr}")
            self.logger.error(f"Falló la ejecución del playbook {playbook}.")
            return False

    def check_yaml_syntax(self) -> bool:
        """Validate YAML files syntax"""
        self.print_status("🔍 Validating YAML files...", Colors.BLUE)
        
        yaml_files = [
            "docker-compose.yml",
            "ansible-control/playbooks/ping.yml",
            "ansible-control/playbooks/setup-base.yml",
            "ansible-control/playbooks/setup-webservers.yml",
            "ansible-control/config/all.yml",
            "ansible-control/config/managed_nodes.yml"
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
                        yaml.safe_load(f)
                    self.passed_checks.append(f"✅ {yaml_file}: Valid YAML syntax")
                except Exception as e:
                    self.errors.append(f"❌ {yaml_file}: Invalid YAML - {e}")
                    all_valid = False
            else:
                self.warnings.append(f"⚠️ {yaml_file}: File not found")
        
        return all_valid

    def run_all_checks(self) -> bool:
        """Run all pre-commit checks"""
        self.print_status("🚀 Starting pre-commit validation...", Colors.CYAN)
        
        # Static checks
        self.check_yaml_syntax()
        
        # Phase 1 validation logic
        if not self.check_critical_files():
            # No continuar si faltan archivos esenciales
            return False 

        if not self.docker_compose_up():
            self.docker_compose_down()
            return False

        success = True
        try:
            if not self.run_playbook("ping.yml"):
                success = False
            if success and not self.run_playbook("setup-base.yml"):
                success = False
            if success and not self.run_playbook("setup-webservers.yml"):
                success = False
        finally:
            self.docker_compose_down()

        self.print_summary()
        return not self.errors

    def print_summary(self):
        """Print the summary of all checks"""
        print("\n" + "="*50)
        self.print_status("📊 Validation Summary", Colors.CYAN)
        print("="*50)

        for check in self.passed_checks:
            print(f"{Colors.GREEN}{check}{Colors.NC}")

        if self.warnings:
            self.print_status("\n⚠️ Warnings:", Colors.YELLOW)
            for warning in self.warnings:
                print(f"  {warning}")

        if self.errors:
            self.print_status("\n❌ Errors:", Colors.RED)
            for error in self.errors:
                print(f"  {error}")
            print("-" * 50)
            self.print_status("🚫 Validation Failed", Colors.RED)
        else:
            print("-" * 50)
            self.print_status("✅ Validation Successful", Colors.GREEN)
        
        print("="*50 + "\n")

def main():
    """Main function to run the validator"""
    parser = argparse.ArgumentParser(description="Phase 1 Local Validation Script")
    parser.add_argument("--skip-performance", action="store_true", help="Omitir tests de rendimiento")
    parser.add_argument("--verbose", action="store_true", help="Mostrar salida detallada")
    parser.add_argument("--docker-compose", help="Especificar comando docker-compose (auto-detectado)")
    
    args = parser.parse_args()

    validator = PreCommitValidator(
        skip_performance=args.skip_performance,
        verbose=args.verbose,
        docker_compose_cmd=args.docker_compose
    )
    
    if not validator.run_all_checks():
        sys.exit(1)

if __name__ == "__main__":
    main()
