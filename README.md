# 🐳 Ansible Docker Environment

[![Docker](https://img.shields.io/badge/Docker-20.10+-blue.svg)](https://www.docker.com/)
[![CentOS](https://img.shields.io/badge/CentOS-9%20Stream-red.svg)](https://www.centos.org/)
[![Ansible](https://img.shields.io/badge/Ansible-Ready-green.svg)](https://www.ansible.com/)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue.svg)](https://github.com/PowerShell/PowerShell)
[![Version](https://img.shields.io/badge/Version-1.1.0-success.svg)](https://github.com/sebastian-alejandro/ansible-docker/releases)
[![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-brightgreen.svg)](https://github.com/sebastian-alejandro/ansible-docker/actions)

## 🎯 Descripción

Ambiente completo de **Ansible** utilizando **Docker containers** para desarrollo, testing y automatización. Incluye:

- **CentOS 9 Stream** como **Managed Nodes** escalables
- **Ansible Control Node** para gestión centralizada (Sprint 2)
- **CI/CD Pipeline completo** con GitHub Actions
- **5 tipos de pruebas automatizadas** (Build, Functional, SSH, Security, Integration)
- Scripts de automatización y gestión con PowerShell
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
- Docker Desktop for Windows
- PowerShell 5.1+
- Git (opcional)

### 2. Instalación Rápida

```powershell
# Clonar o descargar el proyecto
cd c:\yumitt\ansible_docker

# Construir e iniciar
.\manage.ps1 build
.\manage.ps1 start

# Verificar estado
.\manage.ps1 status
.\manage.ps1 test
```

### 3. Conectarse a los Containers

```powershell
# SSH desde Windows
ssh ansible@localhost -p 2201  # Node 1
ssh ansible@localhost -p 2202  # Node 2

# O directamente al container
.\manage.ps1 shell centos9-node1
```

## 📚 Documentación por Sprints

### Sprint 1: ✅ Completado (v1.1.0)
- [📖 Sprint 1 - Fundamentos y CentOS 9](docs/sprint1.md)
- Container CentOS 9 optimizado
- Scripts de gestión PowerShell mejorados
- Docker Compose base con health checks
- **CI/CD Pipeline completo con GitHub Actions**
- **5 tipos de pruebas automatizadas**
- **Testing local y remoto integrado**

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

## 🛠️ Comandos Principales

```powershell
# Gestión básica
.\manage.ps1 build     # Construir imágenes
.\manage.ps1 start     # Iniciar containers
.\manage.ps1 stop      # Detener containers
.\manage.ps1 status    # Ver estado

# Testing Local (v1.1.0+)
.\manage.ps1 test               # Tests básicos de conectividad
.\manage.ps1 test-build         # Validar construcción de imagen
.\manage.ps1 test-security      # Tests básicos de seguridad
.\manage.ps1 test-full          # Suite completa de tests

# Testing Remoto via GitHub Actions (v1.1.0+)
.\manage.ps1 test-remote all                    # Ejecutar todos los tests remotos
.\manage.ps1 test-remote-build                  # Tests de build en CI/CD
.\manage.ps1 test-remote-security standard      # Tests de seguridad remotos
.\manage.ps1 test-remote-integration 5 2        # Tests de integración (5min, 2 containers)
.\manage.ps1 workflow-status                    # Ver estado de workflows
.\manage.ps1 setup-github                       # Configurar GitHub CLI

# Desarrollo y debug
.\manage.ps1 logs centos9-node1  # Ver logs
.\manage.ps1 shell centos9-node1 # Conectarse
.\manage.ps1 clean              # Limpiar ambiente

# Ayuda
.\manage.ps1 help      # Ver todos los comandos
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
├── 🐳 docker-compose.yml      # Orquestación
├── 💻 manage.ps1              # Script de gestión
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
```powershell
# Test completo de conectividad
.\manage.ps1 test

# Verificación manual SSH
ssh ansible@localhost -p 2201
```

## 🐛 Troubleshooting

### Problemas Comunes

**Container no inicia:**
```powershell
.\manage.ps1 logs centos9-node1
```

**Error de conexión SSH:**
```powershell
.\manage.ps1 test
.\manage.ps1 status
```

**Limpiar ambiente:**
```powershell
.\manage.ps1 clean
.\manage.ps1 build
.\manage.ps1 start
```

## 🤝 Contribución

### Desarrollo Local
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
