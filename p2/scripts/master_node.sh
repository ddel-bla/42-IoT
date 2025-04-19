#!/bin/bash
#
# Script de instalación y configuración del nodo Master para K3s
# Inception-of-Things - Parte 2
#

echo "=== Iniciando configuración del nodo Master ==="

# Actualizar repositorios del sistema
echo "Actualizando repositorios..."
apt-get update

# Configurar archivo hosts para resolución local de nombres
echo "Configurando archivo /etc/hosts..."
cat >> /etc/hosts <<EOF
192.168.56.110 ddel-blaS
# Agregar entradas para las aplicaciones web
192.168.56.110 app1.com
192.168.56.110 app2.com
EOF

# Deshabilitar swap (requisito de Kubernetes)
echo "Deshabilitando swap..."
swapoff -a
sed -i '/swap/s/^\(.*\)$/#\1/g' /etc/fstab

# Crear directorio compartido para los archivos de Vagrant
echo "Creando directorio compartido..."
mkdir -p /vagrant

# Instalar K3s en modo servidor con configuraciones específicas
echo "Instalando K3s en modo servidor..."
curl -sfL https://get.k3s.io | sh -s - \
# No deshabilitamos traefik porque lo necesitamos para Ingress
  --node-ip=192.168.56.110 \
  --advertise-address=192.168.56.110

# Esperar a que K3s se inicie completamente
echo "Esperando a que K3s esté listo..."
sleep 10

# Configurar kubectl para el usuario vagrant
echo "Configurando kubectl para usuario vagrant..."
mkdir -p /home/vagrant/.kube
cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube
echo "export KUBECONFIG=/home/vagrant/.kube/config" >> /home/vagrant/.bashrc

# Crear manifiestos para las aplicaciones web en el directorio compartido
echo "Creando manifiestos para las aplicaciones web..."
mkdir -p /vagrant/manifests

# Aplicar configuración inicial
echo "Configuración inicial completada"
echo "=== Configuración del nodo Master completada ==="