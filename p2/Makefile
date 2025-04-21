# Variables
SERVER_NODE = ddel-blaS
SCRIPTS_DIR = scripts
MANIFESTS_DIR = manifests

# Usar vagrant directamente (cambiar con WSL)
VAGRANT = vagrant

.PHONY: all up start stop restart destroy status clean apply-manifests check connect-server debug-ingress curl help

# Target por defecto
all: up

# Levantar el servidor
up:
	@echo "Iniciando el servidor K3s..."
	@if not exist $(SCRIPTS_DIR) mkdir $(SCRIPTS_DIR)
	@if not exist $(MANIFESTS_DIR) mkdir $(MANIFESTS_DIR)
	$(VAGRANT) up

# Aplicar los manifiestos de Kubernetes
apply-manifests:
	@echo "Aplicando manifiestos de Kubernetes..."
	$(VAGRANT) ssh $(SERVER_NODE) -c "bash /vagrant/scripts/apply-manifests.sh"

# Iniciar la máquina virtual (si ya está creada)
start:
	@echo "Iniciando la máquina virtual..."
	$(VAGRANT) up --no-provision

# Detener el servidor sin destruirlo
stop:
	@echo "Deteniendo el servidor K3s..."
	$(VAGRANT) halt

# Reiniciar el servidor
restart: stop start
	@echo "Servidor K3s reiniciado"

# Destruir el servidor por completo
destroy: 
	@echo "Destruyendo el servidor K3s..."
	$(VAGRANT) destroy -f
	@if exist .vagrant\machines\*\virtualbox\action_provision del /F .vagrant\machines\*\virtualbox\action_provision

# Verificar el estado de la máquina virtual
status:
	@echo "Estado del servidor K3s:"
	$(VAGRANT) status

# Limpiar archivos temporales
clean: destroy
	@echo "Limpiando archivos temporales..."
	@if exist .vagrant rmdir /S /Q .vagrant
	@if exist kubeconfig.yaml del /F kubeconfig.yaml
	@if exist ddel-blaS_env.sh del /F ddel-blaS_env.sh

# Verificación completa del servidor
check:
	@echo "=== Verificando estado de los nodos ==="
	$(VAGRANT) ssh $(SERVER_NODE) -c "sudo kubectl get nodes -o wide"
	@echo ""
	@echo "=== Verificando pods en ejecución ==="
	$(VAGRANT) ssh $(SERVER_NODE) -c "sudo kubectl get pods -o wide"
	@echo ""
	@echo "=== Verificando servicios ==="
	$(VAGRANT) ssh $(SERVER_NODE) -c "sudo kubectl get services -o wide"
	@echo ""
	@echo "=== Verificando configuración de Ingress ==="
	$(VAGRANT) ssh $(SERVER_NODE) -c "sudo kubectl get ingress -o wide"

# Conectarse al servidor por SSH
connect-server:
	@echo "Conectando al servidor..."
	$(VAGRANT) ssh $(SERVER_NODE)

# Depurar la configuración de Ingress
debug-ingress:
	@echo "Depurando configuración de Ingress..."
	$(VAGRANT) ssh $(SERVER_NODE) -c "sudo kubectl describe ingress app-ingress"
	@echo ""
	@echo "=== Verificando pods de Traefik ==="
	$(VAGRANT) ssh $(SERVER_NODE) -c "sudo kubectl get pods -n kube-system | grep traefik"

# Probar todas las aplicaciones con curl
curl:
	@echo "=== Probando app1.com ==="
	$(VAGRANT) ssh $(SERVER_NODE) -c "curl -H 'Host: app1.com' http://localhost"
	@echo ""
	@echo "=== Probando app2.com ==="
	$(VAGRANT) ssh $(SERVER_NODE) -c "curl -H 'Host: app2.com' http://localhost"
	@echo ""
	@echo "=== Probando aplicación default con host personalizado ==="
	$(VAGRANT) ssh $(SERVER_NODE) -c "curl -H 'Host: cualquier-cosa.com' http://localhost"
	@echo ""
	@echo "=== Probando aplicación default sin host específico ==="
	$(VAGRANT) ssh $(SERVER_NODE) -c "curl http://localhost"
	curl -H 'Host: app1.com' 192.168.56.110"

# Mostrar información de ayuda
help:
	@echo "Makefile para gestion de servidor K3s con Vagrant"
	@echo ""
	@echo "Targets disponibles:"
	@echo "  all             - Alias de 'up', crea e inicia el servidor"
	@echo "  up              - Crea e inicia el servidor K3s completo"
	@echo "  apply-manifests - Aplica los manifiestos de Kubernetes"
	@echo "  start           - Inicia la máquina virtual sin hacer provision"
	@echo "  stop            - Detiene la máquina virtual"
	@echo "  restart         - Reinicia la máquina virtual"
	@echo "  status          - Muestra el estado actual de la máquina virtual"
	@echo "  check           - Verifica el estado de los componentes"
	@echo "  connect-server  - Conecta por SSH al servidor"
	@echo "  debug-ingress   - Muestra información detallada del Ingress"
	@echo "  curl            - Prueba todas las aplicaciones usando curl"
	@echo "  destroy         - Destruye completamente el servidor"
	@echo "  clean           - Elimina la máquina y archivos temporales"
	@echo "  help            - Muestra esta ayuda"