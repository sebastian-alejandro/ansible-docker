#!/bin/bash
# Script de inicialización del nodo de control de Ansible

set -e

echo "🚀 Iniciando Nodo de Control de Ansible..."

# Función para logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Verificar que estamos ejecutando como root inicialmente
if [ "$EUID" -ne 0 ]; then
    log "❌ Este script debe ejecutarse como root inicialmente"
    exit 1
fi

# Inicializar systemd si no está corriendo
if ! pgrep -f systemd > /dev/null; then
    log "🔧 Iniciando systemd..."
    exec /sbin/init &
    sleep 2
fi

# Esperar a que systemd esté listo
log "⏳ Esperando a que systemd esté listo..."
while ! systemctl is-system-running --wait > /dev/null 2>&1; do
    sleep 1
done

# Iniciar SSH daemon
log "🔐 Iniciando SSH daemon..."
systemctl start sshd
systemctl enable sshd

# Generar claves SSH para el usuario ansible si no existen
log "🔑 Configurando claves SSH para usuario ansible..."
su - ansible -c "/usr/local/bin/generate-ssh-keys.sh"

# Generar inventario inicial
log "📋 Generando inventario inicial..."
/usr/local/bin/generate-inventory.sh

# Esperar a que los nodos managed estén disponibles
log "⏳ Esperando a que los nodos managed estén disponibles..."
sleep 30

# Distribuir claves SSH a los nodos managed
log "🔐 Distribuyendo claves SSH a nodos managed..."
su - ansible -c "/usr/local/bin/distribute-ssh-keys.sh" || {
    log "⚠️ Advertencia: Distribución de claves SSH falló - se puede realizar manualmente más tarde"
}

# Configurar permisos finales
chown -R ansible:ansible /home/ansible
chmod 600 /home/ansible/.ssh/*
chmod 644 /home/ansible/.ssh/*.pub 2>/dev/null || true

# Verificar instalación de Ansible
log "✅ Verificando instalación de Ansible..."
su - ansible -c "ansible --version" || {
    log "❌ Error: Ansible no está instalado correctamente"
    exit 1
}

# Test básico de Ansible
log "🧪 Ejecutando test básico de Ansible..."
su - ansible -c "ansible localhost -m ping -c local" || {
    log "⚠️ Advertencia: Test básico de Ansible falló"
}

log "✅ Nodo de Control de Ansible iniciado correctamente"
log "📝 Usuario: ansible"
log "🏠 Home: /home/ansible"
log "📋 Inventario: /home/ansible/inventory/hosts"
log "📚 Playbooks: /home/ansible/playbooks/"

# Mantener el contenedor ejecutándose
if [ "$1" = "--daemon" ] || [ -z "$1" ]; then
    log "🔄 Ejecutando en modo daemon..."
    
    # Cambiar a usuario ansible y ejecutar bash interactivo
    exec su - ansible -c "
        echo '✨ ¡Bienvenido al Nodo de Control de Ansible!'
        echo '📋 Inventario disponible en: ~/inventory/hosts'
        echo '📚 Playbooks disponibles en: ~/playbooks/'
        echo '🔧 Configuración en: ~/.ansible.cfg'
        echo ''
        echo '🚀 Comandos útiles:'
        echo '  ansible all -m ping              # Test de conectividad'
        echo '  ansible-playbook playbooks/ping.yml  # Ejecutar playbook'
        echo '  ansible-inventory --list         # Ver inventario'
        echo ''
        
        # Mantener bash ejecutándose
        exec /bin/bash
    "
else
    # Ejecutar comando personalizado
    exec "$@"
fi
