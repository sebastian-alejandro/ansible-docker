# ===================================
# CentOS 9 Stream - Ansible Managed Node
# ===================================
# Dockerfile para crear un container CentOS 9 optimizado para ser gestionado por Ansible
# Incluye SSH server, herramientas de administración y configuración base

FROM quay.io/centos/centos:stream9

# Metadata del container
LABEL maintainer="DevOps Team"
LABEL description="CentOS 9 Stream container optimized for Ansible management"
LABEL version="1.0"

# Instalar Dockerfile healthcheck y setear shell con pipefail
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Variables de entorno
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV ANSIBLE_USER=ansible
ENV ANSIBLE_USER_HOME=/home/ansible

# Actualizar sistema e instalar paquetes esenciales con versiones específicas
RUN dnf -y update && \
    dnf -y install epel-release && \
    dnf -y install --allowerasing \
        openssh-server \
        openssh-clients \
        sudo \
        python3 \
        python3-pip \
        curl \
        wget \
        vim \
        nano \
        htop \
        net-tools \
        bind-utils \
        tar \
        gzip \
        unzip \
        rsync \
        git \
        which \
        passwd \
        cronie \
        systemd \
        iproute && \
    dnf clean all

# Configurar SSH
RUN ssh-keygen -A && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#Port 22/Port 22/' /etc/ssh/sshd_config

# Crear usuario para Ansible
RUN useradd -m -s /bin/bash $ANSIBLE_USER && \
    echo "$ANSIBLE_USER:ansible123" | chpasswd && \
    usermod -aG wheel $ANSIBLE_USER && \
    mkdir -p $ANSIBLE_USER_HOME/.ssh && \
    chmod 700 $ANSIBLE_USER_HOME/.ssh && \
    chown $ANSIBLE_USER:$ANSIBLE_USER $ANSIBLE_USER_HOME/.ssh

# Configurar sudo sin password para el usuario ansible
RUN echo "$ANSIBLE_USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/ansible && \
    chmod 440 /etc/sudoers.d/ansible

# Configurar root password
RUN echo "root:rootpass123" | chpasswd

# Crear directorios necesarios
RUN mkdir -p /var/run/sshd /var/log/ansible

# Copiar scripts de inicialización
COPY scripts/init.sh /usr/local/bin/init.sh
COPY scripts/health-check.sh /usr/local/bin/health-check.sh

# Hacer ejecutables los scripts
RUN chmod +x /usr/local/bin/init.sh /usr/local/bin/health-check.sh

# Exponer puerto SSH
EXPOSE 22

# Configurar systemd (necesario para algunos playbooks de Ansible)
RUN systemctl enable sshd && \
    systemctl enable crond

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD /usr/local/bin/health-check.sh

# Punto de entrada
ENTRYPOINT ["/usr/local/bin/init.sh"]
CMD ["/usr/sbin/sshd", "-D"]
