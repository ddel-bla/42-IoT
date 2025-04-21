#!/bin/bash
#
# Script de instalación y configuración del nodo Master para K3s
# Inception-of-Things - Parte 1
#

# Cargar las funciones comunes
source /vagrant/scripts/common_setup.sh

echo "=== Iniciando configuración del nodo Master ==="

# Ejecutar configuración base del sistema
setup_base_system

# Configurar archivo hosts para p1
setup_hosts "p1-master"

# Instalar K3s en modo master (con traefik deshabilitado)
install_k3s_master "true"

# Configurar kubectl
setup_kubectl

# Generar y guardar el token para el worker
save_k3s_token

# Configurar SSH
setup_ssh

echo "=== Configuración del nodo Master completada ==="