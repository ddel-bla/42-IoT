#!/bin/bash
#
# Script principal para configurar todo el entorno
# Inception-of-Things - Parte 3
#

echo "=== Configurando entorno completo para IoT Parte 3 ==="

# Cargar configuraciones
source ./configs.sh

# Verificar requisitos previos
bash ./scripts/check-prereqs.sh
if [ $? -ne 0 ]; then
    echo "Faltan requisitos previos. Por favor, resuelve los problemas antes de continuar."
    exit 1
fi

# Configurar K3d
echo "Configurando K3d y el clúster..."
bash ./scripts/bootstrap_k3d.sh

# Configurar Argo CD
echo "Configurando Argo CD..."
bash ./scripts/bootstrap_argocd.sh

# Construir imágenes Docker
echo "Construyendo imágenes Docker..."
bash ./scripts/build-images.sh

# Inicializar repositorio Git
echo "Inicializando repositorio Git..."
bash ./scripts/init-repo.sh

# Configurar aplicación en Argo CD
echo "Configurando aplicación en Argo CD..."
bash ./scripts/setup-argocd.sh

echo "=== Configuración completada ==="
echo "Puedes acceder a:"
echo "- Aplicación: $APP_URL"
echo "- Argo CD: $APP_URL/argocd"