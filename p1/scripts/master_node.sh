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

# Instalar K3s en modo servidor
curl -sfL https://get.k3s.io | sh -s - --disable=traefik --node-ip=192.168.56.110 --advertise-address=192.168.56.110 --flannel-iface=eth1

# Configurar kubectl para el usuario vagrant
mkdir -p /home/vagrant/.kube
cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube
echo "export KUBECONFIG=/home/vagrant/.kube/config" >> /home/vagrant/.bashrc

# Obtener el token para el nodo worker
TOKEN=$(cat /var/lib/rancher/k3s/server/node-token)

# Crear el archivo token_env 
install -m 600 /dev/null /vagrant/token_env
echo "export K3S_TOKEN=\"$TOKEN\"" > /vagrant/token_env

# Configurar acceso SSH sin contraseña
if [ ! -f /home/vagrant/.ssh/id_rsa ]; then
  mkdir -p /home/vagrant/.ssh
  su - vagrant -c "ssh-keygen -t rsa -f /home/vagrant/.ssh/id_rsa -N ''"
  su - vagrant -c "cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys"
  chmod 600 /home/vagrant/.ssh/authorized_keys
  chown -R vagrant:vagrant /home/vagrant/.ssh
fi