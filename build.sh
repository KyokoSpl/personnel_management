#!/bin/bash
set -e

echo "Building Personnel Management System (C++/Qt6)"
echo "==============================================="

# Create build directory
mkdir -p build
cd build

# Configure
echo "Configuring with CMake..."
cmake ..

# Build
echo "Building..."
cmake --build . -j$(nproc)

echo ""
echo "Build complete!"
echo "Run with: ./personnel_management"
