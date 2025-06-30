#!/usr/bin/env python3
"""
Phase 1 Local Validation Script (Python)
=========================================
Este script ejecuta las validaciones principales de Phase 1 localmente
antes de hacer push al repositorio (versión multiplataforma en Python).

Uso:
    python validate_phase1.py [opciones]
    
Opciones:
    --skip-performance    Omitir tests de rendimiento
    --verbose            Mostrar salida detallada
    --help               Mostrar esta ayuda
    --docker-compose     Especificar comando docker-compose (auto-detectado)
"""

import os
import sys
import time
import subprocess
import argparse
import platform
from pathlib import Path
from typing import List, Optional, Tuple
import json

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

# Colores para output
class Colors:
    if platform.system() == "Windows":
        # En Windows, usar códigos ANSI si está disponible
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

class Phase1Validator:
    """Clase principal para validación de Phase 1"""
    
    def __init__(self, skip_performance: bool = False, verbose: bool = False, docker_compose_cmd: Optional[str] = None):
        self.skip_performance = skip_performance
        self.logger = Logger(verbose)
        self.docker_compose_cmd = docker_compose_cmd or self._detect_docker_compose()
        self.project_root = Path.cwd()
        
    def _detect_docker_compose(self) -> str:
        """Detectar automáticamente el comando docker-compose disponible"""
        commands_to_try = ["docker compose", "docker-compose"]
        
        for cmd in commands_to_try:
            try:
                result = subprocess.run(
                    cmd.split() + ["version"], 
                    capture_output=True, 
                    text=True, 
                    timeout=10
                )
                if result.returncode == 0:
                    self.logger.success(f"Docker Compose detected: {cmd}")
                    return cmd
            except (subprocess.TimeoutExpired, FileNotFoundError):
                continue
        
        raise RuntimeError("Docker Compose not found. Please install Docker Desktop or docker-compose.")
    
    def _run_command(self, command: List[str], capture_output: bool = True, timeout: int = 300) -> Tuple[int, str, str]:
        """Ejecutar comando y retornar código de salida, stdout y stderr"""
        try:
            self.logger.debug(f"Running command: {' '.join(command)}")
            
            result = subprocess.run(
                command,
                capture_output=capture_output,
                text=True,
                timeout=timeout,
                cwd=self.project_root
            )
            
            return result.returncode, result.stdout, result.stderr
        
        except subprocess.TimeoutExpired:
            self.logger.error(f"Command timed out after {timeout} seconds: {' '.join(command)}")
            return 1, "", "Timeout"
        except Exception as e:
            self.logger.error(f"Error running command: {e}")
            return 1, "", str(e)
    
    def check_docker(self) -> bool:
        """Verificar si Docker está ejecutándose"""
        self.logger.info("Checking Docker...")
        
        returncode, stdout, stderr = self._run_command(["docker", "info"])
        
        if returncode == 0:
            self.logger.success("Docker is running")
            return True
        else:
            self.logger.error("Docker is not running. Please start Docker first.")
            self.logger.debug(f"Docker error: {stderr}")
            return False
    
    def check_docker_compose(self) -> bool:
        """Verificar si docker-compose está disponible"""
        self.logger.info("Checking Docker Compose...")
        
        try:
            returncode, stdout, stderr = self._run_command(self.docker_compose_cmd.split() + ["version"])
            
            if returncode == 0:
                self.logger.success(f"Docker Compose is available: {self.docker_compose_cmd}")
                return True
            else:
                self.logger.error(f"Docker Compose check failed: {stderr}")
                return False
                
        except Exception as e:
            self.logger.error(f"Docker Compose is not available: {e}")
            return False
    
    def validate_structure(self) -> bool:
        """Validar estructura de archivos"""
        self.logger.info("Validating Phase 1 file structure...")
        
        missing_files = 0
        
        for file_path in CRITICAL_FILES:
            full_path = self.project_root / file_path
            if full_path.exists():
                self.logger.success(f"Found: {file_path}")
            else:
                self.logger.error(f"Missing critical file: {file_path}")
                missing_files += 1
        
        if missing_files > 0:
            self.logger.error(f"Missing {missing_files} critical files. Phase 1 is not ready.")
            return False
        
        self.logger.success("All critical files present")
        return True
    
    def validate_script_permissions(self) -> bool:
        """Validar permisos de scripts (Linux/Mac)"""
        if platform.system() == "Windows":
            self.logger.info("Skipping script permissions check on Windows")
            return True
            
        self.logger.info("Validating script permissions...")
        
        scripts_dir = self.project_root / "ansible-control" / "scripts"
        
        if not scripts_dir.exists():
            self.logger.error("Scripts directory not found")
            return False
        
        for script_file in scripts_dir.glob("*.sh"):
            if os.access(script_file, os.X_OK):
                self.logger.success(f"Execute permission OK: {script_file.name}")
            else:
                self.logger.warning(f"Missing execute permission: {script_file}")
                try:
                    os.chmod(script_file, 0o755)
                    self.logger.info(f"Fixed execute permission: {script_file}")
                except Exception as e:
                    self.logger.error(f"Could not fix permission for {script_file}: {e}")
                    return False
        
        return True
    
    def validate_yaml(self) -> bool:
        """Validar sintaxis YAML"""
        self.logger.info("Validating YAML syntax...")
        
        # Verificar si yamllint está disponible
        returncode, stdout, stderr = self._run_command(["yamllint", "--version"])
        
        if returncode == 0:
            self.logger.info("Running yamllint...")
            yaml_files = [
                "docker-compose.yml",
                "ansible-control/playbooks/",
                "ansible-control/config/"
            ]
            
            cmd = ["yamllint"] + yaml_files
            returncode, stdout, stderr = self._run_command(cmd)
            
            if returncode == 0:
                self.logger.success("YAML syntax validation passed")
                return True
            else:
                self.logger.warning("YAML syntax issues found (non-critical)")
                self.logger.debug(f"yamllint output: {stderr}")
                return True  # No crítico
        else:
            self.logger.warning("yamllint not installed, skipping YAML validation")
            self.logger.info("Install with: pip install yamllint")
            return True
    
    def validate_dockerfile(self) -> bool:
        """Validar Dockerfile"""
        self.logger.info("Validating Dockerfile...")
        
        dockerfile_path = self.project_root / "ansible-control" / "Dockerfile"
        
        if not dockerfile_path.exists():
            self.logger.error("Dockerfile not found")
            return False
        
        # Leer contenido del Dockerfile
        try:
            with open(dockerfile_path, 'r', encoding='utf-8') as f:
                dockerfile_content = f.read()
        except Exception as e:
            self.logger.error(f"Could not read Dockerfile: {e}")
            return False
        
        # Verificaciones básicas
        if "USER" in dockerfile_content and "ansible" in dockerfile_content:
            self.logger.success("Non-root user configured")
        else:
            self.logger.error("Non-root user not configured in Dockerfile")
            return False
        
        if "HEALTHCHECK" in dockerfile_content:
            self.logger.success("Health check configured")
        else:
            self.logger.error("Health check missing in Dockerfile")
            return False
        
        # Verificar si hadolint está disponible
        returncode, stdout, stderr = self._run_command(["hadolint", "--version"])
        
        if returncode == 0:
            self.logger.info("Running hadolint...")
            returncode, stdout, stderr = self._run_command(["hadolint", str(dockerfile_path)])
            
            if returncode == 0:
                self.logger.success("Dockerfile validation passed")
            else:
                self.logger.warning("Dockerfile issues found (review recommended)")
                self.logger.debug(f"hadolint output: {stderr}")
        else:
            self.logger.warning("hadolint not installed, skipping Dockerfile linting")
            self.logger.info("Install from: https://github.com/hadolint/hadolint")
        
        return True
    
    def build_container(self) -> bool:
        """Build del container"""
        self.logger.info("Building Ansible Control Node container...")
        
        cmd = self.docker_compose_cmd.split() + ["build", "ansible-control"]
        returncode, stdout, stderr = self._run_command(cmd, timeout=600)  # 10 minutos
        
        if returncode == 0:
            self.logger.success("Container build successful")
            return True
        else:
            self.logger.error("Container build failed")
            self.logger.debug(f"Build error: {stderr}")
            return False
    
    def test_container(self) -> bool:
        """Test básico del container"""
        self.logger.info("Testing container functionality...")
        
        try:
            # Iniciar container
            self.logger.info("Starting container...")
            cmd = self.docker_compose_cmd.split() + ["up", "-d", "ansible-control"]
            returncode, stdout, stderr = self._run_command(cmd)
            
            if returncode != 0:
                self.logger.error("Failed to start container")
                self.logger.debug(f"Start error: {stderr}")
                return False
            
            # Esperar que esté listo
            self.logger.info("Waiting for container to be ready...")
            time.sleep(30)
            
            # Verificar que está corriendo
            cmd = self.docker_compose_cmd.split() + ["ps", "ansible-control"]
            returncode, stdout, stderr = self._run_command(cmd)
            
            if returncode == 0 and "Up" in stdout:
                self.logger.success("Container is running")
            else:
                self.logger.error("Container failed to start")
                # Mostrar logs
                cmd = self.docker_compose_cmd.split() + ["logs", "ansible-control"]
                _, logs, _ = self._run_command(cmd)
                self.logger.debug(f"Container logs: {logs}")
                return False
            
            # Test health check
            self.logger.info("Testing health check...")
            cmd = self.docker_compose_cmd.split() + ["exec", "-T", "ansible-control", "/usr/local/bin/health-check-control.sh"]
            returncode, stdout, stderr = self._run_command(cmd)
            
            if returncode == 0:
                self.logger.success("Health check passed")
            else:
                self.logger.error("Health check failed")
                self.logger.debug(f"Health check error: {stderr}")
                return False
            
            # Test Ansible
            self.logger.info("Testing Ansible installation...")
            cmd = self.docker_compose_cmd.split() + ["exec", "-T", "ansible-control", "ansible", "--version"]
            returncode, stdout, stderr = self._run_command(cmd)
            
            if returncode == 0:
                self.logger.success("Ansible is working")
                self.logger.debug(f"Ansible version: {stdout.strip()}")
            else:
                self.logger.error("Ansible test failed")
                self.logger.debug(f"Ansible error: {stderr}")
                return False
            
            # Test playbook syntax
            self.logger.info("Testing playbook syntax...")
            cmd = self.docker_compose_cmd.split() + ["exec", "-T", "ansible-control", "ansible-playbook", "--syntax-check", "/ansible/playbooks/ping.yml"]
            returncode, stdout, stderr = self._run_command(cmd)
            
            if returncode == 0:
                self.logger.success("Playbook syntax is valid")
            else:
                self.logger.error("Playbook syntax error")
                self.logger.debug(f"Playbook error: {stderr}")
                return False
            
            return True
            
        except Exception as e:
            self.logger.error(f"Container test failed: {e}")
            return False
    
    def test_performance(self) -> bool:
        """Performance test rápido"""
        if self.skip_performance:
            self.logger.info("Skipping performance tests (--skip-performance specified)")
            return True
        
        self.logger.info("Running quick performance test...")
        
        try:
            # Test boot time
            start_time = time.time()
            cmd = self.docker_compose_cmd.split() + ["up", "-d", "ansible-control"]
            returncode, stdout, stderr = self._run_command(cmd)
            
            if returncode != 0:
                self.logger.error("Failed to start container for performance test")
                return False
            
            # Esperar hasta que esté listo
            max_wait = 60
            wait_time = 0
            
            while wait_time < max_wait:
                cmd = self.docker_compose_cmd.split() + ["exec", "-T", "ansible-control", "/usr/local/bin/health-check-control.sh"]
                returncode, stdout, stderr = self._run_command(cmd)
                
                if returncode == 0:
                    break
                
                time.sleep(2)
                wait_time += 2
            
            end_time = time.time()
            boot_time = end_time - start_time
            
            self.logger.info(f"Container boot time: {boot_time:.1f} seconds")
            
            if boot_time > 60:
                self.logger.warning(f"Boot time is slow: {boot_time:.1f}s (consider optimization)")
            else:
                self.logger.success(f"Boot time is acceptable: {boot_time:.1f}s")
            
            return True
            
        except Exception as e:
            self.logger.error(f"Performance test failed: {e}")
            return False
    
    def cleanup(self):
        """Cleanup del entorno de test"""
        self.logger.info("Cleaning up test environment...")
        
        try:
            # Parar containers
            cmd = self.docker_compose_cmd.split() + ["down", "-v"]
            self._run_command(cmd)
            
            # Limpiar sistema Docker
            cmd = ["docker", "system", "prune", "-f"]
            self._run_command(cmd)
            
            self.logger.success("Cleanup completed")
            
        except Exception as e:
            self.logger.warning(f"Cleanup may not have completed fully: {e}")
    
    def validate(self) -> bool:
        """Ejecutar validación completa"""
        try:
            # Verificar prerrequisitos
            if not self.check_docker():
                return False
            
            if not self.check_docker_compose():
                return False
            
            print()
            self.logger.info("Starting Phase 1 validation...")
            print()
            
            # Validaciones estáticas
            if not self.validate_structure():
                return False
            
            if not self.validate_script_permissions():
                return False
            
            if not self.validate_yaml():
                return False
            
            if not self.validate_dockerfile():
                return False
            
            print()
            self.logger.info("Static validation completed. Starting container tests...")
            print()
            
            # Cleanup previo
            self.cleanup()
            
            # Tests del container
            if not self.build_container():
                return False
            
            if not self.test_container():
                return False
            
            if not self.skip_performance:
                print()
                self.logger.info("Running performance check...")
                print()
                
                self.cleanup()
                if not self.test_performance():
                    self.logger.warning("Performance test failed (non-critical)")
            
            return True
            
        finally:
            # Cleanup final
            self.cleanup()

