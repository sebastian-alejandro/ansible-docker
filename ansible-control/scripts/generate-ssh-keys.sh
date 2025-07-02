#!/bin/bash
# Script para generar claves SSH para el usuario ansible

set -e

# Función para logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] SSH-KEYGEN: $1"
}

log "🔑 Iniciando generación de claves SSH..."

# Verificar que estamos ejecutando como usuario ansible
if [ "$USER" != "ansible" ]; then
    log "❌ Este script debe ejecutarse como usuario 'ansible'"
    exit 1
fi

# Directorio SSH
SSH_DIR="$HOME/.ssh"
PRIVATE_KEY="$SSH_DIR/id_rsa"
PUBLIC_KEY="$SSH_DIR/id_rsa.pub"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"

# Crear directorio SSH si no existe
if [ ! -d "$SSH_DIR" ]; then
    log "📁 Creando directorio SSH: $SSH_DIR"
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
fi

# Generar clave SSH si no existe
if [ ! -f "$PRIVATE_KEY" ]; then
    log "🔐 Generando par de claves SSH..."
    ssh-keygen -t rsa -b 4096 -f "$PRIVATE_KEY" -N "" -C "ansible@control-node"
    
    # Configurar permisos
    chmod 600 "$PRIVATE_KEY"
    chmod 644 "$PUBLIC_KEY"
    
    log "✅ Claves SSH generadas:"
    log "   🔒 Clave privada: $PRIVATE_KEY"
    log "   🔓 Clave pública: $PUBLIC_KEY"
else
    log "ℹ️ Las claves SSH ya existen, omitiendo generación"
fi

# Configurar authorized_keys para acceso local
if [ ! -f "$AUTHORIZED_KEYS" ]; then
    log "📝 Configurando authorized_keys..."
    cp "$PUBLIC_KEY" "$AUTHORIZED_KEYS"
    chmod 600 "$AUTHORIZED_KEYS"
    log "✅ Archivo authorized_keys configurado"
else
    # Verificar que nuestra clave esté en authorized_keys
    if ! grep -q -F "$(cat "$PUBLIC_KEY")" "$AUTHORIZED_KEYS" 2>/dev/null; then
        log "➕ Agregando clave pública a authorized_keys..."
        cat "$PUBLIC_KEY" >> "$AUTHORIZED_KEYS"
    fi
fi

# Crear configuración SSH cliente
SSH_CONFIG="$SSH_DIR/config"
if [ ! -f "$SSH_CONFIG" ]; then
    log "⚙️ Creando configuración SSH..."
    cat > "$SSH_CONFIG" << 'EOF'
# Configuración SSH para nodo de control Ansible
Host *
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    ControlMaster auto
    ControlPath ~/.ssh/ansible-%r@%h:%p
    ControlPersist 5m
    ServerAliveInterval 60
    ServerAliveCountMax 3
    ConnectTimeout 10

# Configuración específica para nodos del laboratorio
Host centos9-node-* ansible-control
    User ansible
    IdentityFile ~/.ssh/id_rsa
    Port 22
EOF
    
    chmod 600 "$SSH_CONFIG"
    log "✅ Configuración SSH creada"
fi

# Mostrar información de la clave pública
log "📋 Información de la clave pública:"
ssh-keygen -l -f "$PUBLIC_KEY"

log "🎉 Configuración SSH completada exitosamente"
log "📌 Recuerda: Esta clave pública debe distribuirse a todos los nodos de destino"
