#!/bin/bash
# ===================================
# Health Check Script para CentOS 9 Container
# ===================================

# Función para logging
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - HEALTH CHECK: $1"
}

log_message "Starting health check..."

# Verificar procesos básicos del sistema
if ! pgrep -f systemd > /dev/null; then
    log_message "ERROR: systemd is not running"
    exit 1
fi

# Verificar que SSH esté ejecutándose (con retry y más tolerancia)
SSH_RETRIES=5
SSH_ACTIVE=false
for i in $(seq 1 $SSH_RETRIES); do
    # Verificar tanto el servicio como el proceso
    if systemctl is-active --quiet sshd 2>/dev/null || pgrep -f sshd > /dev/null; then
        SSH_ACTIVE=true
        break
    else
        log_message "SSH service not active yet (attempt $i/$SSH_RETRIES)"
        sleep 3
    fi
done

if [ "$SSH_ACTIVE" = false ]; then
    log_message "ERROR: SSH service is not running after $SSH_RETRIES attempts"
    systemctl status sshd || true
    exit 1
fi

log_message "SSH service is active"

# Verificar que el puerto SSH esté escuchando (con retry)
PORT_RETRIES=5
PORT_LISTENING=false
for i in $(seq 1 $PORT_RETRIES); do
    if netstat -tuln 2>/dev/null | grep -q ":22 " || ss -tuln 2>/dev/null | grep -q ":22 "; then
        PORT_LISTENING=true
        break
    else
        log_message "SSH port not listening yet (attempt $i/$PORT_RETRIES)"
        sleep 3
    fi
done

if [ "$PORT_LISTENING" = false ]; then
    log_message "ERROR: SSH port 22 is not listening after $PORT_RETRIES attempts"
    netstat -tuln 2>/dev/null || ss -tuln 2>/dev/null || true
    exit 1
fi

log_message "SSH port 22 is listening"

# Verificar que el usuario ansible existe
if ! id ansible &>/dev/null; then
    log_message "ERROR: Ansible user does not exist"
    exit 1
fi

log_message "Ansible user exists"

# Verificar acceso al directorio home del usuario ansible
if [ ! -d "/home/ansible" ]; then
    log_message "ERROR: Ansible user home directory does not exist"
    exit 1
fi

log_message "Ansible home directory exists"

# Verificar que Python3 esté disponible
if ! which python3 &>/dev/null; then
    log_message "ERROR: Python3 is not available"
    exit 1
fi

log_message "Python3 is available"

# Todo OK
log_message "Health check passed: Container is healthy"
exit 0
