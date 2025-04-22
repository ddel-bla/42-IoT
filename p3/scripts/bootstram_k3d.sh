#!/bin/bash
#
# Script para configurar K3d
# Inception-of-Things - Parte 3
#

# Cargar configuraciones
source ./configs.sh

echo "=== Iniciando instalación de K3d ==="

# Verificar si Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "Docker no encontrado, instalando..."
    # Instalar las dependencias necesarias
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    
    # Agregar clave GPG de Docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    
    # Agregar repositorio de Docker
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    
    # Instalar Docker CE
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    
    # Agregar usuario actual al grupo docker
    sudo usermod -aG docker $USER
    
    echo "Docker instalado correctamente"
    echo "Es posible que necesites reiniciar tu sesión para usar Docker sin sudo"
else
    echo "Docker ya está instalado"
fi

# Verificar si k3d está instalado
if ! command -v k3d &> /dev/null; then
    echo "K3d no encontrado, instalando..."
    curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
    echo "K3d instalado correctamente"
else
    echo "K3d ya está instalado"
fi

# Verificar si kubectl está instalado
if ! command -v kubectl &> /dev/null; then
    echo "kubectl no encontrado, instalando..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
    echo "kubectl instalado correctamente"
else
    echo "kubectl ya está instalado"
fi

# Crear un clúster K3d
echo "Creando un clúster K3d..."
k3d cluster create $K3D_CLUSTER_NAME --api-port 6550 -p "8080:80@loadbalancer" -p "8443:443@loadbalancer" --agents 2

# Esperar a que el clúster esté listo
echo "Esperando a que el clúster K3d esté listo..."
until kubectl get nodes | grep -q " Ready"; do
    sleep 5
    echo "Esperando a que los nodos estén listos..."
done

# Crear los namespaces necesarios
echo "Creando namespaces..."
kubectl create namespace $ARGOCD_NAMESPACE
kubectl create namespace $APP_NAMESPACE

echo "=== Configuración de K3d completada ==="