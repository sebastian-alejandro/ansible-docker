#!/usr/bin/env python3
# Script de inventario dinámico para Ansible v1.3.0
# Siguiendo las especificaciones del plan de desarrollo

import json
import socket

def check_host_connectivity(hostname, port=22):
    """Check if host is reachable on SSH port"""
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(5)
        result = sock.connect_ex((hostname, port))
        sock.close()
        return result == 0
    except:
        return False

def get_managed_nodes():
    """Get list of managed nodes from Docker network"""
    nodes = []
    managed_hosts = ["centos9-node-1", "centos9-node-2"]
    
    for host in managed_hosts:
        if check_host_connectivity(host):
            nodes.append(host)
    
    return nodes

def generate_inventory():
    """Generate Ansible inventory"""
    managed_nodes = get_managed_nodes()
    
    inventory = {
        "managed_nodes": {
            "hosts": managed_nodes,
            "vars": {
                "ansible_user": "ansible",
                "ansible_ssh_private_key_file": "/home/ansible/.ssh/id_rsa",
                "ansible_ssh_common_args": "-o StrictHostKeyChecking=no"
            }
        },
        "_meta": {
            "hostvars": {}
        }
    }
    
    # Add host-specific variables
    for i, node in enumerate(managed_nodes, 1):
        inventory["_meta"]["hostvars"][node] = {
            "node_id": i,
            "ssh_port": 22,
            "environment": "lab"
        }
    
    return inventory

if __name__ == "__main__":
    print(json.dumps(generate_inventory(), indent=2))
