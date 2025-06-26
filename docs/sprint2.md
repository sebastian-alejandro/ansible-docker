# Sprint 2: Nodo de Control de Ansible y Automatización SSH

## 🎯 Objetivos del Sprint 2

Este sprint se enfoca en crear un verdadero entorno de laboratorio de Ansible con un nodo de control dedicado y automatización completa de SSH.

### Funcionalidades Principales

1. **Nodo de Control de Ansible**
   - Contenedor dedicado para Ansible Control Node
   - Instalación automática de Ansible y herramientas
   - Configuración de usuario ansible con privilegios sudo

2. **Automatización de SSH**
   - Generación automática de claves SSH
   - Distribución automática de claves públicas
   - Configuración sin contraseña entre nodos

3. **Inventario Dinámico**
   - Inventario de Ansible generado automáticamente
   - Grupos predefinidos (webservers, databases, etc.)
   - Variables de grupo y host configuradas

4. **Playbooks de Demostración**
   - Playbooks básicos para testing
   - Ejemplos de configuración de servicios
   - Validación de conectividad

## 🏗️ Arquitectura Propuesta

```
ansible-control-node (rocky9-ansible)
├── Ansible Core instalado
├── SSH keys generadas
├── Inventario dinámico
└── Playbooks de ejemplo

target-nodes (centos9-node-*)
├── SSH daemon configurado
├── Usuario ansible creado
├── Claves SSH autorizadas
└── Sudo sin contraseña
```

## 📋 Tareas del Sprint

### Fase 1: Nodo de Control de Ansible
- [ ] Crear Dockerfile para nodo de control (Rocky Linux 9)
- [ ] Instalar Ansible Core y herramientas adicionales
- [ ] Configurar usuario ansible con privilegios
- [ ] Script de inicialización del nodo de control

### Fase 2: Automatización SSH
- [ ] Script para generar claves SSH automáticamente
- [ ] Distribución automática de claves públicas
- [ ] Configuración de SSH sin contraseña
- [ ] Validación de conectividad SSH

### Fase 3: Inventario Dinámico
- [ ] Script para generar inventario automáticamente
- [ ] Configuración de grupos y variables
- [ ] Integración con Docker Compose
- [ ] Validación de inventario

### Fase 4: Playbooks y Testing
- [ ] Playbooks básicos de demostración
- [ ] Tests de conectividad
- [ ] Ejemplos de configuración
- [ ] Documentación de uso

## 🔧 Herramientas y Tecnologías

- **Ansible Core**: Motor principal de automatización
- **Rocky Linux 9**: OS base para nodo de control
- **SSH**: Comunicación segura entre nodos
- **Docker Compose**: Orquestación de contenedores
- **Bash Scripts**: Automatización de tareas

## 📊 Criterios de Aceptación

1. ✅ **Nodo de Control Funcional**
   - Ansible instalado y operativo
   - Usuario ansible configurado
   - SSH keys generadas automáticamente

2. ✅ **Conectividad SSH Automática**
   - Conexión sin contraseña entre nodos
   - Claves distribuidas correctamente
   - Validación automática de conectividad

3. ✅ **Inventario Dinámico**
   - Inventario generado automáticamente
   - Grupos y variables configuradas
   - Integración con Docker Compose

4. ✅ **Playbooks Funcionales**
   - Playbooks básicos ejecutándose
   - Tests de conectividad pasando
   - Documentación completa

## 🚀 Comandos de Gestión

```bash
# Levantar entorno completo con nodo de control
docker compose up -d

# Acceder al nodo de control
docker compose exec ansible-control bash

# Ejecutar playbook de prueba
docker compose exec ansible-control ansible-playbook -i inventory/hosts playbooks/ping.yml

# Validar conectividad SSH
docker compose exec ansible-control ansible all -i inventory/hosts -m ping

# Ver estado de todos los nodos
docker compose ps
```

## 📈 Métricas de Éxito

- **Tiempo de setup**: < 2 minutos para entorno completo
- **Conectividad SSH**: 100% de nodos accesibles
- **Playbooks**: 100% de ejecución exitosa
- **Documentación**: Guías completas y actualizadas

## 🔄 Integración CI/CD

- Tests automáticos de SSH connectivity
- Validación de playbooks en CI/CD
- Tests de inventario dinámico
- Verificación de nodo de control

## 📚 Entregables

1. **Código**
   - Dockerfile para nodo de control
   - Scripts de automatización SSH
   - Generador de inventario dinámico
   - Playbooks de demostración

2. **Documentación**
   - Guía de uso del nodo de control
   - Ejemplos de playbooks
   - Troubleshooting común
   - Arquitectura detallada

3. **Tests**
   - Tests de conectividad SSH
   - Validación de playbooks
   - Tests de inventario
   - CI/CD actualizado

---

*Sprint 2 - Automatización completa del laboratorio Ansible*
