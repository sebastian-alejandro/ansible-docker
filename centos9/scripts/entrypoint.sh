#!/bin/bash
# =====================================================
# Entrypoint Script for Ansible Docker Environment
# Compatible with both development and CI/CD environments
# =====================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Starting Ansible Docker Environment...${NC}"

# Check if we're running in CI environment
if [ "${CI}" = "true" ] || [ "${GITHUB_ACTIONS}" = "true" ]; then
    echo -e "${YELLOW}📋 Detected CI environment - starting in CI mode${NC}"
    CI_MODE=true
else
    echo -e "${YELLOW}📋 Running in development mode${NC}"
    CI_MODE=false
fi

# Function to wait for systemd
wait_for_systemd() {
    echo -e "${YELLOW}⏳ Waiting for systemd to be ready...${NC}"
    local timeout=30  # Reduced timeout for CI
    local count=0
    
    while [ $count -lt $timeout ]; do
        local status=$(systemctl is-system-running 2>/dev/null || echo "offline")
        if echo "$status" | grep -E "(running|degraded)" > /dev/null; then
            echo -e "${GREEN}✅ Systemd is ready${NC}"
            return 0
        fi
        echo "Systemd status: $status"
        sleep 2
        count=$((count + 2))
    done
    
    echo -e "${YELLOW}⚠️ Systemd failed to start within ${timeout} seconds${NC}"
    return 1
}

# Function to start services without systemd (fallback mode)
start_services_fallback() {
    echo -e "${YELLOW}🔧 Starting services in fallback mode (no systemd)...${NC}"
    
    # Generate SSH host keys if they don't exist
    if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
        echo "Generating SSH host keys..."
        ssh-keygen -A
    fi
    
    # Start SSH daemon
    echo "Starting SSH daemon..."
    /usr/sbin/sshd
    
    if pgrep sshd > /dev/null; then
        echo -e "${GREEN}✅ SSH daemon started${NC}"
    else
        echo -e "${RED}❌ Failed to start SSH daemon${NC}"
        return 1
    fi
    
    # Start cron if available
    if command -v crond > /dev/null; then
        echo "Starting cron daemon..."
        crond
        if pgrep crond > /dev/null; then
            echo -e "${GREEN}✅ Cron daemon started${NC}"
        else
            echo -e "${YELLOW}⚠️ Cron daemon failed to start (non-critical)${NC}"
        fi
    fi
}

# Function to start essential services
start_services() {
    echo -e "${YELLOW}🔧 Starting essential services...${NC}"
    
    # Start SSH service
    if ! systemctl is-active --quiet sshd; then
        echo "Starting SSH service..."
        systemctl start sshd
        if systemctl is-active --quiet sshd; then
            echo -e "${GREEN}✅ SSH service started${NC}"
        else
            echo -e "${RED}❌ Failed to start SSH service${NC}"
            return 1
        fi
    else
        echo -e "${GREEN}✅ SSH service already running${NC}"
    fi
    
    # Start cron service
    if ! systemctl is-active --quiet crond; then
        echo "Starting cron service..."
        systemctl start crond
        if systemctl is-active --quiet crond; then
            echo -e "${GREEN}✅ Cron service started${NC}"
        else
            echo -e "${YELLOW}⚠️ Cron service failed to start (non-critical)${NC}"
        fi
    else
        echo -e "${GREEN}✅ Cron service already running${NC}"
    fi
    
    # Start ansible-init service
    if systemctl list-unit-files ansible-init.service > /dev/null 2>&1; then
        if ! systemctl is-active --quiet ansible-init; then
            echo "Starting ansible-init service..."
            systemctl start ansible-init
            if systemctl is-active --quiet ansible-init; then
                echo -e "${GREEN}✅ Ansible-init service started${NC}"
            else
                echo -e "${YELLOW}⚠️ Ansible-init service failed to start (non-critical)${NC}"
            fi
        else
            echo -e "${GREEN}✅ Ansible-init service already running${NC}"
        fi
    fi
}

