FROM node:22-alpine

WORKDIR /usr/src/app

# Copia apenas package.json e package-lock.json para otimizar cache
COPY frontend/package*.json ./

# Instala dependências
RUN npm install

# Copia o resto do código
COPY frontend .

# Lib necessária para Next.js no alpine
RUN apk add --no-cache libc6-compat

CMD ["npm", "run", "dev", "--", "-H", "0.0.0.0", "-p", "3000"]
