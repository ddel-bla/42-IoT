#!/bin/bash
#
# Script para construir y cargar las imágenes Docker
# Inception-of-Things - Parte 3
#

echo "=== Construyendo imágenes Docker ==="

# Verificar que Docker esté funcionando
if ! docker info &> /dev/null; then
    echo "Error: Docker no está funcionando. Asegúrate de que esté instalado y en ejecución."
    exit 1
fi

# Construir imagen v1
echo "Construyendo imagen webapp:v1..."
cd docker/v1 || exit 1
docker build -t webapp:v1 .
cd ../..

# Construir imagen v2
echo "Construyendo imagen webapp:v2..."
cd docker/v2 || exit 1
docker build -t webapp:v2 .
cd ../..

# Cargar las imágenes en el registro local de K3d
echo "Cargando imágenes en el registro local de K3d..."
k3d image import webapp:v1 webapp:v2 -c argocd-cluster

echo "=== Imágenes construidas y cargadas correctamente ==="
echo "Imágenes disponibles:"
echo "  - webapp:v1"
echo "  - webapp:v2"