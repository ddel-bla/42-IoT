#!/bin/bash

# Actualizar repositorios
apt-get update

# Configurar hosts
cat >> /etc/hosts <<EOF
192.168.56.110 [tu-login]S
192.168.56.111 [tu-login]SW
EOF

# Deshabilitar swap (requerido para Kubernetes)
swapoff -a
sed -i '/swap/s/^\(.*\)$/#\1/g' /etc/fstab

# Instalar K3s en modo servidor
curl -sfL https://get.k3s.io | sh -s - --disable=traefik --node-ip=192.168.56.110 --advertise-address=192.168.56.110 --flannel-iface=eth1

# Configurar kubectl para el usuario vagrant
mkdir -p /home/vagrant/.kube
cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube
echo "export KUBECONFIG=/home/vagrant/.kube/config" >> /home/vagrant/.bashrc

# Obtener el token para el nodo worker
cp /var/lib/rancher/k3s/server/node-token /vagrant/node-token
TOKEN=$(cat /var/lib/rancher/k3s/server/node-token)

# Configurar acceso SSH sin contraseña
mkdir -p /home/vagrant/.ssh
cat > /home/vagrant/.ssh/id_rsa <<EOF
#!/bin/bash
ssh-keygen -t rsa -f /home/vagrant/.ssh/id_rsa -N ""
cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
EOF
chmod +x /home/vagrant/.ssh/id_rsa
su - vagrant -c "/home/vagrant/.ssh/id_rsa"

# Pasar el token como variable de entorno para el nodo worker
echo "export K3S_TOKEN=\"$TOKEN\"" > /vagrant/token_env