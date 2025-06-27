# 🚀 Guía de Control de Versión - Ansible Docker Environment

## 📋 Scripts Disponibles

### 1. `pre-commit-check.ps1` - Verificación Pre-Commit
**Propósito**: Verifica que todas las correcciones estén implementadas correctamente antes del commit.

```powershell
# Ejecutar verificación
.\pre-commit-check.ps1
```

**Qué verifica**:
- ✅ Lógica adaptativa en functional tests
- ✅ Variables CI en SSH tests  
- ✅ Compatibilidad dual en security tests
- ✅ Script de prueba local correcto
- ✅ Documentación actualizada
- ✅ Estado git y conectividad

### 2. `version-control.ps1` - Control de Versión Automatizado
**Propósito**: Automatiza commit, tag y push para disparar GitHub Actions.

```powershell
# Ejecución básica (patch version)
.\version-control.ps1

# Ver qué se ejecutaría sin hacer cambios
.\version-control.ps1 -DryRun

# Incrementar versión minor
.\version-control.ps1 -VersionType minor

# Con mensaje personalizado
.\version-control.ps1 -Message "🔧 Fix: Critical CI/CD Issue"
```

**Parámetros**:
- `-DryRun`: Muestra qué comandos se ejecutarían sin ejecutarlos
- `-VersionType`: major, minor, patch (default: patch)  
- `-Message`: Mensaje personalizado de commit

### 3. `test-functional-ci.ps1` - Prueba Local CI
**Propósito**: Reproduce las condiciones exactas de GitHub Actions localmente.

```powershell
# Probar funcionalidad en modo CI
.\test-functional-ci.ps1
```

## 🔄 Workflow Recomendado

### Paso 1: Verificar Correcciones
```powershell
# Verificar que todo está correcto
.\pre-commit-check.ps1
```

**Resultado esperado**: ✅ LISTO PARA COMMIT

### Paso 2: Prueba Local (Opcional)
```powershell
# Probar las correcciones localmente
.\test-functional-ci.ps1
```

**Resultado esperado**: 🎉 Functional test completed successfully!

### Paso 3: Control de Versión
```powershell
# Primero ver qué se haría (dry run)
.\version-control.ps1 -DryRun

# Si todo se ve bien, ejecutar
.\version-control.ps1
```

**Resultado esperado**: 🎉 ¡Control de versión completado exitosamente!

## 📊 Versionado Semántico

### Tipos de Versión:
- **major** (v1.0.0 → v2.0.0): Cambios incompatibles
- **minor** (v1.0.0 → v1.1.0): Nueva funcionalidad compatible  
- **patch** (v1.0.0 → v1.0.1): Fixes y correcciones

### Para nuestro caso actual:
```powershell
# Fix crítico de CI/CD = patch version
.\version-control.ps1 -VersionType patch
```

## 🎯 Resultado Final

Después de ejecutar el workflow completo:

1. **Commit creado** con mensaje detallado
2. **Tag de versión** generado (ej: v1.2.1)
3. **Push automático** a GitHub
4. **GitHub Actions disparado** automáticamente
5. **Tests ejecutándose** con las correcciones

## 🔗 Monitoreo Post-Deploy

### Enlaces para monitorear:
- **Actions**: https://github.com/tu-usuario/ansible-docker/actions
- **Releases**: https://github.com/tu-usuario/ansible-docker/releases
- **Tags**: https://github.com/tu-usuario/ansible-docker/tags

### Tiempo estimado:
- ⏱️ **CI/CD completo**: 10-15 minutos
- 🎯 **Tests que deberían pasar**: Functional Tests, SSH Tests, Security Tests

## ❗ Solución de Problemas

### Si pre-commit-check.ps1 falla:
```powershell
# Verificar archivos específicos
Get-Content .github/workflows/ci-cd.yml | Select-String "fallback mode"
Get-Content test-functional-ci.ps1 | Select-String "CI=true"
```

### Si version-control.ps1 falla:
```powershell
# Verificar estado git
git status
git remote -v
git log --oneline -5
```

### Si GitHub Actions sigue fallando:
1. Verificar logs del workflow
2. Ejecutar `.\test-functional-ci.ps1` localmente
3. Comparar logs local vs CI

## 🎉 Éxito Esperado

Después de implementar las correcciones:

```
✅ Build Tests: Passed
✅ Functional Tests: Passed (SIN TIMEOUT)
✅ SSH Tests: Passed  
✅ Security Tests: Passed
✅ Integration Tests: Passed
🎉 Overall Result: SUCCESS
```

---

**Fecha**: Junio 27, 2025  
**Cambios**: Corrección crítica CI/CD Fallback Mode  
**Estado**: Listo para deploy 🚀
