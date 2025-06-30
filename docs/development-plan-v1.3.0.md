# Development Plan - Version 1.3.0: Ansible Control Node

## Overview

**Target Version**: 1.3.0  
**Code Name**: Ansible Control Node  
**Estimated Timeline**: 10-15 days  
**Release Date**: Q3 2025  

## Current State Analysis

### Version 1.2.1 (Current)
- ✅ 2 CentOS 9 Stream managed nodes
- ✅ SSH connectivity configured
- ✅ Docker Compose orchestration
- ✅ CI/CD pipeline with automated testing
- ✅ Network communication between containers
- ❌ No dedicated Ansible Control Node
- ❌ No centralized playbook management
- ❌ No automated SSH key distribution

### Version 1.3.0 (Target)
- ✅ Dedicated Ansible Control Node container
- ✅ Automated SSH key generation and distribution
- ✅ Dynamic inventory management
- ✅ Sample playbooks and roles
- ✅ Centralized Ansible automation

## Architecture Design

### Current Architecture
```
┌─────────────────────────┐
│     Docker Host         │
│  ┌─────────────────┐   │
│  │ centos9-node-1  │   │
│  │ Port: 2201      │   │
│  └─────────────────┘   │
│  ┌─────────────────┐   │
│  │ centos9-node-2  │   │
│  │ Port: 2202      │   │
│  └─────────────────┘   │
└─────────────────────────┘
```

### Target Architecture
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

## Implementation Plan

### Phase 1: Architecture Design (1-2 days)

#### Deliverables
- [ ] Dockerfile for Ansible Control Node
- [ ] Updated docker-compose.yml
- [ ] Network and volume configuration
- [ ] Service dependencies definition

#### Technical Specifications

**Dockerfile.control**
```dockerfile
FROM centos:stream9

# Install base packages
RUN dnf update -y && \
    dnf install -y \
    python3 \
    python3-pip \
    openssh-clients \
    openssh-server \
    git \
    sudo \
    && dnf clean all

# Install Ansible Core
RUN pip3 install ansible-core

# Create ansible user
RUN useradd -m -s /bin/bash ansible && \
    echo 'ansible:ansible123' | chpasswd && \
    echo 'ansible ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ansible

# Configure SSH
RUN mkdir -p /home/ansible/.ssh && \
    chown -R ansible:ansible /home/ansible/.ssh && \
    chmod 700 /home/ansible/.ssh

# Create Ansible directory structure
RUN mkdir -p /ansible/{playbooks,roles,inventory,group_vars,host_vars} && \
    chown -R ansible:ansible /ansible

WORKDIR /ansible
USER ansible

# Install Ansible collections
RUN ansible-galaxy collection install community.general ansible.posix

COPY entrypoint-control.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/entrypoint-control.sh"]
```

**docker-compose.yml updates**
```yaml
services:
  ansible-control:
    build:
      context: ./ansible-control
      dockerfile: Dockerfile
    container_name: ansible-control
    hostname: ansible-control
    ports:
      - "2200:22"
    networks:
      - ansible-network
    volumes:
      - ansible-data:/ansible
      - ssh-keys:/home/ansible/.ssh
    environment:
      - ANSIBLE_HOST_KEY_CHECKING=False
      - ANSIBLE_SSH_PIPELINING=True
    depends_on:
      - centos9-node-1
      - centos9-node-2
    healthcheck:
      test: ["CMD", "ansible", "--version"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s

volumes:
  ansible-data:
  ssh-keys:
```

### Phase 2: Core Implementation (3-4 days)

#### Deliverables
- [ ] Ansible Control Node container functional
- [ ] SSH service configured and running
- [ ] Ansible installation validated
- [ ] Basic connectivity to managed nodes

#### Technical Tasks

1. **Create ansible-control directory structure**
```
ansible-control/
├── Dockerfile
├── config/
│   └── ansible.cfg
├── scripts/
│   ├── entrypoint-control.sh
│   ├── generate-ssh-keys.sh
│   └── setup-inventory.sh
└── ansible/
    ├── playbooks/
    ├── roles/
    ├── inventory/
    └── group_vars/
```

2. **Configure Ansible settings**
```ini
# ansible-control/config/ansible.cfg
[defaults]
inventory = /ansible/inventory/hosts.yml
remote_user = ansible
private_key_file = /home/ansible/.ssh/id_rsa
host_key_checking = False
retry_files_enabled = False
stdout_callback = yaml
bin_ansible_callbacks = True

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
pipelining = True
```

