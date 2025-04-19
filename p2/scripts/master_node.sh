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
# Usamos la variable INSTALL_K3S_EXEC para pasar los argumentos con permisos adecuados
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--node-ip=192.168.56.110 --advertise-address=192.168.56.110 --write-kubeconfig-mode=644" sh -

# Esperar a que K3s se inicie completamente
echo "Esperando a que K3s esté listo..."
sleep 20

# Configurar kubectl para el usuario vagrant
echo "Configurando kubectl para usuario vagrant..."
mkdir -p /home/vagrant/.kube
cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
# Reemplazar 127.0.0.1 por la IP real del nodo
sed -i 's/127.0.0.1/192.168.56.110/g' /home/vagrant/.kube/config
chmod 644 /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube
echo "export KUBECONFIG=/home/vagrant/.kube/config" >> /home/vagrant/.bashrc

# También copiar el archivo kubeconfig al directorio compartido
cp /etc/rancher/k3s/k3s.yaml /vagrant/kubeconfig.yaml
sed -i 's/127.0.0.1/192.168.56.110/g' /vagrant/kubeconfig.yaml
chmod 644 /vagrant/kubeconfig.yaml

# Crear manifiestos para las aplicaciones web en el directorio compartido
echo "Creando manifiestos para las aplicaciones web..."
mkdir -p /vagrant/manifests

# Aplicar configuración inicial
echo "Configuración inicial completada"
echo "=== Configuración del nodo Master completada ==="