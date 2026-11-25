# Build context is repository root; production image is built by backend Dockerfile.
FROM node:22-alpine AS build
WORKDIR /app
COPY src/frontend/starter-web/package*.json ./
RUN npm install
COPY src/frontend/starter-web/ ./
RUN npm run build