3. **Container initialization script**
```bash
#!/bin/bash
# ansible-control/scripts/entrypoint-control.sh

# Start SSH service
sudo systemctl start sshd
sudo systemctl enable sshd

# Generate SSH keys if not exist
if [ ! -f /home/ansible/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -f /home/ansible/.ssh/id_rsa -N ""
    chmod 600 /home/ansible/.ssh/id_rsa
    chmod 644 /home/ansible/.ssh/id_rsa.pub
fi

# Wait for managed nodes to be ready
echo "Waiting for managed nodes..."
sleep 30

# Setup inventory
/ansible/scripts/setup-inventory.sh

# Keep container running
exec "$@"
```

### Phase 3: SSH Automation (2-3 days)

#### Deliverables
- [ ] Automated SSH key generation
- [ ] SSH key distribution to managed nodes
- [ ] Passwordless SSH connectivity validated
- [ ] Dynamic inventory configuration

#### Technical Implementation

1. **SSH Key Distribution Script**
```bash
#!/bin/bash
# ansible-control/scripts/distribute-ssh-keys.sh

MANAGED_NODES=("centos9-node-1" "centos9-node-2")
SSH_PASSWORD="ansible123"

for node in "${MANAGED_NODES[@]}"; do
    echo "Distributing SSH key to $node..."
    
    # Wait for node to be ready
    until nc -z $node 22; do
        echo "Waiting for $node SSH service..."
        sleep 5
    done
    
    # Copy SSH key
    sshpass -p "$SSH_PASSWORD" ssh-copy-id \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        ansible@$node
    
    if [ $? -eq 0 ]; then
        echo "✅ SSH key distributed to $node"
    else
        echo "❌ Failed to distribute SSH key to $node"
    fi
done
```

2. **Dynamic Inventory Script**
```python
#!/usr/bin/env python3
# ansible-control/scripts/dynamic-inventory.py

import json
import subprocess
import socket

def check_host_connectivity(hostname, port=22):
    """Check if host is reachable on SSH port"""
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(5)
        result = sock.connect_ex((hostname, port))
        sock.close()
        return result == 0
    except:
        return False

def get_managed_nodes():
    """Get list of managed nodes from Docker network"""
    nodes = []
    managed_hosts = ["centos9-node-1", "centos9-node-2"]
    
    for host in managed_hosts:
        if check_host_connectivity(host):
            nodes.append(host)
    
    return nodes

def generate_inventory():
    """Generate Ansible inventory"""
    managed_nodes = get_managed_nodes()
    
    inventory = {
        "managed_nodes": {
            "hosts": managed_nodes,
            "vars": {
                "ansible_user": "ansible",
                "ansible_ssh_private_key_file": "/home/ansible/.ssh/id_rsa",
                "ansible_ssh_common_args": "-o StrictHostKeyChecking=no"
            }
        },
        "_meta": {
            "hostvars": {}
        }
    }
    
    # Add host-specific variables
    for i, node in enumerate(managed_nodes, 1):
        inventory["_meta"]["hostvars"][node] = {
            "node_id": i,
            "ssh_port": 22,
            "environment": "lab"
        }
    
    return inventory

if __name__ == "__main__":
    print(json.dumps(generate_inventory(), indent=2))
```

### Phase 4: Playbooks and Roles (2-3 days)

#### Deliverables
- [ ] Sample playbooks for common tasks
- [ ] Reusable Ansible roles
- [ ] Health check automation
- [ ] System configuration examples

#### Ansible Structure
```
ansible/
├── ansible.cfg
├── site.yml                    # Main playbook
├── playbooks/
│   ├── setup.yml              # Initial setup
│   ├── health-check.yml       # Health monitoring
│   ├── update-systems.yml     # System updates
│   └── security-hardening.yml # Security configuration
├── roles/
│   ├── common/                # Common system configuration
│   │   ├── tasks/main.yml
│   │   ├── handlers/main.yml
│   │   ├── vars/main.yml
│   │   └── templates/
│   ├── monitoring/            # System monitoring setup
│   │   ├── tasks/main.yml
│   │   └── templates/
│   └── security/              # Security hardening
│       ├── tasks/main.yml
│       └── templates/
├── inventory/
│   ├── hosts.yml              # Static inventory
│   └── dynamic.py             # Dynamic inventory script
└── group_vars/
    ├── all.yml                # Global variables
    └── managed_nodes.yml      # Managed nodes variables
```

#### Sample Playbooks

