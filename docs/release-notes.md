# Release Notes - v1.2.1

## Current Release

**Version**: 1.2.1  
**Date**: June 27, 2025  
**Status**: Stable

## Features

### Container Infrastructure
- CentOS 9 Stream base containers
- Docker Compose orchestration
- Health monitoring and automatic recovery
- Network isolation with custom bridge network

### SSH Access
- Password and key-based authentication
- User 'ansible' with passwordless sudo privileges
- Port mapping for external SSH access (2201, 2202)
- Secure container isolation

### Testing Framework
- Automated CI/CD pipeline with GitHub Actions
- Functional, integration, and security test suites
- Cross-platform compatibility verification
- Automated release management

### Development Tools
- Python testing framework
- Docker management scripts
- Version control integration
- Documentation automation

## Technical Specifications

### System Requirements
- Docker Engine 20.10+
- Docker Compose v2.0+
- 2GB RAM minimum
- 5GB disk space

### Container Configuration
- **Base OS**: CentOS 9 Stream
- **User**: ansible (passwordless sudo)
- **SSH**: Password authentication enabled
- **Network**: Bridge mode with custom network
- **Health Checks**: Enabled for all services

### Port Mapping
| Service | Internal Port | External Port |
|---------|---------------|---------------|
| centos9-node-1 SSH | 22 | 2201 |
| centos9-node-2 SSH | 22 | 2202 |

## Installation

### Quick Start
```bash
git clone https://github.com/sebastian-alejandro/ansible-docker.git
cd ansible-docker
docker compose up -d
```

### Verification
```bash
docker compose ps
ssh ansible@localhost -p 2201
```

## Usage Examples

### Container Management
```bash
# Start environment
docker compose up -d

# Stop environment
docker compose down

# View container status
docker compose ps

# View logs
docker compose logs
```

### SSH Access
```bash
# Connect to containers
ssh ansible@localhost -p 2201  # Node 1
ssh ansible@localhost -p 2202  # Node 2

# Default password: ansible123
```

### Testing
```bash
# Run functional tests
python3 test_functional_ci.py

# Manual connectivity test
ssh ansible@localhost -p 2201 "hostname && whoami"
```

## Known Issues

### Resolved in v1.2.1
- Fixed netcat package installation in CI/CD pipeline
- Resolved virtual package dependency issues
- Improved cross-platform compatibility

### Workarounds
- For systemd-related issues, containers fallback to direct service management
- SSH service starts automatically in both systemd and fallback modes

## Upgrade Notes

### From v1.2.0 to v1.2.1
- No breaking changes
- CI/CD improvements only
- No manual intervention required

### Migration Steps
```bash
# Pull latest changes
git pull origin main

# Restart environment
docker compose down
docker compose up -d
```

## Security Considerations

### Container Security
- Containers run with minimal privileges
- SSH access restricted to ansible user
- Network isolation between containers and host

### Access Control
- Default password should be changed in production
- SSH key authentication recommended
- Regular security updates via base image updates

## Performance

### Resource Usage
- Memory: ~200MB per container
- CPU: Minimal usage during idle
- Disk: ~500MB per container image

### Scaling Considerations
- Supports multiple container instances
- Network performance depends on host configuration
- Resource limits can be configured in docker-compose.yml

## Support

### Documentation
- [README.md](../README.md): Project overview
- [docs/README.md](README.md): Technical documentation
- [CONTRIBUTING.md](../CONTRIBUTING.md): Development guidelines

### Troubleshooting
- Check container logs: `docker compose logs`
- Verify service status: `docker compose ps`
- Test connectivity: `ssh ansible@localhost -p 2201`

### Issues
Report issues via [GitHub Issues](https://github.com/sebastian-alejandro/ansible-docker/issues)
