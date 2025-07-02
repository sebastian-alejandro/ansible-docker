#!/bin/bash
# Health check para el nodo de control de Ansible

set -e

# Función para logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] HEALTH: $1"
}

# Función para verificar servicios
check_service() {
    local service=$1
    if systemctl is-active --quiet "$service"; then
        log "✅ Servicio $service está ejecutándose"
        return 0
    else
        log "❌ Servicio $service no está ejecutándose"
        return 1
    fi
}

# Función para verificar comandos
check_command() {
    local cmd=$1
    local description=$2
    if command -v "$cmd" > /dev/null 2>&1; then
        log "✅ $description disponible"
        return 0
    else
        log "❌ $description no disponible"
        return 1
    fi
}

# Función para verificar archivos
check_file() {
    local file=$1
    local description=$2
    if [ -f "$file" ]; then
        log "✅ $description existe: $file"
        return 0
    else
        log "❌ $description no existe: $file"
        return 1
    fi
}

# Inicio del health check
log "🔍 Iniciando health check del nodo de control..."

exit_code=0

# Verificar systemd
if ! systemctl is-system-running --wait > /dev/null 2>&1; then
    log "⚠️ Systemd aún no está completamente listo"
fi

# Verificar SSH daemon
if ! check_service sshd; then
    exit_code=1
fi

# Verificar puerto SSH
if ! netstat -tuln 2>/dev/null | grep -q ':22 '; then
    log "❌ Puerto SSH (22) no está escuchando"
    exit_code=1
else
    log "✅ Puerto SSH (22) está escuchando"
fi

# Verificar usuario ansible
if id ansible > /dev/null 2>&1; then
    log "✅ Usuario ansible existe"
else
    log "❌ Usuario ansible no existe"
    exit_code=1
fi

# Verificar directorio home de ansible
if [ -d "/home/ansible" ]; then
    log "✅ Directorio home de ansible existe"
else
    log "❌ Directorio home de ansible no existe"
    exit_code=1
fi

# Verificar instalación de Ansible
if ! check_command ansible "Ansible"; then
    exit_code=1
fi

# Verificar versión de Ansible
if su - ansible -c "ansible --version" > /dev/null 2>&1; then
    log "✅ Ansible funciona correctamente"
else
    log "❌ Ansible no funciona correctamente"
    exit_code=1
fi

# Verificar configuración de Ansible
if ! check_file "/home/ansible/.ansible.cfg" "Configuración de Ansible"; then
    exit_code=1
fi

# Verificar claves SSH
if ! check_file "/home/ansible/.ssh/id_rsa" "Clave privada SSH"; then
    exit_code=1
fi

if ! check_file "/home/ansible/.ssh/id_rsa.pub" "Clave pública SSH"; then
    exit_code=1
fi

# Verificar inventario
if ! check_file "/home/ansible/inventory/hosts" "Inventario de Ansible"; then
    exit_code=1
fi

# Verificar conectividad local
if su - ansible -c "ansible localhost -m ping -c local" > /dev/null 2>&1; then
    log "✅ Conectividad local de Ansible funciona"
else
    log "❌ Conectividad local de Ansible no funciona"
    exit_code=1
fi

# Verificar directorio de playbooks
if [ -d "/home/ansible/playbooks" ]; then
    log "✅ Directorio de playbooks existe"
else
    log "❌ Directorio de playbooks no existe"
    exit_code=1
fi

# Resultado final
if [ $exit_code -eq 0 ]; then
    log "✅ Health check completado exitosamente - Nodo de control saludable"
else
    log "❌ Health check falló - Revisar errores anteriores"
fi

exit $exit_code
