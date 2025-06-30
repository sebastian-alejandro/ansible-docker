# 🤝 Contributing to Ansible Docker Environment

¡Gracias por tu interés en contribuir al proyecto! Esta guía te ayudará a comenzar.

## 📋 Cómo Contribuir

### 🐛 Reportar Bugs
1. Verifica que el bug no haya sido reportado previamente
2. Usa el template de [Bug Report](.github/ISSUE_TEMPLATE/bug_report.md)
3. Incluye información detallada del ambiente y logs
4. Ejecuta `.\manage.ps1 test` antes de reportar

### ✨ Sugerir Funcionalidades
1. Usa el template de [Feature Request](.github/ISSUE_TEMPLATE/feature_request.md)
2. Explica claramente el problema que resuelve
3. Proporciona ejemplos de uso
4. Considera el impacto en la arquitectura existente

### 🔧 Enviar Pull Requests
1. Fork del repositorio
2. Crear rama de feature desde `main`
3. Seguir los estándares de código
4. Agregar tests apropiados
5. Actualizar documentación
6. Enviar Pull Request

## 🏗️ Estructura del Proyecto

```
ansible_docker/
├── centos9/                    # Container CentOS 9
├── ansible-control/            # Container Ansible (futuro)
├── docs/                       # Documentación por Sprint
├── .github/                    # Templates y workflows
├── docker-compose.yml          # Orquestación
└── manage.ps1                  # Scripts de gestión
```

## 📝 Estándares de Código

### Dockerfiles
- Usar multi-stage builds cuando sea posible
- Comentarios descriptivos en español
- Optimizar capas y tamaño de imagen
- Incluir health checks
- Seguir mejores prácticas de seguridad

### Scripts PowerShell
- Funciones con nombres descriptivos
- Comentarios explicativos
- Manejo de errores apropiado
- Validación de parámetros
- Seguir PSScriptAnalyzer rules

### Docker Compose
- Usar versión 3.8+
- Comentarios por sección
- Variables de entorno documentadas
- Redes y volúmenes nombrados apropiadamente

### Documentación
- Formato Markdown
- Emojis para mejor legibilidad
- Ejemplos prácticos
- Troubleshooting actualizado
- Links internos funcionales

## 🧪 Testing

### Antes de enviar PR:
```powershell
# Construir y probar localmente
.\manage.ps1 build
.\manage.ps1 start
.\manage.ps1 test

# Verificar logs
.\manage.ps1 logs

# Limpiar ambiente
.\manage.ps1 clean
```

### CI/CD Pipeline
- Lint de Dockerfiles con Hadolint
- Validación de Docker Compose
- Análisis de PowerShell scripts
- Tests de integración automáticos

## 📚 Desarrollo por Sprints

### Sprint Actual: 1/5 ✅
- CentOS 9 base implementation

### Próximos Sprints:
- **Sprint 2:** Ansible Control Node
- **Sprint 3:** Orquestación avanzada
- **Sprint 4:** Playbooks y automatización  
- **Sprint 5:** Monitoreo y optimización

## 🔄 Workflow de Git

### Ramas
- `main` - Código estable en producción
- `develop` - Desarrollo activo
- `feature/nombre-feature` - Nuevas funcionalidades
- `hotfix/nombre-fix` - Correcciones urgentes

### Commits
Usar [Conventional Commits](https://www.conventionalcommits.org/):

```
tipo(scope): descripción

feat(docker): agregar health check to centos9 container
fix(scripts): corregir issue con permisos SSH
docs(readme): actualizar guía de instalación
```

### Tags de Versión
- `v1.0.0` - Sprint 1 completion
- `v1.1.0` - Sprint 2 completion
- `v2.0.0` - Major architecture changes

## 🎯 Issues y Labels

### Labels de Issues:
- `bug` - Reportes de bugs
- `enhancement` - Mejoras
- `feature-request` - Nuevas funcionalidades
- `documentation` - Mejoras en documentación
- `sprint-2`, `sprint-3`, etc. - Por sprint
- `good-first-issue` - Para nuevos contribuidores
- `help-wanted` - Necesita ayuda de la comunidad

## 📞 Comunicación

### Canales:
- **GitHub Issues** - Bugs y feature requests
- **GitHub Discussions** - Preguntas generales
- **Pull Requests** - Revisión de código

### Tiempos de Respuesta:
- Issues: 24-48 horas
- Pull Requests: 2-5 días
- Preguntas: 24 horas

## ⚖️ Código de Conducta

### Nuestros Compromisos:
- Ser inclusivos y respetuosos
- Aceptar críticas constructivas
- Focalizarse en lo mejor para la comunidad
- Mostrar empatía hacia otros miembros

### Comportamientos No Aceptados:
- Lenguaje o imágenes sexualizadas
- Trolling, insultos o ataques personales
- Acoso público o privado
- Publicar información privada sin permiso

## 🏆 Reconocimientos

Los contribuidores serán reconocidos en:
- README.md del proyecto
- Releases notes
- Changelog del proyecto

### Tipos de Contribuciones:
- 💻 Código
- 📖 Documentación
- 🐛 Bug reports
- 💡 Ideas y sugerencias
- 🎨 Diseño
- 📋 Project management

## 📄 Licencia

Al contribuir, aceptas que tus contribuciones serán licenciadas bajo la misma licencia MIT del proyecto.

---

**¿Preguntas?** Abre un [GitHub Discussion](https://github.com/sebastian-alejandro/ansible-docker/discussions) o crea un issue.

¡Esperamos tus contribuciones! 🚀
