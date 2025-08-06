# Multi-stage build for Claude Code UI Docker deployment
FROM docker.cnb.cool/masx200/docker_mirror/node:20.19.3-alpine AS base



run npm install -g cnpm --registry=https://registry.npmmirror.com
run npm config set registry https://registry.npmmirror.com
run cnpm i -g --force npm cnpm


run sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories

# Install system dependencies required for the application
RUN apk add --no-cache \
    python3 py3-pip\
    make \
    g++ \
    git \
    bash \
    curl \
    nano \
    tree

# Set working directory
WORKDIR /app

# Copy package files (both package.json and package-lock.json)
COPY package.json package-lock.json ./


run pip config set install.trusted-host 'https://pypi.tuna.tsinghua.edu.cn'
run pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

# Install dependencies using npm ci for reproducible builds
RUN cnpm ci --omit=dev --detial && npm cache clean --force

# Build stage for frontend
FROM base AS build



run npm install -g cnpm --registry=https://registry.npmmirror.com
run npm config set registry https://registry.npmmirror.com
run cnpm i -g --force npm cnpm



run sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories

# Copy package files for build stage
COPY package.json package-lock.json ./

# Install all dependencies including dev dependencies for building
RUN npm ci

# Copy source code
COPY . .

# Build the frontend
RUN npm run build

# Production stage
FROM docker.cnb.cool/masx200/docker_mirror/node:20.19.3-alpine AS production




run npm install -g cnpm --registry=https://registry.npmmirror.com
run npm config set registry https://registry.npmmirror.com
run cnpm i -g --force npm cnpm



run sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories

# Install system dependencies required for runtime and native modules
RUN apk add --no-cache \
    python3 py3-pip\
    make \
    g++ \
    bash \
    curl \
    git

# Install Claude CLI globally
RUN npm install -g @anthropic-ai/claude-code

# Install SuperClaude framework
RUN cd /tmp && \
    git clone https://bgithub.xyz/NomenAK/SuperClaude.git && \
    cd SuperClaude && git checkout SuperClaude-v2 && \
    echo "y" | ./install.sh && \
    rm -rf /tmp/SuperClaude

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./


run pip config set install.trusted-host 'https://pypi.tuna.tsinghua.edu.cn'
run pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple


# Install production dependencies only
RUN npm ci --detail --omit=dev && npm cache clean --force

# Copy built frontend from build stage
COPY --from=build /app/dist ./dist

# Copy server code and other necessary files
COPY server ./server
COPY public ./public
COPY package*.json ./
COPY .env.example ./

# Create directory for SQLite database
RUN mkdir -p /app/data

# Create default .env file for Docker deployment
RUN echo "PORT=3008\nNODE_ENV=production\nDB_PATH=/app/data/auth.db\nHOME=/opt/docker" > .env

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Set up directory permissions
RUN chown -R nodejs:nodejs /app

# Switch to non-root user
USER nodejs

# Expose port internally (not to host)
EXPOSE 3008

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3008/api/auth/status || exit 1

# Start the application (server only, build is already done)
CMD ["npm", "run", "server"]