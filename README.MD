# Inception-of-Things (IoT)

Este proyecto consiste en una serie de ejercicios relacionados con la administración de sistemas, enfocados en aprender y utilizar K3s y K3d con Vagrant y Docker.

## Estructura del Proyecto

El proyecto está dividido en 3 partes obligatorias y una parte bonus opcional:

```
./
├── p1/            # K3s y Vagrant
├── p2/            # K3s y aplicaciones
├── p3/            # K3d y Argo CD
└── bonus/         # GitLab (opcional)
```

## Parte 1: K3s y Vagrant

Configuración de un cluster K3s básico usando Vagrant.

### Requisitos:
- 2 máquinas virtuales con recursos mínimos (1 CPU, 512MB-1024MB RAM)
- Máquinas con IPs dedicadas: 192.168.56.110 (Server) y 192.168.56.111 (ServerWorker)
- Acceso SSH sin contraseña entre las máquinas
- K3s en modo controlador en el servidor y modo agente en el worker
- Kubectl instalado y configurado

## Parte 2: K3s y tres aplicaciones simples

Implementación de aplicaciones web en un clúster K3s con enrutamiento basado en host.

### Requisitos:
- 1 máquina virtual con K3s en modo servidor
- 3 aplicaciones web funcionando en el clúster
- Enrutamiento basado en host:
  - app1.com → muestra app1
  - app2.com → muestra app2
  - Cualquier otro host → muestra app3 (por defecto)
- La app2 debe tener 3 réplicas

## Parte 3: K3d y Argo CD

Configuración de un pipeline de CI/CD usando K3d, Docker y Argo CD.

### Requisitos:
- Instalar K3d y sus dependencias (Docker, etc.)
- Crear dos namespaces: uno para Argo CD y otro llamado "dev" para aplicaciones
- Repositorio público en GitHub (debe incluir el login de un miembro del equipo)
- Desplegar una aplicación con dos versiones diferentes (v1 y v2)
- Configurar Argo CD para despliegue automático desde GitHub
- Demostrar la actualización de versión a través de cambios en GitHub

## Bonus: GitLab

Integración de GitLab en el entorno K3d.

### Requisitos:
- Instalar y configurar GitLab localmente
- Configurar GitLab para trabajar con el clúster K3d
- Crear un namespace dedicado "gitlab"
- Migrar la infraestructura de CI/CD de la Parte 3 para que funcione con GitLab local

## Instrucciones de Instalación

1. Clonar este repositorio
2. Navegar a la carpeta de la parte que desea implementar
3. Seguir las instrucciones específicas en cada directorio

### Parte 1
```bash
cd p1
vagrant up
```

### Parte 2
```bash
cd p2
vagrant up
```

### Parte 3
```bash
cd p3
./scripts/install.sh
```

## Verificación

Cada parte incluye instrucciones específicas para verificar su funcionamiento correcto. Consulte los archivos README.md en cada directorio para más detalles.

## Tecnologías Utilizadas

- Vagrant
- VirtualBox
- K3s (Kubernetes ligero)
- K3d (K3s en Docker)
- Docker
- Argo CD
- Git/GitHub
- GitLab (para el bonus)