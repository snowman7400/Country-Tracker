#!/bin/bash

# Website Visits Tracker Monitoring Script
# This script monitors the health and performance of the application

set -e

API_URL="http://localhost:3000"
FRONTEND_URL="http://localhost:5173"

echo "🔍 Website Visits Tracker Health Monitor"
echo "========================================"
echo ""

# Function to check HTTP endpoint
check_endpoint() {
    local url=$1
    local name=$2
    local expected_status=${3:-200}
    
    echo -n "Checking $name... "
    
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")
    
    if [ "$response" = "$expected_status" ]; then
        echo "✅ OK ($response)"
        return 0
    else
        echo "❌ FAILED ($response)"
        return 1
    fi
}

# Function to get response time
get_response_time() {
    local url=$1
    curl -s -o /dev/null -w "%{time_total}" "$url" 2>/dev/null || echo "0"
}

# Check all endpoints
echo "📊 Health Checks:"
echo "----------------"

# Backend health
check_endpoint "$API_URL/health" "Backend Health" 200
backend_health=$?

# Backend stats
check_endpoint "$API_URL/stats" "Backend Stats" 200
backend_stats=$?

# Frontend health
check_endpoint "$FRONTEND_URL/health" "Frontend Health" 200
frontend_health=$?

# Frontend main page
check_endpoint "$FRONTEND_URL" "Frontend Main" 200
frontend_main=$?

echo ""

# Performance metrics
echo "⚡ Performance Metrics:"
echo "----------------------"

if [ $backend_health -eq 0 ]; then
    backend_time=$(get_response_time "$API_URL/health")
    echo "Backend response time: ${backend_time}s"
fi

if [ $backend_stats -eq 0 ]; then
    stats_time=$(get_response_time "$API_URL/stats")
    echo "Stats response time: ${stats_time}s"
fi

if [ $frontend_health -eq 0 ]; then
    frontend_time=$(get_response_time "$FRONTEND_URL/health")
    echo "Frontend response time: ${frontend_time}s"
fi

echo ""

# Test visit endpoint
echo "🧪 Testing Visit Endpoint:"
echo "-------------------------"

visit_response=$(curl -s -X POST "$API_URL/visit/test" 2>/dev/null || echo "")
if [ -n "$visit_response" ]; then
    echo "✅ Visit endpoint working"
    echo "Response: $visit_response"
else
    echo "❌ Visit endpoint failed"
fi

echo ""

# Docker container status
echo "🐳 Docker Container Status:"
echo "-------------------------"

if command -v docker-compose &> /dev/null; then
    docker-compose ps
else
    echo "Docker Compose not available"
fi

echo ""

# Overall status
echo "📈 Overall Status:"
echo "----------------"

total_checks=4
passed_checks=0

[ $backend_health -eq 0 ] && ((passed_checks++))
[ $backend_stats -eq 0 ] && ((passed_checks++))
[ $frontend_health -eq 0 ] && ((passed_checks++))
[ $frontend_main -eq 0 ] && ((passed_checks++))

if [ $passed_checks -eq $total_checks ]; then
    echo "🎉 All systems operational!"
    exit 0
elif [ $passed_checks -gt 0 ]; then
    echo "⚠️  Partial system operational ($passed_checks/$total_checks checks passed)"
    exit 1
else
    echo "❌ System not operational"
    exit 2
fi
