# 📋 Changelog - Ansible Docker Environment

Todas las modificaciones importantes del proyecto serán documentadas en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-06-24 - Sprint 1 Release 🚀

### ✅ Agregado
- **CentOS 9 Stream Base Container**
  - Dockerfile optimizado para gestión con Ansible
  - SSH server preconfigurado (puerto 22)
  - Usuario `ansible` con permisos sudo sin password
  - Usuario `root` configurado para acceso administrativo
  - Python3 y herramientas esenciales de administración

- **Scripts de Automatización**
  - `init.sh` - Script de inicialización con logging completo
  - `health-check.sh` - Verificaciones automatizadas de salud del container
  - `manage.ps1` - Script PowerShell para gestión completa del ambiente

- **Orquestación Docker**
  - `docker-compose.yml` con configuración multi-container
  - Red interna `ansible-network` (172.20.0.0/16)
  - Volúmenes persistentes para datos y logs
  - Health checks integrados con Docker

- **Documentación Completa**
  - `README.md` - Documentación principal del proyecto
  - `docs/sprint1.md` - Documentación detallada del Sprint 1
  - `.gitignore` - Configuración para control de versiones
  - Guías de instalación, uso y troubleshooting

### 🏗️ Arquitectura Implementada
- 2 containers CentOS 9 por defecto (escalable)
- Mapeo de puertos SSH: 2201, 2202
- Estructura preparada para Ansible Control Node
- Logging centralizado y monitoreo de salud

### 🔧 Herramientas de Gestión
- Comandos simplificados via `manage.ps1`
- Tests automatizados de conectividad
- Construcción y deploy automatizado
- Limpieza y mantenimiento del ambiente

### 📚 Compatibilidad
- **OS:** Windows con Docker Desktop
- **PowerShell:** 5.1+
- **Docker:** 20.10+
- **Docker Compose:** 2.0+

### 🎯 Próximos Desarrollos
- **Sprint 2:** Ansible Control Node container
- **Sprint 3:** Orquestación avanzada y escalado
- **Sprint 4:** Playbooks y automatización
- **Sprint 5:** Monitoreo y optimización

---

## Formato de Versionado

**Major.Minor.Patch** (Semantic Versioning)

- **Major:** Cambios incompatibles en la API/arquitectura
- **Minor:** Nueva funcionalidad compatible hacia atrás (Sprints)
- **Patch:** Correcciones de bugs y mejoras menores

### Ejemplos:
- `1.0.0` - Sprint 1: Base implementation
- `1.1.0` - Sprint 2: Ansible Control Node
- `1.2.0` - Sprint 3: Advanced orchestration
- `2.0.0` - Major architecture changes

---

## Contribuciones

Para contribuir al proyecto:
1. Fork del repositorio
2. Crear rama de feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crear Pull Request

---

**Repositorio:** https://github.com/sebastian-alejandro/ansible-docker  
**Mantenido por:** DevOps Team  
**Licencia:** MIT
