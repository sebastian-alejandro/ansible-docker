# ===================================
# Script de Gestión - Ambiente Ansible Docker
# Sprint 1: CentOS 9 Base Setup con Tests Automatizados
# ===================================

# Función para mostrar ayuda actualizada
function Show-Help {
    Write-Host @"
🐳 === Gestión del Ambiente Ansible Docker ===

COMANDOS BÁSICOS:
  build              - Construir las imágenes Docker
  start              - Iniciar los containers
  stop               - Detener los containers
  restart            - Reiniciar los containers
  status             - Mostrar estado de los containers
  logs [container]   - Mostrar logs de container específico
  shell [container]  - Conectarse a un container específico
  clean              - Limpiar containers e imágenes

TESTING LOCAL:
  test               - Ejecutar tests de conectividad básicos
  test-build         - Validar construcción de imagen
  test-security      - Tests básicos de seguridad
  test-full          - Suite completa de tests locales

TESTING REMOTO (GitHub Actions):
  test-remote [type] - Ejecutar tests remotos (all|build|security|integration)
  test-remote-build  - Tests de build en GitHub Actions
  test-remote-security [level] - Tests de seguridad remotos
  test-remote-integration [duration] [count] - Tests de integración remotos
  workflow-status    - Ver estado de workflows de GitHub
  setup-github       - Configurar GitHub CLI

UTILIDADES:
  scale [count]      - Escalar número de nodos (Sprint 3)
  help               - Mostrar esta ayuda

EJEMPLOS:
  .\manage.ps1 build
  .\manage.ps1 start
  .\manage.ps1 test-full
  .\manage.ps1 test-remote all
  .\manage.ps1 test-remote-security standard
  .\manage.ps1 shell centos9-node1
  .\manage.ps1 workflow-status

"@ -ForegroundColor Green
}

# Función para construir imágenes
function Build-Images {
    Write-Host "🔨 Construyendo imágenes Docker..." -ForegroundColor Blue
    docker-compose build --no-cache
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Imágenes construidas exitosamente" -ForegroundColor Green
    } else {
        Write-Host "❌ Error al construir imágenes" -ForegroundColor Red
        exit 1
    }
}

# Función para iniciar containers
function Start-Containers {
    Write-Host "🚀 Iniciando containers..." -ForegroundColor Blue
    docker-compose up -d
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Containers iniciados exitosamente" -ForegroundColor Green
        Show-Status
    } else {
        Write-Host "❌ Error al iniciar containers" -ForegroundColor Red
        exit 1
    }
}

# Función para detener containers
function Stop-Containers {
    Write-Host "🛑 Deteniendo containers..." -ForegroundColor Yellow
    docker-compose down
    Write-Host "✅ Containers detenidos" -ForegroundColor Green
}

# Función para reiniciar containers
function Restart-Containers {
    Write-Host "🔄 Reiniciando containers..." -ForegroundColor Blue
    docker-compose restart
    Write-Host "✅ Containers reiniciados" -ForegroundColor Green
    Show-Status
}

# Función para mostrar estado
function Show-Status {
    Write-Host "📊 Estado de los containers:" -ForegroundColor Blue
    docker-compose ps
    Write-Host "`n🌐 Información de red:" -ForegroundColor Blue
    docker network ls | Select-String "ansible"
    Write-Host "`n💾 Volúmenes:" -ForegroundColor Blue
    docker volume ls | Select-String "ansible"
}

# Función para mostrar logs
function Show-Logs {
    param($Container)
    if ($Container) {
        Write-Host "📝 Logs del container: $Container" -ForegroundColor Blue
        docker-compose logs -f $Container
    } else {
        Write-Host "📝 Logs de todos los containers:" -ForegroundColor Blue
        docker-compose logs -f
    }
}

# Función para conectarse a un container
function Connect-Shell {
    param($Container)
    if (-not $Container) {
        Write-Host "❌ Especifica el nombre del container" -ForegroundColor Red
        Write-Host "Containers disponibles:" -ForegroundColor Yellow
        docker-compose ps --format "table {{.Service}}"
        return
    }
    
    Write-Host "🖥️  Conectando a $Container..." -ForegroundColor Blue
    docker-compose exec $Container /bin/bash
}

