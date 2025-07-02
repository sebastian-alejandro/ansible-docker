#!/bin/bash
# Entrypoint para el nodo de control de Ansible

# Iniciar el servicio SSH en segundo plano
/usr/sbin/sshd -D &

# Mantener el contenedor en ejecucion
tail -f /dev/null
