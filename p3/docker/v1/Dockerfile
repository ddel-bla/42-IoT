FROM nginx:alpine

# Copiar el contenido del sitio web
COPY index.html /usr/share/nginx/html/index.html

# Exponer puerto 80
EXPOSE 80

# Comando por defecto para iniciar nginx
CMD ["nginx", "-g", "daemon off;"]