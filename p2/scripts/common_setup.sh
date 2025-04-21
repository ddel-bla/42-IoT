#!/bin/bash
#
# Script común de instalación y configuración para K3s
# Inception-of-Things
#

# Función para actualizar y configurar el sistema base
setup_base_system() {
    echo "=== Configuración base del sistema ==="
    
    # Actualizar repositorios del sistema
    echo "Actualizando repositorios..."
    apt-get update
    
    # Deshabilitar swap (requisito de Kubernetes)
    echo "Deshabilitando swap..."
    swapoff -a
    sed -i '/swap/s/^\(.*\)$/#\1/g' /etc/fstab
    
    # Crear directorio compartido para los archivos de Vagrant
    echo "Creando directorio compartido..."
    mkdir -p /vagrant
}

# Función para configurar el archivo hosts
setup_hosts() {
    local role=$1
    echo "Configurando archivo /etc/hosts..."
    
    # Configuración base de hosts
    cat >> /etc/hosts <<EOF
192.168.56.110 ddel-blaS
EOF
    
    # Añadir configuración adicional según el rol
    if [ "$role" = "p1-master" ] || [ "$role" = "p1-worker" ]; then
        echo "192.168.56.111 ddel-blaSW" >> /etc/hosts
    elif [ "$role" = "p2-server" ]; then
        cat >> /etc/hosts <<EOF
# Agregar entradas para las aplicaciones web
192.168.56.110 app1.com
192.168.56.110 app2.com
EOF
    fi
}

# Función para configurar SSH (solo para p1)
setup_ssh() {
    echo "Configurando acceso SSH sin contraseña..."
    if [ ! -f /home/vagrant/.ssh/id_rsa ]; then
        mkdir -p /home/vagrant/.ssh
        su - vagrant -c "ssh-keygen -t rsa -f /home/vagrant/.ssh/id_rsa -N ''"
        su - vagrant -c "cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys"
        chmod 600 /home/vagrant/.ssh/authorized_keys
        chown -R vagrant:vagrant /home/vagrant/.ssh
    fi
}

# Función para configurar kubectl
setup_kubectl() {
    echo "Configurando kubectl para usuario vagrant..."
    mkdir -p /home/vagrant/.kube
    cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
    
    # Para p2, reemplazar 127.0.0.1 por la IP real del nodo
    if [ -n "$1" ] && [ "$1" = "p2" ]; then
        sed -i 's/127.0.0.1/192.168.56.110/g' /home/vagrant/.kube/config
        # También copiar el archivo kubeconfig al directorio compartido
        cp /etc/rancher/k3s/k3s.yaml /vagrant/kubeconfig.yaml
        sed -i 's/127.0.0.1/192.168.56.110/g' /vagrant/kubeconfig.yaml
        chmod 644 /vagrant/kubeconfig.yaml
    fi
    
    chmod 644 /home/vagrant/.kube/config
    chown -R vagrant:vagrant /home/vagrant/.kube
    echo "export KUBECONFIG=/home/vagrant/.kube/config" >> /home/vagrant/.bashrc
}

# Función para instalar K3s en el master
install_k3s_master() {
    local disable_traefik=$1
    echo "Instalando K3s en modo servidor..."
    
    if [ "$disable_traefik" = "true" ]; then
        curl -sfL https://get.k3s.io | sh -s - \
          --disable=traefik \
          --node-ip=192.168.56.110 \
          --advertise-address=192.168.56.110
    else
        curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--node-ip=192.168.56.110 --advertise-address=192.168.56.110 --write-kubeconfig-mode=644" sh -
    fi
    
    # Esperar a que K3s se inicie completamente
    echo "Esperando a que K3s esté listo..."
    sleep 20
}

# Función para generar y almacenar el token (solo para p1)
save_k3s_token() {
    echo "Generando token para el nodo worker..."
    TOKEN=$(cat /var/lib/rancher/k3s/server/node-token)
    
    # Crear el archivo token_env con permisos restrictivos
    install -m 600 /dev/null /vagrant/token_env
    echo "export K3S_TOKEN=\"$TOKEN\"" > /vagrant/token_env
    echo "Token generado y almacenado con permisos 600"
}

# Función para instalar K3s en el worker (solo para p1)
install_k3s_worker() {
    # Esperar a que el token esté disponible desde el nodo master
    local MAX_ATTEMPTS=10
    local ATTEMPT=0
    
    echo "Esperando al token desde el nodo master..."
    while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
        if [ -f "/vagrant/token_env" ]; then
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
}