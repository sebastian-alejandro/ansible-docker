# Ansible Docker Environment

[![Docker](https://img.shields.io/badge/Docker-20.10+-blue.svg)](https://www.docker.com/)
[![CentOS](https://img.shields.io/badge/CentOS-9%20Stream-red.svg)](https://www.centos.org/)
[![Ansible](https://img.shields.io/badge/Ansible-Core-green.svg)](https://www.ansible.com/)
[![Version](https://img.shields.io/badge/Version-1.3.0-success.svg)](https://github.com/sebastian-alejandro/ansible-docker/releases)

## Description

Containerized Ansible lab environment using CentOS 9 Stream with Docker Compose orchestration. Provides isolated, reproducible infrastructure for Ansible automation testing and development.

### Current Status

- **Version**: 1.3.0
- **Base OS**: CentOS 9 Stream
- **Orchestration**: Docker Compose
- **CI/CD**: GitHub Actions automated testing
- **Ansible Control Node**: Included

## Architecture

The current architecture includes a dedicated Ansible Control Node for centralized automation.

```
┌─────────────────────────────────────┐
│            Docker Host              │
│                                     │
│  ┌─────────────────┐                │
│  │ ansible-control │ ←──────────────┤
│  │ Port: 2200      │                │
│  │ SSH: 22         │                │
│  │ Ansible: ✓      │                │
│  └─────────────────┘                │
│           │                         │
│           ├─────────────────────┐   │
│           ▼                     ▼   │
│  ┌─────────────────┐   ┌─────────────────┐
│  │ centos9-node-1  │   │ centos9-node-2  │
│  │ Port: 2201      │   │ Port: 2202      │
│  │ SSH: 22         │   │ SSH: 22         │
│  └─────────────────┘   └─────────────────┘
└─────────────────────────────────────┘
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
docker compose up -d --build
```

### Verify Deployment
```bash
docker compose ps
docker compose logs ansible-control
```

## Usage

### SSH Access

- **Ansible Control Node**: `ssh ansible@localhost -p 2200`
- **Managed Node 1**: `ssh ansible@localhost -p 2201`
- **Managed Node 2**: `ssh ansible@localhost -p 2202`

Default password for all nodes: `ansible123`

### Container Shell Access
```bash
docker compose exec ansible-control bash
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

## Python Scripts for Automation

This project uses a suite of Python scripts for cross-platform automation and CI/CD tasks.

### `automation.py`
A centralized script to run all major project tasks.

**Usage:**
```bash
# Run the full CI/CD pipeline
python automation.py full

# Run only functional tests
python automation.py test

# Run pre-commit validation
python automation.py validate
```

### `test_functional_ci.py`
Executes functional tests, simulating the CI environment locally.

### `pre_commit_check.py`
Validates code and configuration before commits.

### `version_control.py`
Automates versioning, commits, and tagging.

For more details on the Python scripts, see the [Technical Reference](docs/technical-reference.md).

## Documentation

- [**Project Architecture**](docs/project-architecture.md): Detailed architecture and design.
- [**Development Plan**](docs/development-plan-v1.3.0.md): Roadmap for version 1.3.0.
- [**Technical Reference**](docs/technical-reference.md): Commands, scripts, and technical details.
- [**Release Notes**](docs/release-notes.md): Features and updates for the current version.
- [**Change Log**](CHANGELOG.md): History of changes.
- [**Contributing Guidelines**](CONTRIBUTING.md): How to contribute to the project.

## Troubleshooting

### Common Issues

**Container fails to start**
```bash
# Check container logs
docker compose logs <container_name>

# Verify systemd status
docker compose exec <container_name> systemctl status
```

**SSH connection refused**
```bash
# Verify SSH service status
docker compose exec <container_name> systemctl status sshd

# Check port mapping
docker compose ps
```

## Contributing

1. Fork the repository.
2. Create a feature branch: `git checkout -b feature/your-feature`.
3. Commit your changes: `git commit -m 'Add your feature'`.
4. Push to the branch: `git push origin feature/your-feature`.
5. Submit a pull request.

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for more details.

## License

MIT License - see the [LICENSE](LICENSE) file for details.
