#!/bin/bash
#
# Script para verificar el estado completo del entorno
# Inception-of-Things - Parte 3
#

# Cargar configuraciones
source ./scripts/configs.sh

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "=== Ejecutando verificación completa del entorno ==="

# Verificar K3d
echo -e "${BLUE}[1/5]${NC} Verificando K3d..."
if k3d cluster list | grep -q "$K3D_CLUSTER_NAME"; then
    echo -e "  ${GREEN}✓${NC} Clúster K3d '$K3D_CLUSTER_NAME' encontrado."
    
    # Verificar si el clúster está en ejecución
    if kubectl get nodes &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} Clúster K3d está en ejecución."
    else
        echo -e "  ${RED}✗${NC} Clúster K3d no está en ejecución."
        echo -e "  ${YELLOW}!${NC} Inicia el clúster con: k3d cluster start $K3D_CLUSTER_NAME"
    fi
else
    echo -e "  ${RED}✗${NC} Clúster K3d '$K3D_CLUSTER_NAME' no encontrado."
    echo -e "  ${YELLOW}!${NC} Crea el clúster con: bash ./scripts/bootstrap_k3d.sh"
fi

# Verificar Namespaces
echo -e "${BLUE}[2/5]${NC} Verificando namespaces..."
if kubectl get namespace $ARGOCD_NAMESPACE &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} Namespace '$ARGOCD_NAMESPACE' existe."
else
    echo -e "  ${RED}✗${NC} Namespace '$ARGOCD_NAMESPACE' no existe."
    echo -e "  ${YELLOW}!${NC} Crea el namespace con: kubectl create namespace $ARGOCD_NAMESPACE"
fi

if kubectl get namespace $DEV_NAMESPACE &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} Namespace '$DEV_NAMESPACE' existe."
else
    echo -e "  ${RED}✗${NC} Namespace '$DEV_NAMESPACE' no existe."
    echo -e "  ${YELLOW}!${NC} Crea el namespace con: kubectl create namespace $DEV_NAMESPACE"
fi

# Verificar Argo CD
echo -e "${BLUE}[3/5]${NC} Verificando Argo CD..."
if kubectl get deployment argocd-server -n $ARGOCD_NAMESPACE &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} Argo CD está instalado."
    
    # Verificar si Argo CD está en ejecución
    if kubectl get pods -n $ARGOCD_NAMESPACE -l app.kubernetes.io/name=argocd-server -o jsonpath='{.items[0].status.phase}' 2>/dev/null | grep -q "Running"; then
        echo -e "  ${GREEN}✓${NC} Argo CD está en ejecución."
    else
        echo -e "  ${RED}✗${NC} Argo CD no está en ejecución correctamente."
        echo -e "  ${YELLOW}!${NC} Verifica los pods con: kubectl get pods -n $ARGOCD_NAMESPACE"
    fi
    
    # Verificar si el servicio está expuesto como LoadBalancer
    if kubectl get svc argocd-server -n $ARGOCD_NAMESPACE -o jsonpath='{.spec.type}' 2>/dev/null | grep -q "LoadBalancer"; then
        echo -e "  ${GREEN}✓${NC} Servicio Argo CD está expuesto correctamente."
    else
        echo -e "  ${RED}✗${NC} Servicio Argo CD no está expuesto como LoadBalancer."
        echo -e "  ${YELLOW}!${NC} Expón el servicio con: kubectl patch svc argocd-server -n $ARGOCD_NAMESPACE -p '{\"spec\": {\"type\": \"LoadBalancer\"}}'"
    fi
else
    echo -e "  ${RED}✗${NC} Argo CD no está instalado."
    echo -e "  ${YELLOW}!${NC} Instala Argo CD con: bash ./scripts/bootstrap_argocd.sh"
fi

