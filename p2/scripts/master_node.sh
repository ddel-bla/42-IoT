#!/bin/bash
#
# Script de instalación y configuración del nodo Master para K3s
# Inception-of-Things - Parte 2
#

echo "=== Iniciando configuración del nodo Master ==="

# Ejecutar configuración base del sistema
setup_base_system
setup_hosts "p2-server"

# Instalar K3s en modo master (con traefik habilitado)
echo "Instalando K3s en modo servidor con Traefik habilitado..."
curl -sfL https://get.k3s.io | sh -s - \
  --node-ip=192.168.56.110 \
  --advertise-address=192.168.56.110 \
  --write-kubeconfig-mode=644

# Esperar a que K3s se inicie completamente
echo "Esperando a que K3s esté listo..."
sleep 20

# Configurar kubectl para el usuario vagrant
echo "Configurando kubectl para usuario vagrant..."
mkdir -p /home/vagrant/.kube
cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
sed -i 's/127.0.0.1/192.168.56.110/g' /home/vagrant/.kube/config
chmod 644 /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube
echo "export KUBECONFIG=/home/vagrant/.kube/config" >> /home/vagrant/.bashrc

# También copiar el archivo kubeconfig al directorio compartido
cp /etc/rancher/k3s/k3s.yaml /vagrant/kubeconfig.yaml
sed -i 's/127.0.0.1/192.168.56.110/g' /vagrant/kubeconfig.yaml
chmod 644 /vagrant/kubeconfig.yaml

# Crear directorio para manifiestos de aplicaciones web
echo "Creando manifiestos para las aplicaciones web..."
mkdir -p /vagrant/manifests

echo "Configuración inicial completada"
echo "=== Configuración del nodo Master completada ==="