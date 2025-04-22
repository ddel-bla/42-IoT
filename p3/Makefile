# Variables
include configs.sh

.PHONY: all install setup start stop restart destroy status clean check deploy-v1 deploy-v2 help

# Target por defecto
all: install setup

# Instalar todo el entorno
install:
	@echo "Instalando todo el entorno..."
	bash ./scripts/setup.sh

# Configurar K3d y clúster
setup-k3d:
	@echo "Configurando K3d y creando el clúster..."
	bash ./scripts/bootstrap_k3d.sh

# Configurar Argo CD
setup-argocd:
	@echo "Instalando y configurando Argo CD..."
	bash ./scripts/bootstrap_argocd.sh

# Construir imágenes Docker
build-images:
	@echo "Construyendo imágenes Docker..."
	bash ./scripts/build-images.sh

# Inicializar repositorio Git
init-repo:
	@echo "Inicializando repositorio Git..."
	bash ./scripts/init-repo.sh

# Configurar la aplicación en Argo CD
setup-app:
	@echo "Configurando aplicación en Argo CD..."
	bash ./scripts/setup-argocd.sh

# Iniciar el clúster K3d si ya está creado
start:
	@echo "Iniciando el clúster K3d..."
	k3d cluster start $(K3D_CLUSTER_NAME)

# Detener el clúster K3d sin destruirlo
stop:
	@echo "Deteniendo el clúster K3d..."
	k3d cluster stop $(K3D_CLUSTER_NAME)

# Reiniciar el clúster K3d
restart: stop start
	@echo "Clúster K3d reiniciado"

# Destruir el clúster K3d por completo
destroy: 
	@echo "Destruyendo el clúster K3d..."
	k3d cluster delete $(K3D_CLUSTER_NAME)

# Verificar el estado del clúster K3d
status:
	@echo "Estado del clúster K3d:"
	k3d cluster list | grep $(K3D_CLUSTER_NAME)
	@echo ""
	@echo "Estado de Argo CD:"
	kubectl get pods -n $(ARGOCD_NAMESPACE)
	@echo ""
	@echo "Estado de la aplicación:"
	kubectl get pods -n $(APP_NAMESPACE)

# Limpiar por completo (destruir clúster y eliminar archivos)
clean: destroy
	@echo "Limpieza completa..."
	rm -f .argocd_password
	rm -rf gitops-repo

# Verificación completa del entorno
check:
	@echo "Ejecutando verificación completa..."
	bash ./scripts/check.sh

# Desplegar versión 1 de la aplicación
deploy-v1:
	@echo "Desplegando versión 1 de la aplicación..."
	bash ./scripts/deploy-version.sh 1

# Desplegar versión 2 de la aplicación
deploy-v2:
	@echo "Desplegando versión 2 de la aplicación..."
	bash ./scripts/deploy-version.sh 2

# Mostrar información de ayuda
help:
	@echo "Makefile para gestión de K3d, Docker y Argo CD"
	@echo ""
	@echo "Targets disponibles:"
	@echo "  all           - Instala y configura todo el entorno (K3d y Argo CD)"
	@echo "  install       - Ejecuta el script de instalación completa"
	@echo "  setup-k3d     - Configura K3d y crea el clúster"
	@echo "  setup-argocd  - Instala y configura Argo CD"
	@echo "  build-images  - Construye las imágenes Docker"
	@echo "  init-repo     - Inicializa el repositorio Git"
	@echo "  setup-app     - Configura la aplicación en Argo CD"
	@echo "  start         - Inicia el clúster K3d si está detenido"
	@echo "  stop          - Detiene el clúster K3d sin destruirlo"
	@echo "  restart       - Reinicia el clúster K3d"
	@echo "  status        - Muestra el estado actual del clúster y aplicaciones"
	@echo "  check         - Verifica el estado completo del entorno"
	@echo "  deploy-v1     - Despliega la versión 1 de la aplicación"
	@echo "  deploy-v2     - Despliega la versión 2 de la aplicación"
	@echo "  destroy       - Destruye completamente el clúster K3d"
	@echo "  clean         - Elimina todo (clúster y archivos temporales)"
	@echo "  help          - Muestra esta ayuda"