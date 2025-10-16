# Production Deployment Guide

This guide covers deploying the Website Visits Tracker to production environments.

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Load Balancer │    │   Application   │    │   Redis Cluster │
│   (Nginx/HAProxy)│◄──►│   (Docker)      │◄──►│   (Redis)       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🚀 Quick Deployment

### Using Docker Compose (Recommended for small-medium deployments)

```bash
# 1. Clone the repository
git clone <repository-url>
cd visit-track

# 2. Set up environment variables
cp backend/env.example backend/.env
cp frontend/env.example frontend/.env

# 3. Deploy with Docker Compose
docker-compose up -d

# 4. Verify deployment
curl http://localhost:3000/health
curl http://localhost:5173
```

### Using Kubernetes (Recommended for large-scale deployments)

```yaml
# k8s-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: visits-backend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: visits-backend
  template:
    metadata:
      labels:
        app: visits-backend
    spec:
      containers:
      - name: backend
        image: visits-backend:latest
        ports:
        - containerPort: 3000
        env:
        - name: REDIS_HOST
          value: "redis-service"
        - name: REDIS_PORT
          value: "6379"
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: visits-backend-service
spec:
  selector:
    app: visits-backend
  ports:
  - port: 3000
    targetPort: 3000
  type: LoadBalancer
```

## 🔧 Environment Configuration

### Backend Environment Variables

```env
# Production Configuration
NODE_ENV=production
PORT=3000

# Redis Configuration
REDIS_HOST=your-redis-host
REDIS_PORT=6379
REDIS_PASSWORD=your-redis-password

# CORS Configuration
FRONTEND_URL=https://your-frontend-domain.com

# Logging
LOG_LEVEL=info

# Rate Limiting
THROTTLE_TTL=60000
THROTTLE_LIMIT=100
```

### Frontend Environment Variables

```env
# API Configuration
VITE_API_URL=https://your-api-domain.com

# Build Configuration
VITE_APP_TITLE=Website Visits Tracker
VITE_APP_VERSION=1.0.0
```

## 🗄️ Database Setup

### Redis Configuration

For production, use a managed Redis service:

#### AWS ElastiCache
```bash
# Create ElastiCache cluster
aws elasticache create-cache-cluster \
  --cache-cluster-id visits-redis \
  --cache-node-type cache.t3.micro \
  --engine redis \
  --num-cache-nodes 1
```

#### Redis Cloud
```bash
# Sign up at https://redis.com/redis-enterprise-cloud/
# Get connection details from dashboard
```

#### Self-hosted Redis
```yaml
# docker-compose.prod.yml
version: '3.8'
services:
  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes --requirepass your-password
    volumes:
      - redis_data:/data
    ports:
      - "6379:6379"
    deploy:
      resources:
        limits:
          memory: 1G
        reservations:
          memory: 512M
```

## 🌐 Load Balancer Configuration

### Nginx Configuration

```nginx
upstream backend {
    server backend1:3000;
    server backend2:3000;
    server backend3:3000;
}

upstream frontend {
    server frontend1:80;
    server frontend2:80;
}

server {
    listen 80;
    server_name your-domain.com;
    
    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=web:10m rate=30r/s;
    
    # API endpoints
    location /api/ {
        limit_req zone=api burst=20 nodelay;
        proxy_pass http://backend/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
    
    # Frontend
    location / {
        limit_req zone=web burst=50 nodelay;
        proxy_pass http://frontend/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

## 📊 Monitoring and Logging

### Application Monitoring

```yaml
# prometheus-config.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'visits-backend'
    static_configs:
      - targets: ['backend:3000']
    metrics_path: '/metrics'
    scrape_interval: 5s
```

### Log Aggregation

```yaml
# docker-compose.monitoring.yml
version: '3.8'
services:
  elasticsearch:
    image: elasticsearch:8.8.0
    environment:
      - discovery.type=single-node
    volumes:
      - es_data:/usr/share/elasticsearch/data

  kibana:
    image: kibana:8.8.0
    ports:
      - "5601:5601"
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200

  logstash:
    image: logstash:8.8.0
    volumes:
      - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf
```

## 🔒 Security Considerations

### SSL/TLS Configuration

```nginx
server {
    listen 443 ssl http2;
    server_name your-domain.com;
    
    ssl_certificate /path/to/certificate.crt;
    ssl_certificate_key /path/to/private.key;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    ssl_prefer_server_ciphers off;
    
    # Security headers
    add_header Strict-Transport-Security "max-age=63072000" always;
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
}
```

### Firewall Configuration

```bash
# UFW (Ubuntu)
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw enable

# iptables
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -j DROP
```

## 📈 Performance Optimization

### Redis Optimization

```redis
# redis.conf
maxmemory 2gb
maxmemory-policy allkeys-lru
tcp-keepalive 60
timeout 300

# Connection pooling
tcp-backlog 511
```

### Application Optimization

```javascript
// PM2 ecosystem file
module.exports = {
  apps: [{
    name: 'visits-backend',
    script: 'dist/main.js',
    instances: 'max',
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    max_memory_restart: '1G',
    node_args: '--max-old-space-size=1024'
  }]
};
```

## 🚨 Backup and Recovery

### Redis Backup

```bash
# Automated backup script
#!/bin/bash
BACKUP_DIR="/backups/redis"
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup
redis-cli --rdb $BACKUP_DIR/redis_backup_$DATE.rdb

# Compress backup
gzip $BACKUP_DIR/redis_backup_$DATE.rdb

# Keep only last 7 days
find $BACKUP_DIR -name "redis_backup_*.rdb.gz" -mtime +7 -delete
```

### Application Backup

```bash
# Database backup
pg_dump visits_db > backup_$(date +%Y%m%d).sql

# Application files backup
tar -czf app_backup_$(date +%Y%m%d).tar.gz /opt/visits-tracker/
```

## 🔄 CI/CD Pipeline

### GitHub Actions

```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Build and push Docker images
        run: |
          docker build -t visits-backend ./backend
          docker build -t visits-frontend ./frontend
          
      - name: Deploy to production
        run: |
          docker-compose -f docker-compose.prod.yml up -d
          
      - name: Run health checks
        run: |
          ./monitor.sh
```

## 📋 Health Checks

### Application Health

```bash
# Health check script
#!/bin/bash
curl -f http://localhost:3000/health || exit 1
curl -f http://localhost:5173/health || exit 1
```

### Load Balancer Health

```nginx
# Health check endpoint
location /health {
    access_log off;
    return 200 "healthy\n";
    add_header Content-Type text/plain;
}
```

## 🎯 Performance Targets

- **Response Time**: < 100ms for 95% of requests
- **Throughput**: 1000+ requests per second
- **Availability**: 99.9% uptime
- **Error Rate**: < 0.1%

## 📞 Support and Maintenance

### Monitoring Alerts

```yaml
# alertmanager.yml
route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'web.hook'

receivers:
- name: 'web.hook'
  webhook_configs:
  - url: 'http://your-webhook-url'
```

### Maintenance Windows

- **Database Maintenance**: Weekly, 2 AM UTC
- **Application Updates**: Monthly, 6 AM UTC
- **Security Patches**: As needed, 4 AM UTC

This deployment guide provides a comprehensive approach to deploying the Website Visits Tracker in production environments with proper monitoring, security, and performance considerations.
