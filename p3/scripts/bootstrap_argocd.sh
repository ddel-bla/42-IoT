#!/bin/bash
#
# Script para instalar y configurar Argo CD
# Inception-of-Things - Parte 3
#

# Cargar configuraciones
source ./configs.sh

echo "=== Instalando Argo CD ==="

# Instalar Argo CD
echo "Instalando Argo CD..."
kubectl apply -n $ARGOCD_NAMESPACE -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Esperar a que Argo CD esté listo
echo "Esperando a que todos los pods de Argo CD estén listos..."
kubectl wait --for=condition=Ready pods --all -n $ARGOCD_NAMESPACE --timeout=300s

# Configurar el acceso a la interfaz de Argo CD
echo "Configurando acceso a la interfaz de Argo CD..."
kubectl patch svc argocd-server -n $ARGOCD_NAMESPACE -p '{"spec": {"type": "LoadBalancer"}}'

# Obtener la contraseña de admin de Argo CD
echo "Obteniendo la contraseña de admin de Argo CD..."
ARGOCD_PASS=$(kubectl -n $ARGOCD_NAMESPACE get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "Usuario: admin"
echo "Contraseña: $ARGOCD_PASS"
echo "$ARGOCD_PASS" > .argocd_password

# Instalar la CLI de Argo CD si no está ya instalada
if ! command -v argocd &> /dev/null; then
    echo "Instalando CLI de Argo CD..."
    sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
    sudo chmod +x /usr/local/bin/argocd
else
    echo "CLI de Argo CD ya está instalada"
fi

echo "=== Instalación de Argo CD completada ==="