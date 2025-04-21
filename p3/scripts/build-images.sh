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

# Verificar que el directorio docker existe
if [ ! -d "docker" ]; then
    echo "Error: No se encuentra el directorio 'docker'."
    echo "Verifica que estás en el directorio p3 y que el directorio 'docker' existe."
    exit 1
fi

# Verificar que las subcarpetas existen
if [ ! -d "docker/v1" ] || [ ! -d "docker/v2" ]; then
    echo "Error: Faltan los directorios 'docker/v1' o 'docker/v2'."
    echo "Estructura esperada:"
    echo "docker/"
    echo "├── v1/"
    echo "│   ├── Dockerfile"
    echo "│   └── index.html"
    echo "└── v2/"
    echo "    ├── Dockerfile"
    echo "    └── index.html"
    exit 1
fi

# Construir imagen v1
echo "Construyendo imagen webapp:v1..."
cd docker/v1 || exit 1
docker build -t webapp:v1 .
if [ $? -ne 0 ]; then
    echo "Error al construir imagen webapp:v1"
    exit 1
fi
cd ../..

# Construir imagen v2
echo "Construyendo imagen webapp:v2..."
cd docker/v2 || exit 1
docker build -t webapp:v2 .
if [ $? -ne 0 ]; then
    echo "Error al construir imagen webapp:v2"
    exit 1
fi
cd ../..

# Verificar que el clúster K3d existe
if ! k3d cluster list | grep -q "argocd-cluster"; then
    echo "Error: No se encontró el clúster K3d 'argocd-cluster'."
    echo "Crea primero el clúster con: make install"
    exit 1
fi

# Cargar las imágenes en el registro local de K3d
echo "Cargando imágenes en el registro local de K3d..."
k3d image import webapp:v1 webapp:v2 -c argocd-cluster

echo "=== Imágenes construidas y cargadas correctamente ==="
echo "Imágenes disponibles:"
echo "  - webapp:v1"
echo "  - webapp:v2"