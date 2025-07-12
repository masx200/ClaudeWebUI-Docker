#!/bin/bash

# Claude Code UI Docker Setup Script
# This script helps set up the Docker environment for Claude Code UI

set -e

echo "🐳 Claude Code UI Docker Setup"
echo "================================"

# Check if Docker and Docker Compose are installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Check if shared_net network exists
if ! docker network ls | grep -q shared_net; then
    echo "📡 Creating shared_net network..."
    docker network create shared_net
    echo "✅ shared_net network created"
else
    echo "✅ shared_net network already exists"
fi

# Generate secure JWT secret if not provided
if [ ! -f .env ]; then
    echo "🔐 Creating environment configuration..."
    cp .env.docker .env
    
    # Generate a secure JWT secret
    JWT_SECRET=$(openssl rand -base64 32)
    sed -i "s/your-super-secure-jwt-secret-change-this-in-production/$JWT_SECRET/" .env
    
    echo "✅ Environment configuration created"
    echo "📝 Please review and customize .env file as needed"
else
    echo "✅ Environment configuration already exists"
fi

# Build and start the container
echo "🏗️  Building Claude Code UI container..."
docker-compose build

echo "🚀 Starting Claude Code UI..."
docker-compose up -d

# Wait for the service to be healthy
echo "⏳ Waiting for service to be ready..."
sleep 10

# Check if the service is running
if docker-compose ps | grep -q "Up"; then
    echo "✅ Claude Code UI is running successfully!"
    echo ""
    echo "📋 Service Information:"
    echo "   Container Name: claudecodeui"
    echo "   Network: shared_net"
    echo "   Internal Port: 3008"
    echo "   Files Access: /opt/docker (mounted)"
    echo ""
    echo "🔗 To access from other containers on shared_net:"
    echo "   URL: http://claudecodeui:3008"
    echo ""
    echo "📊 To check status:"
    echo "   docker-compose logs -f claudecodeui"
    echo ""
    echo "🛑 To stop:"
    echo "   docker-compose down"
else
    echo "❌ Service failed to start. Check logs:"
    docker-compose logs claudecodeui
    exit 1
fi