**site.yml - Main Playbook**
```yaml
---
- name: Configure Ansible Lab Environment
  hosts: managed_nodes
  become: yes
  gather_facts: yes
  
  roles:
    - common
    - monitoring
  
  post_tasks:
    - name: Restart services if needed
      meta: flush_handlers

- name: Validate Environment Health
  hosts: managed_nodes
  tasks:
    - name: Check system health
      include: playbooks/health-check.yml
```

**playbooks/health-check.yml**
```yaml
---
- name: System Health Check
  block:
    - name: Check disk usage
      shell: df -h /
      register: disk_usage
      
    - name: Check memory usage
      shell: free -h
      register: memory_usage
      
    - name: Check running services
      systemd:
        name: "{{ item }}"
        state: started
      loop:
        - sshd
        - systemd-logind
      
    - name: Display system status
      debug:
        msg: |
          Disk Usage: {{ disk_usage.stdout }}
          Memory Usage: {{ memory_usage.stdout }}
          
    - name: Connectivity test
      ping:
      register: ping_result
      
    - name: Report health status
      debug:
        msg: "✅ Node {{ inventory_hostname }} is healthy"
      when: ping_result is succeeded
```

**roles/common/tasks/main.yml**
```yaml
---
- name: Update system packages
  dnf:
    name: "*"
    state: latest
    update_cache: yes
  tags: [system, updates]

- name: Install essential packages
  dnf:
    name:
      - vim
      - htop
      - curl
      - wget
      - git
      - net-tools
      - lsof
    state: present
  tags: [packages]

- name: Configure timezone
  timezone:
    name: UTC
  notify: restart chronyd
  tags: [system]

- name: Ensure services are running
  systemd:
    name: "{{ item }}"
    state: started
    enabled: yes
  loop:
    - sshd
    - chronyd
  tags: [services]
```

### Phase 5: Testing and CI/CD Integration (2-3 days)

#### Deliverables
- [ ] Updated functional tests
- [ ] Ansible-specific test cases
- [ ] CI/CD pipeline integration
- [ ] Performance validation

#### Test Implementation

**Updated test_functional_ci.py**
```python
def test_ansible_control_node_startup():
    """Test Ansible Control Node starts correctly"""
    result = subprocess.run([
        'docker', 'compose', 'ps', '--filter', 'name=ansible-control'
    ], capture_output=True, text=True)
    
    assert 'ansible-control' in result.stdout
    assert 'Up' in result.stdout

def test_ansible_installation():
    """Test Ansible is properly installed"""
    result = subprocess.run([
        'docker', 'compose', 'exec', '-T', 'ansible-control', 
        'ansible', '--version'
    ], capture_output=True, text=True)
    
    assert result.returncode == 0
    assert 'ansible' in result.stdout.lower()

def test_ssh_key_generation():
    """Test SSH keys are generated automatically"""
    result = subprocess.run([
        'docker', 'compose', 'exec', '-T', 'ansible-control',
        'test', '-f', '/home/ansible/.ssh/id_rsa'
    ], capture_output=True, text=True)
    
    assert result.returncode == 0

def test_managed_nodes_connectivity():
    """Test Ansible can connect to managed nodes"""
    result = subprocess.run([
        'docker', 'compose', 'exec', '-T', 'ansible-control',
        'ansible', 'managed_nodes', '-m', 'ping'
    ], capture_output=True, text=True)
    
    assert result.returncode == 0
    assert 'SUCCESS' in result.stdout

def test_dynamic_inventory():
    """Test dynamic inventory script"""
    result = subprocess.run([
        'docker', 'compose', 'exec', '-T', 'ansible-control',
        'ansible-inventory', '--list'
    ], capture_output=True, text=True)
    
    assert result.returncode == 0
    inventory_data = json.loads(result.stdout)
    assert 'managed_nodes' in inventory_data
    assert 'centos9-node-1' in inventory_data['managed_nodes']['hosts']

def test_sample_playbook_execution():
    """Test sample playbook can be executed"""
    result = subprocess.run([
        'docker', 'compose', 'exec', '-T', 'ansible-control',
        'ansible-playbook', '/ansible/playbooks/health-check.yml'
    ], capture_output=True, text=True)
    
    assert result.returncode == 0
    assert 'PLAY RECAP' in result.stdout
```

#### CI/CD Pipeline Updates

