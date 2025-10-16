# Website Visits Tracker

A high-performance REST API and web application for tracking website visits by country, built with Node.js, NestJS, Redis, React, and TypeScript.

## 🚀 Features

- **High Performance**: Optimized for 1000+ requests per second
- **Real-time Statistics**: Live updates with caching
- **Modern UI**: Beautiful React interface with charts
- **Robust Error Handling**: Comprehensive logging and error management
- **Health Monitoring**: Built-in health checks
- **Load Testing**: Included load testing with k6 and Artillery
- **Docker Ready**: Containerized for easy deployment

## 📋 Requirements

- Node.js 18+
- Redis 6+
- npm or yarn

## 🛠️ Quick Start

### 1. Clone and Install

```bash
git clone <repository-url>
cd visit-track
npm install
```

### 2. Start Redis

```bash
# Using Docker
docker run -d -p 6379:6379 redis:alpine

# Or install Redis locally
# macOS: brew install redis && brew services start redis
# Ubuntu: sudo apt install redis-server && sudo systemctl start redis
```

### 3. Start Development Servers

```bash
# Start both backend and frontend
npm run dev

# Or start individually:
# Backend: npm run start:dev --prefix backend
# Frontend: npm run dev --prefix frontend
```

### 4. Access the Application

- **Frontend**: http://localhost:5173
- **Backend API**: http://localhost:3000
- **Health Check**: http://localhost:3000/health

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   React Frontend│    │  NestJS Backend │    │   Redis Cache   │    │  External APIs  │
│                 │    │                 │    │                 │    │                 │
│  - Real-time UI │◄──►│  - REST API     │◄──►│  - Visit Counts │◄──►│  - REST Countries│
│  - Charts       │    │  - Validation   │    │  - Caching      │    │  - Country Data │
│  - Forms        │    │  - Logging      │    │  - Persistence  │    │  - Real-time    │
└─────────────────┘    └─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🌐 External API Integration

The application uses external APIs for country validation and data:

### REST Countries API
- **URL**: https://restcountries.com/v3.1
- **Purpose**: Real-time country code validation and country information
- **Features**:
  - ISO 3166-1 alpha-2 country code validation
  - Country names in multiple languages
  - Up-to-date country data
  - Free and reliable service

### Caching Strategy
- **Backend**: Redis caching for country data (24-hour TTL)
- **Frontend**: In-memory caching for API responses (5-minute TTL)
- **Benefits**: Reduced API calls, improved performance, offline fallback

## 📡 API Endpoints

### POST `/visit/:country`
Records a visit for a specific country.

**Parameters:**
- `country` (string): Country code (e.g., "us", "ru", "it")

**Response:**
```json
{
  "us": 123
}
```

### GET `/stats`
Retrieves visit statistics for all countries.

**Response:**
```json
{
  "us": 456,
  "ru": 123,
  "it": 89,
  "fr": 67
}
```

### GET `/health`
Returns the health status of the service.

**Response:**
```json
{
  "status": "healthy",
  "redis": "connected"
}
```

### POST `/clear`
Clears all visit statistics.

**Response:**
```json
{
  "message": "Successfully cleared 5 visit records",
  "cleared": 5
}
```

### POST `/clear/:country`
Clears visit statistics for a specific country.

**Parameters:**
- `country` (string): Country code (e.g., "us", "ru", "it")

**Response:**
```json
{
  "message": "Cleared visits for us",
  "cleared": true
}
```

### GET `/countries`
Returns all available countries with their codes and names.

**Response:**
```json
{
  "countries": [
    { "code": "US", "name": "United States" },
    { "code": "CA", "name": "Canada" },
    { "code": "GB", "name": "United Kingdom" }
  ]
}
```

### GET `/countries/search?q=query`
Searches for countries matching the query string.

**Parameters:**
- `q` (string): Search query

**Response:**
```json
{
  "countries": [
    { "code": "US", "name": "United States" },
    { "code": "UK", "name": "United Kingdom" }
  ]
}
```

### GET `/countries/validate/:country`
Validates a country code and returns country information.

**Parameters:**
- `country` (string): Country code to validate

**Response:**
```json
{
  "valid": true,
  "name": "United States"
}
```

## 🧪 Testing

### Run Tests

```bash
# Backend tests
cd backend
npm test

# Backend tests with coverage
npm run test:cov

# Frontend tests
cd frontend
npm test
```

### Load Testing

```bash
# Using k6
cd backend
k6 run loadtest.js

# Using Artillery
artillery run loadtest.yml
```

## 🚀 Deployment

### Docker Deployment

```bash
# Build and run with Docker Compose
docker-compose up -d
```

### Environment Variables

Create `.env` files in both backend and frontend directories:

**Backend (.env):**
```env
PORT=3000
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
FRONTEND_URL=http://localhost:5173
```

**Frontend (.env):**
```env
VITE_API_URL=http://localhost:3000
```

### Production Deployment

1. **Build the application:**
   ```bash
   npm run build --prefix backend
   npm run build --prefix frontend
   ```

2. **Set up Redis:**
   - Use managed Redis service (AWS ElastiCache, Redis Cloud, etc.)
   - Configure connection pooling
   - Set up monitoring

3. **Deploy backend:**
   - Use PM2 for process management
   - Set up reverse proxy (Nginx)
   - Configure SSL/TLS

4. **Deploy frontend:**
   - Serve static files with CDN
   - Configure caching headers

## 📊 Performance

- **Target Load**: 1000 requests/second
- **Response Time**: < 100ms average
- **Caching**: 1-second cache for stats retrieval
- **Redis Optimization**: Pipeline operations, SCAN instead of KEYS

## 🔧 Development

### Project Structure

```
├── backend/                 # NestJS API
│   ├── src/
│   │   ├── app.module.ts    # Main app module
│   │   ├── main.ts         # Application entry point
│   │   ├── stats.controller.ts
│   │   ├── stats.service.ts
│   │   └── *.spec.ts       # Test files
│   ├── loadtest.js         # k6 load test
│   ├── loadtest.yml        # Artillery load test
│   └── package.json
├── frontend/                # React application
│   ├── src/
│   │   ├── components/     # React components
│   │   ├── types/          # TypeScript types
│   │   └── App.tsx         # Main app component
│   └── package.json
└── package.json            # Root package.json
```

### Code Quality

- **TypeScript**: Strict type checking
- **ESLint**: Code linting
- **Prettier**: Code formatting
- **Jest**: Unit and integration testing
- **Coverage**: 90%+ test coverage

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Run the test suite
6. Submit a pull request

## 📝 License

This project is licensed under the MIT License.

## 🆘 Support

For issues and questions:
1. Check the documentation
2. Search existing issues
3. Create a new issue with detailed information

## 🔄 Changelog

### v1.0.0
- Initial release
- Basic visit tracking
- Real-time statistics
- Load testing setup
- Docker support
