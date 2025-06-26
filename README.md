# 🐳 Ansible Docker Environment - Plataforma Evolutiva

[![Docker](https://img.shields.io/badge/Docker-20.10+-blue.svg)](https://www.docker.com/)
[![CentOS](https://img.shields.io/badge/CentOS-9%20Stream-red.svg)](https://www.centos.org/)
[![Rocky](https://img.shields.io/badge/Rocky-9-blue.svg)](https://rockylinux.org/)
[![Ansible](https://img.shields.io/badge/Ansible-Core-green.svg)](https://www.ansible.com/)
[![Version](https://img.shields.io/badge/Version-1.2.0-success.svg)](https://github.com/sebastian-alejandro/ansible-docker/releases)
[![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-brightgreen.svg)](https://github.com/sebastian-alejandro/ansible-docker/actions)
[![Sprint](https://img.shields.io/badge/Sprint-1%2F5%20Completado-orange.svg)](docs/project-vision.md)

## 🎯 Descripción

**Plataforma evolutiva de automatización Ansible** que transforma desde un laboratorio básico hasta una **solución empresarial de clase mundial**. Proyecto estructurado en **5 sprints** con metodología ágil, cada uno construyendo sobre el anterior.

### 🚀 Visión del Proyecto

> **Transformar la automatización de infraestructura** desde fundamentos sólidos hasta excelencia operacional con observabilidad completa, self-healing y optimización predictiva.

**Estado Actual**: ✅ **Sprint 1 COMPLETADO** - Base sólida establecida  
**Próximo Hito**: 📅 **Sprint 2** - Control Node y automatización SSH

### ✨ Evolución por Sprints

| Sprint | Fase | Estado | Valor de Negocio |
|--------|------|--------|------------------|
| 🏗️ **Sprint 1** | Fundamentos | ✅ **Completado** | Base confiable |
| 🎛️ **Sprint 2** | Control & Automatización | 📅 **Planificado** | Reducir errores 90% |
| 🌐 **Sprint 3** | Orquestación Avanzada | 📅 **Planificado** | Escalabilidad empresarial |
| 🏢 **Sprint 4** | Nivel Empresarial | 📅 **Planificado** | Reducir costos 40% |
| 📊 **Sprint 5** | Excelencia Operacional | 📅 **Planificado** | 99.9% uptime, ML-powered |

## 🏗️ Arquitectura Sprint 2

```
┌─────────────────────────┐
│   Ansible Control Node │
│   (Rocky Linux 9)       │  SSH Passwordless
│   Port: 2200           │ ◄────────────────┐
└─────────────────────────┘                  │
            │                                │
            │ Ansible Automation             │
            ▼                                │
┌─────────────────────────┐                  │
│     Managed Nodes       │                  │
│                         │                  │
│  ┌─────────────────┐   │                  │
│  │ centos9-node-1  │   │ ◄────────────────┤
│  │ Port: 2201      │   │                  │
│  └─────────────────┘   │                  │
│  ┌─────────────────┐   │                  │
│  │ centos9-node-2  │   │ ◄────────────────┤
│  │ Port: 2202      │   │                  │
│  └─────────────────┘   │                  │
│  ┌─────────────────┐   │                  │
│  │ centos9-node-3  │   │ ◄────────────────┘
│  │ Port: 2203      │   │
│  └─────────────────┘   │
└─────────────────────────┘
```

## 🚀 Quick Start Sprint 2

### 1. Prerrequisitos
- Docker Desktop (Windows/Linux/macOS)
- Docker Compose v2.0+
- Git (para clonación del repositorio)

### 2. Instalación y Configuración

```bash
# Clonar repositorio
git clone https://github.com/sebastian-alejandro/ansible-docker.git
cd ansible-docker

# Usar script de gestión (recomendado)
chmod +x manage-sprint2.sh
./manage-sprint2.sh start

# O usar Docker Compose directamente
docker compose up -d --build
```

### 3. Acceso al Nodo de Control

```bash
# Método 1: Script de gestión
./manage-sprint2.sh shell

# Método 2: Docker Compose directo
docker compose exec ansible-control bash
```
### 4. Verificar Conectividad y Estado

```bash
# Verificar estado del laboratorio
./manage-sprint2.sh status

# Test de conectividad Ansible
./manage-sprint2.sh test

# Ver inventario de hosts
./manage-sprint2.sh inventory
```

### 5. Ejecutar Playbooks de Demostración

```bash
# Playbook básico de conectividad
./manage-sprint2.sh playbook ping.yml

# Configuración base de nodos
./manage-sprint2.sh playbook setup-base.yml

# Configuración de webservers
./manage-sprint2.sh playbook setup-webservers.yml
```

## 🎛️ Script de Gestión Sprint 2

El script `manage-sprint2.sh` proporciona comandos simplificados para gestionar el laboratorio:

```bash
# Comandos principales
./manage-sprint2.sh start        # Iniciar laboratorio completo
./manage-sprint2.sh stop         # Detener laboratorio
./manage-sprint2.sh restart      # Reiniciar laboratorio
./manage-sprint2.sh status       # Verificar estado

# Gestión de Ansible
./manage-sprint2.sh shell        # Acceso al control node
./manage-sprint2.sh test         # Test de conectividad
./manage-sprint2.sh playbook     # Ejecutar playbooks
./manage-sprint2.sh inventory    # Ver inventario
./manage-sprint2.sh keys         # Redistribuir claves SSH

# Mantenimiento
./manage-sprint2.sh logs         # Ver logs
./manage-sprint2.sh build        # Reconstruir imágenes
./manage-sprint2.sh backup       # Backup de datos
./manage-sprint2.sh cleanup      # Limpiar todo
```

## 🔐 Acceso SSH

### Desde el Nodo de Control (automático)
```bash
# Dentro del nodo de control
ansible all -m ping                    # Test todos los nodos
ssh ansible@centos9-node-1            # SSH directo a nodo
ssh ansible@centos9-node-2            # SSH directo a nodo
ssh ansible@centos9-node-3            # SSH directo a nodo
```

### Desde Host Externo
```bash
# SSH directo desde el host
ssh ansible@localhost -p 2200  # Control Node
ssh ansible@localhost -p 2201  # Node 1  
ssh ansible@localhost -p 2202  # Node 2
ssh ansible@localhost -p 2203  # Node 3

# Contraseña por defecto: ansible123
```

### Acceso Docker Directo
```bash
# Ejecutar bash directamente
docker compose exec ansible-control bash
docker compose exec centos9-node-1 bash
docker compose exec centos9-node-2 bash
docker compose exec centos9-node-3 bash
```

## 📚 Documentación por Sprints

## 📚 Documentación por Sprints

> 📖 **[Visión Completa del Proyecto](docs/project-vision.md)** - Arquitectura evolutiva y roadmap detallado

### Sprint 1: ✅ Completado (v1.2.0) - **ACTUAL**
- [📖 Sprint 1 - Fundamentos y CentOS 9](docs/sprint1.md)
- ✅ Container CentOS 9 optimizado
- ✅ **Comandos nativos Docker/Docker Compose** para gestión multiplataforma
- ✅ Docker Compose base con health checks
- ✅ **CI/CD Pipeline completo con GitHub Actions**
- ✅ **5 tipos de pruebas automatizadas**
- ✅ **Testing automatizado en GitHub Actions**

### Sprint 2: 📅 Planificado (v2.0.0)
- [📖 Sprint 2 - Control Node y Automatización SSH](docs/sprint2.md)
- 🔄 Ansible Control Node (Rocky Linux 9)
- 🔄 SSH keys automáticas y distribución
- 🔄 Inventario dinámico con grupos
- 🔄 Playbooks de demostración
- 🔄 Script de gestión avanzado

### Sprint 3: 📅 Planificado (v3.0.0)
- [📖 Sprint 3 - Orquestación Avanzada](docs/sprint3.md)
- 🔄 Múltiples entornos (dev/staging/prod)
- 🔄 Ansible Vault para gestión de secretos
- 🔄 Roles y collections empresariales
- 🔄 Pipeline CI/CD avanzado con Molecule
- 🔄 AWX/Tower para orquestación

### Sprint 4: 📅 Planificado (v4.0.0)
- [📖 Sprint 4 - Automatización Empresarial](docs/sprint4.md)
- 🔄 Playbooks de administración avanzada
- 🔄 Integración con sistemas externos (LDAP, ServiceNow)
- 🔄 Reporting y auditoría empresarial
- 🔄 Escalado automático multi-cloud
- 🔄 Governance y compliance automático

### Sprint 5: 📅 Planificado (v5.0.0)
- [📖 Sprint 5 - Excelencia Operacional](docs/sprint5.md)
- 🔄 Observabilidad 360° (Prometheus, Grafana, ELK)
- 🔄 Machine Learning para optimización predictiva
- 🔄 Self-healing y auto-remediation
- 🔄 FinOps y cost optimization avanzado
- 🔄 Capacidades de IA y predictive analytics

### 🔗 Enlaces de Navegación Rápida
- 📊 **[Visión del Proyecto](docs/project-vision.md)** - Arquitectura evolutiva completa y roadmap
- 🏗️ **[Sprint Actual - Sprint 1](docs/sprint1.md)** - Detalles del sprint completado
- 🎛️ **[Próximo Sprint - Sprint 2](docs/sprint2.md)** - Control Node y automatización SSH
- 📈 **[Roadmap Completo](docs/project-vision.md#-roadmap-temporal)** - Timeline y métricas de progreso
- 🎯 **[Criterios de Éxito](docs/project-vision.md#-criterios-de-éxito-del-proyecto)** - KPIs y objetivos del proyecto
- 🔄 **[Metodología Ágil](docs/project-vision.md#-flujo-de-desarrollo-ágil)** - Proceso de desarrollo por sprints

## �️ Comandos de Gestión

### Sprint 1 (Actual)
```bash
# Gestión básica con Docker Compose
docker compose up -d
docker compose ps
docker compose logs
docker compose down

# SSH a containers
ssh ansible@localhost -p 2201  # Node 1
ssh ansible@localhost -p 2202  # Node 2
```

### Sprint 2 (Próximo)
```bash
# Script de gestión avanzado
./manage-sprint2.sh start       # Iniciar laboratorio
./manage-sprint2.sh shell       # Acceso al control node
./manage-sprint2.sh test        # Test conectividad Ansible
./manage-sprint2.sh playbook    # Ejecutar playbooks
```

## � Métricas de Progreso

| Sprint | Estado | Progreso | Valor de Negocio |
|--------|--------|----------|------------------|
| 🏗️ **Sprint 1** | ✅ **Completado** | 100% | Base confiable establecida |
| 🎛️ **Sprint 2** | 📅 **Planificado** | 0% | Reducir errores manuales 90% |
| 🌐 **Sprint 3** | 📅 **Futuro** | 0% | Escalabilidad empresarial |
| 🏢 **Sprint 4** | 📅 **Futuro** | 0% | Reducir costos infraestructura 40% |
| 📊 **Sprint 5** | 📅 **Futuro** | 0% | Excelencia operacional 99.9% |

## 🤝 Contribución

### 🌟 Cómo Contribuir

1. **Fork** el repositorio
2. **Clone** tu fork localmente
3. **Crea** una branch para tu feature: `git checkout -b feature/amazing-feature`
4. **Commit** tus cambios: `git commit -m 'Add amazing feature'`
5. **Push** a tu branch: `git push origin feature/amazing-feature`
6. **Abre** un Pull Request

### 📋 Guidelines

- Seguir el estilo de código existente
- Incluir tests para nuevas funcionalidades
- Actualizar documentación cuando sea necesario
- Usar conventional commits

### � Reportar Issues

- Usar templates de issues
- Incluir información de entorno
- Pasos para reproducir el problema
- Logs relevantes

## 📜 Licencia

Este proyecto está licenciado bajo la **MIT License** - ver el archivo [LICENSE](LICENSE) para detalles.

## 🙏 Agradecimientos

- **Red Hat Ansible** por la increíble plataforma de automatización
- **Docker Community** por containerización sencilla
- **CentOS/Rocky Linux** por sistemas operativos estables
- **GitHub Actions** por CI/CD gratuito
- **Open Source Community** por herramientas y bibliotecas

## 📞 Soporte

### 🆘 ¿Necesitas Ayuda?

- 📖 **Documentación**: Revisa la documentación en `/docs`
- � **Issues**: Reporta problemas en GitHub Issues
- 💬 **Discusiones**: Únete a las discusiones de la comunidad
- 📧 **Email**: Contacto directo para soporte empresarial

### 🔗 Enlaces Útiles

- [📖 Documentación Completa](docs/)
- [🐛 Reportar Issue](https://github.com/tu-usuario/ansible-docker/issues)
- [💬 Discusiones](https://github.com/tu-usuario/ansible-docker/discussions)
- [� Roadmap](docs/project-vision.md)

---

⭐ **Si este proyecto te ayuda, dale una estrella en GitHub!** ⭐

*Hecho con ❤️ para la comunidad DevOps y Ansible*