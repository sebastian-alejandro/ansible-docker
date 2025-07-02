#!/bin/bash
# ===================================
# Script de inicialización para CentOS 9 Container
# ===================================

set -e

# Configurar locale
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

echo "=== Iniciando CentOS 9 Container para Ansible ===" | tee -a /var/log/ansible/init.log

# Función para logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a /var/log/ansible/init.log
}

# Crear directorio de logs si no existe
mkdir -p /var/log/ansible
chown ansible:ansible /var/log/ansible 2>/dev/null || true

# Verificar si systemd está disponible y no está ejecutándose como PID 1
if [ "$$" != "1" ] && command -v systemctl &> /dev/null; then
    log "Detectado systemd disponible pero no como PID 1"
    # En este caso, inicializar systemd
    log "Iniciando systemd..."
    exec /sbin/init "$@"
fi

# Si llegamos aquí, somos PID 1 o systemd no está disponible
log "Ejecutándose como PID 1 o sin systemd"

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
    ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime
    echo "$TZ" > /etc/timezone
fi

# Configurar hostname si se proporciona
if [ -n "$HOSTNAME" ]; then
    log "Configurando hostname: $HOSTNAME"
    echo "$HOSTNAME" > /etc/hostname
    hostname "$HOSTNAME"
fi

# Verificar conectividad de red (opcional, no crítico)
log "Verificando conectividad de red..."
if timeout 5 ping -c 1 8.8.8.8 &> /dev/null; then
    log "Conectividad de red: OK"
else
    log "WARNING: Sin conectividad externa"
fi

# Inicializar servicios
log "Iniciando servicios..."

# Verificar si systemctl está disponible
if command -v systemctl &> /dev/null; then
    # Esperar a que systemd esté listo (si estamos usando systemd)
    log "Esperando a que systemd esté listo..."
    timeout 60 bash -c 'while ! systemctl is-system-running --wait &>/dev/null; do sleep 1; done' || {
        log "WARNING: systemd no está completamente listo, continuando..."
    }
    
    # Habilitar servicios primero
    systemctl enable sshd || true
    systemctl enable crond || true
    
    # Iniciar servicios con retry
    for service in sshd crond; do
        log "Iniciando $service..."
        for i in {1..5}; do
            if systemctl start "$service" 2>/dev/null; then
                log "$service iniciado correctamente"
                break
            else
                log "Intento $i falló para $service, reintentando..."
                sleep 3
            fi
        done
    done
else
    # Fallback sin systemd
    log "systemctl no disponible, iniciando servicios manualmente..."
    /usr/sbin/sshd -D &
    /usr/sbin/crond &
fi

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
