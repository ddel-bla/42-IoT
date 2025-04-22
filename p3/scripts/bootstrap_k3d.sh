#!/bin/bash
#
# Script para configurar K3d
# Inception-of-Things - Parte 3
#

# Cargar configuraciones
source ./configs.sh

echo "=== Iniciando instalación de K3d ==="

# Verificar si k3d está instalado
if ! command -v k3d &> /dev/null; then
    echo "K3d no encontrado, instalando..."
    curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
    if [ $? -ne 0 ]; then
        echo "Error al instalar k3d."
        exit 1
    fi
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
    if [ $? -ne 0 ]; then
        echo "Error al instalar kubectl."
        exit 1
    fi
    echo "kubectl instalado correctamente"
else
    echo "kubectl ya está instalado"
fi

# Verificar si el clúster ya existe
if k3d cluster list | grep -q "$K3D_CLUSTER_NAME"; then
    echo "El clúster '$K3D_CLUSTER_NAME' ya existe."
    # Verificar si el clúster está corriendo
    if ! k3d cluster list | grep -q "$K3D_CLUSTER_NAME.*running"; then
        echo "El clúster está detenido. Iniciándolo..."
        k3d cluster start $K3D_CLUSTER_NAME
    fi
else
    echo "Creando un clúster K3d..."
    k3d cluster create $K3D_CLUSTER_NAME --api-port 6550 -p "8080:80@loadbalancer" -p "8443:443@loadbalancer" --agents 2
    if [ $? -ne 0 ]; then
        echo "Error al crear el clúster K3d."
        exit 1
    fi
fi

# Esperar a que el clúster esté listo
echo "Esperando a que el clúster K3d esté listo..."
READY=false
ATTEMPTS=0
MAX_ATTEMPTS=30

while [ "$READY" = false ] && [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
    if kubectl get nodes | grep -q " Ready"; then
        READY=true
    else
        echo "Esperando a que los nodos estén listos... (intento $((ATTEMPTS+1))/$MAX_ATTEMPTS)"
        sleep 5
        ATTEMPTS=$((ATTEMPTS+1))
    fi
done

if [ "$READY" = false ]; then
    echo "Error: Los nodos no están listos después de $MAX_ATTEMPTS intentos."
    exit 1
fi

# Crear los namespaces necesarios
echo "Creando namespace para Argo CD..."
kubectl create namespace $ARGOCD_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

echo "Creando namespace para aplicaciones..."
kubectl create namespace $DEV_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

echo "=== Configuración de K3d completada ==="