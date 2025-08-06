# Claude Code UI - Docker Deployment

This guide covers deploying Claude Code UI in a Docker container connected to
the `shared_net` network with secure authentication and access to the
`/opt/docker` directory.

## Quick Start

1. **Run the setup script:**
   ```bash
   cd /opt/docker/claudecodeui
   ./docker-setup.sh
   ```

2. **Access the application:**
   - From other containers on `shared_net`: `http://claudecodeui:3008`
   - The application will prompt for initial user setup on first access

## Manual Setup

If you prefer manual setup, follow these steps:

### 1. Create Docker Network

```bash
# Create the shared_net network if it doesn't exist
docker network create shared_net
```

### 2. Configure Environment

```bash
# Copy and customize environment configuration
cp .env.docker .env

# Generate a secure JWT secret
JWT_SECRET=$(openssl rand -base64 32)
sed -i "s/your-super-secure-jwt-secret-change-this-in-production/$JWT_SECRET/" .env
```

### 3. Build and Deploy

```bash
# Build the container
docker compose build

# Start the service
docker compose up -d

# Check status
docker compose logs -f claudecodeui
```

## Configuration

### Environment Variables

Key environment variables in `.env`:

```bash
# Server configuration
PORT=3008
NODE_ENV=production

# Security (REQUIRED - change these)
JWT_SECRET=your-secure-jwt-secret
API_KEY=optional-api-key-for-additional-security

# Database
DB_PATH=/app/data/auth.db

# File access
HOME=/opt/docker
```

### Security Features

1. **JWT Authentication**: Required for all access - set up during first visit
2. **Optional API Key**: Additional security layer via `X-API-Key` header
3. **Network Isolation**: Only accessible via `shared_net` network
4. **File System Sandboxing**: Limited to `/opt/docker` directory access

### Volume Mounts

- `/opt/docker:/opt/docker:rw` - Full access to the parent Docker workspace
- `claudecodeui_data:/app/data` - Persistent storage for SQLite database

## Accessing from Other Containers

### Example: Nginx Proxy Manager

Add to your reverse proxy configuration:

```nginx
location /claudecodeui/ {
    proxy_pass http://claudecodeui:3008/;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_cache_bypass $http_upgrade;
}
```

### Example: Docker Compose Service

```yaml
services:
  your-service:
    # ... your service config
    depends_on:
      - claudecodeui
    networks:
      - shared_net
    environment:
      - CLAUDE_UI_URL=http://claudecodeui:3008
```

## Operations

### Monitoring

```bash
# Check service status
docker compose ps

# View logs
docker compose logs -f claudecodeui

# Monitor resource usage
docker stats claudecodeui
```

### Maintenance

```bash
# Restart the service
docker compose restart claudecodeui

# Update the application
git pull
docker compose build
docker compose up -d

# Backup database
docker cp claudecodeui:/app/data/auth.db ./auth-backup-$(date +%Y%m%d).db
```

### Troubleshooting

#### Service Won't Start

```bash
# Check logs for errors
docker compose logs claudecodeui

# Verify network exists
docker network ls | grep shared_net

# Check disk space
df -h
```

#### Authentication Issues

```bash
# Reset authentication database
docker compose down
docker volume rm claudecodeui_claudecodeui_data
docker compose up -d
```

#### File Access Problems

```bash
# Check volume mounts
docker inspect claudecodeui | grep -A 10 "Mounts"

# Verify permissions
docker exec claudecodeui ls -la /opt/docker
```

## Security Considerations

1. **Change Default Secrets**: Always customize `JWT_SECRET` and `API_KEY`
2. **Network Isolation**: Service is not exposed to localhost
3. **User Authentication**: Required for all access
4. **File System Access**: Limited to `/opt/docker` directory
5. **Regular Updates**: Keep the container image updated

## Features Available in Docker

✅ **Full Claude Code UI functionality** ✅ **Access to all projects in
`/opt/docker`** ✅ **WebSocket real-time communication** ✅ **File editing and
management** ✅ **Git operations** ✅ **Terminal integration** ✅ **Progressive
Web App features** ✅ **Mobile responsive interface**

## Integration with Existing Services

The containerized Claude Code UI integrates seamlessly with:

- **Nginx Proxy Manager** - For SSL termination and routing
- **N8N Workflows** - For automation integration
- **Other Docker services** - Via shared_net network
- **File-based services** - Through `/opt/docker` volume mount

## Support

For issues specific to the Docker deployment:

1. Check the container logs: `docker compose logs claudecodeui`
2. Verify network connectivity: `docker network inspect shared_net`
3. Test file access: `docker exec claudecodeui ls -la /opt/docker`

For application-specific issues, refer to the main README.md file.
