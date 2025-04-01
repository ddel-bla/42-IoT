#!/bin/bash

# Actualizar repositorios
apt-get update

# Configurar hosts
cat >> /etc/hosts <<EOF
192.168.56.110 ddel-blaS
192.168.56.111 ddel-blaSW
EOF

# Deshabilitar swap (requerido para Kubernetes)
swapoff -a
sed -i '/swap/s/^\(.*\)$/#\1/g' /etc/fstab

# Crear directorio compartido ya que vagrant.synced_folder está deshabilitado
mkdir -p /vagrant

# Esperar a que el token esté disponible desde el nodo maestro
while [ ! -f /vagrant/token_env ]; do
  echo "Esperando al token desde el nodo maestro..."
  sleep 5
done

# Obtener el token del nodo maestro
source /vagrant/token_env

# Instalar K3s en modo agente
curl -sfL https://get.k3s.io | sh -s - --url=https://192.168.56.110:6443 --token="$K3S_TOKEN" --node-ip=192.168.56.111 --flannel-iface=eth1

# Configurar kubectl para el usuario vagrant
mkdir -p /home/vagrant/.kube
echo "export KUBECONFIG=/home/vagrant/.kube/config" >> /home/vagrant/.bashrc

# Configurar acceso SSH sin contraseña (método corregido)
if [ ! -f /home/vagrant/.ssh/id_rsa ]; then
  mkdir -p /home/vagrant/.ssh
  su - vagrant -c "ssh-keygen -t rsa -f /home/vagrant/.ssh/id_rsa -N ''"
  su - vagrant -c "cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys"
  chmod 600 /home/vagrant/.ssh/authorized_keys
  chown -R vagrant:vagrant /home/vagrant/.ssh
fi