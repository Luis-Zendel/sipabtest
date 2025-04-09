# Etapa 1: Build
FROM registry.redhat.io/ubi8/nodejs-18 as builder

WORKDIR /app

# Solución a permisos
RUN mkdir -p /app/node_modules && chmod -R 777 /app


# Copia los archivos uno por uno (evita permisos heredados de Git)
COPY package.json ./
COPY package-lock.json ./

# Ahora sí puedes cambiar permisos porque tú controlas los archivos
RUN chmod 777 package.json package-lock.json

RUN npm install

COPY . .
RUN npm run build

# Etapa 2: Producción
FROM registry.redhat.io/ubi8/nodejs-16-minimal as runner

WORKDIR /app

ENV NODE_ENV production

COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

EXPOSE 3000

CMD ["npm", "start"]
