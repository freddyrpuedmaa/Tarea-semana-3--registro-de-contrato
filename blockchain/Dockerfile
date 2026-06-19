FROM node:22-alpine

WORKDIR /app

# Instalar dependencias de Node.js
COPY package*.json ./
RUN npm install

# Copiar configuración y dependencias del entorno de desarrollo
COPY hardhat.config.ts tsconfig.json ./
COPY contracts/ contracts
COPY scripts/ scripts
COPY test/ test

# COMPILACIÓN: Compila los contratos inteligentes (RegistroIncidentesSOC.sol) 
# durante la fase de construcción de la imagen.
RUN npx hardhat compile

# EJECUCIÓN: Ejecuta el script de TypeScript adaptado al levantar el contenedor.
# Reemplazamos "crear-titulo.ts" por el nombre de tu nuevo script (ej. deploy-soc.ts)
CMD ["npx", "hardhat", "run", "scripts/crear-incidente.ts"]
CMD [ "npx", "hardhat", "compile"]