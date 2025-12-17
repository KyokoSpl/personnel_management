#!/bin/bash
#
# Build Windows executable using Docker - No local dependencies needed!
# Only requires Docker to be installed.
#
# Usage: ./scripts/build-windows-docker.sh
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_NAME="personnel_management"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed!"
    echo ""
    echo "Install Docker:"
    echo "  Arch Linux:  sudo pacman -S docker && sudo systemctl start docker"
    echo "  Ubuntu:      sudo apt install docker.io && sudo systemctl start docker"
    echo "  Fedora:      sudo dnf install docker && sudo systemctl start docker"
    echo ""
    echo "Don't forget to add your user to the docker group:"
    echo "  sudo usermod -aG docker \$USER"
    echo "  # Then log out and back in"
    exit 1
fi

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    print_error "Docker daemon is not running!"
    echo "Start it with: sudo systemctl start docker"
    exit 1
fi

print_info "Building Windows executable using Docker..."
print_info "This may take a while on first run (downloading ~2GB image)"
echo ""

# Create output directory
mkdir -p "$PROJECT_ROOT/build-windows-docker"

# Create Dockerfile for MXE (M cross environment) based build
DOCKERFILE="$PROJECT_ROOT/build-windows-docker/Dockerfile.mingw"

cat > "$DOCKERFILE" << 'DOCKERFILE_CONTENT'
# Multi-stage build for Windows cross-compilation
FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

