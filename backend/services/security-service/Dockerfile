# Base de Node.js
FROM node:16-alpine

# Crear directorio de trabajo
WORKDIR /app

# Copiar package.json y package-lock.json
COPY ./backend/services/security-service/package*.json ./

# Instalar dependencias
RUN npm install
# Instalar `firebase-admin`
RUN npm install firebase-admin

# Copiar todo el servicio
COPY ./backend/services/security-service /app

# Copiar la carpeta `shared` al contenedor
COPY ./backend/shared /app/shared

COPY ./backend/config/serviceAccountKey.json /app/config/serviceAccountKey.json

# Exponer el puerto en el que corre el servicio
EXPOSE 3001

# Comando para iniciar el microservicio
CMD ["node", "index.js"]
