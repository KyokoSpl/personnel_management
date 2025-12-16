# Packaging Documentation

## Overview

The Personnel Management System includes a comprehensive packaging script (`package.sh`) that supports building and packaging the application for multiple platforms. This document provides detailed instructions for creating distribution packages.

## Table of Contents

- [Quick Start](#quick-start)
- [Prerequisites](#prerequisites)
- [Package Script Usage](#package-script-usage)
- [Platform-Specific Guides](#platform-specific-guides)
  - [Fedora/RHEL (RPM)](#fedorarhel-rpm)
  - [Debian/Ubuntu (DEB)](#debianubuntu-deb)
  - [Arch Linux (PKGBUILD)](#arch-linux-pkgbuild)
  - [Windows (ZIP)](#windows-zip)
  - [AppImage](#appimage)
- [GitHub Releases](#github-releases)
- [Troubleshooting](#troubleshooting)

## Quick Start

```bash
# Build and package for all platforms
./package.sh --all

# Build for specific platforms
./package.sh fedora debian

# Clean, build, and package
./package.sh --clean --all

# Create a GitHub release
./package.sh --release v0.2.0
```

## Prerequisites

### Common Requirements

| Tool | Version | Purpose |
|------|---------|---------|
| CMake | 3.21+ | Build system |
| GCC/Clang | C++17 support | Compilation |
| Qt6 | 6.2+ | Application framework |
| Git | Any | Version control |

### Platform-Specific Tools

| Platform | Required Tools | Installation |
|----------|---------------|--------------|
| Fedora RPM | `rpmbuild`, `rpmdevtools` | `sudo dnf install rpm-build rpmdevtools` |
| Debian DEB | `dpkg-deb`, `dpkg-dev` | `sudo apt install dpkg-dev` |
| Arch Linux | `makepkg`, `base-devel` | `sudo pacman -S base-devel` |
| Windows | MinGW-w64, Qt6 for Windows | See [Windows Setup](#windows-setup) |
| AppImage | `appimagetool` | Download from GitHub |

### GitHub CLI (for releases)

```bash
# Fedora
sudo dnf install gh

# Debian/Ubuntu
sudo apt install gh

# Arch Linux
sudo pacman -S github-cli

# macOS
brew install gh

# Authenticate
gh auth login
```

## Package Script Usage

### Command Line Options

```
Usage: ./package.sh [OPTIONS] [PLATFORMS...]

OPTIONS:
    -h, --help          Show help message
    -c, --clean         Clean previous builds before packaging
    -a, --all           Build packages for all supported platforms
    -b, --build-only    Only build the application, don't package
    --no-build          Skip building (use existing build)
    -r, --release TAG   Create GitHub release with specified tag

PLATFORMS:
    fedora              Create Fedora RPM package
    arch                Create Arch Linux PKGBUILD
    debian              Create Debian DEB package
    windows             Create Windows ZIP package
    appimage            Create AppImage (portable Linux)
```

### Examples

```bash
# Build only (no packaging)
./package.sh --build-only

# Clean build with Fedora and Debian packages
./package.sh --clean fedora debian

# Use existing build, package for Arch Linux
./package.sh --no-build arch

# Full release workflow
./package.sh --clean --all --release v1.0.0
```

### Output Structure

```
packages/
├── fedora/
│   ├── personnel-management-0.2.0-1.fc*.rpm
│   └── personnel-management-0.2.0-1.fc*.src.rpm
├── debian/
│   ├── personnel-management_0.2.0/
│   │   └── DEBIAN/
│   │       └── control
│   └── personnel-management_0.2.0.deb
├── arch/
│   ├── PKGBUILD
│   ├── .SRCINFO
│   └── personnel-management-0.2.0.tar.gz
├── windows/
│   ├── personnel-management-0.2.0-windows/
│   └── personnel-management-0.2.0-windows.zip
└── appimage/
    └── personnel-management-x86_64.AppImage
```

## Platform-Specific Guides

### Fedora/RHEL (RPM)

#### Prerequisites

```bash
# Install build dependencies
sudo dnf install cmake gcc-c++ rpm-build rpmdevtools

# Install Qt6 development packages
sudo dnf install qt6-qtbase-devel qt6-qtdeclarative-devel qt6-qtquickcontrols2-devel
```

#### Building

```bash
./package.sh fedora
```

#### Output Files

- `packages/fedora/personnel-management-0.2.0-1.fc*.x86_64.rpm` - Binary RPM
- `packages/fedora/personnel-management-0.2.0-1.fc*.src.rpm` - Source RPM

#### Installation

```bash
sudo dnf install packages/fedora/personnel-management-0.2.0-1.fc*.rpm
```

#### RPM Spec Details

The generated RPM spec file includes:

```spec
Name:           personnel-management
Version:        0.2.0
Release:        1%{?dist}
Summary:        Personnel Management System - Qt6/QML Frontend Application

License:        MIT
URL:            https://github.com/kyokospl/personnel-management

BuildRequires:  cmake >= 3.21
BuildRequires:  gcc-c++
BuildRequires:  qt6-qtbase-devel
BuildRequires:  qt6-qtdeclarative-devel

Requires:       qt6-qtbase
Requires:       qt6-qtdeclarative
Requires:       qt6-qtquickcontrols2
```

### Debian/Ubuntu (DEB)

#### Prerequisites

```bash
# Install build dependencies
sudo apt update
sudo apt install build-essential cmake dpkg-dev

# Install Qt6 development packages
sudo apt install qt6-base-dev qt6-declarative-dev qt6-quickcontrols2-dev
```

#### Building

```bash
./package.sh debian
```

#### Output Files

- `packages/debian/personnel-management_0.2.0.deb` - Binary DEB package

#### Installation

```bash
sudo dpkg -i packages/debian/personnel-management_0.2.0.deb

# Fix any dependency issues
sudo apt install -f
```

#### Control File Details

```
Package: personnel-management
Version: 0.2.0
Section: misc
Priority: optional
Architecture: amd64
Depends: libqt6core6, libqt6gui6, libqt6qml6, libqt6quick6, libqt6network6,
         qml6-module-qtquick, qml6-module-qtquick-controls
Maintainer: Kyoko Kiese <kyokokiese@proton.me>
Description: Personnel Management System - Qt6/QML Frontend Application
```

### Arch Linux (PKGBUILD)

#### Prerequisites

```bash
# Install build dependencies
sudo pacman -S base-devel cmake qt6-base qt6-declarative
```

#### Building

```bash
./package.sh arch
```

#### Output Files

- `packages/arch/PKGBUILD` - Package build script
- `packages/arch/.SRCINFO` - Package metadata
- `packages/arch/personnel-management-0.2.0.tar.gz` - Source tarball

#### Installation

```bash
cd packages/arch
makepkg -si
```

#### AUR Submission

To submit to the AUR:

1. Create an AUR account at https://aur.archlinux.org/
2. Set up SSH keys
3. Clone the AUR repository:
   ```bash
   git clone ssh://aur@aur.archlinux.org/personnel-management.git
   ```
4. Copy PKGBUILD and .SRCINFO:
   ```bash
   cp packages/arch/{PKGBUILD,.SRCINFO} personnel-management/
   ```
5. Commit and push:
   ```bash
   cd personnel-management
   git add PKGBUILD .SRCINFO
   git commit -m "Initial commit: personnel-management 0.2.0"
   git push
   ```

### Windows (ZIP)

#### Prerequisites (Cross-Compilation from Linux)

```bash
# Fedora
sudo dnf install mingw64-gcc-c++ mingw64-qt6-qtbase mingw64-qt6-qtdeclarative

# Debian/Ubuntu
sudo apt install mingw-w64
```

#### Prerequisites (Native Windows Build)

1. Install Visual Studio 2019 or later with C++ workload
2. Install Qt6 from https://www.qt.io/download-qt-installer
3. Install CMake from https://cmake.org/download/

#### Building (Cross-Compilation)

```bash
./package.sh windows
```

#### Building (Native Windows)

```powershell
# Open Qt Command Prompt or set up environment
mkdir build
cd build
cmake -DCMAKE_PREFIX_PATH="C:\Qt\6.x.x\msvc2019_64" -DCMAKE_BUILD_TYPE=Release ..
cmake --build . --config Release
```

#### Output Files

- `packages/windows/personnel-management-0.2.0-windows.zip` - Complete package
- `packages/windows/personnel-management-0.2.0-windows/` - Unpacked directory

#### Deployment with windeployqt

For native Windows builds, use Qt's deployment tool:

```powershell
windeployqt --qmldir ..\resources\qml --release personnel_management.exe
```

### AppImage

#### Prerequisites

```bash
# Download appimagetool
wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
chmod +x appimagetool-x86_64.AppImage
sudo mv appimagetool-x86_64.AppImage /usr/local/bin/appimagetool
```

#### Building

```bash
./package.sh appimage
```

#### Output Files

- `packages/appimage/personnel-management-x86_64.AppImage` - Portable executable

#### Running

```bash
chmod +x packages/appimage/personnel-management-x86_64.AppImage
./packages/appimage/personnel-management-x86_64.AppImage
```

## GitHub Releases

### Creating a Release

The package script supports creating GitHub releases automatically:

```bash
# Create a release with all packages
./package.sh --clean --all --release v0.2.0
```

This will:
1. Clean previous builds
2. Build the application
3. Create all platform packages
4. Create a GitHub release with the specified tag
5. Upload all package files as release assets

### Manual Release Process

If you prefer to create releases manually:

```bash
# Build all packages first
./package.sh --clean --all

# Create the release
gh release create v0.2.0 \
  --title "Personnel Management v0.2.0" \
  --notes "Release notes here" \
  packages/fedora/*.rpm \
  packages/debian/*.deb \
  packages/windows/*.zip \
  packages/appimage/*.AppImage
```

### Release Notes Template

```markdown
## Personnel Management v0.2.0

### What's New
- Feature 1
- Feature 2

### Bug Fixes
- Fix 1
- Fix 2

### Installation

#### Fedora/RHEL
```
sudo dnf install personnel-management-0.2.0-1.*.rpm
```

#### Debian/Ubuntu
```
sudo dpkg -i personnel-management_0.2.0.deb
```

#### Arch Linux
```
yay -S personnel-management
```

#### Windows
Download and extract the ZIP file, then run `personnel-management.bat`

#### AppImage (Portable Linux)
```
chmod +x personnel-management-x86_64.AppImage
./personnel-management-x86_64.AppImage
```

### Checksums
```
SHA256:
abc123... personnel-management-0.2.0-1.fc40.x86_64.rpm
def456... personnel-management_0.2.0.deb
ghi789... personnel-management-0.2.0-windows.zip
jkl012... personnel-management-x86_64.AppImage
```
```

## Troubleshooting

### Common Issues

#### Build Fails: Qt6 Not Found

**Error:**
```
CMake Error: Could not find a package configuration file provided by "Qt6"
```

**Solution:**
```bash
# Specify Qt6 path
cmake -DCMAKE_PREFIX_PATH="/usr/lib64/cmake/Qt6" ..

# Or set environment variable
export Qt6_DIR=/usr/lib64/cmake/Qt6
```

#### RPM Build: Missing Dependencies

**Error:**
```
error: Failed build dependencies:
    qt6-qtbase-devel is needed by personnel-management-0.2.0-1.fc40.x86_64
```

**Solution:**
```bash
# Install missing dependencies
sudo dnf install qt6-qtbase-devel qt6-qtdeclarative-devel

# Or build with --nodeps (not recommended)
rpmbuild -ba --nodeps personnel-management.spec
```

#### DEB Build: Architecture Mismatch

**Error:**
```
dpkg-deb: error: control file has unsupported architecture value
```

**Solution:**
Ensure you're building on the correct architecture, or modify the control file:
```bash
# Check system architecture
dpkg --print-architecture

# Update control file if needed
sed -i 's/Architecture: amd64/Architecture: arm64/' DEBIAN/control
```

#### AppImage: Missing Libraries

**Error:**
```
./personnel_management: error while loading shared libraries: libQt6Core.so.6
```

**Solution:**
Deploy Qt libraries with the AppImage:
```bash
# Use linuxdeployqt
linuxdeployqt personnel_management -qmldir=resources/qml -appimage
```

#### GitHub Release: Authentication Failed

**Error:**
```
error: authentication required
```

**Solution:**
```bash
# Authenticate with GitHub CLI
gh auth login

# Or use a token
export GITHUB_TOKEN=your_token_here
```

### Debug Mode

For detailed output during packaging:

```bash
# Enable bash debug mode
bash -x ./package.sh fedora

# Or add set -x to the script temporarily
```

### Log Files

Build logs are stored in:
- `/tmp/rpmbuild_personnel-management.log` - RPM build log
- `build/CMakeOutput.log` - CMake configuration log
- `build/CMakeError.log` - CMake error log

## Version Management

### Updating Version Number

1. Update `CMakeLists.txt`:
   ```cmake
   project(personnel_management VERSION 0.3.0 LANGUAGES CXX)
   ```

2. Update `package.sh`:
   ```bash
   PROJECT_VERSION="0.3.0"
   ```

3. Update `docs/CHANGELOG.md` with release notes

### Semantic Versioning

This project follows [Semantic Versioning](https://semver.org/):

- **MAJOR** (1.x.x): Breaking changes
- **MINOR** (x.1.x): New features, backward compatible
- **PATCH** (x.x.1): Bug fixes, backward compatible

## Continuous Integration

### GitHub Actions Example

```yaml
name: Build and Release

on:
  push:
    tags:
      - 'v*'

jobs:
  build-linux:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install dependencies
        run: |
          sudo apt update
          sudo apt install -y cmake qt6-base-dev qt6-declarative-dev
          
      - name: Build packages
        run: ./package.sh --clean fedora debian appimage
        
      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: linux-packages
          path: packages/

  release:
    needs: build-linux
    runs-on: ubuntu-latest
    steps:
      - name: Download artifacts
        uses: actions/download-artifact@v3
        
      - name: Create Release
        uses: softprops/action-gh-release@v1
        with:
          files: |
            linux-packages/**/*.rpm
            linux-packages/**/*.deb
            linux-packages/**/*.AppImage
```

## References

- [RPM Packaging Guide](https://rpm-packaging-guide.github.io/)
- [Debian Policy Manual](https://www.debian.org/doc/debian-policy/)
- [Arch Linux PKGBUILD](https://wiki.archlinux.org/title/PKGBUILD)
- [AppImage Documentation](https://docs.appimage.org/)
- [Qt Deployment](https://doc.qt.io/qt-6/deployment.html)
- [GitHub CLI Manual](https://cli.github.com/manual/)