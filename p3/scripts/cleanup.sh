#!/bin/bash
#
# Script para limpiar todos los recursos creados
# Inception-of-Things - Parte 3
#

echo "=== Iniciando limpieza del entorno ==="

# Eliminar el clúster K3d
if k3d cluster list | grep -q "argocd-cluster"; then
    echo "Eliminando clúster K3d..."
    k3d cluster delete argocd-cluster
else
    echo "No se encontró el clúster K3d para eliminar."
fi

# Eliminar imágenes Docker si existen
if docker images | grep -q "webapp"; then
    echo "Eliminando imágenes Docker..."
    docker rmi webapp:v1 webapp:v2 2>/dev/null || true
fi

# Eliminar archivos temporales
echo "Eliminando archivos temporales..."
rm -f .argocd_password 2>/dev/null || true

echo "=== Limpieza completada ==="
echo "Todos los recursos han sido eliminados."
echo ""
echo "Para recrear el entorno, ejecuta:"
echo "  make install"