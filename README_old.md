# Ansible Docker Environment

[![Docker](https://img.shields.io/badge/Docker-20.10+-blue.svg)](https://www.docker.com/)
[![CentOS](https://img.shields.io/badge/CentOS-9%20Stream-red.svg)](https://www.centos.org/)
[![Ansible](https://img.shields.io/badge/Ansible-Core-green.svg)](https://www.ansible.com/)
[![Version](https://img.shields.io/badge/Version-1.2.1-success.svg)](https://github.com/sebastian-alejandro/ansible-docker/releases)

## Description

Containerized Ansible lab environment using CentOS 9 Stream with Docker Compose orchestration. Provides isolated, reproducible infrastructure for Ansible automation testing and development.

### Current Status

- **Version**: 1.2.1
- **Base OS**: CentOS 9 Stream  
- **Orchestration**: Docker Compose
- **CI/CD**: GitHub Actions automated testing

## Architecture

```
┌─────────────────────────┐
│     Docker Host         │
│                         │
│  ┌─────────────────┐   │
│  │ centos9-node-1  │   │
│  │ Port: 2201      │   │
│  │ SSH: 22         │   │
│  └─────────────────┘   │
│  ┌─────────────────┐   │
│  │ centos9-node-2  │   │
│  │ Port: 2202      │   │
│  │ SSH: 22         │   │
│  └─────────────────┘   │
└─────────────────────────┘
```

## Requirements

- Docker Engine 20.10+
- Docker Compose v2.0+
- 2GB RAM minimum
- 5GB disk space

## Installation

### Clone Repository
```bash
git clone https://github.com/sebastian-alejandro/ansible-docker.git
cd ansible-docker
```

### Start Environment
```bash
docker compose up -d
```

### Verify Deployment
```bash
docker compose ps
docker compose logs
```

## Usage

### SSH Access
```bash
# Node 1
ssh ansible@localhost -p 2201

# Node 2  
ssh ansible@localhost -p 2202

# Default password: ansible123
```

### Container Shell Access
```bash
docker compose exec centos9-node-1 bash
docker compose exec centos9-node-2 bash
```

### Management Commands
```bash
# Start environment
docker compose up -d

# Stop environment  
docker compose down

# View logs
docker compose logs

# Rebuild containers
docker compose up -d --build
```

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