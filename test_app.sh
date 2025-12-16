#!/bin/bash

# Personnel Management System - Quick Test Script
# This script verifies that the application builds and runs correctly

set -e  # Exit on error

echo "========================================"
echo "Personnel Management System - Test Suite"
echo "========================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to print test result
test_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ PASS${NC}: $2"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗ FAIL${NC}: $2"
        ((TESTS_FAILED++))
    fi
}

# Test 1: Check if required tools are installed
echo "Test 1: Checking required tools..."
command -v cmake >/dev/null 2>&1
test_result $? "CMake is installed"

command -v g++ >/dev/null 2>&1
test_result $? "C++ compiler is installed"

qmake --version >/dev/null 2>&1
test_result $? "Qt is installed"

# Test 2: Check if .env file exists
echo ""
echo "Test 2: Checking configuration..."
if [ -f .env ]; then
    test_result 0 ".env file exists"
    if grep -q "API_BASE_URL" .env; then
        test_result 0 ".env contains API_BASE_URL"
    else
        test_result 1 ".env missing API_BASE_URL"
    fi
else
    test_result 1 ".env file not found"
fi

# Test 3: Check source files exist
echo ""
echo "Test 3: Checking source files..."
[ -f src/main.cpp ]
test_result $? "main.cpp exists"

[ -f CMakeLists.txt ]
test_result $? "CMakeLists.txt exists"

[ -d resources/qml ]
test_result $? "QML resources directory exists"

[ -f resources/qml/main.qml ]
test_result $? "main.qml exists"

# Test 4: Build the application
echo ""
echo "Test 4: Building application..."
if [ -d build ]; then
    echo "Removing old build directory..."
    rm -rf build
fi

mkdir build
cd build

echo "Running CMake..."
if cmake .. >/dev/null 2>&1; then
    test_result 0 "CMake configuration successful"
else
    test_result 1 "CMake configuration failed"
    cd ..
    exit 1
fi

echo "Compiling..."
if cmake --build . >/dev/null 2>&1; then
    test_result 0 "Build successful"
else
    test_result 1 "Build failed"
    cd ..
    exit 1
fi

# Test 5: Check binary
echo ""
echo "Test 5: Checking binary..."
if [ -f personnel_management ]; then
    test_result 0 "Binary created"

    SIZE=$(ls -lh personnel_management | awk '{print $5}')
    echo "   Binary size: $SIZE"

    if [ -x personnel_management ]; then
        test_result 0 "Binary is executable"
    else
        test_result 1 "Binary is not executable"
    fi
else
    test_result 1 "Binary not found"
fi

# Test 6: Check QML files copied
echo ""
echo "Test 6: Checking QML resources..."
if [ -d resources/qml ]; then
    test_result 0 "QML directory copied"

    QML_COUNT=$(find resources/qml -name "*.qml" | wc -l)
    if [ $QML_COUNT -gt 0 ]; then
        test_result 0 "QML files found ($QML_COUNT files)"
    else
        test_result 1 "No QML files found"
    fi
else
    test_result 1 "QML directory not copied"
fi

# Test 7: Runtime test
echo ""
echo "Test 7: Runtime test..."
echo "Starting application (will run for 2 seconds)..."

# Capture output
timeout 2 ./personnel_management > /tmp/app_output.txt 2>&1 || true

if [ -f /tmp/app_output.txt ]; then
    # Check for critical errors
    if grep -q "Segmentation fault" /tmp/app_output.txt; then
        test_result 1 "Application crashed (segfault)"
    elif grep -q "Cannot read property.*of null" /tmp/app_output.txt; then
        test_result 1 "QML null pointer errors detected"
    elif grep -q "Cannot assign a value to a signal" /tmp/app_output.txt; then
        test_result 1 "QML signal handler errors detected"
    else
        test_result 0 "Application runs without critical errors"
    fi

    # Check if data was loaded
    if grep -q "Received.*departments" /tmp/app_output.txt 2>/dev/null; then
        test_result 0 "Departments data loaded"
    fi

    if grep -q "Received.*employees" /tmp/app_output.txt 2>/dev/null; then
        test_result 0 "Employees data loaded"
    fi

    if grep -q "Received.*salary grades" /tmp/app_output.txt 2>/dev/null; then
        test_result 0 "Salary grades data loaded"
    fi
else
    test_result 1 "Could not capture application output"
fi

# Test 8: API connectivity (optional)
echo ""
echo "Test 8: API connectivity test..."
if command -v curl >/dev/null 2>&1; then
    if curl -s http://212.132.110.72:8082/api/departments >/dev/null 2>&1; then
        test_result 0 "API server is reachable"
    else
        test_result 1 "API server is not reachable (check network)"
    fi
else
    echo "   Skipping (curl not installed)"
fi

cd ..

# Summary
echo ""
echo "========================================"
echo "Test Summary"
echo "========================================"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    echo ""
    echo "The application is ready to use:"
    echo "  cd build"
    echo "  ./personnel_management"
    exit 0
else
    echo -e "${RED}✗ Some tests failed.${NC}"
    echo ""
    echo "Check TROUBLESHOOTING.md for help."
    exit 1
fi
