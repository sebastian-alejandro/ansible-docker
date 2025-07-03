# Technical Reference

## Docker Command Reference

### Basic Environment Management
```bash
# Start environment
docker compose up -d

# Stop environment
docker compose down

# View container status
docker compose ps

# View logs
docker compose logs

# Follow logs in real-time
docker compose logs -f
```

### Individual Container Management
```bash
# Start specific container
docker compose up -d centos9-node-1

# Stop specific container
docker compose stop centos9-node-1

# Restart specific container
docker compose restart centos9-node-1

# Access container shell
docker compose exec centos9-node-1 bash

# Execute command in container
docker compose exec centos9-node-1 systemctl status sshd
```

### Development Commands
```bash
# Rebuild images
docker compose build

# Rebuild specific image
docker compose build centos9-node-1

# Force rebuild without cache
docker compose build --no-cache

# Pull latest base images
docker compose pull
```

### Testing and Verification
```bash
# Test SSH connectivity
ssh ansible@localhost -p 2201 "hostname"

# Test sudo access
ssh ansible@localhost -p 2202 "sudo whoami"

# Test network connectivity
docker compose exec centos9-node-1 ping centos9-node-2

# Check container health
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
```

### Scaling Operations
```bash
# Scale specific service
docker compose up -d --scale centos9-node-1=3

# View scaled containers
docker compose ps

# Scale down
docker compose up -d --scale centos9-node-1=1
```

### Debugging and Troubleshooting
```bash
# Container resource usage
docker stats

# Detailed container information
docker inspect centos9-node-1

# Network information
docker network ls
docker network inspect ansible-network

# Volume information
docker volume ls
docker volume inspect ansible_docker_ansible-data
```

### Maintenance and Cleanup
```bash
# Remove stopped containers
docker compose rm

# Remove all project containers and networks
docker compose down --remove-orphans

# Clean up Docker system
docker system prune

# Remove unused images
docker image prune

# Remove unused volumes
docker volume prune
```

### Advanced Operations
```bash
# View container processes
docker compose top

# Export container configuration
docker compose config

# Validate compose file
docker compose config --quiet

# Create and start specific services
docker compose create centos9-node-1
docker compose start centos9-node-1
```

## Security Considerations

### Container Security
- Containers run with minimal privileges where possible
- SSH access restricted to ansible user
- Network isolation between containers and host
- Regular security updates via base image updates

### SSH Security
- Default passwords should be changed in production environments
- SSH key authentication recommended over password authentication
- Regular key rotation in production deployments
- SSH configuration hardening for production use

### Network Security
- Isolated container networks with minimal port exposure
- Traffic encryption for sensitive data transmission
- Access logging and monitoring capabilities
- Firewall configuration for production deployments

## Performance Optimization

### Resource Management
- Container resource limits configuration
- Memory and CPU usage monitoring
- Disk space management and cleanup
- Network performance tuning

### Container Optimization
- Multi-stage builds for smaller images
- Layer caching for faster builds
- Volume management for data persistence
- Health checks for automatic recovery

## Monitoring and Logging

### Health Monitoring
```bash
# Check container health status
docker compose ps

# View health check logs
docker inspect --format='{{.State.Health}}' centos9-node-1

# Monitor resource usage
docker stats --no-stream
```

### Log Management
```bash
# View container logs
docker compose logs centos9-node-1

# Filter logs by time
docker compose logs --since 30m centos9-node-1

# Export logs to file
docker compose logs centos9-node-1 > container.log
```
