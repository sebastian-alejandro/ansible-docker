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

from utils import Colors

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

    def build_image(self) -> bool:
        """Build the Docker image"""
        print(f"{Colors.YELLOW}🏗️ Building Docker image...{Colors.NC}")
        
        result = self.run_command(["docker", "build", "-t", self.image_name, "./centos9"], timeout=300)
        
        if result.returncode != 0:
            print(f"{Colors.RED}❌ Failed to build Docker image{Colors.NC}")
            print(result.stderr)
            return False
        
        print(f"{Colors.GREEN}✅ Docker image built successfully{Colors.NC}")
        return True

    def start_container(self) -> bool:
        """Start container with CI environment variables"""
        print(f"{Colors.YELLOW}🚀 Starting container in CI mode...{Colors.NC}")
        
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
            print(f"{Colors.RED}❌ Failed to start container{Colors.NC}")
            print(result.stderr)
            return False
        
        print(f"{Colors.GREEN}✅ Container started successfully{Colors.NC}")
        return True

    def wait_for_container_ready(self) -> bool:
        """Wait for container to be ready using CI-compatible logic"""
        print(f"{Colors.YELLOW}⏳ Waiting for container to start...{Colors.NC}")
        time.sleep(10)
        
        # Check if container is running
        result = self.run_command(["docker", "ps", "--filter", f"name={self.container_name}", "--format", "{{.Status}}"])
        
        if not result.stdout or "Up" not in result.stdout:
            print(f"{Colors.RED}❌ Container is not running properly{Colors.NC}")
            self.show_container_logs()
            return False
        
        print(f"{Colors.GREEN}✅ Container is running: {result.stdout.strip()}{Colors.NC}")
        
        # Wait for container initialization using corrected logic
        print(f"{Colors.YELLOW}⏳ Waiting for container initialization...{Colors.NC}")
        
        # Check if we're in CI fallback mode (no systemd)
        systemd_check = self.run_command([
            "docker", "exec", self.container_name, 
            "test", "-f", "/run/systemd/system"
        ])
        
        if systemd_check.returncode == 0:
            print(f"{Colors.CYAN}🔧 Detected systemd mode{Colors.NC}")
            return self._wait_systemd_mode()
        else:
            print(f"{Colors.CYAN}🔧 Detected fallback mode (no systemd){Colors.NC}")
            return self._wait_fallback_mode()

    def _wait_systemd_mode(self) -> bool:
        """Wait for systemd to be ready"""
        for i in range(24):  # 2 minutes max
            result = self.run_command([
                "docker", "exec", self.container_name,
                "systemctl", "is-system-running"
            ])
            
            if result.stdout and any(status in result.stdout for status in ["running", "degraded"]):
                print(f"{Colors.GREEN}✅ Systemd is ready{Colors.NC}")
                break
            
            print(f"System status: {result.stdout.strip() if result.stdout else 'starting'}")
            time.sleep(5)
        else:
            print(f"{Colors.RED}❌ Container initialization timeout{Colors.NC}")
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
                print(f"{Colors.GREEN}✅ SSH daemon is running{Colors.NC}")
                break
            
            print("SSH process status: starting")
            time.sleep(5)
        else:
            print(f"{Colors.RED}❌ Container initialization timeout in fallback mode{Colors.NC}")
            self.show_container_logs()
            return False
        
        return self._wait_ssh_service()

    def _wait_ssh_service(self) -> bool:
        """Wait for SSH service to be listening"""
        print(f"{Colors.YELLOW}⏳ Waiting for SSH service...{Colors.NC}")
        
        for i in range(20):  # 1 minute max
            result = self.run_command([
                "docker", "exec", self.container_name,
                "netstat", "-tlnp"
            ])
            
            if result.stdout and ":22 " in result.stdout:
                print(f"{Colors.GREEN}✅ SSH port 22 is listening{Colors.NC}")
                return True
            
            print("SSH port status: not_listening")
            time.sleep(3)
        
        print(f"{Colors.RED}❌ SSH service failed to start{Colors.NC}")
        self.show_ssh_status()
        return False

    def test_ssh_service(self) -> bool:
        """Test SSH service (compatible with both modes)"""
        print(f"{Colors.YELLOW}🔐 Testing SSH service...{Colors.NC}")
        
        # Check if we're in fallback mode or systemd mode
        systemd_check = self.run_command([
            "docker", "exec", self.container_name,
            "test", "-f", "/run/systemd/system"
        ])
        
        if systemd_check.returncode == 0:
            print(f"{Colors.CYAN}🔧 Testing SSH in systemd mode{Colors.NC}")
            result = self.run_command([
                "docker", "exec", self.container_name,
                "systemctl", "is-active", "sshd"
            ])
            
            if result.stdout and result.stdout.strip() == "active":
                print(f"{Colors.GREEN}✅ SSH service is active{Colors.NC}")
            else:
                print(f"{Colors.RED}❌ SSH service is not active: {result.stdout.strip()}{Colors.NC}")
                return False
        else:
            print(f"{Colors.CYAN}🔧 Testing SSH in fallback mode{Colors.NC}")
            result = self.run_command([
                "docker", "exec", self.container_name, "pgrep", "sshd"
            ])
            
            if result.returncode == 0:
                print(f"{Colors.GREEN}✅ SSH daemon is running{Colors.NC}")
            else:
                print(f"{Colors.RED}❌ SSH daemon is not running{Colors.NC}")
                return False
        
        # Test SSH port listening (works in both modes)
        result = self.run_command([
            "docker", "exec", self.container_name,
            "netstat", "-tlnp"
        ])
        
        if result.stdout and ":22 " in result.stdout:
            print(f"{Colors.GREEN}✅ SSH port 22 is listening{Colors.NC}")
            return True
        else:
            print(f"{Colors.RED}❌ SSH port 22 is not listening{Colors.NC}")
            return False

    def show_container_logs(self):
        """Show container logs for debugging"""
        print(f"{Colors.YELLOW}📋 Container logs:{Colors.NC}")
        result = self.run_command(["docker", "logs", self.container_name])
        if result.stdout:
            print(result.stdout)
        if result.stderr:
            print(result.stderr)

    def show_ssh_status(self):
        """Show SSH service status for debugging"""
        print(f"{Colors.YELLOW}📋 SSH service status:{Colors.NC}")
        
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
        print(f"{Colors.YELLOW}🧹 Cleaning up...{Colors.NC}")
        self.run_command(["docker", "stop", self.container_name])
        self.run_command(["docker", "rm", self.container_name])

    def run_all_tests(self) -> bool:
        """Run all tests and return success status"""
        try:
            print(f"{Colors.GREEN}🔧 Testing Functional Tests in CI Mode...{Colors.NC}")
            
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
            
            print(f"{Colors.GREEN}🎉 Functional test completed successfully!{Colors.NC}")
            return True
            
        except KeyboardInterrupt:
            print(f"{Colors.YELLOW}⚠️ Test interrupted by user{Colors.NC}")
            return False
        except Exception as e:
            print(f"❌ Test failed with error: {e}", Colors.RED)
            return False
        finally:
            self.cleanup()

def main():
    """Main entry point"""
    Colors.init()
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
