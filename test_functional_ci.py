#!/usr/bin/env python3
"""
===================================
Test Script - Reproduce CI Functional Test
Simulates the same conditions as GitHub Actions
===================================
"""

import subprocess
import sys
import time
import os
import json
from typing import Dict, List, Optional

class Colors:
    """ANSI color codes for terminal output"""
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    CYAN = '\033[0;36m'
    NC = '\033[0m'  # No Color

class DockerTestRunner:
    """Main class for running Docker tests in CI mode"""
    
    def __init__(self):
        self.container_name = "test-functional"
        self.image_name = "centos9-ansible:test"
        self.ssh_port = "2299"
        
    def run_command(self, command: List[str], capture_output: bool = True, timeout: int = 30) -> subprocess.CompletedProcess:
        """Run a shell command and return the result"""
        try:
            result = subprocess.run(
                command,
                capture_output=capture_output,
                text=True,
                timeout=timeout,
                check=False
            )
            return result
        except subprocess.TimeoutExpired:
            print(f"{Colors.RED}❌ Command timed out after {timeout} seconds{Colors.NC}")
            return subprocess.CompletedProcess(command, 124, "", "Command timed out")
        except Exception as e:
            print(f"{Colors.RED}❌ Command failed: {e}{Colors.NC}")
            return subprocess.CompletedProcess(command, 1, "", str(e))

    def print_status(self, message: str, color: str = Colors.YELLOW):
        """Print a colored status message"""
        print(f"{color}{message}{Colors.NC}")

    def build_image(self) -> bool:
        """Build the Docker image"""
        self.print_status("🏗️ Building Docker image...", Colors.YELLOW)
        
        result = self.run_command(["docker", "build", "-t", self.image_name, "./centos9"], timeout=300)
        
        if result.returncode != 0:
            self.print_status("❌ Failed to build Docker image", Colors.RED)
            print(result.stderr)
            return False
        
        self.print_status("✅ Docker image built successfully", Colors.GREEN)
        return True

    def start_container(self) -> bool:
        """Start container with CI environment variables"""
        self.print_status("🚀 Starting container in CI mode...", Colors.YELLOW)
        
        # Stop and remove existing container if it exists
        self.run_command(["docker", "stop", self.container_name])
        self.run_command(["docker", "rm", self.container_name])
        
        command = [
            "docker", "run", "-d", "--name", self.container_name,
            "-p", f"{self.ssh_port}:22",
            "-e", "CI=true",
            "-e", "GITHUB_ACTIONS=true",
            "--privileged",
            "--tmpfs", "/tmp",
            "--tmpfs", "/run",
            "--tmpfs", "/run/lock",
            "-v", "/sys/fs/cgroup:/sys/fs/cgroup:ro",
            self.image_name
        ]
        
        result = self.run_command(command)
        
        if result.returncode != 0:
            self.print_status("❌ Failed to start container", Colors.RED)
            print(result.stderr)
            return False
        
        self.print_status("✅ Container started successfully", Colors.GREEN)
        return True

    def wait_for_container_ready(self) -> bool:
        """Wait for container to be ready using CI-compatible logic"""
        self.print_status("⏳ Waiting for container to start...", Colors.YELLOW)
        time.sleep(10)
        
        # Check if container is running
        result = self.run_command(["docker", "ps", "--filter", f"name={self.container_name}", "--format", "{{.Status}}"])
        
        if not result.stdout or "Up" not in result.stdout:
            self.print_status("❌ Container is not running properly", Colors.RED)
            self.show_container_logs()
            return False
        
        self.print_status(f"✅ Container is running: {result.stdout.strip()}", Colors.GREEN)
        
        # Wait for container initialization using corrected logic
        self.print_status("⏳ Waiting for container initialization...", Colors.YELLOW)
        
        # Check if we're in CI fallback mode (no systemd)
        systemd_check = self.run_command([
            "docker", "exec", self.container_name, 
            "test", "-f", "/run/systemd/system"
        ])
        
        if systemd_check.returncode == 0:
            self.print_status("🔧 Detected systemd mode", Colors.CYAN)
            return self._wait_systemd_mode()
        else:
            self.print_status("🔧 Detected fallback mode (no systemd)", Colors.CYAN)
            return self._wait_fallback_mode()

    def _wait_systemd_mode(self) -> bool:
        """Wait for systemd to be ready"""
        for i in range(24):  # 2 minutes max
            result = self.run_command([
                "docker", "exec", self.container_name,
                "systemctl", "is-system-running"
            ])
            
            if result.stdout and any(status in result.stdout for status in ["running", "degraded"]):
                self.print_status("✅ Systemd is ready", Colors.GREEN)
                break
            
            print(f"System status: {result.stdout.strip() if result.stdout else 'starting'}")
            time.sleep(5)
        else:
            self.print_status("❌ Container initialization timeout", Colors.RED)
            self.show_container_logs()
            return False
        
        return self._wait_ssh_service()

    def _wait_fallback_mode(self) -> bool:
        """Wait for SSH daemon in fallback mode"""
        for i in range(24):  # 2 minutes max
            result = self.run_command([
                "docker", "exec", self.container_name, "pgrep", "sshd"
            ])
            
            if result.returncode == 0:
                self.print_status("✅ SSH daemon is running", Colors.GREEN)
                break
            
            print("SSH process status: starting")
            time.sleep(5)
        else:
            self.print_status("❌ Container initialization timeout in fallback mode", Colors.RED)
            self.show_container_logs()
            return False
        
        return self._wait_ssh_service()

    def _wait_ssh_service(self) -> bool:
        """Wait for SSH service to be listening"""
        self.print_status("⏳ Waiting for SSH service...", Colors.YELLOW)
        
        for i in range(20):  # 1 minute max
            result = self.run_command([
                "docker", "exec", self.container_name,
                "netstat", "-tlnp"
            ])
            
            if result.stdout and ":22 " in result.stdout:
                self.print_status("✅ SSH port 22 is listening", Colors.GREEN)
                return True
            
            print("SSH port status: not_listening")
            time.sleep(3)
        
        self.print_status("❌ SSH service failed to start", Colors.RED)
        self.show_ssh_status()
        return False

    def test_ssh_service(self) -> bool:
        """Test SSH service (compatible with both modes)"""
        self.print_status("🔐 Testing SSH service...", Colors.YELLOW)
        
        # Check if we're in fallback mode or systemd mode
        systemd_check = self.run_command([
            "docker", "exec", self.container_name,
            "test", "-f", "/run/systemd/system"
        ])
        
        if systemd_check.returncode == 0:
            self.print_status("🔧 Testing SSH in systemd mode", Colors.CYAN)
            result = self.run_command([
                "docker", "exec", self.container_name,
                "systemctl", "is-active", "sshd"
            ])
            
            if result.stdout and result.stdout.strip() == "active":
                self.print_status("✅ SSH service is active", Colors.GREEN)
            else:
                self.print_status(f"❌ SSH service is not active: {result.stdout.strip()}", Colors.RED)
                return False
        else:
            self.print_status("🔧 Testing SSH in fallback mode", Colors.CYAN)
            result = self.run_command([
                "docker", "exec", self.container_name, "pgrep", "sshd"
            ])
            
            if result.returncode == 0:
                self.print_status("✅ SSH daemon is running", Colors.GREEN)
            else:
                self.print_status("❌ SSH daemon is not running", Colors.RED)
                return False
        
        # Test SSH port listening (works in both modes)
        result = self.run_command([
            "docker", "exec", self.container_name,
            "netstat", "-tlnp"
        ])
        
        if result.stdout and ":22 " in result.stdout:
            self.print_status("✅ SSH port 22 is listening", Colors.GREEN)
            return True
        else:
            self.print_status("❌ SSH port 22 is not listening", Colors.RED)
            return False

    def show_container_logs(self):
        """Show container logs for debugging"""
        self.print_status("📋 Container logs:", Colors.YELLOW)
        result = self.run_command(["docker", "logs", self.container_name])
        if result.stdout:
            print(result.stdout)
        if result.stderr:
            print(result.stderr)

    def show_ssh_status(self):
        """Show SSH service status for debugging"""
        self.print_status("📋 SSH service status:", Colors.YELLOW)
        
        # Check SSH process
        result = self.run_command([
            "docker", "exec", self.container_name, "pgrep", "sshd"
        ])
        if result.returncode != 0:
            print("SSH daemon not running")
        
        # Check SSH port
        result = self.run_command([
            "docker", "exec", self.container_name,
            "netstat", "-tlnp"
        ])
        if result.stdout and ":22 " not in result.stdout:
            print("SSH port not listening")

    def cleanup(self):
        """Clean up test resources"""
        self.print_status("🧹 Cleaning up...", Colors.YELLOW)
        self.run_command(["docker", "stop", self.container_name])
        self.run_command(["docker", "rm", self.container_name])

    def run_all_tests(self) -> bool:
        """Run all tests and return success status"""
        try:
            self.print_status("🔧 Testing Functional Tests in CI Mode...", Colors.GREEN)
            
            # Build image
            if not self.build_image():
                return False
            
            # Start container
            if not self.start_container():
                return False
            
            # Wait for container to be ready
            if not self.wait_for_container_ready():
                return False
            
            # Test SSH service
            if not self.test_ssh_service():
                return False
            
            # Show final logs for verification
            self.show_container_logs()
            
            self.print_status("🎉 Functional test completed successfully!", Colors.GREEN)
            return True
            
        except KeyboardInterrupt:
            self.print_status("⚠️ Test interrupted by user", Colors.YELLOW)
            return False
        except Exception as e:
            self.print_status(f"❌ Test failed with error: {e}", Colors.RED)
            return False
        finally:
            self.cleanup()

def main():
    """Main entry point"""
    # Check if Docker is available
    try:
        result = subprocess.run(["docker", "--version"], capture_output=True, text=True)
        if result.returncode != 0:
            print(f"{Colors.RED}❌ Docker is not available or not running{Colors.NC}")
            sys.exit(1)
    except FileNotFoundError:
        print(f"{Colors.RED}❌ Docker is not installed{Colors.NC}")
        sys.exit(1)
    
    # Run tests
    runner = DockerTestRunner()
    success = runner.run_all_tests()
    
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
