# Dockerfile para Nodo de Control de Ansible
# Base: CentOS Stream 9 (siguiendo el plan de desarrollo v1.3.0)
FROM quay.io/centos/centos:stream9

# Información del mantenedor
LABEL maintainer="Ansible Lab Environment"
LABEL description="Ansible Control Node con CentOS Stream 9"
LABEL version="1.3.0"

# Variables de entorno
ENV ANSIBLE_USER=ansible
ENV ANSIBLE_HOME=/home/ansible
ENV ANSIBLE_CONFIG=/ansible/ansible.cfg
ENV PYTHONUNBUFFERED=1
ENV ANSIBLE_HOST_KEY_CHECKING=False
ENV ANSIBLE_SSH_PIPELINING=True

# Instalar paquetes base y Python
RUN dnf update -y && \
    dnf install -y --allowerasing \
        python3 \
        python3-pip \
        openssh-clients \
        openssh-server \
        git \
        sudo \
        which \
        procps-ng \
        iputils \
        systemd \
        systemd-sysv \
        sshpass \
        curl \
        wget \
        vim \
        rsync && \
    dnf clean all

# Instalar Ansible Core (siguiendo las especificaciones del plan)
RUN pip3 install ansible-core

# Crear usuario ansible con privilegios sudo
RUN useradd -m -s /bin/bash $ANSIBLE_USER && \
    echo "$ANSIBLE_USER:ansible123" | chpasswd && \
    echo "$ANSIBLE_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ansible

# Configurar SSH
RUN mkdir -p $ANSIBLE_HOME/.ssh && \
    chown -R $ANSIBLE_USER:$ANSIBLE_USER $ANSIBLE_HOME/.ssh && \
    chmod 700 $ANSIBLE_HOME/.ssh

# Configurar SSH para el servidor
RUN ssh-keygen -A && \
    systemctl enable sshd

# Crear estructura de directorios para Ansible (siguiendo el plan v1.3.0)
RUN mkdir -p /ansible/{playbooks,roles,inventory,group_vars,host_vars} && \
    chown -R $ANSIBLE_USER:$ANSIBLE_USER /ansible

WORKDIR /ansible
USER $ANSIBLE_USER

# Instalar colecciones de Ansible
RUN ansible-galaxy collection install community.general ansible.posix

# Volver a root para configuración final
USER root

# Copiar archivos de configuración
COPY config/ansible.cfg /ansible/ansible.cfg
COPY scripts/init-control-node.sh /usr/local/bin/
COPY scripts/generate-ssh-keys.sh /usr/local/bin/
COPY scripts/generate-inventory.sh /usr/local/bin/
COPY scripts/distribute-ssh-keys.sh /usr/local/bin/
COPY scripts/health-check-control.sh /usr/local/bin/
COPY playbooks/ /ansible/playbooks/

# Hacer scripts ejecutables
RUN chmod +x /usr/local/bin/*.sh

# Cambiar permisos y propietario final
RUN chown -R $ANSIBLE_USER:$ANSIBLE_USER /ansible && \
    chown -R $ANSIBLE_USER:$ANSIBLE_USER $ANSIBLE_HOME

# Puerto SSH
EXPOSE 22

# Volúmenes para persistir datos (siguiendo especificaciones v1.3.0)
VOLUME ["/ansible", "$ANSIBLE_HOME/.ssh"]

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD ["ansible", "--version"]

# Script de inicialización por defecto
ENTRYPOINT ["/usr/local/bin/init-control-node.sh"]
