# Variables
SCRIPTS_DIR = scripts
K3D_CLUSTER = argocd-cluster
APP_NAME = simple-app

.PHONY: all install setup start stop restart destroy status clean check push-v1 push-v2 help

# Target por defecto
all: install setup

# Instalar K3d y Argo CD
install:
	@echo "Instalando K3d y Argo CD..."
	@if [ ! -d "$(SCRIPTS_DIR)" ]; then mkdir -p $(SCRIPTS_DIR); fi
	@bash $(SCRIPTS_DIR)/install.sh

# Configurar Argo CD con el repositorio y aplicación
setup:
	@echo "Configurando Argo CD con el repositorio y aplicación..."
	@bash $(SCRIPTS_DIR)/setup-argocd.sh

# Iniciar el clúster K3d si ya está creado
start:
	@echo "Iniciando el clúster K3d..."
	@if k3d cluster list | grep -q $(K3D_CLUSTER); then \
		k3d cluster start $(K3D_CLUSTER); \
	else \
		echo "El clúster $(K3D_CLUSTER) no existe. Use 'make install' para crearlo."; \
		exit 1; \
	fi

# Detener el clúster K3d sin destruirlo
stop:
	@echo "Deteniendo el clúster K3d..."
	@if k3d cluster list | grep -q $(K3D_CLUSTER); then \
		k3d cluster stop $(K3D_CLUSTER); \
	else \
		echo "El clúster $(K3D_CLUSTER) no existe."; \
		exit 1; \
	fi

# Reiniciar el clúster K3d
restart: stop start
	@echo "Clúster K3d reiniciado"

# Destruir el clúster K3d por completo
destroy: 
	@echo "Destruyendo el clúster K3d..."
	@if k3d cluster list | grep -q $(K3D_CLUSTER); then \
		k3d cluster delete $(K3D_CLUSTER); \
	else \
		echo "El clúster $(K3D_CLUSTER) no existe."; \
	fi

# Verificar el estado del clúster K3d
status:
	@echo "Estado del clúster K3d:"
	@k3d cluster list | grep $(K3D_CLUSTER) || echo "El clúster $(K3D_CLUSTER) no existe."
	@echo ""
	@echo "Estado de Argo CD:"
	@kubectl get pods -n argocd 2>/dev/null || echo "No se puede acceder al clúster o Argo CD no está instalado."
	@echo ""
	@echo "Estado de la aplicación:"
	@kubectl get pods -n dev 2>/dev/null || echo "No se puede acceder al clúster o no hay pods en el namespace dev."

# Limpiar por completo (destruir clúster y eliminar archivos)
clean: destroy
	@echo "Limpieza completa..."

# Verificación completa del entorno
check:
	@echo "=== Verificando estado del clúster K3d ==="
	@k3d cluster list | grep $(K3D_CLUSTER) || echo "El clúster $(K3D_CLUSTER) no existe."
	@echo ""
	@echo "=== Verificando nodos de Kubernetes ==="
	@kubectl get nodes 2>/dev/null || echo "No se puede acceder al clúster."
	@echo ""
	@echo "=== Verificando namespaces ==="
	@kubectl get namespaces 2>/dev/null || echo "No se puede acceder al clúster."
	@echo ""
	@echo "=== Verificando pods de Argo CD ==="
	@kubectl get pods -n argocd 2>/dev/null || echo "No se puede acceder al clúster o Argo CD no está instalado."
	@echo ""
	@echo "=== Verificando aplicación en dev ==="
	@kubectl get all -n dev 2>/dev/null || echo "No se puede acceder al clúster o no hay recursos en el namespace dev."

# Desplegar versión 1 de la aplicación
push-v1:
	@echo "Desplegando versión 1 de la aplicación..."
	@bash $(SCRIPTS_DIR)/deploy-version.sh 1

# Desplegar versión 2 de la aplicación
push-v2:
	@echo "Desplegando versión 2 de la aplicación..."
	@bash $(SCRIPTS_DIR)/deploy-version.sh 2

# Mostrar información de ayuda
help:
	@echo "Makefile para gestión de K3d, Docker y Argo CD"
	@echo ""
	@echo "Targets disponibles:"
	@echo "  all         - Instala y configura todo el entorno (K3d y Argo CD)"
	@echo "  install     - Instala K3d, crea el clúster e instala Argo CD"
	@echo "  setup       - Configura Argo CD con el repositorio y aplicación"
	@echo "  start       - Inicia el clúster K3d si está detenido"
	@echo "  stop        - Detiene el clúster K3d sin destruirlo"
	@echo "  restart     - Reinicia el clúster K3d"
	@echo "  status      - Muestra el estado actual del clúster y aplicaciones"
	@echo "  check       - Verifica el estado completo del entorno"
	@echo "  push-v1     - Despliega la versión 1 de la aplicación"
	@echo "  push-v2     - Despliega la versión 2 de la aplicación"
	@echo "  destroy     - Destruye completamente el clúster K3d"
	@echo "  clean       - Elimina todo (clúster y archivos temporales)"
	@echo "  help        - Muestra esta ayuda"