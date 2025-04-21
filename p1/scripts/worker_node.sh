#!/bin/bash
#
# Script de instalación y configuración del nodo Worker para K3s
# Inception-of-Things - Parte 1
#

# Cargar las funciones comunes
source /vagrant/scripts/common_setup.sh

echo "=== Iniciando configuración del nodo Worker ==="

# Ejecutar configuración base del sistema
setup_base_system

# Configurar archivo hosts para p1
setup_hosts "p1-worker"

# Instalar K3s en modo worker
install_k3s_worker

# Configurar kubectl
setup_kubectl

# Configurar SSH
setup_ssh

echo "=== Configuración del nodo Worker completada ==="