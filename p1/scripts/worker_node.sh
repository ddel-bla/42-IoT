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

# Esperar a que el token esté disponible
MAX_ATTEMPTS=5
ATTEMPT=0

echo "Esperando al token desde el nodo master..."

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
  if [ -f "/vagrant/token_env" ]; then
    echo "Token encontrado."
    break
  fi
  
  echo "Esperando... (intento $((ATTEMPT+1))/$MAX_ATTEMPTS)"
  sleep 5
  ATTEMPT=$((ATTEMPT+1))
done

if [ ! -f "/vagrant/token_env" ]; then
  echo "Error: No se pudo obtener el token. Verifique que el nodo master está funcionando."
  exit 1
fi

# Cargar el token
source /vagrant/token_env

# Instalar K3s en modo agente
echo "Instalando K3s en modo agente..."
curl -sfL https://get.k3s.io | sh -s - --url=https://192.168.56.110:6443 --token="$K3S_TOKEN" --node-ip=192.168.56.111 --flannel-iface=eth1

# Configurar kubectl para el usuario vagrant
mkdir -p /home/vagrant/.kube
echo "export KUBECONFIG=/home/vagrant/.kube/config" >> /home/vagrant/.bashrc

# Configurar acceso SSH sin contraseña
if [ ! -f /home/vagrant/.ssh/id_rsa ]; then
  mkdir -p /home/vagrant/.ssh
  su - vagrant -c "ssh-keygen -t rsa -f /home/vagrant/.ssh/id_rsa -N ''"
  su - vagrant -c "cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys"
  chmod 600 /home/vagrant/.ssh/authorized_keys
  chown -R vagrant:vagrant /home/vagrant/.ssh
fi