# Función para limpiar
function Clean-Environment {
    Write-Host "🧹 Limpiando ambiente..." -ForegroundColor Yellow
    Write-Host "Deteniendo containers..." -ForegroundColor Yellow
    docker-compose down -v --remove-orphans
    Write-Host "Eliminando imágenes..." -ForegroundColor Yellow
    docker image prune -f
    Write-Host "✅ Limpieza completada" -ForegroundColor Green
}

# Función para tests básicos de conectividad
function Test-Connectivity {
    Write-Host "🔍 Ejecutando tests de conectividad..." -ForegroundColor Blue
    
    $containers = @("centos9-node1", "centos9-node2")
    
    foreach ($container in $containers) {
        Write-Host "Testing $container..." -ForegroundColor Yellow
        
        # Test SSH connectivity
        Write-Host "  - SSH connectivity..." -ForegroundColor Cyan
        $sshTest = docker-compose exec -T $container ss -tuln | Select-String ":22"
        if ($sshTest) {
            Write-Host "    ✅ SSH is listening" -ForegroundColor Green
        } else {
            Write-Host "    ❌ SSH is not listening" -ForegroundColor Red
        }
        
        # Test user ansible
        Write-Host "  - User ansible..." -ForegroundColor Cyan
        $userTest = docker-compose exec -T $container id ansible 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    ✅ User ansible exists" -ForegroundColor Green
        } else {
            Write-Host "    ❌ User ansible not found" -ForegroundColor Red
        }
        
        # Test Python
        Write-Host "  - Python availability..." -ForegroundColor Cyan
        $pythonTest = docker-compose exec -T $container python3 --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    ✅ Python3 is available" -ForegroundColor Green
        } else {
            Write-Host "    ❌ Python3 not found" -ForegroundColor Red
        }
        
        Write-Host ""
    }
}

# Función para escalar
function Scale-Nodes {
    param($Count)
    if (-not $Count -or $Count -lt 1) {
        Write-Host "❌ Especifica el número de nodos (mínimo 1)" -ForegroundColor Red
        return
    }
    
    Write-Host "📈 Escalando a $Count nodos..." -ForegroundColor Blue
    Write-Host "⚠️  Funcionalidad de escalado se implementará en Sprint 3" -ForegroundColor Yellow
}

# Función para tests completos del ambiente
function Test-Environment {
    Write-Host "🧪 Ejecutando suite completa de tests..." -ForegroundColor Blue
    
    # Ejecutar tests básicos localmente
    Test-Connectivity
    Test-BuildValidation
    Test-SecurityBasics
}

# Función para tests específicos de build
function Test-BuildValidation {
    Write-Host "🔨 Ejecutando validación de build..." -ForegroundColor Blue
    
    try {
        # Verificar que la imagen existe
        $imageExists = docker images --format "table {{.Repository}}:{{.Tag}}" | Select-String "centos9"
        if (-not $imageExists) {
            Write-Host "❌ Imagen no encontrada, ejecutando build..." -ForegroundColor Red
            Build-Images
        }
        
        Write-Host "✅ Validación de build completada" -ForegroundColor Green
        
    } catch {
        Write-Host "❌ Error en validación de build: $_" -ForegroundColor Red
    }
}

