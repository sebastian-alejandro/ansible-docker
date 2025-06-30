# Phase 1 Validation Script (Python)

## 📖 Overview

`validate_phase1.py` is a comprehensive, cross-platform validation script that ensures your Phase 1 Ansible Docker implementation meets production-ready standards before pushing to the repository.

## ✨ Features

- 🌐 **Cross-platform** - Works on Windows, Linux, and macOS
- 🔍 **Comprehensive Testing** - Same validation as GitHub Actions workflows
- 🎨 **Colored Output** - Enhanced readability with progress indicators
- ⚡ **Auto-detection** - Automatically detects Docker Compose command
- 🛠️ **Error Handling** - Detailed error messages and debugging information
- 🧹 **Auto-cleanup** - Automatic cleanup of test resources
- ⚙️ **Configurable** - Multiple options and verbosity levels

## 🚀 Quick Start

```bash
# Basic usage
python validate_phase1.py

# With enhanced features (install optional dependencies)
pip install -r requirements-validation.txt
python validate_phase1.py
```

## 📋 Prerequisites

### Required
- **Python 3.7+**
- **Docker Desktop** (Windows/Mac) or **Docker Engine** (Linux)
- **Docker Compose** v2.x or docker-compose v1.29+

### Optional (for enhanced experience)
```bash
# Install optional dependencies
pip install -r requirements-validation.txt
```

**Optional dependencies provide:**
- Colored output on Windows (`colorama`)
- YAML syntax validation (`yamllint`)

## 🎯 Usage

### Basic Commands

```bash
# Run complete validation
python validate_phase1.py

# Skip performance tests (faster execution)
python validate_phase1.py --skip-performance

# Enable verbose output for debugging
python validate_phase1.py --verbose

# Combine options
python validate_phase1.py --skip-performance --verbose
```

### Advanced Options

```bash
# Specify docker-compose command explicitly
python validate_phase1.py --docker-compose "docker compose"

# On systems with both docker-compose and docker compose
python validate_phase1.py --docker-compose "docker-compose"

# Get help
python validate_phase1.py --help
```

## 🔍 Validation Process

The script performs the following validations in order:

### 1. Prerequisites Check
- ✅ Docker daemon running
- ✅ Docker Compose availability
- ✅ Project directory structure

### 2. Static Analysis
- ✅ **File Structure** - All critical Phase 1 files present
- ✅ **Script Permissions** - Execute permissions on shell scripts (Linux/Mac)
- ✅ **YAML Syntax** - Valid YAML in configurations and playbooks
- ✅ **Dockerfile Validation** - Best practices and required configurations

### 3. Container Testing
- ✅ **Build Process** - Container builds successfully
- ✅ **Container Startup** - Container starts and runs properly
- ✅ **Health Checks** - Built-in health check functionality
- ✅ **Ansible Installation** - Ansible Core properly installed and working
- ✅ **Playbook Syntax** - All playbooks have valid syntax

### 4. Performance Testing (Optional)
- ✅ **Boot Time** - Container startup performance (< 60s target)
- ✅ **Resource Usage** - Memory and CPU monitoring

## 📊 Output Examples

### Successful Validation
```
==================================================
  Phase 1 Local Validation Script
  (Python Multiplatform Version)
==================================================

[INFO] Checking Docker...
[SUCCESS] Docker is running
[INFO] Checking Docker Compose...
[SUCCESS] Docker Compose is available: docker compose

[INFO] Starting Phase 1 validation...

[INFO] Validating Phase 1 file structure...
[SUCCESS] Found: ansible-control/Dockerfile
[SUCCESS] Found: ansible-control/config/ansible.cfg
[SUCCESS] Found: ansible-control/scripts/init-control-node.sh
...
[SUCCESS] All critical files present

[INFO] Validating Dockerfile...
[SUCCESS] Non-root user configured
[SUCCESS] Health check configured

[INFO] Static validation completed. Starting container tests...

[INFO] Building Ansible Control Node container...
[SUCCESS] Container build successful

[INFO] Testing container functionality...
[INFO] Starting container...
[INFO] Waiting for container to be ready...
[SUCCESS] Container is running
[INFO] Testing health check...
[SUCCESS] Health check passed
[INFO] Testing Ansible installation...
[SUCCESS] Ansible is working
[INFO] Testing playbook syntax...
[SUCCESS] Playbook syntax is valid

[INFO] Running performance check...

[INFO] Container boot time: 23.4 seconds
[SUCCESS] Boot time is acceptable: 23.4s

[INFO] Cleaning up test environment...
[SUCCESS] Cleanup completed

==================================================
🎉 ALL PHASE 1 VALIDATIONS PASSED!
==================================================

[INFO] Your Phase 1 implementation is ready for:
  ✅ Git push
  ✅ Pull request
  ✅ Production deployment
  ✅ Phase 2 development

[INFO] Next steps:
  1. git add .
  2. git commit -m 'Complete Phase 1 implementation'
  3. git push origin your-branch
```

