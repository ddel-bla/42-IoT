#!/bin/bash
#
# Script para inicializar el repositorio Git para Argo CD
# Inception-of-Things - Parte 3
#

echo "=== Inicializando repositorio Git para Argo CD ==="

# Variables de configuración
REPO_URL="https://github.com/ddel-bla/42-IoT.git"
REPO_DIR="./gitops-repo"
KUBERNETES_DIR="$REPO_DIR/p3/kubernetes/base"
GITHUB_USER="ddel-bla"
GITHUB_EMAIL="ddel-bla@student.42.fr"  # Reemplazar con tu correo real si es diferente

# Verificar requisitos previos
if ! command -v git &> /dev/null; then
    echo "Error: Git no está instalado. Por favor, instálalo primero."
    exit 1
fi

# Verificar si el directorio ya existe
if [ -d "$REPO_DIR" ]; then
    echo "El directorio $REPO_DIR ya existe."
    read -p "¿Deseas eliminar el repositorio existente y crear uno nuevo? (s/n): " RESPUESTA
    if [[ "$RESPUESTA" =~ ^[Ss]$ ]]; then
        echo "Eliminando repositorio existente..."
        rm -rf "$REPO_DIR"
    else
        echo "Saliendo sin cambios."
        exit 0
    fi
fi

# Clonar el repositorio
echo "Clonando repositorio $REPO_URL..."
git clone "$REPO_URL" "$REPO_DIR"

if [ $? -ne 0 ]; then
    echo "Error al clonar el repositorio. ¿La URL es correcta y tienes permisos?"
    echo "En caso de error, puedes crear un nuevo repositorio local:"
    echo "mkdir -p $REPO_DIR"
    echo "cd $REPO_DIR"
    echo "git init"
    echo "git remote add origin $REPO_URL"
    exit 1
fi

# Configurar usuario Git si es necesario
cd "$REPO_DIR"
if ! git config user.name &> /dev/null || ! git config user.email &> /dev/null; then
    echo "Configurando Git user..."
    git config user.name "$GITHUB_USER"
    git config user.email "$GITHUB_EMAIL"
fi

# Crear la estructura de directorios para Kubernetes
echo "Creando estructura de directorios para Kubernetes..."
mkdir -p "$KUBERNETES_DIR"

# Copiar los manifiestos de Kubernetes al repositorio
echo "Copiando manifiestos de Kubernetes..."
cp -r ../kubernetes/*.yaml "$KUBERNETES_DIR/"

# Verificar los archivos copiados
if [ ! -f "$KUBERNETES_DIR/deployment.yaml" ] || \
   [ ! -f "$KUBERNETES_DIR/service.yaml" ] || \
   [ ! -f "$KUBERNETES_DIR/ingress.yaml" ]; then
    echo "Advertencia: Algunos archivos de manifiesto no se encontraron."
    echo "Asegúrate de que existan en el directorio ../kubernetes/"
    
    # Crear archivos básicos si no existen
    if [ ! -f "$KUBERNETES_DIR/deployment.yaml" ]; then
        echo "Creando deployment.yaml básico..."
        cat > "$KUBERNETES_DIR/deployment.yaml" <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
  labels:
    app: webapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: webapp
        image: webapp:v1
        ports:
        - containerPort: 80
EOF
    fi
    
    if [ ! -f "$KUBERNETES_DIR/service.yaml" ]; then
        echo "Creando service.yaml básico..."
        cat > "$KUBERNETES_DIR/service.yaml" <<EOF
apiVersion: v1
kind: Service
metadata:
  name: webapp-service
spec:
  selector:
    app: webapp
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF
    fi
    
    if [ ! -f "$KUBERNETES_DIR/ingress.yaml" ]; then
        echo "Creando ingress.yaml básico..."
        cat > "$KUBERNETES_DIR/ingress.yaml" <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: webapp-ingress
  annotations:
    kubernetes.io/ingress.class: "traefik"
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: webapp-service
            port:
              number: 80
EOF
    fi
fi

# Crear o actualizar el archivo kustomization.yaml
echo "Creando kustomization.yaml..."
cat > "$KUBERNETES_DIR/kustomization.yaml" <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- deployment.yaml
- service.yaml
- ingress.yaml

namespace: dev
EOF

# Verificar el estado del repositorio
echo "Estado del repositorio:"
git status

# Añadir archivos al control de versiones
echo "Añadiendo archivos al control de versiones..."
git add .

# Hacer el primer commit si hay cambios
if git diff-index --quiet HEAD --; then
    echo "No hay cambios para hacer commit."
else
    echo "Haciendo commit de los cambios iniciales..."
    git commit -m "Configuración inicial para Argo CD"
    
    # Preguntar si se desea hacer push
    read -p "¿Deseas hacer push de los cambios a GitHub? (s/n): " PUSH
    if [[ "$PUSH" =~ ^[Ss]$ ]]; then
        echo "Haciendo push a GitHub..."
        git push origin main
        if [ $? -ne 0 ]; then
            echo "Error al hacer push. Verifica tus credenciales y permisos."
            echo "Puedes hacer push manualmente después con: git push origin main"
        else
            echo "Push exitoso a GitHub."
        fi
    else
        echo "No se hizo push. Puedes hacerlo manualmente después con: git push origin main"
    fi
fi

echo "=== Inicialización del repositorio Git completada ==="
echo "Repositorio local: $REPO_DIR"
echo "URL remoto: $REPO_URL"
echo ""
echo "Puedes continuar con la configuración de Argo CD ejecutando:"
echo "  make setup  o  bash ./scripts/setup-argocd.sh"