# 🐳 Ansible Docker Environment - Sprint 1

## 📋 Descripción del Proyecto

Este proyecto implementa un ambiente completo de **Ansible** utilizando **Docker containers**, donde:
- **CentOS 9 Stream** actúa como **Managed Nodes** (servidores a gestionar)
- **Ansible Control Node** gestiona y aprovisiona los containers CentOS 9

## 🎯 Sprint 1: Fundamentos y Container Base CentOS 9

### ✅ Objetivos Completados

- [x] **Dockerfile optimizado para CentOS 9**
  - SSH server configurado y funcional
  - Usuario `ansible` con permisos sudo
  - Herramientas de administración esenciales
  - Python3 para compatibilidad con Ansible
  - Health checks implementados

- [x] **Scripts de inicialización y gestión**
  - Script de inicialización con logging
  - Health check automatizado
  - **Comandos nativos Docker/Docker Compose** para gestión multiplataforma

- [x] **Docker Compose base**
  - Configuración multi-container
  - Red interna optimizada
  - Volúmenes persistentes
  - Mapeo de puertos SSH

- [x] **Documentación completa**
  - Guías de instalación y uso
  - **Comandos nativos Docker** documentados
  - Troubleshooting
  - Mejores prácticas

## 🏗️ Arquitectura Actual

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Host                              │
│                                                             │
│  ┌─────────────────┐       ┌─────────────────┐            │
│  │   CentOS 9      │       │   CentOS 9      │            │
│  │   Node 1        │       │   Node 2        │            │
│  │   Port: 2201    │       │   Port: 2202    │            │
│  │   SSH: ✅       │       │   SSH: ✅       │            │
│  │   User: ansible │       │   User: ansible │            │
│  └─────────────────┘       └─────────────────┘            │
│           │                          │                     │
│           └──────────┬───────────────┘                     │
│                      │                                     │
│              ┌───────────────┐                             │
│              │ ansible-network│                             │
│              │ 172.20.0.0/16 │                             │
│              └───────────────┘                             │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 Instalación y Uso

### Prerrequisitos

- **Docker Desktop** instalado (Windows/Linux/macOS)
- **Docker Compose** v2.0 o superior
- **SSH Client** para conectividad

### 1. Clonar y Preparar el Proyecto

```bash
# Clonar el repositorio
git clone https://github.com/sebastian-alejandro/ansible-docker.git
cd ansible-docker

# Verificar estructura del proyecto
ls -la
```

### 2. Construir las Imágenes Docker

```bash
# Construir todas las imágenes
docker compose build

# Construir con cache limpio (si es necesario)
docker compose build --no-cache
```

### 3. Iniciar los Containers

```bash
# Iniciar todos los containers en background
docker compose up -d

# Verificar estado
docker compose ps
```

### 4. Verificar Conectividad

```bash
# Test de health check interno
docker exec centos9-node1 /usr/local/bin/health-check.sh

# Test de conectividad SSH
ssh ansible@localhost -p 2201
ssh ansible@localhost -p 2202
```
.\manage.ps1 test

# Conectarse a un container específico
.\manage.ps1 shell centos9-node1
```

## 📊 Información de Conexión

### Acceso SSH a los Containers

| Container | Puerto | Usuario | Password | SSH Command |
|-----------|--------|---------|----------|-------------|
| centos9-node1 | 2201 | ansible | ansible123 | `ssh ansible@localhost -p 2201` |
| centos9-node2 | 2202 | ansible | ansible123 | `ssh ansible@localhost -p 2202` |
| centos9-node1 | 2201 | root | rootpass123 | `ssh root@localhost -p 2201` |
| centos9-node2 | 2202 | root | rootpass123 | `ssh root@localhost -p 2202` |

### Ejemplos de Conexión

```powershell
# Conectarse via SSH desde Windows
ssh ansible@localhost -p 2201

# Conectarse directamente al container
docker-compose exec centos9-node1 bash

# Ver logs de un container específico
.\manage.ps1 logs centos9-node1
```

## 🔧 Comandos de Gestión

El script `manage.ps1` proporciona comandos simplificados:

```powershell
# Mostrar ayuda
.\manage.ps1 help

# Construir imágenes
.\manage.ps1 build

# Iniciar containers
.\manage.ps1 start

# Detener containers
.\manage.ps1 stop

# Reiniciar containers
.\manage.ps1 restart

# Ver estado
.\manage.ps1 status

# Ver logs
.\manage.ps1 logs centos9-node1

# Conectarse a un container
.\manage.ps1 shell centos9-node1

# Ejecutar tests
.\manage.ps1 test

# Limpiar ambiente
.\manage.ps1 clean
```

## 🔍 Verificación y Testing

### Health Checks Automatizados

Los containers incluyen health checks que verifican:
- ✅ Servicio SSH ejecutándose
- ✅ Puerto 22 escuchando
- ✅ Usuario ansible existe
- ✅ Directorio home accesible
- ✅ Python3 disponible

### Tests Manuales

```bash
# Dentro del container
systemctl status sshd          # Verificar SSH
id ansible                     # Verificar usuario
python3 --version             # Verificar Python
sudo whoami                   # Verificar permisos sudo
```

## 📁 Estructura del Proyecto

```
ansible_docker/
├── centos9/                    # Container CentOS 9
│   ├── Dockerfile             # Imagen base CentOS 9
│   └── scripts/               # Scripts de inicialización
│       ├── init.sh           # Script de inicialización
│       └── health-check.sh   # Health check
├── ansible-control/          # Container Ansible (Sprint 2)
├── docs/                     # Documentación
│   └── sprint1.md           # Este archivo
├── docker-compose.yml       # Orquestación containers
└── manage.ps1              # Script de gestión PowerShell
```

## 🐛 Troubleshooting

### Problemas Comunes

**1. Error al construir la imagen**
```powershell
# Limpiar cache de Docker
docker system prune -f
.\manage.ps1 build
```

**2. Container no inicia**
```powershell
# Ver logs detallados
.\manage.ps1 logs centos9-node1
```

**3. No se puede conectar por SSH**
```powershell
# Verificar que el container esté corriendo
.\manage.ps1 status

# Ejecutar test de conectividad
.\manage.ps1 test
```

**4. Problemas de permisos**
```bash
# Dentro del container, verificar permisos
ls -la /home/ansible/.ssh/
sudo -l  # Verificar permisos sudo
```

### Logs y Diagnóstico

```powershell
# Ver todos los logs
docker-compose logs

# Logs de un container específico
docker-compose logs -f centos9-node1

# Entrar al container para diagnóstico
docker-compose exec centos9-node1 bash
```

## 📈 Próximos Pasos (Sprint 2)

- [ ] **Ansible Control Node Container**
- [ ] **Configuración SSH automatizada**
- [ ] **Inventario dinámico**
- [ ] **Playbooks básicos de conectividad**

## 📝 Notas Técnicas

### Seguridad
- Containers corren con usuario no-root por defecto
- SSH configurado con autenticación por clave y password
- Sudo sin password solo para usuario ansible (ambiente de desarrollo)

### Performance
- Imágenes optimizadas con multi-stage builds
- Volúmenes persistentes para datos importantes
- Health checks configurados apropiadamente

### Escalabilidad
- Red Docker personalizada para comunicación interna
- Estructura preparada para múltiples nodos
- Scripts preparados para automatización

---

**Desarrollado por:** DevOps Team  
**Sprint:** 1 de 5  
**Fecha:** Junio 2025  
**Estado:** ✅ Completado
