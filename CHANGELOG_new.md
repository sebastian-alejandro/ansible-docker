# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.1] - 2025-06-27

### Fixed
- CI/CD pipeline netcat package installation error
- Replaced generic `netcat` package with `netcat-openbsd` in ci-cd.yml workflow
- Resolved "Package 'netcat' has no installation candidate" error in Ubuntu runners
- Aligned package configuration with integration-tests.yml for consistency

### Technical Details
- `netcat` is a virtual package in Ubuntu/Debian requiring specific implementation
- Used `netcat-openbsd` as standard implementation across all workflows
- Fixed port mapping tests in CI/CD pipeline

## [1.2.0] - 2025-06-26

### Fixed
- Docker build critical error with curl package conflicts
- Added `epel-release` repository for additional packages
- Removed deprecated `version` attribute in docker-compose.yml
- Fixed health check syntax for Docker Compose compatibility
- Resolved "failed to solve: exit code: 1" in GitHub Actions

### Technical Details
- Optimized package installation layers
- Explicit removal of `curl-minimal` before installing full `curl`
- Docker Compose v2.x compatibility validation
- Fixed health check format for proper container monitoring

### Testing
- Local container build verification
- Package installation validation
- Docker Compose compatibility verification

## [1.1.2] - 2025-06-25

### Fixed
- Container startup issues with systemd
- SSH service initialization in CI environments
- Health check timeout adjustments

### Added
- Fallback mode for containers without systemd
- Enhanced container initialization logging
- Improved error handling in startup scripts

## [1.1.1] - 2025-06-24

### Fixed
- SSH key generation and distribution
- Container networking issues
- Port mapping configuration

### Changed
- Improved container health checks
- Enhanced logging for debugging
- Updated documentation formatting

## [1.1.0] - 2025-06-23

### Added
- Multi-container Docker Compose setup
- Health checks for all containers
- SSH password authentication
- User configuration with sudo privileges

### Changed
- Migrated from single container to orchestrated environment
- Updated base image configuration
- Improved network isolation

## [1.0.1] - 2025-06-22

### Fixed
- Container initialization scripts
- SSH service configuration
- User privilege escalation

## [1.0.0] - 2025-06-21

### Added
- Initial release
- CentOS 9 Stream base container
- SSH server configuration
- Basic user setup
- Docker Compose orchestration
- GitHub Actions CI/CD pipeline

### Features
- Containerized Ansible lab environment
- SSH access with password authentication
- Automated testing suite
- Cross-platform compatibility
