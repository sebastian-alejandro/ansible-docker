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
MANAGED_NODES=("centos9-node-1" "centos9-node-2")
SSH_PASSWORD="ansible123"

for node in "${MANAGED_NODES[@]}"; do
    log "🎯 Distribuyendo clave SSH a $node..."
    
    # Wait for node to be ready
    until nc -z $node 22; do
        log "⏳ Esperando servicio SSH de $node..."
        sleep 5
    done
    
    # Copy SSH key
    sshpass -p "$SSH_PASSWORD" ssh-copy-id \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        ansible@$node
    
    if [ $? -eq 0 ]; then
        log "✅ Clave SSH distribuida a $node"
    else
        log "❌ Falló distribución de clave SSH a $node"
    fi
done

log "✅ Distribución de claves SSH completada"
            log "✅ $node está disponible"
            break
        else
            retry_count=$((retry_count + 1))
            log "⏳ Esperando a que $node esté disponible ($retry_count/$max_retries)..."
            sleep $retry_delay
        fi
    done
    
    if [ $retry_count -eq $max_retries ]; then
        log "❌ $node no está disponible después de $max_retries intentos"
        return 1
    fi
    
    # Intentar distribución de clave con sshpass
    retry_count=0
    while [ $retry_count -lt $max_retries ]; do
        if sshpass -p "$TEMP_PASSWORD" ssh-copy-id -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ansible@$node 2>/dev/null; then
            log "✅ Clave distribuida exitosamente a $node"
            
            # Verificar conectividad SSH sin contraseña
            if ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=10 ansible@$node "echo 'SSH OK'" 2>/dev/null; then
                log "✅ Conectividad SSH sin contraseña verificada para $node"
                return 0
            else
                log "⚠️ Advertencia: Clave distribuida pero verificación SSH falló para $node"
                return 1
            fi
        else
            retry_count=$((retry_count + 1))
            log "⚠️ Intento $retry_count/$max_retries falló para $node, reintentando en $retry_delay segundos..."
            sleep $retry_delay
        fi
    done
    
    log "❌ Failed to distribute key to $node after $max_retries attempts"
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
    # Test con Ansible
    log "🔧 Ejecutando test con Ansible..."
    cd /home/ansible
    if ansible all -i inventory/hosts -m ping --one-line 2>/dev/null; then
        log "✅ Test de conectividad Ansible exitoso"
    else
        log "⚠️ Test de conectividad Ansible falló - algunos nodos pueden no estar disponibles"
    fi
else
    # Test manual con SSH
    log "🔧 Ejecutando test manual con SSH..."
    for node in "${NODES[@]}"; do
        if ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5 ansible@$node "echo 'Test OK'" 2>/dev/null; then
            log "✅ $node - Conectividad SSH OK"
        else
            log "❌ $node - Conectividad SSH falló"
        fi
    done
fi

if [ $failed_nodes -eq 0 ]; then
    log "🎉 Distribución de claves SSH completada exitosamente"
    exit 0
else
    log "⚠️ Distribución completada con errores - $failed_nodes nodos fallaron"
    exit 1
fi
