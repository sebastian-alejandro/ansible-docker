#!/bin/bash
# ===================================
# Script de inicialización para CentOS 9 Container
# ===================================

set -e

echo "=== Iniciando CentOS 9 Container para Ansible ===" | tee -a /var/log/ansible/init.log

# Función para logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a /var/log/ansible/init.log
}

# Verificar y configurar SSH
log "Configurando SSH..."
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    ssh-keygen -A
fi

# Configurar permisos SSH
chmod 600 /etc/ssh/ssh_host_*_key
chmod 644 /etc/ssh/ssh_host_*_key.pub

# Crear directorio de logs si no existe
mkdir -p /var/log/ansible
chown ansible:ansible /var/log/ansible

# Configurar timezone (opcional)
if [ -n "$TZ" ]; then
    log "Configurando timezone: $TZ"
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
    echo $TZ > /etc/timezone
fi

# Configurar hostname si se proporciona
if [ -n "$HOSTNAME" ]; then
    log "Configurando hostname: $HOSTNAME"
    hostnamectl set-hostname $HOSTNAME
fi

# Verificar conectividad de red
log "Verificando conectividad de red..."
if ping -c 1 8.8.8.8 &> /dev/null; then
    log "Conectividad de red: OK"
else
    log "WARNING: Sin conectividad externa"
fi

# Inicializar servicios
log "Iniciando servicios..."
systemctl start sshd
systemctl start crond

# Mostrar información del sistema
log "=== Información del Sistema ==="
log "Hostname: $(hostname)"
log "IP Address: $(hostname -I | awk '{print $1}')"
log "CentOS Version: $(cat /etc/centos-release)"
log "Python Version: $(python3 --version)"
log "SSH Status: $(systemctl is-active sshd)"

# Mostrar usuarios configurados
log "=== Usuarios Configurados ==="
log "Usuario ansible: $(id ansible)"
log "Usuario root: $(id root)"

log "=== Container iniciado correctamente ==="

# Ejecutar comando principal
exec "$@"
