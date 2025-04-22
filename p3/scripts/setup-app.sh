#!/bin/bash
#
# Script para configurar la aplicación en Argo CD
# Inception-of-Things - Parte 3
#

# Cargar configuraciones
source ./configs.sh

echo "=== Configurando aplicación en Argo CD ==="

# Verificar que kubectl está disponible
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl no está instalado."
    exit 1
fi

# Verificar que el clúster está en funcionamiento
if ! kubectl get nodes &> /dev/null; then
    echo "Error: No se puede conectar al clúster Kubernetes."
    exit 1
fi

# Verificar que Argo CD está instalado
if ! kubectl get deployment argocd-server -n $ARGOCD_NAMESPACE &> /dev/null; then
    echo "Error: Argo CD no está instalado. Ejecuta primero bootstrap_argocd.sh."
    exit 1
fi

# Esperar a que el puerto de Argo CD esté disponible
echo "Esperando a que Argo CD esté disponible..."
READY=false
ATTEMPTS=0
MAX_ATTEMPTS=30

while [ "$READY" = false ] && [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
    if kubectl get svc argocd-server -n $ARGOCD_NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}' &> /dev/null; then
        READY=true
    else
        echo "Esperando a que Argo CD esté disponible... (intento $((ATTEMPTS+1))/$MAX_ATTEMPTS)"
        sleep 5
        ATTEMPTS=$((ATTEMPTS+1))
    fi
done

if [ "$READY" = false ]; then
    echo "Error: Argo CD no está disponible después de $MAX_ATTEMPTS intentos."
    echo "Continuando de todos modos..."
fi

# Crear la aplicación en Argo CD usando un manifiesto
echo "Creando aplicación en Argo CD..."
cat <<EOF > argocd-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: $APP_NAME
  namespace: $ARGOCD_NAMESPACE
spec:
  project: default
  source:
    repoURL: $GITHUB_REPO
    targetRevision: $GIT_BRANCH
    path: p3/kustomize/overlays/dev
  destination:
    server: https://kubernetes.default.svc
    namespace: $DEV_NAMESPACE
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

kubectl apply -f argocd-app.yaml

if [ $? -ne 0 ]; then
    echo "Error al crear la aplicación en Argo CD."
    exit 1
fi

echo "Aplicación configurada en Argo CD."

# Esperar a que la aplicación se sincronice
echo "Esperando a que la aplicación se sincronice..."
SYNC_STATUS=""
ATTEMPTS=0
MAX_ATTEMPTS=20

while [ "$SYNC_STATUS" != "Synced" ] && [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
    SYNC_STATUS=$(kubectl get application $APP_NAME -n $ARGOCD_NAMESPACE -o jsonpath='{.status.sync.status}' 2>/dev/null)
    if [ -z "$SYNC_STATUS" ]; then
        SYNC_STATUS="Pending"
    fi
    echo "Estado de sincronización: $SYNC_STATUS (intento $((ATTEMPTS+1))/$MAX_ATTEMPTS)"
    sleep 10
    ATTEMPTS=$((ATTEMPTS+1))
done

if [ "$SYNC_STATUS" != "Synced" ]; then
    echo "Advertencia: La aplicación no se ha sincronizado completamente después de $MAX_ATTEMPTS intentos."
    echo "Estado actual: $SYNC_STATUS"
    echo "Verifica el estado de la aplicación en la interfaz de Argo CD."
else
    echo "Aplicación sincronizada correctamente."
fi

echo "=== Configuración de la aplicación completada ==="
echo "Puedes acceder a la aplicación en: $APP_URL"
echo "Puedes gestionar la aplicación en Argo CD: $ARGOCD_SERVER_URL"