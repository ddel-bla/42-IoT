#!/bin/bash
#
# Script para desplegar versiones específicas de la aplicación
# Inception-of-Things - Parte 3
#

# Cargar configuraciones
source ./scripts/configs.sh

# Verificar que se haya proporcionado un número de versión
if [ "$#" -ne 1 ]; then
    echo "Uso: $0 <numero_version>"
    echo "Ejemplo: $0 1"
    exit 1
fi

VERSION=$1

# Validar la versión
if [ "$VERSION" != "1" ] && [ "$VERSION" != "2" ]; then
    echo "Error: Versión no válida. Use 1 o 2."
    exit 1
fi

echo "=== Desplegando versión $VERSION de la aplicación ==="

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

# Definir la ruta del overlay según la versión
if [ "$VERSION" == "1" ]; then
    OVERLAY_PATH="$GIT_PATH/overlays/dev"
    VERSION_IMAGE="$IMAGE_NAME:$IMAGE_TAG_V1"
elif [ "$VERSION" == "2" ]; then
    OVERLAY_PATH="$GIT_PATH/overlays/prod"
    VERSION_IMAGE="$IMAGE_NAME:$IMAGE_TAG_V2"
fi

echo "Actualizando aplicación para usar la versión $VERSION..."

# Actualizar la aplicación usando kubectl
kubectl patch application $APP_NAME -n $ARGOCD_NAMESPACE --type merge -p "{\"spec\":{\"source\":{\"path\":\"$OVERLAY_PATH\"}}}"

if [ $? -ne 0 ]; then
    echo "Error al actualizar la aplicación."
    echo "Intentando una solución alternativa..."
    
    # Crear un manifiesto actualizado y aplicarlo
    cat <<EOF > argocd-app-v$VERSION.yaml
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
    path: $OVERLAY_PATH
  destination:
    server: https://kubernetes.default.svc
    namespace: $DEV_NAMESPACE
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

    kubectl apply -f argocd-app-v$VERSION.yaml
    
    if [ $? -ne 0 ]; then
        echo "Error al actualizar la aplicación usando kubectl."
        
        # Intentar con la CLI de Argo CD si está disponible
        if command -v argocd &> /dev/null; then
            echo "Intentando actualizar con la CLI de Argo CD..."
            
            # Obtener la contraseña de Argo CD
            ARGOCD_PASS=$(cat .argocd_password 2>/dev/null)
            if [ -z "$ARGOCD_PASS" ]; then
                ARGOCD_PASS=$(kubectl -n $ARGOCD_NAMESPACE get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
            fi
            
            # Iniciar sesión en Argo CD
            argocd login localhost:$ARGOCD_PORT --username admin --password "$ARGOCD_PASS" --insecure
            
            # Actualizar la aplicación
            argocd app set $APP_NAME --path $OVERLAY_PATH
            
            if [ $? -ne 0 ]; then
                echo "Error al actualizar la aplicación usando la CLI de Argo CD."
                exit 1
            fi
            
            # Sincronizar la aplicación
            argocd app sync $APP_NAME
        else
            echo "La CLI de Argo CD no está instalada."
            exit 1
        fi
    fi
fi

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
    sleep 5
    ATTEMPTS=$((ATTEMPTS+1))
done

if [ "$SYNC_STATUS" != "Synced" ]; then
    echo "Advertencia: La aplicación no se ha sincronizado completamente después de $MAX_ATTEMPTS intentos."
    echo "Estado actual: $SYNC_STATUS"
    echo "Verifica el estado de la aplicación en la interfaz de Argo CD."
else
    echo "Aplicación sincronizada correctamente."
fi

echo "=== Despliegue de la versión $VERSION iniciado ==="
echo "La versión $VERSION está siendo desplegada. La imagen utilizada es: $VERSION_IMAGE"
echo "Puedes verificar el estado con: kubectl get pods -n $DEV_NAMESPACE"
echo ""
echo "Para ver la aplicación, visita: $APP_URL"