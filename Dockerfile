ARG NODE_VERSION=22.23.5-alpine3.24@sha256:1314fb30ec37592d5845e5a160d522c0e680972aa534549940b8d73bde88481a
ARG NGINX_VERSION=1.31.8-alpine3.24-slim@sha256:b19233c62309c8e620732244f9d0d0008678854cb9c6c47898817e8dec93a9e3

# Build stage
FROM node:${NODE_VERSION} AS builder

WORKDIR /app

COPY package*.json ./

RUN npm ci

COPY . .

RUN npm run build

# Serve stage
FROM nginx/nginx-unprivileged:${NGINX_VERSION} AS serve

COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx/nginx.conf /etc/nginx/templates/default.conf.template

ENV BACKEND_URL=http://backend:3007 \
    BACKEND_HOST=backend:3007 \
    NGINX_ENTRYPOINT_LOCAL_RESOLVERS=1

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
