#!/bin/bash
#
# Script de instalación y configuración de K3d y Argo CD
# Inception-of-Things - Parte 3
#

echo "=== Iniciando instalación de K3d y Argo CD ==="

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
k3d cluster create argocd-cluster --api-port 6550 -p "8080:80@loadbalancer" -p "8443:443@loadbalancer" --agents 2

# Esperar a que el clúster esté listo
echo "Esperando a que el clúster K3d esté listo..."
until kubectl get nodes | grep -q " Ready"; do
    sleep 5
    echo "Esperando a que los nodos estén listos..."
done

# Crear los namespaces necesarios
echo "Creando namespaces..."
kubectl create namespace argocd
kubectl create namespace dev

# Instalar Argo CD
echo "Instalando Argo CD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Esperar a que Argo CD esté listo
echo "Esperando a que todos los pods de Argo CD estén listos..."
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s

# Configurar el acceso a la interfaz de Argo CD
echo "Configurando acceso a la interfaz de Argo CD..."
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# Obtener la contraseña de admin de Argo CD
echo "Obteniendo la contraseña de admin de Argo CD..."
ARGOCD_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "Usuario: admin"
echo "Contraseña: $ARGOCD_PASS"

# Instalar la CLI de Argo CD
if ! command -v argocd &> /dev/null; then
    echo "Instalando CLI de Argo CD..."
    sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
    sudo chmod +x /usr/local/bin/argocd
else
    echo "CLI de Argo CD ya está instalada"
fi

echo "=== Instalación completada ==="
echo "Acceda a la interfaz web de Argo CD en: http://localhost:8080"
echo "O use la CLI de Argo CD: argocd login localhost:8080"
echo ""
echo "Para continuar con la configuración, ejecute el script: setup-argocd.sh"