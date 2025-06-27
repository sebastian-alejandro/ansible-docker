# 🐍 Scripts Python - Ansible Docker Environment

Esta carpeta contiene scripts Python multiplataforma que reemplazan los scripts PowerShell para mayor compatibilidad.

## 📋 Scripts Disponibles

### 🚀 `automation.py` - Script Principal
**Propósito**: Interfaz unificada para todos los procesos de CI/CD

**Uso Interactivo**:
```bash
python automation.py
```

**Uso por Línea de Comandos**:
```bash
python automation.py test      # Ejecutar tests funcionales
python automation.py validate # Validación pre-commit
python automation.py commit   # Control de versión
python automation.py full     # Pipeline completo
python automation.py help     # Mostrar ayuda
```

### 🧪 `test_functional_ci.py` - Tests Funcionales
**Propósito**: Reproduce las condiciones exactas de GitHub Actions localmente

**Características**:
- ✅ Construye imagen Docker
- ✅ Inicia contenedor en modo CI
- ✅ Detecta automáticamente systemd vs fallback mode
- ✅ Valida servicios SSH
- ✅ Cleanup automático

**Uso**:
```bash
python test_functional_ci.py
```

### 🔍 `pre_commit_check.py` - Validación Pre-Commit
**Propósito**: Valida código y configuración antes de hacer commit

**Validaciones**:
- ✅ Sintaxis YAML (workflows, docker-compose)
- ✅ Sintaxis Python
- ✅ Archivos requeridos
- ✅ Estado Git
- ✅ Configuración GitHub Actions

**Uso**:
```bash
python pre_commit_check.py
```

### 🚀 `version_control.py` - Control de Versión
**Propósito**: Automatiza commit, push y creación de tags

**Funcionalidades**:
- ✅ Genera mensaje de commit descriptivo
- ✅ Crea y push de cambios
- ✅ Crea tags de versión
- ✅ Dispara workflow de GitHub Actions

**Uso**:
```bash
python version_control.py
```

## 🔧 Dependencias

### Requeridas (Incluidas en Python estándar)
- `subprocess` - Ejecución de comandos
- `sys` - Argumentos y control del sistema
- `os` - Operaciones del sistema operativo
- `json` - Manejo de JSON
- `datetime` - Fechas y tiempo
- `pathlib` - Manejo de rutas

### Opcionales
- `PyYAML` - Para validación avanzada de YAML
  ```bash
  pip install pyyaml
  ```

### Herramientas Externas Requeridas
- **Git** - Control de versión
- **Docker** - Contenedores
- **Python 3.6+** - Interpretador

## 🚀 Quick Start

### 1. Verificar Dependencias
```bash
python automation.py
# El script verificará automáticamente las dependencias
```

### 2. Ejecutar Pipeline Completo
```bash
python automation.py full
```

Esto ejecutará:
1. 🔍 Validación pre-commit
2. 🧪 Tests funcionales
3. 🚀 Control de versión

### 3. Ejecutar Componentes Individuales
```bash
# Solo validación
python automation.py validate

# Solo tests
python automation.py test

# Solo commit
python automation.py commit
```

## 📊 Compatibilidad

### Sistemas Operativos
- ✅ **Windows** (PowerShell, CMD, Git Bash)
- ✅ **Linux** (Ubuntu, CentOS, RHEL, etc.)
- ✅ **macOS** (Terminal, iTerm)

### Entornos Python
- ✅ **Python 3.6+**
- ✅ **CPython**
- ✅ **PyPy** (compatible)

### Shells
- ✅ **Bash**
- ✅ **PowerShell**
- ✅ **Zsh**
- ✅ **Fish**
- ✅ **CMD**

## 🎯 Casos de Uso

### Para Desarrolladores
```bash
# Antes de hacer commit
python automation.py validate

# Probar cambios localmente
python automation.py test

# Pipeline completo
python automation.py full
```

### Para CI/CD
```bash
# En pipelines locales
python automation.py test

# Validación en hooks pre-commit
python automation.py validate
```

### Para DevOps
```bash
# Release completo
python automation.py full

# Verificación rápida
python automation.py validate
```

## 🔍 Troubleshooting

### Error: "Git not available"
```bash
# Instalar Git
# Windows: https://git-scm.com/download/win
# Linux: sudo apt-get install git
# macOS: brew install git
```

### Error: "Docker not available"
```bash
# Instalar Docker
# https://docs.docker.com/get-docker/
```

### Error: "PyYAML import failed"
```bash
# Instalar PyYAML (opcional)
pip install pyyaml
```

### Error: "Permission denied"
```bash
# En Linux/macOS, dar permisos de ejecución
chmod +x *.py

# O ejecutar con python explícitamente
python automation.py
```

## 📈 Mejoras vs PowerShell

| Aspecto | PowerShell | Python |
|---------|------------|---------|
| **Compatibilidad** | Solo Windows/Core | Multiplataforma |
| **Dependencias** | PowerShell requerido | Python estándar |
| **Sintaxis** | Windows-específica | Universal |
| **Mantenimiento** | Limitado | Amplio ecosistema |
| **Debugging** | Limitado | Excelente |
| **Testing** | Básico | Frameworks avanzados |

## 🔄 Migración desde PowerShell

Los scripts Python reemplazan completamente los scripts PowerShell:

| PowerShell (Eliminado) | Python (Nuevo) |
|------------------------|----------------|
| `test-functional-ci.ps1` | `test_functional_ci.py` |
| `version-control.ps1` | `version_control.py` |
| `pre-commit-check.ps1` | `pre_commit_check.py` |
| - | `automation.py` (nuevo) |

**Migración**: Simplemente usa los scripts Python con la misma funcionalidad.

## 📞 Soporte

### Problemas Comunes
1. **Dependencias faltantes**: El script `automation.py` verifica automáticamente
2. **Permisos**: Usar `python script.py` en lugar de `./script.py`
3. **Encoding**: Los scripts usan UTF-8 por defecto

### Logs y Debug
Los scripts incluyen salida colorizada y detallada para facilitar el debugging.

---

📅 **Creado**: Junio 2025  
🔄 **Migración**: PowerShell → Python  
✅ **Estado**: Listo para uso en producción
