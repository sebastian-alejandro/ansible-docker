# 🐳 Ansible Docker Environment

[![Docker](https://img.shields.io/badge/Docker-20.10+-blue.svg)](https://www.docker.com/)
[![CentOS](https://img.shields.io/badge/CentOS-9%20Stream-red.svg)](https://www.centos.org/)
[![Ansible](https://img.shields.io/badge/Ansible-Ready-green.svg)](https://www.ansible.com/)
[![Version](https://img.shields.io/badge/Version-1.2.0-success.svg)](https://github.com/sebastian-alejandro/ansible-docker/releases)
[![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-brightgreen.svg)](https://github.com/sebastian-alejandro/ansible-docker/actions)

## 🎯 Descripción

Ambiente completo de **Ansible** utilizando **Docker containers** para desarrollo, testing y automatización. Incluye:

- **CentOS 9 Stream** como **Managed Nodes** escalables
- **Ansible Control Node** para gestión centralizada (Sprint 2)
- **CI/CD Pipeline completo** con GitHub Actions
- **5 tipos de pruebas automatizadas** (Build, Functional, SSH, Security, Integration)
- **Comandos nativos Docker/Docker Compose** para gestión multiplataforma
- Documentación completa y troubleshooting

## 🏗️ Arquitectura

```
┌─────────────────┐    SSH/Ansible    ┌─────────────────┐
│   Ansible       │ ──────────────────► │   CentOS 9      │
│   Control Node  │                    │   Container 1   │
│   (Container)   │ ──────────────────► │   Container 2   │
└─────────────────┘                    │   Container N   │
                                       └─────────────────┘
```

## 🚀 Quick Start

### 1. Prerrequisitos
- Docker Desktop (Windows/Linux/macOS)
- Docker Compose v2.0+
- Git (opcional)

### 2. Instalación Rápida

```bash
# Clonar o descargar el proyecto
cd ansible_docker

# Construir imágenes
docker compose build

# Iniciar containers
docker compose up -d

# Verificar estado
docker compose ps
docker compose logs
```

### 3. Conectarse a los Containers

```bash
# SSH desde cualquier OS
ssh ansible@localhost -p 2201  # Node 1
ssh ansible@localhost -p 2202  # Node 2

# O directamente al container
docker exec -it centos9-node1 bash
docker exec -it centos9-node2 bash
```

## 📚 Documentación por Sprints

### Sprint 1: ✅ Completado (v1.2.0)
- [📖 Sprint 1 - Fundamentos y CentOS 9](docs/sprint1.md)
- Container CentOS 9 optimizado
- **Comandos nativos Docker/Docker Compose** para gestión multiplataforma
- Docker Compose base con health checks
- **CI/CD Pipeline completo con GitHub Actions**
- **5 tipos de pruebas automatizadas**
- **Testing automatizado en GitHub Actions**

### Sprint 2: 🚧 En Desarrollo
- [ ] Ansible Control Node
- [ ] SSH keys automáticas
- [ ] Inventario dinámico
- [ ] Playbooks de conectividad

### Sprint 3-5: 📅 Planificado
- [ ] Orquestación avanzada
- [ ] Escalado automático
- [ ] Playbooks de administración
- [ ] Monitoreo y logging

## 🛠️ Comandos Docker Nativos

### Gestión Básica
```bash
# Construir imágenes
docker compose build

# Iniciar todos los containers
docker compose up -d

# Detener containers
docker compose down

# Ver estado de containers
docker compose ps

# Ver logs de todos los containers
docker compose logs

# Ver logs de un container específico
docker compose logs centos9-node1
```

### Gestión Individual de Containers
```bash
# Iniciar un container específico
docker compose up -d centos9-node1

# Detener un container específico
docker compose stop centos9-node1

# Reiniciar un container
docker compose restart centos9-node1

# Conectarse a un container
docker exec -it centos9-node1 bash

# Ejecutar comandos en un container
docker exec centos9-node1 systemctl status sshd
```

### Testing y Verificación
```bash
# Verificar conectividad SSH (requiere cliente SSH)
ssh ansible@localhost -p 2201
ssh ansible@localhost -p 2202

# Test de health check
docker compose exec centos9-node1 /usr/local/bin/health-check.sh

# Verificar servicios en containers
docker exec centos9-node1 systemctl status sshd
docker exec centos9-node2 systemctl status sshd

# Verificar usuarios y permisos
docker exec centos9-node1 id ansible
docker exec centos9-node1 sudo -u ansible sudo -n whoami
```

### Scaling y Gestión Avanzada
```bash
# Escalar número de containers
docker compose up -d --scale centos9-node1=3

# Rebuild forzado de imágenes
docker compose build --no-cache

# Limpiar volúmenes y recrear ambiente
docker compose down -v
docker compose up -d

# Ver uso de recursos
docker stats

# Ver redes creadas
docker network ls
docker network inspect ansible_ansible-network
```

## 🔧 Configuración

### Acceso SSH por Defecto

| Container | Puerto | Usuario | Password |
|-----------|--------|---------|----------|
| centos9-node1 | 2201 | ansible | ansible123 |
| centos9-node2 | 2202 | ansible | ansible123 |
| centos9-node1 | 2201 | root | rootpass123 |
| centos9-node2 | 2202 | root | rootpass123 |

### Variables de Entorno

```yaml
# En docker-compose.yml
environment:
  - TZ=America/Mexico_City      # Timezone
  - HOSTNAME=centos9-node1      # Hostname del container
```

## 📁 Estructura del Proyecto

```
ansible_docker/
├── 📁 centos9/                 # Container CentOS 9
│   ├── 🐳 Dockerfile          # Imagen base
│   └── 📁 scripts/            # Scripts de inicialización
│       ├── init.sh           # Inicialización
│       └── health-check.sh   # Health check
├── 📁 ansible-control/        # Container Ansible (Sprint 2)
├── 📁 docs/                   # Documentación completa
│   └── sprint1.md            # Documentación Sprint 1
├── � .github/workflows/      # CI/CD GitHub Actions
│   ├── ci-cd.yml             # Pipeline principal
│   ├── build-tests.yml       # Tests de construcción
│   ├── security-tests.yml    # Tests de seguridad
│   └── integration-tests.yml # Tests de integración
├── 🐳 docker-compose.yml      # Orquestación
└── 📖 README.md               # Este archivo
```

## 🔍 Testing y Verificación

### Health Checks Automáticos
Los containers incluyen verificaciones automáticas:
- ✅ SSH service activo
- ✅ Puerto 22 escuchando
- ✅ Usuario ansible configurado
- ✅ Python3 disponible
- ✅ Permisos sudo correctos

### Tests Manuales
```bash
# Test básico de conectividad
ssh ansible@localhost -p 2201
ssh ansible@localhost -p 2202

# Verificar health check interno
docker exec centos9-node1 /usr/local/bin/health-check.sh

# Tests de servicios
docker exec centos9-node1 systemctl status sshd
docker exec centos9-node1 python3 --version
```

### CI/CD Testing Automático
El proyecto incluye testing automático via GitHub Actions:
- **Build Tests**: Construcción de imágenes y validación
- **Functional Tests**: Servicios y funcionalidad básica
- **SSH Tests**: Conectividad y autenticación SSH
- **Security Tests**: Configuración de seguridad
- **Integration Tests**: Tests multi-container

## 🐛 Troubleshooting

### Problemas Comunes

**Container no inicia:**
```bash
# Ver logs detallados
docker compose logs centos9-node1

# Verificar estado de containers
docker compose ps

# Rebuild si es necesario
docker compose build --no-cache centos9-node1
```

**Error de conexión SSH:**
```bash
# Verificar que el container esté running
docker compose ps

# Verificar que SSH esté activo
docker exec centos9-node1 systemctl status sshd

# Test de conectividad
ssh ansible@localhost -p 2201
```

**Limpiar ambiente completamente:**
```bash
# Detener y eliminar todo
docker compose down -v

# Limpiar imágenes (opcional)
docker image prune -f

# Rebuild completo
docker compose build --no-cache
docker compose up -d
```

**Problemas de permisos o configuración:**
```bash
# Verificar configuración del usuario ansible
docker exec centos9-node1 id ansible
docker exec centos9-node1 groups ansible

# Verificar configuración SSH
docker exec centos9-node1 sshd -T

# Verificar health check
docker exec centos9-node1 /usr/local/bin/health-check.sh
```

## 🤝 Contribución

### Desarrollo Local
```bash
# Fork del repositorio
git clone https://github.com/your-username/ansible-docker.git
cd ansible-docker

# Crear rama de desarrollo
git checkout -b feature/nueva-funcionalidad

# Realizar cambios y testing
docker compose build
docker compose up -d
docker compose exec centos9-node1 bash

# Commit y push
git add .
git commit -m "feat: descripción del cambio"
git push origin feature/nueva-funcionalidad

# Crear Pull Request en GitHub
```

### Testing de Cambios
```bash
# Test básico local
docker compose up -d
ssh ansible@localhost -p 2201

# Test de health checks
docker exec centos9-node1 /usr/local/bin/health-check.sh

# Verificar que no hay regresiones
docker compose down
docker compose build --no-cache
docker compose up -d
```
1. Fork del proyecto
2. Crear rama de feature
3. Desarrollar y probar
4. Pull request con documentación

### Standards
- Documentación en Markdown
- Scripts PowerShell comentados
- Dockerfiles optimizados
- Tests automatizados

## 📈 Roadmap

### Sprint Actual: 1/5 ✅
- [x] CentOS 9 base optimizado
- [x] Scripts de gestión PowerShell
- [x] Docker Compose funcional
- [x] Documentación completa

### Próximos Sprints
- **Sprint 2:** Ansible Control Node
- **Sprint 3:** Orquestación avanzada
- **Sprint 4:** Playbooks y automatización
- **Sprint 5:** Monitoreo y optimización

## 📄 Licencia

Este proyecto está bajo licencia MIT. Ver `LICENSE` para más detalles.

## 👥 Equipo

**DevOps Team**
- Arquitectura y diseño
- Implementación Docker
- Documentación técnica
- Scripts de automatización

---

## 📞 Soporte

Para soporte técnico:
1. Revisar [documentación detallada](docs/sprint1.md)
2. Ejecutar `.\manage.ps1 test` para diagnóstico
3. Revisar logs con `.\manage.ps1 logs`
4. Crear [issue en GitHub](https://github.com/sebastian-alejandro/ansible-docker/issues)

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Por favor revisa:
- [Guía de Contribución](CONTRIBUTING.md)
- [Código de Conducta](CONTRIBUTING.md#-código-de-conducta)
- [Templates de Issues](.github/ISSUE_TEMPLATE/)

## 📋 Changelog

Ver [CHANGELOG.md](CHANGELOG.md) para detalles de todas las versiones y cambios.

## 📄 Licencia

Este proyecto está bajo [Licencia MIT](LICENSE). Ver el archivo LICENSE para más detalles.

---

**Estado del Proyecto:** 🟢 Sprint 1 Completado  
**Versión Actual:** v1.0.1  
**Repositorio:** https://github.com/sebastian-alejandro/ansible-docker  
**Última Actualización:** Junio 2025

## 🧪 Testing Automatizado (v1.1.0+)

### 🏗️ CI/CD Pipeline Completo
Este proyecto incluye un pipeline de CI/CD completo con **GitHub Actions** que ejecuta automáticamente 5 tipos de pruebas en cada commit y pull request:

[![CI/CD Tests](https://github.com/sebastian-alejandro/ansible-docker/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/sebastian-alejandro/ansible-docker/actions/workflows/ci-cd.yml)

### 📋 5 Tipos de Pruebas Automatizadas

#### 1. 🔨 **Build Tests**
- Construcción de imágenes Docker sin errores
- Validación de metadatos del container
- Verificación de variables de entorno
- Análisis de tamaño de imagen

#### 2. ⚡ **Functional Tests**
- Verificación de status del container
- Tests de servicio SSH (activo y escuchando)
- Validación de configuración de usuarios
- Tests de Python y herramientas esenciales

#### 3. 🔐 **SSH Connectivity Tests**
- Configuración del daemon SSH
- Autenticación por contraseña y clave pública
- Pruebas de host keys SSH
- Tests de conexión SSH reales

#### 4. 🔒 **Security Tests**
- Configuración de usuarios y grupos
- Validación de configuración sudo
- Verificación de permisos de archivos críticos
- Tests de servicios innecesarios

#### 5. 🔗 **Integration Tests**
- Despliegue multi-container con Docker Compose
- Tests de conectividad entre containers
- Verificación de mapeo de puertos
- Tests de health checks y persistencia

### 🎮 Ejecución de Tests

#### Tests Locales
```powershell
.\manage.ps1 test-full          # Suite completa
.\manage.ps1 test-build         # Solo build
.\manage.ps1 test-security      # Solo seguridad
```

#### Tests Remotos (GitHub Actions)
```powershell
.\manage.ps1 test-remote all                    # Ejecutar pipeline completo
.\manage.ps1 test-remote-security enhanced      # Tests de seguridad avanzados
.\manage.ps1 workflow-status                    # Ver estado actual
```

### 📊 Workflows Disponibles
- **Complete Test Suite**: Pipeline principal con todos los tests
- **Build Tests Only**: Solo pruebas de construcción
- **Security Tests Only**: Pruebas específicas de seguridad
- **Integration Tests Only**: Tests multi-container
- **Custom Test Runner**: Ejecutor personalizable

---