# Install basic dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    ninja-build \
    git \
    wget \
    pkg-config \
    mingw-w64 \
    g++-mingw-w64-x86-64 \
    && rm -rf /var/lib/apt/lists/*

# Download pre-built Qt6 for MinGW (from official Qt releases)
WORKDIR /opt
RUN wget -q https://github.com/nicco-io/qt6-static-mingw/releases/download/v6.5.0/qt6.5.0-mingw-static.tar.xz \
    && tar -xf qt6.5.0-mingw-static.tar.xz \
    && rm qt6.5.0-mingw-static.tar.xz \
    || echo "Pre-built Qt not available, will try alternative"

# Alternative: Use MXE for Qt (if pre-built not available)
# This is slower but more reliable
RUN if [ ! -d "/opt/qt6" ]; then \
        apt-get update && apt-get install -y \
        autoconf automake autopoint bash bison bzip2 flex gettext \
        intltool libc6-dev-i386 libgdk-pixbuf2.0-dev libltdl-dev \
        libssl-dev libtool-bin libxml-parser-perl lzip make openssl \
        p7zip-full patch perl python3 python3-mako ruby sed unzip \
        xz-utils && \
        git clone https://github.com/mxe/mxe.git /opt/mxe && \
        cd /opt/mxe && \
        make -j$(nproc) MXE_TARGETS='x86_64-w64-mingw32.static' qt6-qtbase qt6-qtdeclarative; \
    fi

WORKDIR /src

# Copy project files
COPY . .

# Create toolchain file
RUN echo 'set(CMAKE_SYSTEM_NAME Windows)' > /tmp/mingw-toolchain.cmake && \
    echo 'set(CMAKE_SYSTEM_PROCESSOR x86_64)' >> /tmp/mingw-toolchain.cmake && \
    echo 'set(CMAKE_C_COMPILER x86_64-w64-mingw32-gcc)' >> /tmp/mingw-toolchain.cmake && \
    echo 'set(CMAKE_CXX_COMPILER x86_64-w64-mingw32-g++)' >> /tmp/mingw-toolchain.cmake && \
    echo 'set(CMAKE_RC_COMPILER x86_64-w64-mingw32-windres)' >> /tmp/mingw-toolchain.cmake && \
    echo 'set(CMAKE_FIND_ROOT_PATH /opt/qt6 /opt/mxe/usr/x86_64-w64-mingw32.static)' >> /tmp/mingw-toolchain.cmake && \
    echo 'set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)' >> /tmp/mingw-toolchain.cmake && \
    echo 'set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)' >> /tmp/mingw-toolchain.cmake && \
    echo 'set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)' >> /tmp/mingw-toolchain.cmake

# Build
RUN mkdir -p /build && cd /build && \
    cmake -DCMAKE_TOOLCHAIN_FILE=/tmp/mingw-toolchain.cmake \
          -DCMAKE_BUILD_TYPE=Release \
          -DBUILD_TESTING=OFF \
          -G Ninja \
          /src && \
    ninja

# Output stage - just the executable
FROM scratch AS export
COPY --from=builder /build/personnel_management.exe /
DOCKERFILE_CONTENT

# Alternative simpler approach using a pre-made image
DOCKERFILE_SIMPLE="$PROJECT_ROOT/build-windows-docker/Dockerfile.simple"

cat > "$DOCKERFILE_SIMPLE" << 'DOCKERFILE_SIMPLE_CONTENT'
# Simpler approach using Fedora's MinGW packages
FROM fedora:39 AS builder

# Install MinGW Qt6 (Fedora has good MinGW Qt6 packages)
RUN dnf install -y \
    cmake \
    ninja-build \
    mingw64-gcc-c++ \
    mingw64-qt6-qtbase \
    mingw64-qt6-qtdeclarative \
    mingw64-qt6-qtquickcontrols2 \
    wine-core \
    && dnf clean all

WORKDIR /src
COPY . .

# Create build directory and configure
RUN mkdir -p /build && cd /build && \
    mingw64-cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_TESTING=OFF \
        -G Ninja \
        /src

# Build
RUN cd /build && ninja

# The executable will be at /build/personnel_management.exe
DOCKERFILE_SIMPLE_CONTENT

print_info "Using Fedora-based Docker image (has best MinGW Qt6 support)..."

# Build using Docker
cd "$PROJECT_ROOT"

# Try the simple Fedora-based build first
docker build \
    -f "$DOCKERFILE_SIMPLE" \
    -t "${PROJECT_NAME}-windows-builder" \
    . 2>&1 | tee "$PROJECT_ROOT/build-windows-docker/build.log"

if [ ${PIPESTATUS[0]} -ne 0 ]; then
    print_error "Docker build failed! Check build-windows-docker/build.log"
    exit 1
fi

# Extract the executable from the container
print_info "Extracting Windows executable..."

CONTAINER_ID=$(docker create "${PROJECT_NAME}-windows-builder")
docker cp "$CONTAINER_ID:/build/personnel_management.exe" "$PROJECT_ROOT/build-windows-docker/" 2>/dev/null || \
docker cp "$CONTAINER_ID:/build/Release/personnel_management.exe" "$PROJECT_ROOT/build-windows-docker/" 2>/dev/null || \
{
    print_warning "Could not find exe in standard locations, searching..."
    docker cp "$CONTAINER_ID:/build/" "$PROJECT_ROOT/build-windows-docker/container-build/"
    find "$PROJECT_ROOT/build-windows-docker/container-build" -name "*.exe" -exec cp {} "$PROJECT_ROOT/build-windows-docker/" \;
}
docker rm "$CONTAINER_ID" > /dev/null

# Check if we got the executable
if [ -f "$PROJECT_ROOT/build-windows-docker/personnel_management.exe" ]; then
    print_success "Windows executable built successfully!"
    echo ""
    echo "Output: $PROJECT_ROOT/build-windows-docker/personnel_management.exe"
    echo ""
    echo "File info:"
    file "$PROJECT_ROOT/build-windows-docker/personnel_management.exe"
    ls -lh "$PROJECT_ROOT/build-windows-docker/personnel_management.exe"
    echo ""
    print_info "Note: You may need to include Qt DLLs when distributing."
    print_info "For static build (no DLLs needed), use the MXE-based Dockerfile."
else
    print_error "Could not find the built executable!"
    print_info "Check the build log: $PROJECT_ROOT/build-windows-docker/build.log"
    exit 1
fi
