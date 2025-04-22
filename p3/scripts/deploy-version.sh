#!/bin/bash
#
# Script para desplegar versiones específicas de la aplicación
# Inception-of-Things - Parte 3
#

# Cargar configuraciones
source ./configs.sh

# Verificar que se haya proporcionado un número de versión
if [ "$#" -ne 1 ]; then
    echo "Uso: $0 <numero_version>"
    echo "Ejemplo: $0 1"
    exit 1
fi

VERSION=$1

# Directorio del repositorio
REPO_DIR="./gitops-repo"

echo "=== Desplegando versión $VERSION de la aplicación ==="

# Verificar que el repositorio esté clonado
if [ ! -d "$REPO_DIR" ]; then
    echo "Error: No se encontró el directorio del repositorio ($REPO_DIR)"
    echo "Ejecuta primero: ./scripts/init-repo.sh"
    exit 1
fi

# Cambiar al directorio del repositorio
cd "$REPO_DIR" || exit 1

# Asegurarse de que estamos en la rama principal y actualizada
git checkout $GIT_BRANCH
git pull

# Configurar la aplicación para usar la versión específica
if [ "$VERSION" == "1" ]; then
    echo "Configurando Argo CD para usar la versión 1..."
    # Actualizar la aplicación en Argo CD para usar la ruta v1
    argocd app set $APP_NAME --path p3/kustomize/overlays/v1
    VERSION_MSG="Despliegue de versión 1"
elif [ "$VERSION" == "2" ]; then
    echo "Configurando Argo CD para usar la versión 2..."
    # Actualizar la aplicación en Argo CD para usar la ruta v2
    argocd app set $APP_NAME --path p3/kustomize/overlays/v2
    VERSION_MSG="Despliegue de versión 2"
else
    echo "Error: Versión no soportada. Use 1 o 2."
    exit 1
fi

# Sincronizar la aplicación
argocd app sync $APP_NAME

echo "=== Despliegue iniciado ==="
echo "La versión $VERSION está siendo desplegada"
echo "Puedes verificar el estado con: kubectl get pods -n $APP_NAMESPACE"
echo ""
echo "Para ver la aplicación, visita: $APP_URL"	