**GitHub Actions Integration**
```yaml
# .github/workflows/ci-cd.yml - new job
ansible-control-tests:
  name: 🎯 Ansible Control Node Tests
  runs-on: ubuntu-latest
  needs: build-tests
  
  steps:
    - name: 📥 Checkout code
      uses: actions/checkout@v4
      
    - name: 📦 Download image artifacts
      uses: actions/download-artifact@v4
      with:
        name: container-images
        path: /tmp
        
    - name: 🔄 Load Docker images
      run: |
        docker load -i /tmp/centos9-image.tar
        docker load -i /tmp/ansible-control-image.tar
        
    - name: 🚀 Start complete environment
      run: |
        docker compose up -d
        sleep 60  # Wait for initialization
        
    - name: 🔍 Test Ansible Control Node
      run: |
        echo "Testing Ansible installation..."
        docker compose exec -T ansible-control ansible --version
        
        echo "Testing SSH key generation..."
        docker compose exec -T ansible-control test -f /home/ansible/.ssh/id_rsa
        
        echo "Testing inventory..."
        docker compose exec -T ansible-control ansible-inventory --list
        
    - name: 🎯 Test Managed Nodes Connectivity
      run: |
        echo "Testing Ansible connectivity to managed nodes..."
        docker compose exec -T ansible-control ansible managed_nodes -m ping
        
    - name: 📋 Execute Sample Playbook
      run: |
        echo "Executing health check playbook..."
        docker compose exec -T ansible-control ansible-playbook \
          /ansible/playbooks/health-check.yml -v
          
    - name: 🧹 Cleanup
      if: always()
      run: |
        docker compose down -v --remove-orphans || true
        docker system prune -f || true
```

## Success Criteria

### Functional Requirements
- [ ] Ansible Control Node container starts successfully
- [ ] SSH connectivity established between control node and managed nodes
- [ ] Dynamic inventory correctly identifies managed nodes
- [ ] Sample playbooks execute without errors
- [ ] Health checks report correct system status
- [ ] CI/CD pipeline validates all Ansible functionality

### Performance Requirements
- [ ] Container startup time < 90 seconds
- [ ] SSH key distribution completes < 60 seconds
- [ ] Playbook execution performance acceptable (< 30s for basic tasks)
- [ ] Memory usage per container < 512MB

### Quality Requirements
- [ ] All automated tests pass
- [ ] Code coverage maintained > 90%
- [ ] Documentation updated and comprehensive
- [ ] Security best practices implemented

## Risk Assessment and Mitigation

### Technical Risks
1. **SSH Key Distribution Timing Issues**
   - *Risk*: Keys distributed before managed nodes are ready
   - *Mitigation*: Implement robust retry logic and health checks

2. **Container Dependencies**
   - *Risk*: Ansible control node starts before managed nodes
   - *Mitigation*: Use depends_on and health checks in docker-compose

3. **Network Connectivity**
   - *Risk*: DNS resolution issues between containers
   - *Mitigation*: Use explicit container names and network configuration

### Integration Risks
1. **CI/CD Pipeline Complexity**
   - *Risk*: Increased pipeline execution time
   - *Mitigation*: Parallel job execution and optimized testing

2. **Backward Compatibility**
   - *Risk*: Breaking changes to existing functionality
   - *Mitigation*: Comprehensive regression testing

## Documentation Updates

### Files to Update
- [ ] README.md - Add Ansible Control Node usage instructions
- [ ] docs/technical-reference.md - Add Ansible command reference
- [ ] docs/release-notes.md - Document v1.3.0 features
- [ ] CHANGELOG.md - Add detailed change log entry

### New Documentation
- [ ] docs/ansible-guide.md - Comprehensive Ansible usage guide
- [ ] docs/playbook-examples.md - Sample playbook documentation
- [ ] docs/troubleshooting-ansible.md - Ansible-specific troubleshooting

## Release Planning

### Pre-Release Checklist
- [ ] All functional tests passing
- [ ] Performance benchmarks validated
- [ ] Security review completed
- [ ] Documentation updated
- [ ] CI/CD pipeline stable

### Release Steps
1. Create release branch `release/v1.3.0`
2. Final testing and validation
3. Update version numbers and documentation
4. Create release tag and GitHub release
5. Update main branch with release changes

### Post-Release
- [ ] Monitor deployment success metrics
- [ ] Gather user feedback
- [ ] Plan for v1.4.0 features

## Timeline Summary

| Week | Phase | Key Deliverables |
|------|-------|------------------|
| Week 1 | Design + Core Implementation | Dockerfile, docker-compose.yml, basic container |
| Week 2 | SSH Automation + Playbooks | Key distribution, inventory, sample playbooks |
| Week 3 | Testing + Documentation | Test suite, CI/CD integration, docs |

**Total Effort**: 2-3 weeks  
**Target Release**: End of Q3 2025
