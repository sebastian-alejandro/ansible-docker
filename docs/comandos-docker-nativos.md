# 🐳 Comandos Docker Nativos - Ansible Environment

Esta guía contiene todos los comandos necesarios para gestionar el ambiente Ansible usando únicamente Docker y Docker Compose nativos.

## 📋 Índice
- [Gestión Básica](#gestión-básica)
- [Gestión Individual de Containers](#gestión-individual-de-containers)
- [Testing y Verificación](#testing-y-verificación)
- [Scaling y Gestión Avanzada](#scaling-y-gestión-avanzada)
- [Debugging y Troubleshooting](#debugging-y-troubleshooting)
- [Limpieza y Mantenimiento](#limpieza-y-mantenimiento)
- [Comandos de Desarrollo](#comandos-de-desarrollo)

---

## 🚀 Gestión Básica

### Inicialización del Ambiente
```bash
# Clonar proyecto
git clone https://github.com/sebastian-alejandro/ansible-docker.git
cd ansible-docker

# Construir todas las imágenes
docker compose build

# Iniciar todos los containers en background
docker compose up -d

# Ver estado de todos los containers
docker compose ps
```

### Control del Ambiente
```bash
# Detener todos los containers
docker compose down

# Detener y eliminar volúmenes
docker compose down -v

# Reiniciar todo el ambiente
docker compose restart

# Ver logs de todos los containers
docker compose logs

# Seguir logs en tiempo real
docker compose logs -f
```

---

## 🔧 Gestión Individual de Containers

### Control Individual
```bash
# Iniciar un container específico
docker compose up -d centos9-node1

# Detener un container específico
docker compose stop centos9-node1

# Reiniciar un container específico
docker compose restart centos9-node1

# Eliminar un container específico
docker compose rm centos9-node1
```

### Acceso a Containers
```bash
# Conectarse a un container (shell interactivo)
docker exec -it centos9-node1 bash
docker exec -it centos9-node2 bash

# Ejecutar comando específico en container
docker exec centos9-node1 systemctl status sshd
docker exec centos9-node1 whoami
docker exec centos9-node1 python3 --version

# Conectarse como usuario específico
docker exec -it --user ansible centos9-node1 bash
docker exec -it --user root centos9-node1 bash
```

### Logs y Monitoreo
```bash
# Ver logs de un container específico
docker compose logs centos9-node1
docker compose logs centos9-node2

# Seguir logs en tiempo real
docker compose logs -f centos9-node1

# Ver últimas N líneas de logs
docker compose logs --tail 50 centos9-node1

# Ver logs con timestamps
docker compose logs -t centos9-node1
```

---

## 🧪 Testing y Verificación

### Conectividad SSH
```bash
# Conectar via SSH (desde host)
ssh ansible@localhost -p 2201  # centos9-node1
ssh ansible@localhost -p 2202  # centos9-node2

# Test de conectividad SSH con comando directo
ssh ansible@localhost -p 2201 "echo 'SSH connection successful'"

# Test con contraseña explícita (para debugging)
sshpass -p 'ansible123' ssh ansible@localhost -p 2201 "whoami"
```

### Health Checks
```bash
# Ejecutar health check interno
docker exec centos9-node1 /usr/local/bin/health-check.sh
docker exec centos9-node2 /usr/local/bin/health-check.sh

# Verificar estado de health en Docker
docker inspect centos9-node1 | grep -A 10 "Health"
```

### Verificación de Servicios
```bash
# Verificar SSH service
docker exec centos9-node1 systemctl status sshd
docker exec centos9-node1 systemctl is-active sshd

# Verificar puertos abiertos
docker exec centos9-node1 netstat -tlnp
docker exec centos9-node1 ss -tlnp

# Verificar usuarios y permisos
docker exec centos9-node1 id ansible
docker exec centos9-node1 groups ansible
docker exec centos9-node1 sudo -u ansible sudo -n whoami
```

### Testing de Red
```bash
# Verificar conectividad entre containers
docker exec centos9-node1 ping centos9-node2
docker exec centos9-node2 ping centos9-node1

# Verificar resolución DNS interna
docker exec centos9-node1 nslookup centos9-node2
docker exec centos9-node1 getent hosts centos9-node2

# Test de puertos desde dentro del container
docker exec centos9-node1 telnet centos9-node2 22
```

---

## ⚡ Scaling y Gestión Avanzada

### Escalado de Containers
```bash
# Escalar a 3 instancias de node1
docker compose up -d --scale centos9-node1=3

# Escalar múltiples servicios
docker compose up -d --scale centos9-node1=2 --scale centos9-node2=3

# Ver todos los containers escalados
docker compose ps
```

### Rebuild y Recreación
```bash
# Rebuild sin cache
docker compose build --no-cache

# Rebuild de un servicio específico
docker compose build --no-cache centos9-node1

# Recrear containers (preservar volúmenes)
docker compose up -d --force-recreate

# Recrear un servicio específico
docker compose up -d --force-recreate centos9-node1
```

### Gestión de Recursos
```bash
# Ver uso de recursos en tiempo real
docker stats

# Ver uso de un container específico
docker stats centos9-node1

# Ver información detallada de un container
docker inspect centos9-node1

# Ver procesos dentro de un container
docker exec centos9-node1 ps aux
docker exec centos9-node1 htop
```

---

## 🔍 Debugging y Troubleshooting

### Análisis de Problemas
```bash
# Ver eventos de Docker Compose
docker compose events

# Verificar configuración de Docker Compose
docker compose config

# Validar sintaxis de docker-compose.yml
docker compose config --quiet

# Ver variables de entorno
docker exec centos9-node1 env
```

### Debugging de Red
```bash
# Inspeccionar red de Docker
docker network ls
docker network inspect ansible_ansible-network

# Ver conectividad de red
docker exec centos9-node1 ip addr
docker exec centos9-node1 ip route

# Test de conectividad externa
docker exec centos9-node1 ping 8.8.8.8
docker exec centos9-node1 curl -I google.com
```

### Debugging de Volúmenes
```bash
# Listar volúmenes
docker volume ls

# Inspeccionar volúmenes específicos
docker volume inspect ansible_centos9-node1-data
docker volume inspect ansible_centos9-node1-logs

# Ver contenido de volúmenes
docker exec centos9-node1 ls -la /home/ansible
docker exec centos9-node1 ls -la /var/log/ansible
```

### Debugging de Imágenes
```bash
# Ver capas de imagen
docker history centos9-ansible:latest

# Inspeccionar imagen
docker inspect centos9-ansible:latest

# Ver imágenes disponibles
docker images | grep centos9
```

---

## 🧹 Limpieza y Mantenimiento

### Limpieza Básica
```bash
# Detener y eliminar containers
docker compose down

# Detener, eliminar containers y volúmenes
docker compose down -v

# Detener, eliminar todo incluyendo imágenes
docker compose down --rmi all -v
```

### Limpieza Avanzada
```bash
# Limpiar containers parados
docker container prune -f

# Limpiar imágenes no utilizadas
docker image prune -f

# Limpiar volúmenes no utilizados
docker volume prune -f

# Limpiar redes no utilizadas
docker network prune -f

# Limpieza completa del sistema
docker system prune -a -f --volumes
```

### Recreación Completa
```bash
# Secuencia completa de recreación
docker compose down -v
docker system prune -f
docker compose build --no-cache
docker compose up -d
```

---

## 💻 Comandos de Desarrollo

### Testing de Cambios
```bash
# Build y test rápido
docker compose build centos9
docker compose up -d
docker exec centos9-node1 /usr/local/bin/health-check.sh

# Test de conectividad después de cambios
ssh ansible@localhost -p 2201 "echo 'Test successful'"
```

### Desarrollo con Hot Reload
```bash
# Para desarrollo con volúmenes montados (si configurado)
docker compose -f docker-compose.dev.yml up -d

# Restart después de cambios en scripts
docker compose restart centos9-node1
```

### Backup y Restauración
```bash
# Backup de volúmenes
docker run --rm -v ansible_centos9-node1-data:/data -v $(pwd):/backup alpine tar czf /backup/node1-data.tar.gz -C /data .

# Restaurar backup
docker run --rm -v ansible_centos9-node1-data:/data -v $(pwd):/backup alpine tar xzf /backup/node1-data.tar.gz -C /data
```

---

## 📊 Comandos de Monitoreo

### Monitoreo en Tiempo Real
```bash
# Seguir logs de todos los containers
docker compose logs -f

# Monitor de recursos
watch docker stats

# Monitor de health checks
watch "docker compose ps"
```

### Información del Sistema
```bash
# Información de Docker
docker info
docker version

# Espacio utilizado
docker system df

# Eventos del sistema
docker events
```

---

## ⚙️ Variables de Entorno y Configuración

### Configuración Runtime
```bash
# Sobrescribir variables de entorno
TZ=UTC docker compose up -d

# Usar archivo de entorno personalizado
docker compose --env-file .env.production up -d

# Ver configuración efectiva
docker compose config
```

### Perfiles y Ambientes
```bash
# Usar profile específico (si configurado)
docker compose --profile production up -d

# Usar archivo compose específico
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

---

## 🚨 Comandos de Emergencia

### Recuperación Rápida
```bash
# Kill forzado de containers
docker kill $(docker ps -q)

# Restart completo de Docker (Linux)
sudo systemctl restart docker

# Verificar integridad después de problemas
docker compose down
docker system prune -f
docker compose up -d --force-recreate
```

### Debugging Extremo
```bash
# Entrar al container como root sin SSH
docker exec -it --user root centos9-node1 bash

# Ver todos los procesos del container
docker exec centos9-node1 ps aux --forest

# Verificar filesystems
docker exec centos9-node1 df -h
docker exec centos9-node1 mount
```

---

**Nota:** Todos estos comandos son multiplataforma y funcionan en Windows, Linux y macOS con Docker Desktop instalado.
