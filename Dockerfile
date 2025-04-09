FROM registry.redhat.io/ubi8/nodejs-18 as builder

USER root

WORKDIR /app

COPY package.json package-lock.json* ./

# Ya como root, puedes instalar sin errores de permisos
RUN npm install

COPY . .

RUN npm run build

# Etapa 2: Producción (usuario seguro y no-root)
FROM registry.redhat.io/ubi8/nodejs-18-minimal as runner

WORKDIR /app

ENV NODE_ENV production

COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

EXPOSE 3000

CMD ["npm", "start"]
