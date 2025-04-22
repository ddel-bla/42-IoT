#!/bin/bash
#
# Script para instalar y configurar Argo CD
# Inception-of-Things - Parte 3
#

# Cargar configuraciones
source ./scripts/configs.sh

echo "=== Instalando Argo CD ==="

# Instalar Argo CD
echo "Instalando Argo CD en namespace $ARGOCD_NAMESPACE..."
kubectl apply -n $ARGOCD_NAMESPACE -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

if [ $? -ne 0 ]; then
    echo "Error al instalar Argo CD."
    exit 1
fi

# Esperar a que Argo CD esté listo
echo "Esperando a que todos los pods de Argo CD estén listos..."
kubectl wait --for=condition=Ready pods --all -n $ARGOCD_NAMESPACE --timeout=300s

if [ $? -ne 0 ]; then
    echo "Error: Algunos pods de Argo CD no están listos después de 5 minutos."
    echo "Verificando el estado actual de los pods:"
    kubectl get pods -n $ARGOCD_NAMESPACE
    exit 1
fi

# Configurar el acceso a la interfaz de Argo CD
echo "Configurando acceso a la interfaz de Argo CD..."
kubectl patch svc argocd-server -n $ARGOCD_NAMESPACE -p '{"spec": {"type": "LoadBalancer"}}'

# Esperar a que el servicio esté disponible
echo "Esperando a que el servicio argocd-server esté disponible..."
READY=false
ATTEMPTS=0
MAX_ATTEMPTS=30

while [ "$READY" = false ] && [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
    if kubectl get svc argocd-server -n $ARGOCD_NAMESPACE | grep -q "LoadBalancer"; then
        READY=true
    else
        echo "Esperando a que el servicio esté disponible... (intento $((ATTEMPTS+1))/$MAX_ATTEMPTS)"
        sleep 5
        ATTEMPTS=$((ATTEMPTS+1))
    fi
done

if [ "$READY" = false ]; then
    echo "Error: El servicio argocd-server no está disponible después de $MAX_ATTEMPTS intentos."
    exit 1
fi

# Obtener la contraseña de admin de Argo CD
echo "Obteniendo la contraseña de admin de Argo CD..."
ARGOCD_PASS=$(kubectl -n $ARGOCD_NAMESPACE get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

if [ -z "$ARGOCD_PASS" ]; then
    echo "Error: No se pudo obtener la contraseña de Argo CD."
    exit 1
fi

echo "Usuario: admin"
echo "Contraseña: $ARGOCD_PASS"
echo "$ARGOCD_PASS" > .argocd_password
chmod 600 .argocd_password

# Instalar la CLI de Argo CD si no está ya instalada
if ! command -v argocd &> /dev/null; then
    echo "Instalando CLI de Argo CD..."
    # Obtener la versión más reciente
    VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    
    # Descargar el binario
    curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64
    
    # Hacerlo ejecutable y moverlo al path
    chmod +x argocd
    sudo mv argocd /usr/local/bin/
    
    if [ $? -ne 0 ]; then
        echo "Error al instalar la CLI de Argo CD."
        echo "Puedes continuar sin la CLI, pero algunas funcionalidades del script podrían no funcionar correctamente."
    else
        echo "CLI de Argo CD instalada correctamente"
    fi
else
    echo "CLI de Argo CD ya está instalada"
fi

echo "=== Instalación de Argo CD completada ==="
echo "Argo CD estará disponible en: $ARGOCD_SERVER_URL"