# Función para tests básicos de seguridad
function Test-SecurityBasics {
    Write-Host "🔒 Ejecutando tests básicos de seguridad..." -ForegroundColor Blue
    
    try {
        # Verificar que los containers estén ejecutándose
        $runningContainers = docker-compose ps --filter "status=running" --services
        if (-not $runningContainers) {
            Write-Host "⚠️ No hay containers ejecutándose, iniciando..." -ForegroundColor Yellow
            Start-Containers
            Start-Sleep 15
        }
        
        # Test usuario ansible en cada container
        $containers = @("centos9-node1", "centos9-node2")
        foreach ($container in $containers) {
            Write-Host "  Testing security on $container..." -ForegroundColor Cyan
            
            $userTest = docker-compose exec -T $container id ansible 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "    ✅ Usuario ansible existe" -ForegroundColor Green
            } else {
                Write-Host "    ❌ Usuario ansible no encontrado" -ForegroundColor Red
            }
            
            # Test permisos directorio SSH
            $sshTest = docker-compose exec -T $container test -d /home/ansible/.ssh 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "    ✅ Directorio SSH existe" -ForegroundColor Green
            } else {
                Write-Host "    ❌ Directorio SSH no encontrado" -ForegroundColor Red
            }
        }
        
        Write-Host "✅ Tests básicos de seguridad completados" -ForegroundColor Green
        
    } catch {
        Write-Host "❌ Error en tests de seguridad: $_" -ForegroundColor Red
    }
}

# Función para ejecutar workflows de GitHub remotamente
function Invoke-GitHubWorkflow {
    param(
        [string]$WorkflowName,
        [hashtable]$Inputs = @{}
    )
    
    Write-Host "🚀 Ejecutando workflow de GitHub: $WorkflowName" -ForegroundColor Blue
    
    # Verificar si gh CLI está instalado
    try {
        $ghVersion = gh --version 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ GitHub CLI (gh) no está instalado" -ForegroundColor Red
            Write-Host "📥 Instala GitHub CLI desde: https://cli.github.com/" -ForegroundColor Yellow
            return
        }
    } catch {
        Write-Host "❌ GitHub CLI no encontrado" -ForegroundColor Red
        return
    }
    
    # Construir comando
    $command = "gh workflow run `"$WorkflowName`""
    
    if ($Inputs.Count -gt 0) {
        foreach ($input in $Inputs.GetEnumerator()) {
            $command += " -f $($input.Key)=$($input.Value)"
        }
    }
    
    Write-Host "📝 Comando: $command" -ForegroundColor Gray
    
    try {
        Invoke-Expression $command
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Workflow iniciado exitosamente" -ForegroundColor Green
            Write-Host "🔍 Ver progreso en: https://github.com/sebastian-alejandro/ansible-docker/actions" -ForegroundColor Cyan
        } else {
            Write-Host "❌ Error al iniciar workflow" -ForegroundColor Red
        }
    } catch {
        Write-Host "❌ Error ejecutando workflow: $_" -ForegroundColor Red
    }
}

# Función para tests remotos completos
function Test-Remote {
    param([string]$TestType = "all")
    
    Write-Host "☁️ Ejecutando tests remotos en GitHub Actions..." -ForegroundColor Blue
    
    $inputs = @{
        "test_type" = $TestType
    }
    
    Invoke-GitHubWorkflow -WorkflowName "Complete Test Suite" -Inputs $inputs
}

# Función para tests de build remotos
function Test-RemoteBuild {
    Write-Host "🔨 Ejecutando tests de build remotos..." -ForegroundColor Blue
    
    Invoke-GitHubWorkflow -WorkflowName "Build Tests Only"
}

# Función para tests de seguridad remotos
function Test-RemoteSecurity {
    param([string]$Level = "standard")
    
    Write-Host "🔒 Ejecutando tests de seguridad remotos..." -ForegroundColor Blue
    
    $inputs = @{
        "security_level" = $Level
    }
    
    Invoke-GitHubWorkflow -WorkflowName "Security Tests Only" -Inputs $inputs
}

# Función para tests de integración remotos
function Test-RemoteIntegration {
    param(
        [string]$Duration = "5",
        [string]$ContainerCount = "2"
    )
    
    Write-Host "🔗 Ejecutando tests de integración remotos..." -ForegroundColor Blue
    
    $inputs = @{
        "test_duration" = $Duration
        "container_count" = $ContainerCount
    }
    
    Invoke-GitHubWorkflow -WorkflowName "Integration Tests Only" -Inputs $inputs
}

# Función para mostrar estado de workflows
function Show-WorkflowStatus {
    Write-Host "📊 Estado de workflows en GitHub..." -ForegroundColor Blue
    
    try {
        $workflows = gh run list --limit 10 --json conclusion,status,workflowName,createdAt,url | ConvertFrom-Json
        
        foreach ($workflow in $workflows) {
            $status = switch ($workflow.conclusion) {
                "success" { "✅" }
                "failure" { "❌" }
                default { 
                    if ($workflow.status -eq "in_progress") { "🔄" } 
                    else { "⏸️" } 
                }
            }
            $date = ([DateTime]$workflow.createdAt).ToString("yyyy-MM-dd HH:mm")
            Write-Host "$status $($workflow.workflowName) - $date" -ForegroundColor Gray
        }
        
        Write-Host "`n🔗 Ver todos los workflows: https://github.com/sebastian-alejandro/ansible-docker/actions" -ForegroundColor Cyan
        
    } catch {
        Write-Host "❌ Error obteniendo estado de workflows: $_" -ForegroundColor Red
        Write-Host "💡 Asegúrate de estar autenticado con 'gh auth login'" -ForegroundColor Yellow
    }
}

