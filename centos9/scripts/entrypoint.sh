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
    local status
    
    while [ $count -lt $timeout ]; do
        status=$(systemctl is-system-running 2>/dev/null || echo "offline")
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
        if systemctl is_active --quiet crond; then
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

# Function to configure CI environment
configure_ci_environment() {
    echo -e "${YELLOW}🔧 Configuring CI environment...${NC}"
    
    # Fix PAM issues in CI environment
    if [ "${CI_MODE}" = "true" ]; then
        echo "Configuring PAM for CI environment..."
        
        # Create a minimal PAM configuration for sudo that bypasses problematic modules
        cat > /etc/pam.d/sudo-ci << 'EOF'
#%PAM-1.0
auth       sufficient   pam_permit.so
account    sufficient   pam_permit.so
session    optional     pam_keyinit.so revoke
session    optional     pam_limits.so
session    [success=1 default=ignore] pam_succeed_if.so service in crond quiet use_uid
session    required     pam_unix.so
EOF
        
        # Backup original sudo PAM config and use CI version
        if [ -f /etc/pam.d/sudo ]; then
            cp /etc/pam.d/sudo /etc/pam.d/sudo.backup
            cp /etc/pam.d/sudo-ci /etc/pam.d/sudo
            echo -e "${GREEN}✅ PAM configuration updated for CI${NC}"
        fi
        
        # Also configure su for CI
        cat > /etc/pam.d/su-ci << 'EOF'
#%PAM-1.0
auth       sufficient   pam_permit.so
account    sufficient   pam_permit.so
session    optional     pam_keyinit.so revoke
session    required     pam_unix.so
EOF
        
        if [ -f /etc/pam.d/su ]; then
            cp /etc/pam.d/su /etc/pam.d/su.backup
            cp /etc/pam.d/su-ci /etc/pam.d/su
            echo -e "${GREEN}✅ SU PAM configuration updated for CI${NC}"
        fi
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
        
        # Configure CI environment if needed
        configure_ci_environment
        
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
        
        # Configure CI environment if needed
        configure_ci_environment
        
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
    
    # Configure SSH key for ansible user
    if [ -n "$ANSIBLE_USER" ] && [ -n "$ANSIBLE_SSH_KEY" ]; then
        echo "Configuring SSH key for user $ANSIBLE_USER..."
        local ansible_user_home
        ansible_user_home=$(getent passwd "$ANSIBLE_USER" | cut -d: -f6)

        if [ ! -d "$ansible_user_home/.ssh" ]; then
            mkdir -p "$ansible_user_home/.ssh"
            chown "$ANSIBLE_USER:$ANSIBLE_USER" "$ansible_user_home/.ssh"
            chmod 700 "$ansible_user_home/.ssh"
        fi

        if [ ! -f "$ansible_user_home/.ssh/authorized_keys" ]; then
            touch "$ansible_user_home/.ssh/authorized_keys"
            chown "$ANSIBLE_USER:$ANSIBLE_USER" "$ansible_user_home/.ssh/authorized_keys"
            chmod 600 "$ansible_user_home/.ssh/authorized_keys"
        fi

        # Add key if it doesn't exist
        if ! grep -q "$ANSIBLE_SSH_KEY" "$ansible_user_home/.ssh/authorized_keys"; then
            echo "$ANSIBLE_SSH_KEY" >> "$ansible_user_home/.ssh/authorized_keys"
            echo "SSH key added."
        else
            echo "SSH key already exists."
        fi
    fi
    
    # Initial health check
    run_health_check() {
        echo -e "${YELLOW}🩺 Running initial health check...${NC}"
        local status
        health_check
        status=$?
        if [ $status -eq 0 ]; then
            echo -e "${GREEN}✅ Health check passed${NC}"
        else
            echo -e "${RED}❌ Health check failed with status ${status}${NC}"
        fi
    }

    # Cleanup function
    cleanup() {
        echo "Cleaning up..."
        # Add any cleanup tasks here
    }

    # Trap signals for graceful shutdown
    trap 'echo "Caught SIGTERM. Shutting down."; cleanup; exit 0' SIGTERM
    trap 'echo "Caught SIGINT. Shutting down."; cleanup; exit 0' SIGINT

    # ===================
    # Main Execution
    # ===================

    # Run init script if it exists
    run_init_script() {
        local init_script_path="/usr/local/bin/init.sh"
        echo "Looking for init script at ${init_script_path}..."
        if [ -x "$init_script_path" ]; then
            echo "Found and executing init script..."
            "$init_script_path"
        else
            echo "Init script not found or not executable."
        fi
    }

    # Start services based on mode
    if [ "$CI_MODE" = "true" ]; then
        echo "Starting services in CI mode..."
        # In CI mode, we might not need all services
        # For example, we may skip SSH and just run the playbook directly
        if ! systemctl is-active --quiet crond; then
            echo "Starting cron service..."
            systemctl start crond
            if systemctl is_active --quiet crond; then
                echo -e "${GREEN}✅ Cron service started${NC}"
            else
                echo -e "${YELLOW}⚠️ Cron service failed to start (non-critical)${NC}"
            fi
        else
            echo -e "${GREEN}✅ Cron service already running${NC}"
        fi
    else
        echo "Starting services in normal mode..."
        # In normal mode, start all essential services
        if ! start_services; then
            echo -e "${RED}❌ Failed to start essential services${NC}"
            exit 1
        fi
    fi
    
    # Validate environment
    validate_environment
    
    echo -e "${GREEN}🎉 Ansible Docker Environment is ready!${NC}"
    echo -e "${YELLOW}📋 Container Info:${NC}"
    echo "  - SSH Port: 22"
    echo "  - Ansible User: ansible"
    echo "  - Ansible Password: ansible123"
    echo "  - Root Password: rootpass123"
    
    # Stop SSHD if running in foreground
    stop_foreground_sshd() {
        local pid
        pid=$(pgrep -f "/usr/sbin/sshd -D")
        if [ -n "$pid" ]; then
            echo "Stopping foreground SSHD (PID: $pid)..."
            kill "$pid"
            wait "$pid" 2>/dev/null
        fi
    }

    # Final cleanup actions
    cleanup() {
        echo "Performing final cleanup..."
        # Add any final cleanup tasks here
    }
}

# Execute main function with all arguments
main "$@"
