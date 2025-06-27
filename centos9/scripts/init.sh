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

# Crear directorio de logs si no existe
mkdir -p /var/log/ansible
chown ansible:ansible /var/log/ansible 2>/dev/null || true

# Inicializar systemd si no está corriendo (para CI/CD)
if ! pgrep -f systemd > /dev/null; then
    log "Iniciando systemd..."
    exec /sbin/init &
    sleep 3
fi

# Esperar a que systemd esté listo
log "Esperando a que systemd esté listo..."
timeout 30 bash -c 'while ! systemctl is-system-running --wait > /dev/null 2>&1; do sleep 1; done' || true

# Verificar y configurar SSH
log "Configurando SSH..."
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    ssh-keygen -A
fi

# Configurar permisos SSH
chmod 600 /etc/ssh/ssh_host_*_key
chmod 644 /etc/ssh/ssh_host_*_key.pub

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

# Habilitar servicios primero
systemctl enable sshd || true
systemctl enable crond || true

# Iniciar servicios con retry
for service in sshd crond; do
    log "Iniciando $service..."
    for i in {1..3}; do
        if systemctl start $service; then
            log "$service iniciado correctamente"
            break
        else
            log "Intento $i falló para $service, reintentando..."
            sleep 2
        fi
    done
done

# Verificar que SSH esté escuchando
log "Verificando puerto SSH..."
for i in {1..10}; do
    if netstat -tlnp | grep :22; then
        log "SSH está escuchando en puerto 22"
        break
    else
        log "Esperando SSH... intento $i/10"
        sleep 2
    fi
done

# Mostrar información del sistema
log "=== Información del Sistema ==="
log "Hostname: $(hostname)"
log "IP Address: $(hostname -I | awk '{print $1}' || echo 'N/A')"
log "CentOS Version: $(cat /etc/centos-release)"
log "Python Version: $(python3 --version)"
log "SSH Status: $(systemctl is-active sshd || echo 'inactive')"

# Mostrar usuarios configurados
log "=== Usuarios Configurados ==="
log "Usuario ansible: $(id ansible 2>/dev/null || echo 'No encontrado')"
log "Usuario root: $(id root 2>/dev/null || echo 'No encontrado')"

log "=== Container iniciado correctamente ==="

# Si estamos en modo daemon (sin argumentos), mantener corriendo
if [ $# -eq 0 ] || [ "$1" = "/usr/sbin/sshd" ]; then
    log "Ejecutando en modo daemon..."
    # Mantener el container ejecutándose
    exec /usr/sbin/sshd -D
else
    # Ejecutar comando especificado
    log "Ejecutando comando: $@"
    exec "$@"
fi
