#!/bin/bash
# Script de inicialización del nodo de control de Ansible v1.3.0
# Siguiendo las especificaciones del plan de desarrollo

set -e

echo "🚀 Iniciando Nodo de Control de Ansible v1.3.0..."

# Función para logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Start SSH service
log "🔐 Iniciando servicio SSH..."
sudo systemctl start sshd
sudo systemctl enable sshd

# Generate SSH keys if not exist
if [ ! -f /home/ansible/.ssh/id_rsa ]; then
    log "� Generando claves SSH..."
    ssh-keygen -t rsa -b 4096 -f /home/ansible/.ssh/id_rsa -N ""
    chmod 600 /home/ansible/.ssh/id_rsa
    chmod 644 /home/ansible/.ssh/id_rsa.pub
    chown ansible:ansible /home/ansible/.ssh/id_rsa*
fi

# Wait for managed nodes to be ready
log "⏳ Esperando a que los nodos managed estén listos..."
sleep 30

# Setup inventory
log "📋 Configurando inventario..."
/usr/local/bin/generate-inventory.sh

# Distribute SSH keys to managed nodes
log "🔐 Distribuyendo claves SSH a nodos managed..."
/usr/local/bin/distribute-ssh-keys.sh || {
    log "⚠️ Advertencia: Distribución de claves SSH falló - se puede realizar manualmente más tarde"
}

# Verificar instalación de Ansible
log "✅ Verificando instalación de Ansible..."
ansible --version || {
    log "❌ Error: Ansible no está instalado correctamente"
    exit 1
}

log "✅ Nodo de Control de Ansible v1.3.0 iniciado correctamente"
log "📝 Usuario: ansible"
log "🏠 Home: /home/ansible"
log "📋 Inventario: /ansible/inventory/hosts.yml"
log "📚 Playbooks: /ansible/playbooks/"

# Keep container running
if [ "$#" -eq 0 ]; then
    log "🔄 Manteniendo contenedor ejecutándose..."
    exec tail -f /dev/null
else
    exec "$@"
fi
