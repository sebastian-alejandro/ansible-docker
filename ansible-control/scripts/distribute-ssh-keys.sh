#!/bin/bash
# Script para distribuir claves SSH desde el nodo de control a los nodos managed v1.3.0
# Siguiendo las especificaciones del plan de desarrollo

set -e

# Función para logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] SSH-DIST: $1"
}

log "🔐 Iniciando distribución de claves SSH v1.3.0..."

# Lista de nodos managed según especificaciones v1.3.0
NODES=("centos9-node-1" "centos9-node-2")
TEMP_PASSWORD="ansible123"
MAX_RETRIES=5
RETRY_DELAY=10

# Función para distribuir la clave a un solo nodo
distribute_key_to_node() {
    local node=$1
    local max_retries=$MAX_RETRIES
    local retry_delay=$RETRY_DELAY
    local retry_count=0

    log "🎯 Procesando nodo: $node"

    # 1. Esperar a que el nodo esté disponible
    while [ "$retry_count" -lt "$max_retries" ]; do
        if nc -z "$node" 22; then
            log "✅ $node está disponible"
            break
        else
            retry_count=$((retry_count + 1))
            log "⏳ Esperando a que $node esté disponible ($retry_count/$max_retries)..."
            sleep "$retry_delay"
        fi
    done

    if [ "$retry_count" -eq "$max_retries" ]; then
        log "❌ $node no está disponible después de $max_retries intentos"
        return 1
    fi

    # 2. Intentar distribución de clave con sshpass
    retry_count=0
    while [ "$retry_count" -lt "$max_retries" ]; do
        if sshpass -p "$TEMP_PASSWORD" ssh-copy-id -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "ansible@$node" 2>/dev/null; then
            log "✅ Clave distribuida exitosamente a $node"

            # 3. Verificar conectividad SSH sin contraseña
            if ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=10 "ansible@$node" "echo 'SSH OK'" 2>/dev/null; then
                log "✅ Conectividad SSH sin contraseña verificada para $node"
                return 0
            else
                log "⚠️ Advertencia: Clave distribuida pero verificación SSH falló para $node"
                return 1 # Considerar esto un fallo
            fi
        else
            retry_count=$((retry_count + 1))
            log "⚠️ Intento $retry_count/$max_retries falló para $node, reintentando en $retry_delay segundos..."
            sleep "$retry_delay"
        fi
    done

    log "❌ Falló la distribución de la clave a $node después de $max_retries intentos"
    return 1
}

# Distribuir claves a todos los nodos
successful_nodes=0
failed_nodes=0

for node in "${NODES[@]}"; do
    if distribute_key_to_node "$node"; then
        successful_nodes=$((successful_nodes + 1))
    else
        failed_nodes=$((failed_nodes + 1))
    fi
done

# Resumen de la distribución
log "📊 Resumen de distribución de claves SSH:"
log "✅ Nodos exitosos: $successful_nodes"
log "❌ Nodos fallidos: $failed_nodes"
log "📋 Total de nodos: ${#NODES[@]}"

# Test de conectividad final
log "🧪 Ejecutando test de conectividad final..."
if command -v ansible > /dev/null 2>&1; then
    if su - ansible -c "ansible all -i /home/ansible/inventory/hosts -m ping"; then
        log "🎉 Test de conectividad final con Ansible exitoso"
    else
        log "❌ Falló el test de conectividad final con Ansible"
    fi
else
    log "⚠️ Ansible no está instalado, omitiendo test de conectividad final."
fi


if [ "$failed_nodes" -gt 0 ]; then
    log "❌ Finalizado con $failed_nodes nodos fallidos."
    exit 1
else
    log "🎉 Distribución de claves SSH completada exitosamente para todos los nodos."
    exit 0
fi
