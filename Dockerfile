# ---------- Build stage: compile the React client ----------
FROM node:22-bookworm-slim AS build
ENV NODE_ENV=production
WORKDIR /app

# Pre-copy package manifests to leverage Docker layer caching
COPY package*.json ./
COPY Calling/package*.json ./Calling/
COPY Server/package*.json ./Server/

# Install dependencies for both client and server
RUN npm --prefix Calling ci && npm --prefix Server ci

# Copy source
COPY . .

# Build the client to Calling/dist
RUN npm --prefix Calling run build

# ---------- Runtime stage: run Express server and serve built client ----------
FROM node:22-bookworm-slim
ENV NODE_ENV=production \
    PORT=8080

WORKDIR /app

# Copy server source and built client artifacts
COPY --from=build /app/Server ./Server
COPY --from=build /app/Calling/dist ./Calling/dist
# Install only server production deps
RUN npm --prefix Server ci --omit=dev

# Add a small entrypoint to inject secrets from env and start server
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

EXPOSE 8080
CMD ["/bin/sh", "/app/entrypoint.sh"]
