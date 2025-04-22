#!/bin/bash
#
# Configuración centralizada para el proyecto
# Inception-of-Things - Parte 3
#

# Nombre del proyecto
export PROJECT_NAME="inception-of-things"

# Configuración de K3d
export K3D_CLUSTER_NAME="iot-cluster"

# Namespaces
export ARGOCD_NAMESPACE="argocd"
export DEV_NAMESPACE="dev"

# Configuración de la aplicación
export APP_NAME="webapp"
export APP_URL="http://localhost:8080"

# Configuración de Docker
export IMAGE_NAME="webapp"
export IMAGE_TAG_V1="v1"
export IMAGE_TAG_V2="v2"

# Configuración de GitHub
export GITHUB_USERNAME="ddel-bla"
export GITHUB_REPO="https://github.com/ddel-bla/42-IoT.git"
export GIT_BRANCH="main"
export GIT_PATH="p3/kustomize"

# No cambiar estas variables
export ARGOCD_PORT=8080
export ARGOCD_SERVER_URL="http://localhost:${ARGOCD_PORT}/argocd"