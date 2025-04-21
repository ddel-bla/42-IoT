#!/bin/bash
#
# Script para verificar requisitos previos
# Inception-of-Things - Parte 3
#

echo "=== Verificando requisitos previos ==="

# Array para almacenar problemas encontrados
ISSUES=()

# Verificar Docker
echo -n "Verificando Docker: "
if command -v docker &> /dev/null && docker info &> /dev/null; then
    echo "✅ OK"
    docker --version
else
    echo "❌ NO INSTALADO"
    ISSUES+=("Docker no está instalado o no se ejecuta correctamente.")
fi

# Verificar Git
echo -n "Verificando Git: "
if command -v git &> /dev/null; then
    echo "✅ OK"
    git --version
else
    echo "❌ NO INSTALADO"
    ISSUES+=("Git no está instalado.")
fi

# Verificar K3d (opcional, se instalará si falta)
echo -n "Verificando K3d: "
if command -v k3d &> /dev/null; then
    echo "✅ OK"
    k3d --version
else
    echo "⚠️  NO INSTALADO (se instalará automáticamente)"
fi

# Verificar kubectl (opcional, se instalará si falta)
echo -n "Verificando kubectl: "
if command -v kubectl &> /dev/null; then
    echo "✅ OK"
    kubectl version --client
else
    echo "⚠️  NO INSTALADO (se instalará automáticamente)"
fi

# Verificar memoria disponible
echo -n "Verificando memoria disponible: "
MEM_AVAILABLE=$(free -m | awk '/^Mem:/{print $7}')
if [ "$MEM_AVAILABLE" -lt 2048 ]; then
    echo "⚠️  ADVERTENCIA: Solo hay $MEM_AVAILABLE MB disponibles"
    ISSUES+=("Memoria disponible baja: $MEM_AVAILABLE MB. Se recomiendan al menos 2048 MB.")
else
    echo "✅ OK ($MEM_AVAILABLE MB)"
fi

# Verificar espacio en disco
echo -n "Verificando espacio en disco: "
DISK_AVAILABLE=$(df -h . | awk 'NR==2 {print $4}')
DISK_AVAILABLE_MB=$(df -m . | awk 'NR==2 {print $4}')
if [ "$DISK_AVAILABLE_MB" -lt 5120 ]; then
    echo "⚠️  ADVERTENCIA: Solo hay $DISK_AVAILABLE disponibles"
    ISSUES+=("Espacio en disco bajo: $DISK_AVAILABLE. Se recomiendan al menos 5GB.")
else
    echo "✅ OK ($DISK_AVAILABLE)"
fi

# Verificar conexión a internet
echo -n "Verificando conexión a internet: "
if ping -c 1 google.com &> /dev/null || ping -c 1 github.com &> /dev/null; then
    echo "✅ OK"
else
    echo "❌ SIN CONEXIÓN"
    ISSUES+=("No hay conexión a Internet. Se requiere para descargar imágenes y herramientas.")
fi

# Mostrar resumen y recomendaciones
echo ""
echo "=== Resumen de verificación ==="
if [ ${#ISSUES[@]} -eq 0 ]; then
    echo "✅ Todos los requisitos previos están cumplidos."
    echo "Puede continuar con la instalación ejecutando: make install"
else
    echo "⚠️  Se encontraron algunos problemas:"
    for i in "${!ISSUES[@]}"; do
        echo "   $((i+1)). ${ISSUES[$i]}"
    done
    echo ""
    echo "Solucione estos problemas antes de continuar."
fi

exit ${#ISSUES[@]}