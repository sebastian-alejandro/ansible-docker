# Ansible Docker Environment

[![Docker](https://img.shields.io/badge/Docker-20.10+-blue.svg)](https://www.docker.com/)
[![CentOS](https://img.shields.io/badge/CentOS-9%20Stream-red.svg)](https://www.centos.org/)
[![Ansible](https://img.shields.io/badge/Ansible-Core-green.svg)](https://www.ansible.com/)
[![Version](https://img.shields.io/badge/Version-1.2.1-success.svg)](https://github.com/sebastian-alejandro/ansible-docker/releases)

## Description

Containerized Ansible lab environment using CentOS 9 Stream with Docker Compose orchestration. Provides isolated, reproducible infrastructure for Ansible automation testing and development.

### Current Status

- **Version**: 1.2.1
- **Base OS**: CentOS 9 Stream  
- **Orchestration**: Docker Compose
- **CI/CD**: GitHub Actions automated testing

## Architecture

```
┌─────────────────────────┐
│     Docker Host         │
│                         │
│  ┌─────────────────┐   │
│  │ centos9-node-1  │   │
│  │ Port: 2201      │   │
│  │ SSH: 22         │   │
│  └─────────────────┘   │
│  ┌─────────────────┐   │
│  │ centos9-node-2  │   │
│  │ Port: 2202      │   │
│  │ SSH: 22         │   │
│  └─────────────────┘   │
└─────────────────────────┘
```

## Requirements

- Docker Engine 20.10+
- Docker Compose v2.0+
- 2GB RAM minimum
- 5GB disk space

## Installation

### Clone Repository
```bash
git clone https://github.com/sebastian-alejandro/ansible-docker.git
cd ansible-docker
```

### Start Environment
```bash
docker compose up -d
```

### Verify Deployment
```bash
docker compose ps
docker compose logs
```

## Usage

### SSH Access
```bash
# Node 1
ssh ansible@localhost -p 2201

# Node 2  
ssh ansible@localhost -p 2202

# Default password: ansible123
```

### Container Shell Access
```bash
docker compose exec centos9-node-1 bash
docker compose exec centos9-node-2 bash
```

### Management Commands
```bash
# Start environment
docker compose up -d

# Stop environment  
docker compose down

# View logs
docker compose logs

# Rebuild containers
docker compose up -d --build
```

## Configuration

### Container Specifications
- **Base OS**: CentOS 9 Stream
- **SSH User**: ansible (passwordless sudo)
- **SSH Password**: ansible123
- **Network**: ansible-network (bridge)
- **Health Checks**: Enabled for all containers

### Ports Configuration
| Container | SSH Port | Status |
|-----------|----------|--------|
| centos9-node-1 | 2201 | Active |
| centos9-node-2 | 2202 | Active |

### Security Configuration
- SSH password authentication enabled
- SSH public key authentication enabled  
- User 'ansible' in wheel group with NOPASSWD sudo
- Container runs with systemd when available

## Testing

### Automated Testing
```bash
# Run functional tests
python3 test_functional_ci.py

# Check container health
docker compose ps
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

## Documentation

- [Installation Guide](docs/README.md)
- [Change Log](CHANGELOG.md)
- [Contributing Guidelines](CONTRIBUTING.md)

## Troubleshooting

### Common Issues

**Container fails to start**
```bash
# Check container logs
docker compose logs centos9-node-1

# Verify systemd status
docker compose exec centos9-node-1 systemctl status
```

**SSH connection refused**
```bash
# Verify SSH service status
docker compose exec centos9-node-1 systemctl status sshd

# Check port mapping
docker compose ps
```

**Health check failing**
```bash
# Manual health check
docker compose exec centos9-node-1 systemctl is-system-running

# Restart container
docker compose restart centos9-node-1
```

## Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/name`
3. Commit changes: `git commit -m 'Add feature'`
4. Push to branch: `git push origin feature/name`
5. Submit pull request

## License

MIT License - see [LICENSE](LICENSE) file for details.
