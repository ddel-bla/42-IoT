#!/bin/bash
#
# Script para limpiar todo el entorno
# Inception-of-Things - Parte 3
#

# Cargar configuraciones
source ./configs.sh

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "=== Limpiando todo el entorno ==="

# Pedir confirmación
echo -e "${RED}ADVERTENCIA${NC}: Esta acción eliminará todo el clúster K3d y todos los recursos."
read -p "¿Estás seguro de que deseas continuar? (s/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo "Operación cancelada."
    exit 0
fi

# Eliminar la aplicación de Argo CD
echo -e "${BLUE}[1/5]${NC} Eliminando aplicación de Argo CD..."
if kubectl get application $APP_NAME -n $ARGOCD_NAMESPACE &> /dev/null; then
    kubectl delete application $APP_NAME -n $ARGOCD_NAMESPACE
    echo -e "  ${GREEN}✓${NC} Aplicación eliminada."
else
    echo -e "  ${YELLOW}!${NC} La aplicación no existía."
fi

# Eliminar aplicaciones del namespace de desarrollo
echo -e "${BLUE}[2/5]${NC} Eliminando recursos del namespace $DEV_NAMESPACE..."
if kubectl get namespace $DEV_NAMESPACE &> /dev/null; then
    kubectl delete all --all -n $DEV_NAMESPACE
    echo -e "  ${GREEN}✓${NC} Recursos eliminados."
else
    echo -e "  ${YELLOW}!${NC} El namespace $DEV_NAMESPACE no existía."
fi

# Eliminar Argo CD
echo -e "${BLUE}[3/5]${NC} Eliminando Argo CD..."
if kubectl get namespace $ARGOCD_NAMESPACE &> /dev/null; then
    kubectl delete -n $ARGOCD_NAMESPACE -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    echo -e "  ${GREEN}✓${NC} Argo CD eliminado."
else
    echo -e "  ${YELLOW}!${NC} El namespace $ARGOCD_NAMESPACE no existía."
fi

# Eliminar las imágenes Docker locales
echo -e "${BLUE}[4/5]${NC} Eliminando imágenes Docker locales..."
if docker images | grep -q $IMAGE_NAME; then
    docker rmi $IMAGE_NAME:$IMAGE_TAG_V1 $IMAGE_NAME:$IMAGE_TAG_V2 2>/dev/null
    echo -e "  ${GREEN}✓${NC} Imágenes eliminadas."
else
    echo -e "  ${YELLOW}!${NC} No había imágenes que eliminar."
fi

# Eliminar el clúster K3d
echo -e "${BLUE}[5/5]${NC} Eliminando clúster K3d..."
if k3d cluster list | grep -q "$K3D_CLUSTER_NAME"; then
    k3d cluster delete $K3D_CLUSTER_NAME
    echo -e "  ${GREEN}✓${NC} Clúster $K3D_CLUSTER_NAME eliminado."
else
    echo -e "  ${YELLOW}!${NC} El clúster no existía."
fi

# Eliminar archivos temporales
echo -e "${BLUE}[Extra]${NC} Eliminando archivos temporales..."
rm -f .argocd_password argocd-app*.yaml 2>/dev/null
echo -e "  ${GREEN}✓${NC} Archivos temporales eliminados."

echo ""
echo -e "${GREEN}=== Limpieza completada ===${NC}"
echo "Todo el entorno ha sido eliminado. Para volver a instalarlo, ejecuta:"
echo "bash ./setup.sh"