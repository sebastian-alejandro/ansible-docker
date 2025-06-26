#!/bin/bash
# ===================================
# Script de Gestión Sprint 2 - Laboratorio Ansible
# Nodo de Control + Nodos Managed
# ===================================

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Función para logging con colores
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅${NC} $1"
}

warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

error() {
    echo -e "${RED}❌${NC} $1"
}

info() {
    echo -e "${CYAN}ℹ️${NC} $1"
}

# Banner
print_banner() {
    echo -e "${PURPLE}"
    echo "======================================================"
    echo "🚀 LABORATORIO ANSIBLE - SPRINT 2"
    echo "======================================================"
    echo "Nodo de Control + Nodos Managed"
    echo "Control Node: ansible-control (Rocky Linux 9)"
    echo "Managed Nodes: centos9-node-1, centos9-node-2, centos9-node-3"
    echo "======================================================"
    echo -e "${NC}"
}

# Funciones de gestión
start_lab() {
    log "🚀 Iniciando laboratorio Ansible completo..."
    
    # Construir y levantar todos los servicios
    docker compose up -d --build
    
    log "⏳ Esperando a que todos los servicios estén listos..."
    sleep 60
    
    # Verificar estado de los servicios
    check_status
    
    success "Laboratorio iniciado exitosamente"
    info "Acceso al nodo de control: docker compose exec ansible-control bash"
}

stop_lab() {
    log "🛑 Deteniendo laboratorio Ansible..."
    docker compose down
    success "Laboratorio detenido"
}

restart_lab() {
    log "🔄 Reiniciando laboratorio Ansible..."
    docker compose restart
    log "⏳ Esperando a que los servicios se reinicien..."
    sleep 30
    check_status
    success "Laboratorio reiniciado"
}

check_status() {
    log "📊 Verificando estado del laboratorio..."
    
    echo -e "\n${CYAN}=== Estado de Contenedores ===${NC}"
    docker compose ps
    
    echo -e "\n${CYAN}=== Estado de Salud ===${NC}"
    for container in ansible-control centos9-node-1 centos9-node-2 centos9-node-3; do
        health=$(docker inspect --format='{{.State.Health.Status}}' $container 2>/dev/null || echo "unknown")
        if [ "$health" = "healthy" ]; then
            success "$container: $health"
        elif [ "$health" = "starting" ]; then
            warning "$container: $health"
        else
            error "$container: $health"
        fi
    done
}

access_control() {
    log "🎯 Accediendo al nodo de control..."
    docker compose exec ansible-control bash
}

test_connectivity() {
    log "🧪 Ejecutando test de conectividad Ansible..."
    docker compose exec ansible-control ansible all -i inventory/hosts -m ping
}

run_playbook() {
    local playbook=${1:-"ping.yml"}
    log "📚 Ejecutando playbook: $playbook"
    docker compose exec ansible-control ansible-playbook -i inventory/hosts playbooks/$playbook
}

show_inventory() {
    log "📋 Mostrando inventario de Ansible..."
    docker compose exec ansible-control ansible-inventory -i inventory/hosts --list
}

distribute_keys() {
    log "🔐 Distribuyendo claves SSH..."
    docker compose exec ansible-control /usr/local/bin/distribute-ssh-keys.sh
}

show_logs() {
    local service=${1:-"ansible-control"}
    log "📝 Mostrando logs de $service..."
    docker compose logs --tail=50 -f $service
}

cleanup() {
    log "🧹 Limpiando laboratorio..."
    docker compose down -v --remove-orphans
    docker system prune -f
    success "Limpieza completada"
}

build_images() {
    log "🏗️ Construyendo imágenes..."
    docker compose build --no-cache
    success "Imágenes construidas"
}

backup_data() {
    log "💾 Creando backup de volúmenes..."
    local backup_dir="backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p $backup_dir
    
    # Backup de volúmenes importantes
    docker run --rm -v ansible_control_ssh:/data -v $(pwd)/$backup_dir:/backup alpine tar czf /backup/control-ssh.tar.gz -C /data .
    docker run --rm -v ansible_playbooks:/data -v $(pwd)/$backup_dir:/backup alpine tar czf /backup/playbooks.tar.gz -C /data .
    docker run --rm -v ansible_inventory:/data -v $(pwd)/$backup_dir:/backup alpine tar czf /backup/inventory.tar.gz -C /data .
    
    success "Backup creado en: $backup_dir"
}

# Función de ayuda
show_help() {
    echo -e "${CYAN}Uso: $0 [comando] [opciones]${NC}"
    echo ""
    echo -e "${YELLOW}Comandos principales:${NC}"
    echo "  start           Iniciar laboratorio completo"
    echo "  stop            Detener laboratorio"
    echo "  restart         Reiniciar laboratorio"
    echo "  status          Verificar estado de servicios"
    echo ""
    echo -e "${YELLOW}Comandos de gestión:${NC}"
    echo "  shell           Acceder al nodo de control"
    echo "  test            Test de conectividad Ansible"
    echo "  playbook [name] Ejecutar playbook (default: ping.yml)"
    echo "  inventory       Mostrar inventario"
    echo "  keys            Distribuir claves SSH"
    echo ""
    echo -e "${YELLOW}Comandos de mantenimiento:${NC}"
    echo "  logs [service]  Mostrar logs (default: ansible-control)"
    echo "  build           Reconstruir imágenes"
    echo "  backup          Crear backup de datos"
    echo "  cleanup         Limpiar todo (⚠️ borra datos)"
    echo ""
    echo -e "${YELLOW}Ejemplos:${NC}"
    echo "  $0 start                    # Iniciar laboratorio"
    echo "  $0 shell                    # Acceder al control node"
    echo "  $0 test                     # Test de conectividad"
    echo "  $0 playbook setup-base.yml  # Ejecutar playbook específico"
    echo "  $0 logs centos9-node-1      # Ver logs de un nodo"
}

# Script principal
main() {
    print_banner
    
    case "${1:-help}" in
        start)
            start_lab
            ;;
        stop)
            stop_lab
            ;;
        restart)
            restart_lab
            ;;
        status)
            check_status
            ;;
        shell|access)
            access_control
            ;;
        test|ping)
            test_connectivity
            ;;
        playbook|play)
            run_playbook "$2"
            ;;
        inventory|inv)
            show_inventory
            ;;
        keys|ssh)
            distribute_keys
            ;;
        logs|log)
            show_logs "$2"
            ;;
        build)
            build_images
            ;;
        backup)
            backup_data
            ;;
        cleanup|clean)
            cleanup
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            error "Comando desconocido: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Verificar que Docker Compose está disponible
if ! command -v docker &> /dev/null; then
    error "Docker no está instalado o no está en el PATH"
    exit 1
fi

if ! docker compose version &> /dev/null; then
    error "Docker Compose no está disponible"
    exit 1
fi

# Ejecutar función principal
main "$@"
