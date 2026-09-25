FROM node:24-slim AS build

WORKDIR /app

COPY package*.json tsconfig.json ./
RUN npm ci

RUN npm run build


FROM node:24-slim AS runtime

WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev --ignore-scripts

COPY --from=build /app/dist ./dist

RUN mkdir -p /config
RUN chmod +x dist/index.js

ENV NODE_ENV=production
ENV GOOGLE_DRIVE_OAUTH_CREDENTIALS=/config/gcp-oauth.keys.json
ENV GOOGLE_DRIVE_MCP_TOKEN_PATH=/config/tokens.json

USER node

ENTRYPOINT ["node", "dist/index.js"]
