# Makefile para gestión de clúster K3s con Vagrant
# Autor: ddel-bla

# Variables
MASTER_NODE = ddel-blaS
WORKER_NODE = ddel-blaSW
SCRIPTS_DIR = scripts

# Colores para output
GREEN = \033[0;32m
YELLOW = \033[0;33m
RED = \033[0;31m
RESET = \033[0m

.PHONY: all up start stop restart destroy status clean check-master check-worker connect-master connect-worker deploy-app help


# Ajustar la variable para usar Vagrant desde Windows
VAGRANT = "/mnt/c/Program Files/Vagrant/bin/vagrant.exe"

# Target por defecto
all: up

# Levantar el clúster completo
up:
	@echo "$(GREEN)Iniciando el clúster K3s...$(RESET)"
	@mkdir -p $(SCRIPTS_DIR) 2>/dev/null || true
	@$(VAGRANT) up

# Iniciar las máquinas virtuales (si ya están creadas)
start:
	@echo "$(GREEN)Iniciando las máquinas virtuales...$(RESET)"
	@$(VAGRANT) up --no-provision

# Detener el clúster sin destruirlo
stop:
	@echo "$(YELLOW)Deteniendo el clúster K3s...$(RESET)"
	@$(VAGRANT) halt

# Reiniciar el clúster
restart: stop start
	@echo "$(GREEN)Clúster K3s reiniciado$(RESET)"

# Destruir el clúster por completo
destroy:
	@echo "$(RED)Destruyendo el clúster K3s...$(RESET)"
	@$(VAGRANT) destroy -f
	@rm -f .vagrant/machines/*/virtualbox/action_provision

# Verificar el estado de las máquinas virtuales
status:
	@echo "$(YELLOW)Estado del clúster K3s:$(RESET)"
	@$(VAGRANT) status

# Limpieza completa del proyecto
clean: destroy
	@echo "$(RED)Limpiando archivos temporales...$(RESET)"
	@rm -rf .vagrant/

# Verificar que el nodo master está funcionando correctamente
check-master:
	@echo "$(YELLOW)Verificando estado del nodo master...$(RESET)"
	@$(VAGRANT) ssh $(MASTER_NODE) -c "sudo kubectl get nodes -o wide"

# Verificar que el nodo worker está funcionando correctamente
check-worker:
	@echo "$(YELLOW)Verificando estado del nodo worker...$(RESET)"
	@$(VAGRANT) ssh $(MASTER_NODE) -c "sudo kubectl get node $(WORKER_NODE) -o wide"

# Conectarse al nodo master por SSH
connect-master:
	@echo "$(GREEN)Conectando al nodo master...$(RESET)"
	@$(VAGRANT) ssh $(MASTER_NODE)

# Conectarse al nodo worker por SSH
connect-worker:
	@echo "$(GREEN)Conectando al nodo worker...$(RESET)"
	@$(VAGRANT) ssh $(WORKER_NODE)

# Desplegar una aplicación de ejemplo (servidor web nginx)
deploy-app:
	@echo "$(GREEN)Desplegando aplicación de ejemplo...$(RESET)"
	@$(VAGRANT) ssh $(MASTER_NODE) -c "sudo kubectl create deployment nginx --image=nginx"
	@$(VAGRANT) ssh $(MASTER_NODE) -c "sudo kubectl scale deployment nginx --replicas=2"
	@$(VAGRANT) ssh $(MASTER_NODE) -c "sudo kubectl expose deployment nginx --port=80 --type=NodePort"
	@echo "$(GREEN)Aplicación desplegada. Verificando estado:$(RESET)"
	@$(VAGRANT) ssh $(MASTER_NODE) -c "sudo kubectl get pods -o wide"
	@$(VAGRANT) ssh $(MASTER_NODE) -c "sudo kubectl get svc nginx -o wide"

# Mostrar información de ayuda
help:
	@echo "$(GREEN)Makefile para gestión de clúster K3s con Vagrant$(RESET)"
	@echo ""
	@echo "Targets disponibles:"
	@echo "  $(YELLOW)all$(RESET)            - Alias de 'up', crea e inicia el clúster"
	@echo "  $(YELLOW)up$(RESET)             - Crea e inicia el clúster K3s completo"
	@echo "  $(YELLOW)start$(RESET)          - Inicia las máquinas virtuales sin hacer provision"
	@echo "  $(YELLOW)stop$(RESET)           - Detiene las máquinas virtuales"
	@echo "  $(YELLOW)restart$(RESET)        - Reinicia las máquinas virtuales"
	@echo "  $(YELLOW)destroy$(RESET)        - Destruye completamente el clúster"
	@echo "  $(YELLOW)status$(RESET)         - Muestra el estado actual de las máquinas virtuales"
	@echo "  $(YELLOW)clean$(RESET)          - Elimina todas las máquinas y archivos temporales"
	@echo "  $(YELLOW)check-master$(RESET)   - Verifica el estado del nodo master"
	@echo "  $(YELLOW)check-worker$(RESET)   - Verifica el estado del nodo worker"
	@echo "  $(YELLOW)connect-master$(RESET) - Conecta por SSH al nodo master"
	@echo "  $(YELLOW)connect-worker$(RESET) - Conecta por SSH al nodo worker"
	@echo "  $(YELLOW)deploy-app$(RESET)     - Despliega una aplicación de ejemplo (nginx)"
	@echo "  $(YELLOW)help$(RESET)           - Muestra esta ayuda"