#!/bin/bash
#
# Script de configuración de Argo CD para GitOps
# Inception-of-Things - Parte 3
#

# Variables (con repositorio actualizado)
GITHUB_REPO="https://github.com/ddel-bla/42-IoT.git"
APP_NAME="simple-app"
GIT_PATH="p3/kubernetes/base"  # Path correcto dentro del repositorio

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
echo "Contraseña de Argo CD: $ARGOCD_PASS"

# Esperar a que el servidor de Argo CD esté completamente listo
echo "Esperando a que el servidor de Argo CD esté completamente disponible..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Configurar port-forward para acceder a Argo CD
echo "Configurando port-forward para acceder a Argo CD..."
# Matar cualquier proceso previo de port-forward
pkill -f "kubectl port-forward svc/argocd-server" || true
# Iniciar port-forward en segundo plano
kubectl port-forward svc/argocd-server -n argocd 8080:443 > /dev/null 2>&1 &
# Guardar PID para poder matarlo después
PORT_FORWARD_PID=$!
# Esperar a que el port-forward esté listo
sleep 5

# Iniciar sesión en Argo CD usando la CLI
echo "Iniciando sesión en Argo CD..."
argocd login localhost:8080 --username admin --password "$ARGOCD_PASS" --insecure

# Verificar que el login fue exitoso
if [ $? -ne 0 ]; then
    echo "Error al iniciar sesión en Argo CD. Intentando con configuración directa..."
    # Configurar directamente usando kubectl en lugar de argocd CLI
    echo "Creando aplicación en Kubernetes directamente..."
    
    # Crear un archivo temporal para la definición de la aplicación
    cat > /tmp/argocd-app.yaml <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: $APP_NAME
  namespace: argocd
spec:
  project: default
  source:
    repoURL: $GITHUB_REPO
    targetRevision: HEAD
    path: $GIT_PATH
  destination:
    server: https://kubernetes.default.svc
    namespace: dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF
    
    # Aplicar el archivo
    kubectl apply -f /tmp/argocd-app.yaml
else
    # Crear la aplicación en Argo CD usando la CLI
    echo "Creando aplicación en Argo CD..."
    argocd app create $APP_NAME \
        --repo $GITHUB_REPO \
        --path $GIT_PATH \
        --dest-server https://kubernetes.default.svc \
        --dest-namespace dev \
        --sync-policy automated \
        --auto-prune \
        --self-heal
fi

# Matar el proceso de port-forward
if [ -n "$PORT_FORWARD_PID" ]; then
    kill $PORT_FORWARD_PID
fi

echo "=== Configuración de Argo CD completada ==="
echo "La aplicación $APP_NAME ha sido configurada para sincronizarse automáticamente desde $GITHUB_REPO"
echo "Puedes verificar el estado con: kubectl get applications -n argocd"
echo ""
echo "Para acceder a la interfaz web de Argo CD:"
echo "  URL: http://localhost:8080"
echo "  Usuario: admin"
echo "  Contraseña: $ARGOCD_PASS"

# Guardar la contraseña para referencia futura
echo "$ARGOCD_PASS" > /tmp/.argocd_password
echo "La contraseña se ha guardado en /tmp/.argocd_password para referencia"