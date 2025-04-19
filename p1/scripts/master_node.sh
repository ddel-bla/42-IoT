#!/bin/bash
#
# Script de instalación y configuración del nodo Master para K3s
# Inception-of-Things - Parte 1
#

echo "=== Iniciando configuración del nodo Master ==="

# Actualizar repositorios del sistema
echo "Actualizando repositorios..."
apt-get update

# Configurar archivo hosts para resolución local de nombres
echo "Configurando archivo /etc/hosts..."
cat >> /etc/hosts <<EOF
192.168.56.110 ddel-blaS
192.168.56.111 ddel-blaSW
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
  --disable=traefik \
  --node-ip=192.168.56.110 \
  --advertise-address=192.168.56.110

# Configurar kubectl para el usuario vagrant
echo "Configurando kubectl para usuario vagrant..."
mkdir -p /home/vagrant/.kube
cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube
echo "export KUBECONFIG=/home/vagrant/.kube/config" >> /home/vagrant/.bashrc

# Obtener el token para el nodo worker y guardarlo de forma segura
echo "Generando token para el nodo worker..."
TOKEN=$(cat /var/lib/rancher/k3s/server/node-token)

# Crear el archivo token_env con permisos restrictivos
install -m 600 /dev/null /vagrant/token_env
echo "export K3S_TOKEN=\"$TOKEN\"" > /vagrant/token_env
echo "Token generado y almacenado con permisos 600"

# Configurar acceso SSH sin contraseña
echo "Configurando acceso SSH sin contraseña..."
if [ ! -f /home/vagrant/.ssh/id_rsa ]; then
  mkdir -p /home/vagrant/.ssh
  su - vagrant -c "ssh-keygen -t rsa -f /home/vagrant/.ssh/id_rsa -N ''"
  su - vagrant -c "cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys"
  chmod 600 /home/vagrant/.ssh/authorized_keys
  chown -R vagrant:vagrant /home/vagrant/.ssh
fi

echo "=== Configuración del nodo Master completada ==="