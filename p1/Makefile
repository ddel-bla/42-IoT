# Variables
MASTER_NODE = ddel-blaS
WORKER_NODE = ddel-blaSW
SCRIPTS_DIR = scripts

# Usar vagrant directamente (cambiar con WSL)
VAGRANT = vagrant

.PHONY: all up start stop restart destroy status clean clean-secrets secure-token check-master check-worker connect-master connect-worker deploy-app help

# Target por defecto
all: up

# Levantar el clúster completo
up:
	@echo "Iniciando el cluster K3s..."
	@if not exist $(SCRIPTS_DIR) mkdir $(SCRIPTS_DIR)
	$(VAGRANT) up

# Iniciar las máquinas virtuales (si ya están creadas)
start:
	@echo "Iniciando las maquinas virtuales..."
	$(VAGRANT) up --no-provision

# Detener el clúster sin destruirlo
stop:
	@echo "Deteniendo el cluster K3s..."
	$(VAGRANT) halt

# Reiniciar el clúster
restart: stop start
	@echo "Cluster K3s reiniciado"

# Destruir el clúster por completo
destroy: 
	@echo "Destruyendo el cluster K3s..."
	$(VAGRANT) destroy -f
	@if exist .vagrant\machines\*\virtualbox\action_provision del /F .vagrant\machines\*\virtualbox\action_provision

# Verificar el estado de las máquinas virtuales
status:
	@echo "Estado del cluster K3s:"
	$(VAGRANT) status

# Limpiar archivos sensibles
clean-secrets:
	@echo "Limpiando archivos sensibles..."
	@if exist token_env del /F token_env
	@if exist kubeconfig.yaml del /F kubeconfig.yaml
	@if exist ddel-blaS_env.sh del /F ddel-blaS_env.sh
	@if exist ddel-blaSW_env.sh del /F ddel-blaSW_env.sh
	@echo "Limpieza completada."

# Verificar permisos del token
secure-token:
	@echo "Verificando permisos del token..."
	$(VAGRANT) ssh $(MASTER_NODE) -c "if [ -f /vagrant/token_env ]; then chmod 600 /vagrant/token_env; echo 'Permisos corregidos.'; else echo 'Archivo token_env no encontrado.'; fi"

# Limpieza completa del proyecto
clean: destroy clean-secrets
	@echo "Limpiando archivos temporales..."
	@if exist .vagrant rmdir /S /Q .vagrant

# Verificación completa del clúster
check:
	@echo "=== Verificando estado de los nodos ==="
	$(VAGRANT) ssh $(MASTER_NODE) -c "sudo kubectl get nodes -o wide"
	@echo ""
	@echo "=== Verificando configuración de red del master ==="
	$(VAGRANT) ssh $(MASTER_NODE) -c "ip a | grep -A 2 192.168.56.110"
	@echo ""
	@echo "=== Verificando configuración de red del worker ==="
	$(VAGRANT) ssh $(WORKER_NODE) -c "ip a | grep -A 2 192.168.56.111"
	@echo ""
	@echo "=== Verificando conectividad entre nodos ==="
	$(VAGRANT) ssh $(MASTER_NODE) -c "ping -c 2 $(WORKER_NODE)"
	$(VAGRANT) ssh $(WORKER_NODE) -c "ping -c 2 $(MASTER_NODE)"
	@echo ""
	@echo "=== Verificando pods en ejecución ==="
	$(VAGRANT) ssh $(MASTER_NODE) -c "sudo kubectl get pods -o wide --all-namespaces"

# Conectarse al nodo master por SSH
connect-master:
	@echo "Conectando al nodo master..."
	$(VAGRANT) ssh $(MASTER_NODE)

# Conectarse al nodo worker por SSH
connect-worker:
	@echo "Conectando al nodo worker..."
	$(VAGRANT) ssh $(WORKER_NODE)

# Desplegar una aplicación de ejemplo (servidor web nginx)
deploy-app:
	@echo "Desplegando aplicacion de ejemplo..."
	$(VAGRANT) ssh $(MASTER_NODE) -c "sudo kubectl create deployment nginx --image=nginx"
	$(VAGRANT) ssh $(MASTER_NODE) -c "sudo kubectl scale deployment nginx --replicas=2"
	$(VAGRANT) ssh $(MASTER_NODE) -c "sudo kubectl expose deployment nginx --port=80 --type=NodePort"
	@echo "Aplicacion desplegada. Verificando estado:"
	$(VAGRANT) ssh $(MASTER_NODE) -c "sudo kubectl get pods -o wide"
	$(VAGRANT) ssh $(MASTER_NODE) -c "sudo kubectl get svc nginx -o wide"

# Mostrar información de ayuda
help:
	@echo "Makefile para gestion de cluster K3s con Vagrant"
	@echo ""
	@echo "Targets disponibles:"
	@echo "  all            - Alias de 'up', crea e inicia el cluster"
	@echo "  up             - Crea e inicia el cluster K3s completo"
	@echo "  start          - Inicia las maquinas virtuales sin hacer provision"
	@echo "  stop           - Detiene las maquinas virtuales"
	@echo "  restart        - Reinicia las maquinas virtuales"
	@echo "  status         - Muestra el estado actual de las maquinas virtuales"
	@echo "  check          - Verifica el subject"
	@echo "  connect-master - Conecta por SSH al nodo master"
	@echo "  connect-worker - Conecta por SSH al nodo worker"
	@echo "  deploy-app     - Despliega una aplicacion de ejemplo (nginx)"
	@echo "  destroy        - Destruye completamente el cluster"
	@echo "  clean          - Elimina todas las maquinas y archivos temporales"
	@echo "  help           - Muestra esta ayuda"