# Función para setup de GitHub CLI
function Setup-GitHubCLI {
    Write-Host "🔧 Configurando GitHub CLI..." -ForegroundColor Blue
    
    # Verificar instalación
    try {
        $ghVersion = gh --version
        Write-Host "✅ GitHub CLI instalado: $ghVersion" -ForegroundColor Green
    } catch {
        Write-Host "❌ GitHub CLI no encontrado" -ForegroundColor Red
        Write-Host "📥 Descarga e instala desde: https://cli.github.com/" -ForegroundColor Yellow
        return
    }
    
    # Verificar autenticación
    try {
        $authStatus = gh auth status 2>&1
        if ($authStatus -like "*Logged in*") {
            Write-Host "✅ Autenticado en GitHub" -ForegroundColor Green
        } else {
            Write-Host "🔐 Iniciando proceso de autenticación..." -ForegroundColor Yellow
            gh auth login
        }
    } catch {
        Write-Host "🔐 Configurando autenticación..." -ForegroundColor Yellow
        gh auth login
    }
    
    Write-Host "✅ GitHub CLI configurado correctamente" -ForegroundColor Green
}

# Lógica principal
param(
    [Parameter(Mandatory=$true)]
    [string]$Action,
    [string]$Container,
    [string]$Target,
    [int]$Count,
    [string]$Level,
    [string]$Duration
)

# Valores por defecto
if (-not $Target) { $Target = "all" }
if (-not $Level) { $Level = "standard" }
if (-not $Duration) { $Duration = "5" }

switch ($Action.ToLower()) {
    # Comandos básicos
    "help" { Show-Help }
    "build" { Build-Images }
    "start" { Start-Containers }
    "stop" { Stop-Containers }
    "restart" { Restart-Containers }
    "status" { Show-Status }
    "logs" { Show-Logs -Container $Container }
    "shell" { Connect-Shell -Container $Container }
    "clean" { Clean-Environment }
    "scale" { Scale-Nodes -Count $Count }
    
    # Testing local
    "test" { Test-Connectivity }
    "test-build" { Test-BuildValidation }
    "test-security" { Test-SecurityBasics }
    "test-full" { Test-Environment }
    
    # Testing remoto
    "test-remote" { Test-Remote -TestType $Target }
    "test-remote-build" { Test-RemoteBuild }
    "test-remote-security" { Test-RemoteSecurity -Level $Level }
    "test-remote-integration" { Test-RemoteIntegration -Duration $Duration -ContainerCount $Count }
    
    # GitHub workflows
    "workflow-status" { Show-WorkflowStatus }
    "setup-github" { Setup-GitHubCLI }
    
    default { 
        Write-Host "❌ Acción no reconocida: $Action" -ForegroundColor Red
        Write-Host "💡 Usa '.\manage.ps1 help' para ver comandos disponibles" -ForegroundColor Yellow
        Show-Help 
    }
}
