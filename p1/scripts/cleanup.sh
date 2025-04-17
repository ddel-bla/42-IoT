#!/bin/bash

# Script para limpiar archivos sensibles y temporales

echo "Limpiando archivos sensibles..."

# Eliminar archivos que contienen el token K3s
if [ -f /vagrant/token_env ]; then
  echo "Eliminando archivo token_env..."
  shred -u /vagrant/token_env
else
  echo "Archivo token_env no encontrado."
fi

# Opcional: Limpiar archivos kubeconfig que puedan contener tokens
if [ -f /vagrant/kubeconfig.yaml ]; then
  echo "Eliminando kubeconfig.yaml..."
  shred -u /vagrant/kubeconfig.yaml
else
  echo "Archivo kubeconfig.yaml no encontrado."
fi

echo "Limpieza completada."