### Failed Validation
```
[ERROR] Missing critical file: ansible-control/Dockerfile
[ERROR] Missing 1 critical files. Phase 1 is not ready.

==================================================
❌ PHASE 1 VALIDATION FAILED
==================================================

[INFO] Please address the issues above and run the script again.
```

## 🛠️ Troubleshooting

### Common Issues

#### Docker Not Running
```bash
[ERROR] Docker is not running. Please start Docker first.
```
**Solution:** Start Docker Desktop or Docker service

#### Permission Issues (Linux/Mac)
```bash
[WARNING] Missing execute permission: ansible-control/scripts/init-control-node.sh
[INFO] Fixed execute permission: ansible-control/scripts/init-control-node.sh
```
**Solution:** Script automatically fixes permissions

#### Missing Dependencies
```bash
[WARNING] yamllint not installed, skipping YAML validation
[INFO] Install with: pip install yamllint
```
**Solution:** Install optional dependencies:
```bash
pip install -r requirements-validation.txt
```

#### Build Failures
```bash
[ERROR] Container build failed
```
**Solution:** Run with verbose mode for detailed error information:
```bash
python validate_phase1.py --verbose
```

#### Timeout Issues
```bash
[ERROR] Command timed out after 300 seconds
```
**Solution:** Check Docker resources and network connectivity

### Debug Mode

For detailed debugging information:

```bash
# Enable verbose output
python validate_phase1.py --verbose

# This will show:
# - Detailed command execution
# - Docker output and errors
# - Step-by-step progress
# - Additional diagnostic information
```

## 🔧 Configuration

### Environment Variables

The script respects these environment variables:

```bash
# Force specific docker-compose command
export DOCKER_COMPOSE_CMD="docker compose"

# Disable colors (for CI environments)
export NO_COLOR=1
```

### Customization

To customize validation behavior, you can modify these variables in the script:

```python
# Timeout for commands (seconds)
DEFAULT_TIMEOUT = 300

# Maximum boot time for performance test (seconds)
MAX_BOOT_TIME = 60

# Critical files that must exist
CRITICAL_FILES = [
    "ansible-control/Dockerfile",
    "docker-compose.yml",
    # ... add more files
]
```

## 🔄 Integration

### Git Hooks

Add to `.git/hooks/pre-commit`:
```bash
#!/bin/bash
python validate_phase1.py --skip-performance
```

### CI/CD Integration

```bash
# In CI environments
python validate_phase1.py --verbose --skip-performance
```

### IDE Integration

Most IDEs can run the script directly:
- **VS Code:** Run in integrated terminal
- **PyCharm:** Run configuration with arguments
- **Vim/Emacs:** Terminal execution

## 📈 Performance

### Execution Times

| Test Category | Typical Duration |
|---------------|------------------|
| Static Analysis | ~10 seconds |
| Container Build | ~2-5 minutes |
| Functionality Tests | ~1-2 minutes |
| Performance Tests | ~1-2 minutes |
| **Total (with performance)** | **~5-10 minutes** |
| **Total (skip performance)** | **~3-8 minutes** |

### Resource Usage

- **Memory:** ~50-100MB for script execution
- **Disk:** Temporary Docker images (cleaned automatically)
- **Network:** Docker Hub downloads (if images not cached)

## 🤝 Contributing

To improve the validation script:

1. **Fork the repository**
2. **Add new validation checks** in the appropriate methods
3. **Test on multiple platforms** (Windows, Linux, macOS)
4. **Update documentation** for new features
5. **Submit a pull request**

### Adding New Validations

```python
def validate_new_feature(self) -> bool:
    """Validate new Phase 1 feature"""
    self.logger.info("Validating new feature...")
    
    try:
        # Your validation logic here
        result = self._check_something()
        
        if result:
            self.logger.success("New feature validation passed")
            return True
        else:
            self.logger.error("New feature validation failed")
            return False
            
    except Exception as e:
        self.logger.error(f"New feature validation error: {e}")
        return False
```

## 📚 Related Documentation

- [GitHub Actions Workflows README](../.github/workflows/README.md)
- [Phase 1 Testing Suite Documentation](../docs/phase1-testing-suite.md)
- [Project Architecture](../docs/project-architecture.md)
- [Technical Reference](../docs/technical-reference.md)

## 🆘 Support

If you encounter issues:

1. **Run with verbose mode:** `python validate_phase1.py --verbose`
2. **Check prerequisites:** Docker, Python version, file structure
3. **Review error messages:** Often contain specific solutions
4. **Check GitHub Actions:** Compare with CI/CD workflow results
5. **Create an issue:** Include verbose output and system information

---

**Note:** This script provides the same validation as the GitHub Actions workflows, ensuring consistency between local development and CI/CD environments.
