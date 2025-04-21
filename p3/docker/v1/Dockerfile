FROM nginx:alpine

# Copiar archivos de configuración personalizados si es necesario
# COPY nginx.conf /etc/nginx/nginx.conf

# Copiar el contenido del sitio web
COPY index.html /usr/share/nginx/html/index.html

# Exponer puerto 80
EXPOSE 80

# Comando por defecto para iniciar nginx
CMD ["nginx", "-g", "daemon off;"]