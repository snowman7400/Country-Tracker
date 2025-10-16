#!/bin/bash

# Website Visits Tracker Deployment Script
# This script sets up the entire application stack

set -e

echo "🚀 Starting Website Visits Tracker Deployment..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Create environment files if they don't exist
echo "📝 Setting up environment files..."

if [ ! -f backend/.env ]; then
    cp backend/env.example backend/.env
    echo "✅ Created backend/.env from example"
fi

if [ ! -f frontend/.env ]; then
    cp frontend/env.example frontend/.env
    echo "✅ Created frontend/.env from example"
fi

# Build and start services
echo "🏗️ Building and starting services..."

# Stop any existing containers
docker-compose down 2>/dev/null || true

# Build and start services
docker-compose up --build -d

# Wait for services to be healthy
echo "⏳ Waiting for services to be ready..."

# Wait for Redis
echo "Waiting for Redis..."
until docker-compose exec redis redis-cli ping > /dev/null 2>&1; do
    sleep 1
done
echo "✅ Redis is ready"

# Wait for Backend
echo "Waiting for Backend..."
until curl -f http://localhost:3000/health > /dev/null 2>&1; do
    sleep 2
done
echo "✅ Backend is ready"

# Wait for Frontend
echo "Waiting for Frontend..."
until curl -f http://localhost:5173/health > /dev/null 2>&1; do
    sleep 2
done
echo "✅ Frontend is ready"

echo ""
echo "🎉 Deployment completed successfully!"
echo ""
echo "📊 Application URLs:"
echo "   Frontend: http://localhost:5173"
echo "   Backend API: http://localhost:3000"
echo "   Health Check: http://localhost:3000/health"
echo "   Stats API: http://localhost:3000/stats"
echo ""
echo "🧪 Test the application:"
echo "   curl -X POST http://localhost:3000/visit/us"
echo "   curl http://localhost:3000/stats"
echo ""
echo "📋 Useful commands:"
echo "   View logs: docker-compose logs -f"
echo "   Stop services: docker-compose down"
echo "   Restart services: docker-compose restart"
echo ""
