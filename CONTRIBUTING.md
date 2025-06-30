# Contributing Guidelines

## Overview

Contributions to the Ansible Docker Environment project are welcome. Please follow these guidelines to ensure consistent code quality and project standards.

## How to Contribute

### Bug Reports
1. Check existing issues before creating new ones
2. Use the bug report template
3. Include environment details and logs
4. Provide steps to reproduce the issue

### Feature Requests
1. Use the feature request template
2. Clearly describe the problem being solved
3. Provide use case examples
4. Consider impact on existing architecture

### Pull Requests
1. Fork the repository
2. Create feature branch from `main`
3. Follow coding standards
4. Add appropriate tests
5. Update documentation
6. Submit pull request

## Project Structure

```
ansible_docker/
├── centos9/                    # CentOS 9 container
├── ansible-control/            # Ansible control container
├── docs/                       # Documentation
├── .github/                    # CI/CD workflows
├── docker-compose.yml          # Service orchestration
└── manage-sprint2.sh           # Management scripts
```

## Development Standards

### Dockerfiles
- Use multi-stage builds when applicable
- Include descriptive comments
- Optimize layers and image size
- Include health checks
- Follow security best practices

### Shell Scripts
- Use descriptive function names
- Include error handling
- Add usage documentation
- Follow POSIX compliance when possible

### Docker Compose
- Use version 3.8+ format
- Include health checks
- Define explicit networks
- Use environment variables for configuration

### Documentation
- Use clear, concise technical language
- Include code examples
- Update version numbers appropriately
- Maintain consistent formatting

## Testing Requirements

### Functional Tests
```bash
# Run test suite
python3 test_functional_ci.py

# Manual verification
docker compose up -d
docker compose ps
```

### CI/CD Pipeline
- All tests must pass in GitHub Actions
- Include both unit and integration tests
- Verify cross-platform compatibility

### Security Testing
- Container security scanning
- SSH configuration validation
- Network isolation verification

## Code Review Process

1. **Automated Checks**: All CI/CD tests must pass
2. **Peer Review**: At least one approval required
3. **Documentation**: Updates must include relevant docs
4. **Testing**: New features require test coverage

## Commit Message Format

```
type(scope): description

- Use imperative mood
- Keep first line under 50 characters
- Include detailed explanation if needed
```

Examples:
```
fix(docker): resolve netcat package installation
feat(ansible): add control node configuration
docs(readme): update installation instructions
```

## Branch Naming

- `feature/description` - New features
- `fix/description` - Bug fixes
- `docs/description` - Documentation updates
- `refactor/description` - Code refactoring

## Version Management

- Follow semantic versioning (MAJOR.MINOR.PATCH)
- Update CHANGELOG.md for all releases
- Tag releases in git
- Update version badges in README

## Environment Setup

### Development Requirements
- Docker Engine 20.10+
- Docker Compose v2.0+
- Git 2.30+
- Python 3.8+ (for testing)

### Local Development
```bash
# Clone repository
git clone https://github.com/sebastian-alejandro/ansible-docker.git
cd ansible-docker

# Start development environment
docker compose up -d

# Run tests
python3 test_functional_ci.py
```

## Issue Templates

Use the provided issue templates:
- [Bug Report](.github/ISSUE_TEMPLATE/bug_report.md)
- [Feature Request](.github/ISSUE_TEMPLATE/feature_request.md)

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Questions

For questions about contributing, please open an issue with the "question" label.
