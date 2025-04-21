#!/bin/bash
#
# Script de instalación y configuración del nodo Worker para K3s
# Inception-of-Things - Parte 1
#

echo "=== Iniciando configuración del nodo Worker ==="

# Actualizar repositorios del sistema
echo "Actualizando repositorios..."
apt-get update

# Configurar archivo hosts para resolución local de nombres
echo "Configurando archivo /etc/hosts..."
cat >> /etc/hosts <<EOF
192.168.56.110 ddel-blaS
192.168.56.111 ddel-blaSW
EOF

#	equisito de Kubernetes)
echo "Deshabilitando swap..."
swapoff -a
sed -i '/swap/s/^\(.*\)$/#\1/g' /etc/fstab

# Crear directorio compartido para los archivos de Vagrant
echo "Creando directorio compartido..."
mkdir -p /vagrant

# Esperar a que el token esté disponible desde el nodo master
MAX_ATTEMPTS=10
ATTEMPT=0

echo "Esperando al token desde el nodo master..."
while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
  if [ -f "/vagrant/token_env" ]; then
    # Verificar que el archivo contiene datos válidos
    if [ -s "/vagrant/token_env" ] && grep -q "K3S_TOKEN" "/vagrant/token_env"; then
      echo "Token encontrado y validado."
      break
    fi
  fi
  
  echo "Esperando... (intento $((ATTEMPT+1))/$MAX_ATTEMPTS)"
  sleep 10
  ATTEMPT=$((ATTEMPT+1))
done

if [ ! -f "/vagrant/token_env" ] || ! grep -q "K3S_TOKEN" "/vagrant/token_env"; then
  echo "Error: No se pudo obtener un token válido. Verifique que el nodo master está funcionando correctamente."
  exit 1
fi

# Cargar el token desde el archivo de entorno
echo "Cargando token de K3s..."
source /vagrant/token_env

# Instalar K3s en modo agente con el token del servidor
echo "Instalando K3s en modo agente..."
curl -sfL https://get.k3s.io | sh -s - agent \
  --server=https://192.168.56.110:6443 \
  --token="$K3S_TOKEN" \
  --node-ip=192.168.56.111

# Configurar kubectl para el usuario vagrant
echo "Configurando entorno para usuario vagrant..."
mkdir -p /home/vagrant/.kube
echo "export KUBECONFIG=/home/vagrant/.kube/config" >> /home/vagrant/.bashrc

# Configurar acceso SSH sin contraseña
echo "Configurando acceso SSH sin contraseña..."
if [ ! -f /home/vagrant/.ssh/id_rsa ]; then
  mkdir -p /home/vagrant/.ssh
  su - vagrant -c "ssh-keygen -t rsa -f /home/vagrant/.ssh/id_rsa -N ''"
  su - vagrant -c "cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys"
  chmod 600 /home/vagrant/.ssh/authorized_keys
  chown -R vagrant:vagrant /home/vagrant/.ssh
fi

echo "=== Configuración del nodo Worker completada ==="