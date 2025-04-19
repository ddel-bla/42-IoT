#!/bin/bash
#
# Script para aplicar los manifiestos de Kubernetes
# Inception-of-Things - Parte 2
#

echo "=== Aplicando manifiestos de Kubernetes ==="

# Usar la variable de entorno KUBECONFIG para el usuario vagrant
export KUBECONFIG=/home/vagrant/.kube/config

# Esperar a que K3s esté completamente listo
echo "Esperando a que K3s esté listo..."
until kubectl get nodes | grep -q " Ready"; do
  sleep 5
  echo "Esperando a que el nodo esté listo..."
done

# Aplicar los manifiestos
echo "Aplicando manifiesto de app1..."
kubectl apply -f /vagrant/manifests/app1-deployment.yaml

echo "Aplicando manifiesto de app2 (con 3 réplicas)..."
kubectl apply -f /vagrant/manifests/app2-deployment.yaml

echo "Aplicando manifiesto de app3 (default)..."
kubectl apply -f /vagrant/manifests/app3-deployment.yaml

echo "Aplicando manifiesto de Ingress..."
kubectl apply -f /vagrant/manifests/ingress.yaml

echo "Esperando a que todos los pods estén listos..."
kubectl wait --for=condition=Ready pods --all --timeout=300s

echo "=== Aplicación de manifiestos completada ==="
echo "Puede acceder a las aplicaciones usando estos hosts:"
echo "  - app1.com"
echo "  - app2.com"
echo "  - Cualquier otro host mostrará app3 (default)"