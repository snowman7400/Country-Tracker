#!/bin/bash

# Comprehensive Test Suite for Website Visits Tracker
# This script runs all tests: unit, integration, e2e, and load tests

set -e

echo "Website Visits Tracker - Comprehensive Test Suite"
echo "=================================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to run test and report result
run_test() {
    local test_name=$1
    local test_command=$2
    local test_dir=${3:-"."}
    
    echo -n "Running $test_name... "
    
    if (cd "$test_dir" && eval "$test_command" > /dev/null 2>&1); then
        echo -e "${GREEN}PASSED${NC}"
        return 0
    else
        echo -e "${RED}FAILED${NC}"
        return 1
    fi
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "Checking prerequisites..."
echo "----------------------------"

# Check Node.js
if command_exists node; then
    echo "Node.js: $(node --version)"
else
    echo "Node.js not found"
    exit 1
fi

# Check npm
if command_exists npm; then
    echo "npm: $(npm --version)"
else
    echo "npm not found"
    exit 1
fi

# Check Redis
if command_exists redis-cli; then
    if redis-cli ping > /dev/null 2>&1; then
        echo "Redis: Connected"
    else
        echo "Redis: Not running (some tests may fail)"
    fi
else
    echo "Redis CLI not found (some tests may fail)"
fi

# Check k6 (for load testing)
if command_exists k6; then
    echo "k6: $(k6 version | head -n1)"
else
    echo "k6 not found (load tests will be skipped)"
fi

echo ""
echo "Installing dependencies..."
echo "-----------------------------"

# Install backend dependencies
echo "Installing backend dependencies..."
cd backend
npm install --silent
cd ..

# Install frontend dependencies
echo "Installing frontend dependencies..."
cd frontend
npm install --silent
cd ..

echo ""
echo "Running Test Suite..."
echo "======================="

# Track test results
total_tests=0
passed_tests=0

# Backend Unit Tests
echo ""
echo "Backend Unit Tests:"
echo "---------------------"
total_tests=$((total_tests + 1))
if run_test "Backend Unit Tests" "npm test" "backend"; then
    passed_tests=$((passed_tests + 1))
fi

# Backend Integration Tests
echo ""
echo "Backend Integration Tests:"
echo "----------------------------"
total_tests=$((total_tests + 1))
if run_test "Backend Integration Tests" "npm run test:e2e" "backend"; then
    passed_tests=$((passed_tests + 1))
fi

# Frontend Tests
echo ""
echo "Frontend Tests:"
echo "----------------"
total_tests=$((total_tests + 1))
if run_test "Frontend Tests" "npm test" "frontend"; then
    passed_tests=$((passed_tests + 1))
fi

# Build Tests
echo ""
echo "Build Tests:"
echo "---------------"

# Backend Build
total_tests=$((total_tests + 1))
if run_test "Backend Build" "npm run build" "backend"; then
    passed_tests=$((passed_tests + 1))
fi

# Frontend Build
total_tests=$((total_tests + 1))
if run_test "Frontend Build" "npm run build" "frontend"; then
    passed_tests=$((passed_tests + 1))
fi

# Load Tests (if k6 is available)
if command_exists k6; then
    echo ""
    echo "Load Tests:"
    echo "-------------"
    total_tests=$((total_tests + 1))
    if run_test "Load Tests" "k6 run loadtest-comprehensive.js" "backend"; then
        passed_tests=$((passed_tests + 1))
    fi
else
    echo ""
    echo "Load Tests: Skipped (k6 not available)"
fi

# Test Results Summary
echo ""
echo "Test Results Summary:"
echo "========================"
echo "Total Tests: $total_tests"
echo "Passed: $passed_tests"
echo "Failed: $((total_tests - passed_tests))"

if [ $passed_tests -eq $total_tests ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed${NC}"
    exit 1
fi
