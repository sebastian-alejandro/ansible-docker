# Dockerfile para Nodo de Control de Ansible
# Base: Rocky Linux 9
FROM rockylinux:9

# Información del mantenedor
LABEL maintainer="Ansible Lab Environment"
LABEL description="Ansible Control Node con Rocky Linux 9"
LABEL version="1.0"

# Variables de entorno
ENV ANSIBLE_USER=ansible
ENV ANSIBLE_HOME=/home/ansible
ENV ANSIBLE_CONFIG=/home/ansible/.ansible.cfg
ENV PYTHONUNBUFFERED=1

# Instalar paquetes base y Python
RUN dnf update -y && \
    dnf install -y --allowerasing \
        python3 \
        python3-pip \
        openssh-clients \
        openssh-server \
        sudo \
        git \
        vim \
        curl \
        wget \
        rsync \
        sshpass \
        which \
        procps-ng \
        systemd \
        systemd-sysv && \
    dnf clean all

# Instalar Ansible usando pip
RUN pip3 install --upgrade pip && \
    pip3 install \
        ansible-core \
        ansible \
        paramiko \
        netaddr \
        jinja2 \
        pyyaml \
        requests

# Crear usuario ansible con privilegios sudo
RUN useradd -m -s /bin/bash $ANSIBLE_USER && \
    echo "$ANSIBLE_USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p $ANSIBLE_HOME/.ssh && \
    chown -R $ANSIBLE_USER:$ANSIBLE_USER $ANSIBLE_HOME/.ssh && \
    chmod 700 $ANSIBLE_HOME/.ssh

# Configurar SSH para el nodo de control
RUN ssh-keygen -A && \
    systemctl enable sshd

# Crear estructura de directorios para Ansible
RUN mkdir -p $ANSIBLE_HOME/{playbooks,inventory,roles,group_vars,host_vars,files,templates} && \
    chown -R $ANSIBLE_USER:$ANSIBLE_USER $ANSIBLE_HOME

# Copiar archivos de configuración
COPY config/ansible.cfg $ANSIBLE_CONFIG
COPY scripts/init-control-node.sh /usr/local/bin/
COPY scripts/generate-ssh-keys.sh /usr/local/bin/
COPY scripts/generate-inventory.sh /usr/local/bin/
COPY scripts/distribute-ssh-keys.sh /usr/local/bin/
COPY playbooks/ $ANSIBLE_HOME/playbooks/

# Hacer scripts ejecutables
RUN chmod +x /usr/local/bin/*.sh

# Cambiar permisos y propietario
RUN chown -R $ANSIBLE_USER:$ANSIBLE_USER $ANSIBLE_HOME

# Configurar systemd para que funcione en contenedor
RUN systemctl mask dev-hugepages.mount sys-fs-fuse-connections.mount

# Puerto SSH
EXPOSE 22

# Volúmenes para persistir datos
VOLUME ["$ANSIBLE_HOME/.ssh", "$ANSIBLE_HOME/playbooks", "$ANSIBLE_HOME/inventory"]

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD /usr/local/bin/health-check-control.sh

# Script de inicialización
COPY scripts/health-check-control.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/health-check-control.sh

# Comando por defecto
CMD ["/usr/local/bin/init-control-node.sh"]