# Function to validate environment
validate_environment() {
    echo -e "${YELLOW}🔍 Validating environment...${NC}"
    
    # Check ansible user
    if id ansible > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Ansible user exists${NC}"
    else
        echo -e "${RED}❌ Ansible user not found${NC}"
        return 1
    fi
    
    # Check SSH keys
    if [ -f /etc/ssh/ssh_host_rsa_key ]; then
        echo -e "${GREEN}✅ SSH host keys exist${NC}"
    else
        echo -e "${RED}❌ SSH host keys not found${NC}"
        return 1
    fi
    
    # Check locale
    if locale -a | grep -q en_US.utf8; then
        echo -e "${GREEN}✅ Locale configured correctly${NC}"
    else
        echo -e "${YELLOW}⚠️ Locale may not be configured correctly${NC}"
    fi
}

# Main execution
main() {
    # If running in CI mode with arguments, handle them
    if [ $CI_MODE = true ] && [ $# -gt 0 ]; then
        echo -e "${YELLOW}📋 CI mode: executing command directly${NC}"
        exec "$@"
    fi
    
    # Check if systemd is available and working
    if [ ! -d /run/systemd/system ] || [ ! -f /sbin/init ] || [ $CI_MODE = true ]; then
        echo -e "${YELLOW}🔧 Using fallback mode (no systemd or CI environment)${NC}"
        
        # Start services in fallback mode
        if ! start_services_fallback; then
            echo -e "${RED}❌ Failed to start services in fallback mode${NC}"
            exit 1
        fi
        
        # Validate environment
        validate_environment
        
        echo -e "${GREEN}🎉 Ansible Docker Environment is ready (fallback mode)!${NC}"
        echo -e "${YELLOW}📋 Container Info:${NC}"
        echo "  - SSH Port: 22"
        echo "  - Ansible User: ansible"
        echo "  - Ansible Password: ansible123"
        echo "  - Root Password: rootpass123"
        
        # Keep container running
        echo "Keeping container running in fallback mode..."
        while true; do
            if ! pgrep sshd > /dev/null; then
                echo -e "${RED}❌ SSH daemon died, restarting...${NC}"
                /usr/sbin/sshd
            fi
            sleep 30
        done
        return
    fi
    
    # If we have arguments and we're not in CI, it might be a command to execute
    if [ $# -gt 0 ] && [ "$1" != "/sbin/init" ]; then
        echo -e "${YELLOW}📋 Executing command: $@${NC}"
        exec "$@"
    fi
    
    # Initialize systemd in background
    /sbin/init &
    INIT_PID=$!
    
    # Wait a bit for systemd to start
    sleep 3
    
    # Wait for systemd to be ready (with shorter timeout)
    if ! wait_for_systemd; then
        echo -e "${YELLOW}⚠️ Systemd initialization failed, falling back to direct service mode${NC}"
        kill $INIT_PID 2>/dev/null || true
        
        # Start services in fallback mode
        if ! start_services_fallback; then
            echo -e "${RED}❌ Failed to start services in fallback mode${NC}"
            exit 1
        fi
        
        # Validate environment
        validate_environment
        
        echo -e "${GREEN}🎉 Ansible Docker Environment is ready (fallback mode)!${NC}"
        echo -e "${YELLOW}📋 Container Info:${NC}"
        echo "  - SSH Port: 22"
        echo "  - Ansible User: ansible"
        echo "  - Ansible Password: ansible123"
        echo "  - Root Password: rootpass123"
        
        # Keep container running
        echo "Keeping container running in fallback mode..."
        while true; do
            if ! pgrep sshd > /dev/null; then
                echo -e "${RED}❌ SSH daemon died, restarting...${NC}"
                /usr/sbin/sshd
            fi
            sleep 30
        done
        return
    fi
    
    # Start essential services
    if ! start_services; then
        echo -e "${RED}❌ Failed to start essential services${NC}"
        exit 1
    fi
    
    # Validate environment
    validate_environment
    
    echo -e "${GREEN}🎉 Ansible Docker Environment is ready!${NC}"
    echo -e "${YELLOW}📋 Container Info:${NC}"
    echo "  - SSH Port: 22"
    echo "  - Ansible User: ansible"
    echo "  - Ansible Password: ansible123"
    echo "  - Root Password: rootpass123"
    
    # Keep container running and handle signals properly
    trap "echo 'Shutting down...'; kill $INIT_PID" TERM INT
    wait $INIT_PID
}

# Execute main function with all arguments
main "$@"
