# Documentation Index

## Current Status

**Version**: 1.2.1  
**Status**: Production Ready  
**Last Updated**: June 27, 2025

## Architecture Overview

The Ansible Docker Environment provides a containerized lab setup for Ansible automation testing and development using CentOS 9 Stream containers orchestrated with Docker Compose.

## Quick Start Guides

### Installation
1. [System Requirements](#requirements)
2. [Installation Steps](#installation)
3. [Basic Configuration](#configuration)

### Usage
1. [Container Management](#management)
2. [SSH Access](#ssh-access)
3. [Testing Procedures](#testing)

## Technical Documentation

### Container Architecture
- **Base OS**: CentOS 9 Stream
- **Container Runtime**: Docker Engine 20.10+
- **Orchestration**: Docker Compose v2.0+
- **Network**: Bridge networking with custom network
- **Storage**: Named volumes for persistence

### Security Configuration
- SSH password and key-based authentication
- User 'ansible' with passwordless sudo
- Isolated container network
- Health monitoring enabled

### Development Workflow
- GitHub Actions CI/CD pipeline
- Automated testing suite
- Cross-platform compatibility
- Version-controlled configuration

## System Requirements

### Minimum Requirements
- Docker Engine 20.10+
- Docker Compose v2.0+
- 2GB RAM
- 5GB disk space

### Supported Platforms
- Linux (Ubuntu 20.04+, CentOS 8+, RHEL 8+)
- Windows 10/11 with Docker Desktop
- macOS 10.15+ with Docker Desktop

## Installation

### Quick Setup
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

## Configuration

### Environment Variables
- `ANSIBLE_USER`: SSH user (default: ansible)
- `ANSIBLE_PASSWORD`: SSH password (default: ansible123)

### Port Mapping
- 2201: centos9-node-1 SSH
- 2202: centos9-node-2 SSH

### Network Configuration
- Network: ansible-network
- Driver: bridge
- Subnet: Auto-assigned by Docker

## Management

### Container Operations
```bash
# Start environment
docker compose up -d

# Stop environment
docker compose down

# View logs
docker compose logs

# Restart services
docker compose restart
```

### Health Monitoring
```bash
# Check container health
docker compose ps

# Individual container status
docker inspect --format='{{.State.Health.Status}}' centos9-node-1
```

## SSH Access

### Direct SSH
```bash
ssh ansible@localhost -p 2201  # Node 1
ssh ansible@localhost -p 2202  # Node 2
```

### Container Shell
```bash
docker compose exec centos9-node-1 bash
docker compose exec centos9-node-2 bash
```

## Testing

### Automated Tests
```bash
python3 test_functional_ci.py
```

### Manual Verification
```bash
# Test SSH connectivity
ssh ansible@localhost -p 2201 "hostname"

# Test sudo access
ssh ansible@localhost -p 2201 "sudo whoami"

# Test network connectivity
docker compose exec centos9-node-1 ping centos9-node-2
```

## Troubleshooting

### Common Issues

**Container startup failure**
- Check Docker daemon status
- Verify port availability
- Review container logs

**SSH connection refused**
- Verify SSH service status
- Check port mapping
- Confirm firewall settings

**Health check failures**
- Review systemd status
- Check service dependencies
- Verify resource availability

### Debug Commands
```bash
# Container logs
docker compose logs centos9-node-1

# Service status
docker compose exec centos9-node-1 systemctl status

# Network connectivity
docker network inspect ansible-network
```

## Development

### Contributing
See [CONTRIBUTING.md](../CONTRIBUTING.md) for development guidelines.

### Testing Framework
- Functional tests: Container operations
- Integration tests: Multi-container scenarios
- Security tests: SSH and user configuration
- Performance tests: Resource utilization

### CI/CD Pipeline
- GitHub Actions automation
- Multi-platform testing
- Automated releases
- Security scanning

## Support

### Documentation
- [README.md](../README.md): Project overview
- [CHANGELOG.md](../CHANGELOG.md): Version history
- [CONTRIBUTING.md](../CONTRIBUTING.md): Development guidelines

### Issues
Report issues via [GitHub Issues](https://github.com/sebastian-alejandro/ansible-docker/issues)
