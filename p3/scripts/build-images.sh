#!/bin/bash
#
# Script para construir y cargar las imágenes Docker
# Inception-of-Things - Parte 3
#

# Cargar configuraciones
source ./configs.sh

echo "=== Construyendo imágenes Docker ==="

# Verificar que Docker esté funcionando
if ! docker info &> /dev/null; then
    echo "Error: Docker no está funcionando. Asegúrate de que esté instalado y en ejecución."
    exit 1
fi

# Verificar que el directorio docker existe
if [ ! -d "docker" ]; then
    echo "Error: No se encuentra el directorio 'docker'."
    echo "Verificando la estructura actual del directorio:"
    ls -la
    exit 1
fi

# Verificar que las subcarpetas existen
if [ ! -d "docker/v1" ] || [ ! -d "docker/v2" ]; then
    echo "Error: Faltan los directorios 'docker/v1' o 'docker/v2'."
    echo "Contenido del directorio docker:"
    ls -la docker
    exit 1
fi

# Construir imagen v1
echo "Construyendo imagen $IMAGE_NAME:$IMAGE_TAG_V1..."
cd docker/v1 || exit 1
docker build -t $IMAGE_NAME:$IMAGE_TAG_V1 .
if [ $? -ne 0 ]; then
    echo "Error al construir imagen $IMAGE_NAME:$IMAGE_TAG_V1"
    exit 1
fi
cd ../..

# Construir imagen v2
echo "Construyendo imagen $IMAGE_NAME:$IMAGE_TAG_V2..."
cd docker/v2 || exit 1
docker build -t $IMAGE_NAME:$IMAGE_TAG_V2 .
if [ $? -ne 0 ]; then
    echo "Error al construir imagen $IMAGE_NAME:$IMAGE_TAG_V2"
    exit 1
fi
cd ../..

# Verificar que el clúster K3d existe
if ! k3d cluster list | grep -q "$K3D_CLUSTER_NAME"; then
    echo "Error: No se encontró el clúster K3d '$K3D_CLUSTER_NAME'."
    echo "Crea primero el clúster con: bash ./scripts/bootstrap_k3d.sh"
    exit 1
fi

# Cargar las imágenes en el registro local de K3d
echo "Cargando imágenes en el registro local de K3d..."
k3d image import $IMAGE_NAME:$IMAGE_TAG_V1 $IMAGE_NAME:$IMAGE_TAG_V2 -c $K3D_CLUSTER_NAME

if [ $? -ne 0 ]; then
    echo "Error al cargar las imágenes en el clúster K3d."
    exit 1
fi

echo "=== Imágenes construidas y cargadas correctamente ==="
echo "Imágenes disponibles:"
echo "  - $IMAGE_NAME:$IMAGE_TAG_V1"
echo "  - $IMAGE_NAME:$IMAGE_TAG_V2"