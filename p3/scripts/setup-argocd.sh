#!/bin/bash
#
# Script de configuración de Argo CD para GitOps
# Inception-of-Things - Parte 3
#

# Variables (modificar según tu repositorio)
GITHUB_REPO="https://github.com/TU_USUARIO/inception-of-things-p3.git"
APP_NAME="simple-app"

echo "=== Configurando Argo CD para GitOps ==="

# Verificar que el clúster K3d esté funcionando
if ! kubectl get nodes &> /dev/null; then
    echo "Error: No se puede conectar al clúster K3d. Asegúrate de que esté funcionando."
    exit 1
fi

# Verificar que Argo CD esté funcionando
if ! kubectl get pods -n argocd | grep -q "argocd-server"; then
    echo "Error: Argo CD no está instalado o no está funcionando correctamente."
    echo "Ejecuta primero el script install.sh"
    exit 1
fi

# Obtener la contraseña de admin de Argo CD
ARGOCD_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
ARGOCD_SERVER="localhost:8080"

echo "Iniciando sesión en Argo CD..."
argocd login --insecure $ARGOCD_SERVER --username admin --password $ARGOCD_PASS

# Crear la aplicación en Argo CD
echo "Creando aplicación en Argo CD..."
argocd app create $APP_NAME \
    --repo $GITHUB_REPO \
    --path kubernetes/base \
    --dest-server https://kubernetes.default.svc \
    --dest-namespace dev \
    --sync-policy automated \
    --auto-prune \
    --self-heal

echo "=== Configuración de Argo CD completada ==="
echo "La aplicación $APP_NAME ha sido configurada para sincronizarse automáticamente desde $GITHUB_REPO"
echo "Puedes verificar el estado de la aplicación con: argocd app get $APP_NAME"
echo ""
echo "Para acceder a la interfaz web de Argo CD:"
echo "  URL: http://localhost:8080"
echo "  Usuario: admin"
echo "  Contraseña: $ARGOCD_PASS"