# Verificar aplicación
echo -e "${BLUE}[4/5]${NC} Verificando aplicación en Argo CD..."
if kubectl get application $APP_NAME -n $ARGOCD_NAMESPACE &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} Aplicación '$APP_NAME' está configurada en Argo CD."
    
    # Verificar estado de sincronización
    SYNC_STATUS=$(kubectl get application $APP_NAME -n $ARGOCD_NAMESPACE -o jsonpath='{.status.sync.status}' 2>/dev/null)
    if [ "$SYNC_STATUS" == "Synced" ]; then
        echo -e "  ${GREEN}✓${NC} Aplicación está sincronizada (estado: $SYNC_STATUS)."
    else
        echo -e "  ${YELLOW}!${NC} Aplicación no está completamente sincronizada (estado: $SYNC_STATUS)."
        echo -e "  ${YELLOW}!${NC} Verifica la aplicación en la interfaz de Argo CD o ejecuta: kubectl describe application $APP_NAME -n $ARGOCD_NAMESPACE"
    fi
    
    # Verificar estado de salud
    HEALTH_STATUS=$(kubectl get application $APP_NAME -n $ARGOCD_NAMESPACE -o jsonpath='{.status.health.status}' 2>/dev/null)
    if [ "$HEALTH_STATUS" == "Healthy" ]; then
        echo -e "  ${GREEN}✓${NC} Aplicación está saludable (estado: $HEALTH_STATUS)."
    else
        echo -e "  ${YELLOW}!${NC} Aplicación no está completamente saludable (estado: $HEALTH_STATUS)."
        echo -e "  ${YELLOW}!${NC} Verifica la aplicación en la interfaz de Argo CD o ejecuta: kubectl describe application $APP_NAME -n $ARGOCD_NAMESPACE"
    fi
else
    echo -e "  ${RED}✗${NC} Aplicación '$APP_NAME' no está configurada en Argo CD."
    echo -e "  ${YELLOW}!${NC} Configura la aplicación con: bash ./scripts/setup-app.sh"
fi

# Verificar despliegue
echo -e "${BLUE}[5/5]${NC} Verificando despliegue de la aplicación..."
if kubectl get deployment $APP_NAME -n $DEV_NAMESPACE &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} Deployment '$APP_NAME' existe en namespace '$DEV_NAMESPACE'."
    
    # Verificar replicas
    AVAILABLE=$(kubectl get deployment $APP_NAME -n $DEV_NAMESPACE -o jsonpath='{.status.availableReplicas}' 2>/dev/null)
    DESIRED=$(kubectl get deployment $APP_NAME -n $DEV_NAMESPACE -o jsonpath='{.spec.replicas}' 2>/dev/null)
    
    if [ "$AVAILABLE" == "$DESIRED" ]; then
        echo -e "  ${GREEN}✓${NC} Todas las réplicas están disponibles ($AVAILABLE/$DESIRED)."
    else
        echo -e "  ${RED}✗${NC} No todas las réplicas están disponibles ($AVAILABLE/$DESIRED)."
        echo -e "  ${YELLOW}!${NC} Verifica el estado con: kubectl get pods -n $DEV_NAMESPACE"
    fi
    
    # Verificar imagen actual
    CURRENT_IMAGE=$(kubectl get deployment $APP_NAME -n $DEV_NAMESPACE -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
    echo -e "  ${BLUE}i${NC} Imagen actual: $CURRENT_IMAGE"
    
    if [ "$CURRENT_IMAGE" == "$IMAGE_NAME:$IMAGE_TAG_V1" ]; then
        echo -e "  ${BLUE}i${NC} Estás usando la versión 1 de la aplicación."
    elif [ "$CURRENT_IMAGE" == "$IMAGE_NAME:$IMAGE_TAG_V2" ]; then
        echo -e "  ${BLUE}i${NC} Estás usando la versión 2 de la aplicación."
    else
        echo -e "  ${YELLOW}!${NC} Estás usando una versión desconocida de la aplicación."
    fi
else
    echo -e "  ${RED}✗${NC} Deployment '$APP_NAME' no existe en namespace '$DEV_NAMESPACE'."
    echo -e "  ${YELLOW}!${NC} Verifica que la aplicación está correctamente configurada en Argo CD."
fi

# Verificar servicios
if kubectl get service webapp-service -n $DEV_NAMESPACE &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} Servicio 'webapp-service' existe."
else
    echo -e "  ${RED}✗${NC} Servicio 'webapp-service' no existe."
fi

# Verificar ingress
if kubectl get ingress webapp-ingress -n $DEV_NAMESPACE &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} Ingress 'webapp-ingress' existe."
else
    echo -e "  ${RED}✗${NC} Ingress 'webapp-ingress' no existe."
fi

echo ""
echo "=== Información de acceso ==="
echo -e "Aplicación web: ${BLUE}$APP_URL${NC}"
echo -e "Panel de Argo CD: ${BLUE}$ARGOCD_SERVER_URL${NC}"
echo -e "Usuario Argo CD: ${BLUE}admin${NC}"
echo -e "Contraseña Argo CD: ${BLUE}$(cat .argocd_password 2>/dev/null || echo 'Ver en archivo .argocd_password')${NC}"

echo ""
echo "=== Verificación completada ==="