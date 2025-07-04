# Build stage
FROM node:24-slim AS builder

WORKDIR /app

# Install OpenSSL for Prisma
RUN apt-get update -y && apt-get install -y openssl

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY tsconfig.json ./
COPY src/ ./src/

# Copy Prisma files
COPY prisma ./prisma

# Build the application
RUN npm run build

# Remove dev dependencies
RUN npm prune --production

# Production stage
FROM node:24-slim AS production

# Install OpenSSL for Prisma runtime
RUN apt-get update -y && apt-get install -y openssl

# Set node environment to production
ENV NODE_ENV=production

WORKDIR /app

# Copy built assets and production dependencies from builder
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./

# Copy Prisma files for migrations
COPY --from=builder /app/prisma ./prisma

# Copy static files
COPY src/public ./dist/public

# Expose port
EXPOSE 3000

# Set healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# Run migrations and start the application
CMD ["sh", "-c", "npx prisma migrate deploy && node dist/index.js"]
