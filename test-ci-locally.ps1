# ===================================
# Local CI/CD Test Script
# Tests the same conditions as GitHub Actions
# ===================================

Write-Host "🚀 Testing Ansible Docker CI/CD functionality locally..." -ForegroundColor Green

# Clean up any existing test containers
Write-Host "🧹 Cleaning up existing test containers..." -ForegroundColor Yellow
docker ps -a --filter "name=test-functional" --format "{{.Names}}" | ForEach-Object {
    if ($_) {
        docker stop $_ 2>$null
        docker rm $_ 2>$null
    }
}

# Build the image
Write-Host "🔨 Building Docker image..." -ForegroundColor Yellow
Set-Location "centos9"
docker build -t centos9-ansible:test .
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Docker build failed" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Docker build successful" -ForegroundColor Green

# Start container with CI environment variables (same as GitHub Actions)
Write-Host "🚀 Starting container for functional tests..." -ForegroundColor Yellow
docker run -d --name test-functional `
    -p 2299:22 `
    -e CI=true `
    -e GITHUB_ACTIONS=true `
    --privileged `
    --tmpfs /tmp `
    --tmpfs /run `
    --tmpfs /run/lock `
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro `
    centos9-ansible:test

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to start container" -ForegroundColor Red
    exit 1
}

# Wait for container to be ready
Write-Host "⏳ Waiting for container to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Check if container is running
$containerStatus = docker ps --filter "name=test-functional" --format "{{.Status}}"
if (-not $containerStatus -or $containerStatus -notmatch "Up") {
    Write-Host "❌ Container failed to start" -ForegroundColor Red
    Write-Host "📋 Container logs:" -ForegroundColor Yellow
    docker logs test-functional
    Write-Host "📋 Container status:" -ForegroundColor Yellow
    docker ps -a --filter "name=test-functional"
    exit 1
}

Write-Host "✅ Container started successfully" -ForegroundColor Green

# Wait for container initialization
Write-Host "⏳ Waiting for container initialization..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Test SSH service
Write-Host "🔐 Testing SSH service..." -ForegroundColor Yellow
$sshProcess = docker exec test-functional pgrep sshd
if (-not $sshProcess) {
    Write-Host "❌ SSH service is not running" -ForegroundColor Red
    docker logs test-functional
    exit 1
}
Write-Host "✅ SSH service is active" -ForegroundColor Green

# Test SSH port listening
$sshPort = docker exec test-functional netstat -tlnp | Select-String ":22 "
if (-not $sshPort) {
    Write-Host "❌ SSH port 22 is not listening" -ForegroundColor Red
    exit 1
}
Write-Host "✅ SSH port 22 is listening" -ForegroundColor Green

# Test ansible user
Write-Host "👤 Testing user configuration..." -ForegroundColor Yellow
docker exec test-functional id ansible 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ User ansible does not exist" -ForegroundColor Red
    exit 1
}
Write-Host "✅ User ansible exists" -ForegroundColor Green

# Test wheel group membership
$wheelGroup = docker exec test-functional groups ansible | Select-String "wheel"
if (-not $wheelGroup) {
    Write-Host "❌ User ansible is not in wheel group" -ForegroundColor Red
    exit 1
}
Write-Host "✅ User ansible is in wheel group" -ForegroundColor Green

# Test Python3
Write-Host "🐍 Testing Python and essential tools..." -ForegroundColor Yellow
$pythonVersion = docker exec test-functional python3 --version
if ($LASTEXITCODE -ne 0 -or $pythonVersion -notmatch "Python 3") {
    Write-Host "❌ Python3 is not available" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Python3 is available: $pythonVersion" -ForegroundColor Green

# Test essential tools
$tools = @("curl", "wget", "vim", "git", "htop")
foreach ($tool in $tools) {
    docker exec test-functional which $tool 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Tool $tool is not available" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Tool $tool is available" -ForegroundColor Green
}

Write-Host "🎉 All tests passed! Container is ready for CI/CD" -ForegroundColor Green

# Cleanup
Write-Host "🧹 Cleaning up..." -ForegroundColor Yellow
docker stop test-functional 2>$null
docker rm test-functional 2>$null

Write-Host "✅ Local CI/CD test completed successfully!" -ForegroundColor Green