def main():
    """Función principal"""
    parser = argparse.ArgumentParser(
        description="Phase 1 Local Validation Script",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
    python validate_phase1.py
    python validate_phase1.py --skip-performance
    python validate_phase1.py --verbose
    python validate_phase1.py --docker-compose "docker compose"
        """
    )
    
    parser.add_argument(
        "--skip-performance",
        action="store_true",
        help="Skip performance tests"
    )
    
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Enable verbose output"
    )
    
    parser.add_argument(
        "--docker-compose",
        type=str,
        help="Specify docker-compose command (auto-detected if not provided)"
    )
    
    args = parser.parse_args()
    
    # Header
    print("=" * 50)
    print("  Phase 1 Local Validation Script")
    print("  (Python Multiplatform Version)")
    print("=" * 50)
    print()
    
    # Verificar que estamos en el directorio correcto
    if not (Path("docker-compose.yml").exists() and Path("ansible-control").exists()):
        print(f"{Colors.RED}[ERROR]{Colors.NC} Please run this script from the project root directory")
        sys.exit(1)
    
    # Crear validador
    try:
        validator = Phase1Validator(
            skip_performance=args.skip_performance,
            verbose=args.verbose,
            docker_compose_cmd=args.docker_compose
        )
        
        # Ejecutar validación
        success = validator.validate()
        
        if success:
            print()
            print("=" * 50)
            print(f"{Colors.GREEN}🎉 ALL PHASE 1 VALIDATIONS PASSED!{Colors.NC}")
            print("=" * 50)
            print()
            print(f"{Colors.BLUE}[INFO]{Colors.NC} Your Phase 1 implementation is ready for:")
            print(f"  {Colors.GREEN}✅ Git push{Colors.NC}")
            print(f"  {Colors.GREEN}✅ Pull request{Colors.NC}")
            print(f"  {Colors.GREEN}✅ Production deployment{Colors.NC}")
            print(f"  {Colors.GREEN}✅ Phase 2 development{Colors.NC}")
            print()
            print(f"{Colors.BLUE}[INFO]{Colors.NC} Next steps:")
            print(f"  {Colors.CYAN}1. git add .{Colors.NC}")
            print(f"  {Colors.CYAN}2. git commit -m 'Complete Phase 1 implementation'{Colors.NC}")
            print(f"  {Colors.CYAN}3. git push origin your-branch{Colors.NC}")
            print()
            sys.exit(0)
        else:
            print()
            print("=" * 50)
            print(f"{Colors.RED}❌ PHASE 1 VALIDATION FAILED{Colors.NC}")
            print("=" * 50)
            print()
            print(f"{Colors.BLUE}[INFO]{Colors.NC} Please address the issues above and run the script again.")
            sys.exit(1)
            
    except KeyboardInterrupt:
        print(f"\n{Colors.YELLOW}[WARNING]{Colors.NC} Validation interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"{Colors.RED}[ERROR]{Colors.NC} Validation failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
