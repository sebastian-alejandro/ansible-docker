#!/bin/bash
# Script para generar inventario dinámico de Ansible

set -e

# Función para logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INVENTORY: $1"
}

log "📋 Generando inventario dinámico de Ansible..."

# Directorio de inventario
INVENTORY_DIR="/home/ansible/inventory"
HOSTS_FILE="$INVENTORY_DIR/hosts"
GROUP_VARS_DIR="$INVENTORY_DIR/group_vars"
HOST_VARS_DIR="$INVENTORY_DIR/host_vars"

# Crear directorios si no existen
mkdir -p "$INVENTORY_DIR" "$GROUP_VARS_DIR" "$HOST_VARS_DIR"

# Generar archivo de hosts principal
log "📝 Creando archivo de hosts principal..."
cat > "$HOSTS_FILE" << 'EOF'
# Inventario dinámico del laboratorio Ansible
# Generado automáticamente

[control]
ansible-control ansible_host=ansible-control ansible_connection=local

[nodes]
centos9-node-1 ansible_host=centos9-node-1
centos9-node-2 ansible_host=centos9-node-2
centos9-node-3 ansible_host=centos9-node-3

[webservers]
centos9-node-1
centos9-node-2

[databases]
centos9-node-3

[production:children]
webservers
databases

[all:vars]
ansible_user=ansible
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
ansible_become=yes
ansible_become_method=sudo
ansible_become_user=root
EOF

# Variables para grupo 'all'
log "⚙️ Configurando variables globales..."
cat > "$GROUP_VARS_DIR/all.yml" << 'EOF'
---
# Variables globales para todos los hosts

# Configuración SSH
ansible_user: ansible
ansible_ssh_private_key_file: ~/.ssh/id_rsa
ansible_ssh_common_args: '-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'

# Configuración de privilegios
ansible_become: yes
ansible_become_method: sudo
ansible_become_user: root

# Variables del laboratorio
lab_environment: development
lab_network: ansible_lab_network
lab_timezone: UTC

# Configuración de paquetes base
base_packages:
  - vim
  - curl
  - wget
  - git
  - htop
  - net-tools

# Configuración de firewall
firewall_enabled: false

# Configuración de SELinux
selinux_state: disabled
EOF

# Variables para webservers
log "🌐 Configurando variables para webservers..."
cat > "$GROUP_VARS_DIR/webservers.yml" << 'EOF'
---
# Variables específicas para webservers

# Configuración HTTP
http_port: 80
https_port: 443

# Paquetes web
web_packages:
  - httpd
  - mod_ssl

# Configuración de servicios
web_services:
  - httpd

# Directorio web
web_root: /var/www/html

# Usuario web
web_user: apache
web_group: apache
EOF

# Variables para databases
log "🗄️ Configurando variables para databases..."
cat > "$GROUP_VARS_DIR/databases.yml" << 'EOF'
---
# Variables específicas para databases

# Configuración de base de datos
db_port: 3306
db_root_password: "{{ vault_db_root_password | default('changeme') }}"

# Paquetes de base de datos
db_packages:
  - mariadb-server
  - mariadb

# Configuración de servicios
db_services:
  - mariadb

# Directorio de datos
db_data_dir: /var/lib/mysql

# Usuario de base de datos
db_user: mysql
db_group: mysql
EOF

# Variables específicas por host
log "🖥️ Configurando variables específicas por host..."

# Variables para centos9-node-1
cat > "$HOST_VARS_DIR/centos9-node-1.yml" << 'EOF'
---
# Variables específicas para centos9-node-1

host_role: primary_web
server_id: 1
backup_schedule: "0 2 * * *"

# Configuración específica
max_connections: 100
memory_limit: 1024M
EOF

# Variables para centos9-node-2
cat > "$HOST_VARS_DIR/centos9-node-2.yml" << 'EOF'
---
# Variables específicas para centos9-node-2

host_role: secondary_web
server_id: 2
backup_schedule: "0 3 * * *"

# Configuración específica
max_connections: 80
memory_limit: 512M
EOF

# Variables para centos9-node-3
cat > "$HOST_VARS_DIR/centos9-node-3.yml" << 'EOF'
---
# Variables específicas para centos9-node-3

host_role: database
server_id: 3
backup_schedule: "0 1 * * *"

# Configuración específica
max_connections: 200
memory_limit: 2048M
innodb_buffer_pool_size: 1G
EOF

# Configurar permisos
chown -R ansible:ansible "$INVENTORY_DIR"
find "$INVENTORY_DIR" -type f -exec chmod 644 {} \;
find "$INVENTORY_DIR" -type d -exec chmod 755 {} \;

log "✅ Inventario dinámico generado exitosamente"
log "📁 Ubicación: $INVENTORY_DIR"
log "📋 Archivo principal: $HOSTS_FILE"
log "⚙️ Variables de grupo: $GROUP_VARS_DIR"
log "🖥️ Variables de host: $HOST_VARS_DIR"

# Validar inventario
if command -v ansible-inventory > /dev/null 2>&1; then
    log "🧪 Validando inventario generado..."
    if su - ansible -c "ansible-inventory -i $HOSTS_FILE --list" > /dev/null 2>&1; then
        log "✅ Inventario válido"
    else
        log "⚠️ Advertencia: Error en la validación del inventario"
    fi
fi
