# Website Visits Tracker

A full-stack web application for tracking website visits by country with real-time statistics visualization.

## Features

- Track website visits by country code
- Real-time statistics dashboard
- Country code validation using external API
- Individual country statistics clearing
- Bulk statistics clearing
- Responsive design with modern UI
- High-performance backend with Redis caching
- Comprehensive test coverage

## Tech Stack

### Backend
- Node.js with NestJS framework
- TypeScript for type safety
- Redis for data storage and caching
- External API integration (REST Countries)
- Comprehensive testing (Jest, Supertest)
- Docker containerization

### Frontend
- React with TypeScript
- Vite for fast development
- Tailwind CSS for styling
- Real-time data updates
- Responsive design

## Prerequisites

- Node.js (v18 or higher)
- npm or yarn
- Redis server
- Docker (optional, for containerized deployment)

## Installation

### 1. Clone the repository
```bash
git clone <repo-url>
cd visit-track
```

### 2. Install dependencies

#### Backend
```bash
cd backend
npm install
```

#### Frontend
```bash
cd frontend
npm install
```

### 3. Set up environment variables

#### Backend Environment
Create `backend/.env` file:
```env
NODE_ENV=development
PORT=3000
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
FRONTEND_URL=http://localhost:5173
```

#### Frontend Environment
Create `frontend/.env` file:
```env
VITE_API_URL=http://localhost:3000
```

### 4. Start Redis server

#### Option A: Using Docker
```bash
docker run -d -p 6379:6379 --name redis redis:alpine
```

#### Option B: Using Docker Compose
```bash
docker-compose up redis -d
```

#### Option C: Install Redis locally
- Windows: Download from Microsoft Redis releases
- macOS: `brew install redis`
- Linux: `sudo apt-get install redis-server`

## Running the Application

### Development Mode

#### Start Backend
```bash
cd backend
npm run start:dev
```

#### Start Frontend
```bash
cd frontend
npm run dev
```

### Production Mode

#### Using Docker Compose
```bash
docker-compose up --build
```

#### Manual Production Build
```bash
# Build backend
cd backend
npm run build
npm run start:prod

# Build frontend
cd frontend
npm run build
# Serve the dist folder with a web server
```

## API Endpoints

### Visit Tracking
- `POST /visit/:country` - Record a visit for a country
- `GET /stats` - Get all visit statistics
- `GET /health` - Health check endpoint

### Statistics Management
- `POST /clear` - Clear all statistics
- `POST /clear/:country` - Clear statistics for a specific country

### Country Information
- `GET /countries` - Get all available countries
- `GET /countries/search?q=query` - Search countries
- `GET /countries/validate/:country` - Validate a country code

## Testing

### Run All Tests
```bash
cd backend
npm test
```

### Run Tests with Coverage
```bash
cd backend
npm run test:cov
```

### Run E2E Tests
```bash
cd backend
npm run test:e2e
```

## Project Structure

```
visit-track/
├── backend/
│   ├── src/
│   │   ├── services/
│   │   │   ├── country-validation.service.ts
│   │   │   └── country-validation.service.spec.ts
│   │   ├── stats.service.ts
│   │   ├── stats.controller.ts
│   │   ├── stats.module.ts
│   │   ├── app.module.ts
│   │   └── main.ts
│   ├── Dockerfile
│   ├── package.json
│   └── .env.example
├── frontend/
│   ├── src/
│   │   ├── components/
│   │   │   ├── CountryForm.tsx
│   │   │   └── SimpleBarChart.tsx
│   │   ├── services/
│   │   │   └── countryService.ts
│   │   ├── types/
│   │   │   └── stats.ts
│   │   └── App.tsx
│   ├── Dockerfile
│   ├── package.json
│   └── .env.example
├── docker-compose.yml
├── deploy.sh
└── README.md
```

## Configuration

### Backend Configuration
The backend can be configured using environment variables:

- `NODE_ENV`: Environment (development/production)
- `PORT`: Server port (default: 3000)
- `REDIS_HOST`: Redis server host (default: localhost)
- `REDIS_PORT`: Redis server port (default: 6379)
- `REDIS_PASSWORD`: Redis password (optional)
- `FRONTEND_URL`: Frontend URL for CORS

### Frontend Configuration
The frontend can be configured using environment variables:

- `VITE_API_URL`: Backend API URL (default: http://localhost:3000)

## Performance Features

- Redis caching for country validation (24-hour TTL)
- In-memory caching for statistics (1-second TTL)
- Redis pipeline operations for bulk data retrieval
- Rate limiting (100 requests per minute per IP)
- Connection pooling and retry logic
- Optimized database queries with SCAN operations

## Security Features

- Input validation and sanitization
- Rate limiting to prevent abuse
- CORS configuration
- Error handling without sensitive data exposure
- Country code validation using external API

## Monitoring and Health Checks

- Health check endpoint (`/health`)
- Redis connection monitoring
- Comprehensive logging
- Error tracking and reporting

## Deployment

### Using Docker Compose
```bash
docker-compose up --build -d
```

### Manual Deployment
1. Build the applications
2. Set up Redis server
3. Configure environment variables
4. Start the services

### Production Considerations
- Use a production Redis instance
- Set up proper logging
- Configure monitoring
- Set up backup strategies
- Use HTTPS in production

## Troubleshooting

### Common Issues

#### Redis Connection Failed
- Ensure Redis server is running
- Check Redis host and port configuration
- Verify Redis is accessible from the application

#### Country Validation Fails
- Check internet connection for external API calls
- Verify REST Countries API is accessible
- Check fallback validation is working

#### Frontend Cannot Connect to Backend
- Verify backend is running on correct port
- Check CORS configuration
- Ensure API URL is correct in frontend environment

### Debug Mode
Enable debug logging by setting:
```env
NODE_ENV=development
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review the logs for error messages
3. Ensure all prerequisites are installed
4. Verify environment configuration

## Changelog

### Version 1.0.0
- Initial release
- Basic visit tracking functionality
- Real-time statistics dashboard
- Country validation with external API
- Individual and bulk statistics clearing
- Comprehensive test coverage
- Docker containerization
- Production deployment support