#!/bin/bash
#
# Script para desplegar versiones específicas de la aplicación
# Inception-of-Things - Parte 3
#

# Verificar que se haya proporcionado un número de versión
if [ "$#" -ne 1 ]; then
    echo "Uso: $0 <numero_version>"
    echo "Ejemplo: $0 1"
    exit 1
fi

VERSION=$1

# Directorio donde se encuentra el repositorio clonado
REPO_DIR="./gitops-repo"
YAML_PATH="$REPO_DIR/p3/kubernetes/base/deployment.yaml"

echo "=== Desplegando versión $VERSION de la aplicación ==="

# Verificar que el repositorio esté clonado
if [ ! -d "$REPO_DIR" ]; then
    echo "Error: No se encontró el directorio del repositorio ($REPO_DIR)"
    echo "Ejecuta primero: ./scripts/init-repo.sh"
    exit 1
fi

# Verificar que existe el archivo deployment.yaml
if [ ! -f "$YAML_PATH" ]; then
    echo "Error: No se encontró el archivo deployment.yaml en $YAML_PATH"
    echo "Verifica la estructura del repositorio."
    exit 1
fi

# Cambiar al directorio del repositorio
cd "$REPO_DIR" || exit 1

# Asegurarse de que estamos en la rama principal y actualizada
git checkout main
git pull

# Actualizar el archivo deployment.yaml para usar la versión específica
if [ "$VERSION" == "1" ]; then
    echo "Configurando para usar la versión 1..."
    # Modificar el archivo para usar la imagen v1
    sed -i 's|image: webapp:v[0-9]|image: webapp:v1|g' "p3/kubernetes/base/deployment.yaml"
    VERSION_MSG="Despliegue de versión 1"
elif [ "$VERSION" == "2" ]; then
    echo "Configurando para usar la versión 2..."
    # Modificar el archivo para usar la imagen v2
    sed -i 's|image: webapp:v[0-9]|image: webapp:v2|g' "p3/kubernetes/base/deployment.yaml"
    VERSION_MSG="Despliegue de versión 2"
else
    echo "Error: Versión no soportada. Use 1 o 2."
    exit 1
fi

# Confirmar los cambios
git add "p3/kubernetes/base/deployment.yaml"
git commit -m "$VERSION_MSG"

# Enviar los cambios al repositorio remoto
echo "Enviando cambios al repositorio remoto..."
git push

echo "=== Despliegue iniciado ==="
echo "Argo CD detectará los cambios y desplegará automáticamente la versión $VERSION"
echo "Puedes verificar el estado con: kubectl get pods -n dev"
echo ""
echo "Para ver la aplicación, visita: http://localhost:8080"
echo "Para ver Argo CD, visita: http://localhost:8080 (usando el namespace argocd)"