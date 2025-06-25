#!/bin/bash
# ===================================
# Health Check Script para CentOS 9 Container
# ===================================

# Verificar que SSH esté ejecutándose
if ! systemctl is-active --quiet sshd; then
    echo "ERROR: SSH service is not running"
    exit 1
fi

# Verificar que el puerto SSH esté escuchando
if ! netstat -tuln | grep -q ":22 "; then
    echo "ERROR: SSH port 22 is not listening"
    exit 1
fi

# Verificar que el usuario ansible existe
if ! id ansible &>/dev/null; then
    echo "ERROR: Ansible user does not exist"
    exit 1
fi

# Verificar acceso al directorio home del usuario ansible
if [ ! -d "/home/ansible" ]; then
    echo "ERROR: Ansible user home directory does not exist"
    exit 1
fi

# Verificar que Python3 esté disponible
if ! which python3 &>/dev/null; then
    echo "ERROR: Python3 is not available"
    exit 1
fi

# Todo OK
echo "Health check passed: Container is healthy"
exit 0
