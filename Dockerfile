
# Stage 1: Build frontend
FROM node:22-bookworm-slim AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build


# Stage 2: Production runtime
FROM node:22-bookworm-slim AS runtime

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=8787
ENV HOST=0.0.0.0
ENV MF_DATA_DIR=/data

# Install production dependencies only
COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

# Copy application files
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/server ./server
COPY --from=builder /app/src ./src
COPY --from=builder /app/public ./public
COPY --from=builder /app/data ./data

# Persistent data directory
RUN mkdir -p /data && chown -R node:node /data /app

USER node

EXPOSE 8787

CMD ["npm", "start"]

