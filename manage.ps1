# ===================================
# Script de Gestión - Ambiente Ansible Docker
# Sprint 1: CentOS 9 Base Setup
# ===================================

# Función para mostrar ayuda
function Show-Help {
    Write-Host @"
=== Gestión del Ambiente Ansible Docker ===

Comandos disponibles:
  build     - Construir las imágenes Docker
  start     - Iniciar los containers
  stop      - Detener los containers
  restart   - Reiniciar los containers
  status    - Mostrar estado de los containers
  logs      - Mostrar logs de los containers
  shell     - Conectarse a un container específico
  clean     - Limpiar containers e imágenes
  test      - Ejecutar tests de conectividad
  scale     - Escalar el número de nodos

Ejemplos:
  .\manage.ps1 build
  .\manage.ps1 start
  .\manage.ps1 shell centos9-node1
  .\manage.ps1 logs centos9-node1
  .\manage.ps1 scale 3

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

# Función para tests
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
    # Esta funcionalidad se implementará en Sprint 3
    Write-Host "⚠️  Funcionalidad de escalado se implementará en Sprint 3" -ForegroundColor Yellow
}

# Lógica principal
param(
    [Parameter(Mandatory=$true)]
    [string]$Action,
    [string]$Container,
    [int]$Count
)

switch ($Action.ToLower()) {
    "help" { Show-Help }
    "build" { Build-Images }
    "start" { Start-Containers }
    "stop" { Stop-Containers }
    "restart" { Restart-Containers }
    "status" { Show-Status }
    "logs" { Show-Logs -Container $Container }
    "shell" { Connect-Shell -Container $Container }
    "clean" { Clean-Environment }
    "test" { Test-Connectivity }
    "scale" { Scale-Nodes -Count $Count }
    default { 
        Write-Host "❌ Acción no reconocida: $Action" -ForegroundColor Red
        Show-Help 
    }
}
