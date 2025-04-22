#!/bin/bash
#
# Script principal para configurar todo el entorno
# Inception-of-Things - Parte 3
#

# Cargar configuraciones
source ./scripts/configs.sh

# Colores para mensajes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}====================================${NC}"
echo -e "${BLUE}     Inception of Things - P3      ${NC}"
echo -e "${BLUE}====================================${NC}"

# Verificar requisitos previos
echo -e "${YELLOW}[1/6]${NC} Verificando requisitos previos..."
if ! command -v docker &> /dev/null; then
    echo "Error: Docker no está instalado. Por favor, instala Docker antes de continuar."
    exit 1
fi

if ! docker info &> /dev/null; then
    echo "Error: Docker no está en ejecución. Por favor, inicia Docker antes de continuar."
    exit 1
fi

echo -e "${GREEN}✓${NC} Docker está instalado y en ejecución."

# Configurar K3d
echo -e "${YELLOW}[2/6]${NC} Configurando K3d..."
bash ./scripts/bootstrap_k3d.sh
if [ $? -ne 0 ]; then
    echo "Error al configurar K3d."
    exit 1
fi

# Configurar Argo CD
echo -e "${YELLOW}[3/6]${NC} Instalando y configurando Argo CD..."
bash ./scripts/bootstrap_argocd.sh
if [ $? -ne 0 ]; then
    echo "Error al configurar Argo CD."
    exit 1
fi

# Construir imágenes Docker
echo -e "${YELLOW}[4/6]${NC} Construyendo imágenes Docker..."
bash ./scripts/build-images.sh
if [ $? -ne 0 ]; then
    echo "Error al construir imágenes Docker."
    exit 1
fi

# Aplicar la configuración de Kustomize
echo -e "${YELLOW}[5/6]${NC} Configurando la aplicación en Argo CD..."
bash ./scripts/setup-app.sh
if [ $? -ne 0 ]; then
    echo "Error al configurar la aplicación."
    exit 1
fi

# Verificar el entorno
echo -e "${YELLOW}[6/6]${NC} Verificando la instalación..."
bash ./scripts/check.sh
if [ $? -ne 0 ]; then
    echo "Error al verificar la instalación."
    exit 1
fi

echo -e "${GREEN}====================================${NC}"
echo -e "${GREEN}       Instalación completada       ${NC}"
echo -e "${GREEN}====================================${NC}"
echo ""
echo -e "Para acceder a la aplicación: ${BLUE}$APP_URL${NC}"
echo -e "Para acceder a Argo CD: ${BLUE}$ARGOCD_SERVER_URL${NC}"
echo -e "Usuario Argo CD: ${BLUE}admin${NC}"
echo -e "Contraseña Argo CD: ${BLUE}$(cat .argocd_password 2>/dev/null || echo 'Ver en archivo .argocd_password')${NC}"
echo ""
echo -e "Para cambiar a la versión v1: ${YELLOW}bash ./scripts/deploy-version.sh 1${NC}"
echo -e "Para cambiar a la versión v2: ${YELLOW}bash ./scripts/deploy-version.sh 2${NC}"
echo ""
echo -e "Para verificar el estado: ${YELLOW}bash ./scripts/check.sh${NC}"
echo -e "Para limpiar todo: ${YELLOW}bash ./scripts/cleanup.sh${NC}"