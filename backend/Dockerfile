ARG NODE_VERSION=22.23.5-alpine3.24@sha256:1314fb30ec37592d5845e5a160d522c0e680972aa534549940b8d73bde88481a

FROM node:${NODE_VERSION}

ENV RESEND_API_KEY=re_dummy_api_key

WORKDIR /app

COPY --chown=node:node package*.json ./

RUN npm ci --omit=dev && npm cache clean --force \
    && rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx /usr/local/lib/node_modules/corepack /usr/local/bin/corepack

COPY --chown=node:node . .

USER node

EXPOSE 3007

CMD ["node", "server.js"]