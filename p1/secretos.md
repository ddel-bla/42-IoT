# Gestión de Secretos en el Proyecto IoT

Este documento describe cómo se gestionan los secretos y la información sensible en el proyecto Inception-of-Things (IoT).

## Secretos en el proyecto

### Token de K3s

El token de K3s es el principal secreto que se maneja en este proyecto. Este token permite que el nodo worker se una al clúster K3s creado por el nodo master.

#### Cómo se genera y almacena

1. **Generación**: El token se genera automáticamente cuando K3s se inicia en el nodo master.
2. **Almacenamiento**: 
   - Se almacena en el archivo `/vagrant/token_env` con permisos restrictivos (600).
   - El archivo tiene formato de script shell para facilitar su carga en el nodo worker.

#### Medidas de seguridad

- **Permisos restrictivos**: El archivo token_env tiene permisos 600 (solo lectura/escritura para el propietario).
- **Detección robusta**: El nodo worker verifica tanto la existencia como el contenido del archivo antes de usarlo.
- **Limpieza automática**: El script `cleanup.sh` elimina de forma segura el token cuando ya no es necesario.

## Mejores prácticas implementadas

### 1. Principio de privilegios mínimos

- Los archivos sensibles solo tienen los permisos necesarios para su uso.
- El token solo se comparte a través del directorio /vagrant compartido, no se expone a la red.

### 2. Gestión del ciclo de vida de los secretos

- Los secretos se crean justo cuando son necesarios.
- Los secretos se eliminan de forma segura cuando ya no son necesarios mediante el comando `make clean-secrets`.

### 3. Verificación de integridad

- Antes de usar el token, el nodo worker verifica que:
  - El archivo exista
  - Contenga datos válidos
  - El token no esté vacío

## Comandos de seguridad

El Makefile incluye comandos específicos para gestionar la seguridad:

- `make secure-token`: Verifica y corrige los permisos del archivo de token.
- `make clean-secrets`: Elimina de forma segura todos los archivos sensibles.

## Recomendaciones para entornos de producción

Este proyecto está diseñado como entorno de desarrollo/aprendizaje. Para entornos de producción, se recomienda:

1. Usar herramientas de gestión de secretos como HashiCorp Vault o Kubernetes Secrets.
2. Implementar rotación periódica de tokens y credenciales.
3. Utilizar cifrado en reposo para todos los secretos almacenados.
4. Registrar auditorías de acceso a los secretos.
