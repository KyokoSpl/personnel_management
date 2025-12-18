# Quick Start Guide

Get the Personnel Management System up and running in just a few minutes!

## Table of Contents

- [One-Minute Start](#one-minute-start)
- [Prerequisites](#prerequisites)
- [Installation by Platform](#installation-by-platform)
- [First Run](#first-run)
- [Basic Usage](#basic-usage)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)

## One-Minute Start

If you have all dependencies installed:

```bash
# Clone and build
git clone https://github.com/kyokospl/personnel-management.git
cd personnel-management
./build.sh

# Run
./build/personnel_management
```

## Prerequisites

### Minimum Requirements

| Requirement | Version |
|-------------|---------|
| CMake | 3.21+ |
| C++ Compiler | C++17 support |
| Qt6 | 6.2+ |

### Quick Dependency Installation

#### Ubuntu/Debian
```bash
sudo apt update
sudo apt install build-essential cmake qt6-base-dev qt6-declarative-dev libqt6quickcontrols2-6
```

#### Fedora
```bash
sudo dnf install gcc-c++ cmake qt6-qtbase-devel qt6-qtdeclarative-devel qt6-qtquickcontrols2-devel
```

#### Arch Linux
```bash
sudo pacman -S base-devel cmake qt6-base qt6-declarative
```

#### macOS
```bash
brew install cmake qt6
```

#### Windows
1. Download and install [Qt6](https://www.qt.io/download-qt-installer)
2. Download and install [CMake](https://cmake.org/download/)
3. Install Visual Studio 2019+ with C++ workload

## Installation by Platform

### From Source (All Platforms)

```bash
# Clone repository
git clone https://github.com/kyokospl/personnel-management.git
cd personnel-management

# Build
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
cmake --build . -j$(nproc)

# Install (optional)
sudo cmake --install .
```

### Pre-built Packages

#### Fedora/RHEL
```bash
sudo dnf install personnel-management-*.rpm
```

#### Debian/Ubuntu
```bash
sudo dpkg -i personnel-management_*.deb
sudo apt install -f  # Fix dependencies if needed
```

#### Arch Linux
```bash
# From AUR
yay -S personnel-management

# Or manually
cd packages/arch
makepkg -si
```

#### AppImage (Portable Linux)
```bash
chmod +x personnel-management-*.AppImage
./personnel-management-*.AppImage
```

#### Windows
1. Download the ZIP file from releases
2. Extract to desired location
3. Run `personnel-management.bat` or `bin\personnel_management.exe`

## First Run

### Starting the Application

```bash
# From build directory
./personnel_management

# Or if installed
personnel-management
```

### What You'll See

1. **Splash Screen** - Application loading
2. **Main Window** - Three tabs at the bottom:
   - 🏢 **Departments** - Organizational units
   - 👥 **Employees** - Personnel records
   - 💰 **Salary Grades** - Compensation levels

### Initial Data

The application connects to a demo API server by default:
- **URL**: http://localhost:8082
- Sample data is pre-loaded for testing

## Basic Usage

### Viewing Data

1. Click on any tab to view that data type
2. Scroll to browse entries
3. Each entry shows key information in a card format

### Creating New Entries

1. Click the **"+ Add"** button in the top-right
2. Fill in the form fields
3. Click **"Create"** to save

### Editing Entries

1. Find the entry you want to edit
2. Click the **✎ (edit)** icon
3. Modify the form fields
4. Click **"Save"** to update

### Deleting Entries

1. Find the entry you want to delete
2. Click the **🗑 (delete)** icon
3. Confirm the deletion in the dialog

### Switching Themes

Click the **🌙/☀️** icon in the header to toggle between dark and light mode.

## Configuration

### Using a .env File

Create a `.env` file in the application directory:

```bash
# API Configuration
API_BASE_URL=http://localhost:8082
API_PREFIX=/api

# Route Configuration
ROUTE_DEPARTMENTS=/departments
ROUTE_EMPLOYEES=/employees
ROUTE_SALARY_GRADES=/salary-grades
```

### Using Environment Variables

```bash
# Set before running
export API_BASE_URL=http://your-server:8082
export API_PREFIX=/api

# Then run
./personnel_management
```

### Configuration Priority

1. Environment variables (highest)
2. `.env` file
3. Default values (lowest)

### Default Values

| Setting | Default |
|---------|---------|
| API_BASE_URL | http://localhost:8082 |
| API_PREFIX | /api |

## Troubleshooting

### Application Won't Start

**Check Qt libraries:**
```bash
ldd ./personnel_management | grep "not found"
```

**Solution:** Install missing Qt6 packages

### "Could not find Qt6" during build

**Set Qt6 path:**
```bash
cmake -DCMAKE_PREFIX_PATH=/path/to/qt6 ..
```

**Common paths:**
- Fedora: `/usr/lib64/cmake/Qt6`
- Ubuntu: `/usr/lib/x86_64-linux-gnu/cmake/Qt6`
- macOS (Homebrew): `$(brew --prefix qt6)`
- Windows: `C:\Qt\6.x.x\msvc2019_64`

### "Network Error" / "Connection Refused"

**Check API server:**
```bash
curl http://localhost:8082/api/departments
```

**Solutions:**
- Verify internet connection
- Check firewall settings
- Use a different API_BASE_URL if running local server

### Blank Screen / QML Errors

**Check QML files exist:**
```bash
ls -la resources/qml/
```

**Run with QML debugging:**
```bash
QML_IMPORT_TRACE=1 ./personnel_management
```

### Theme Not Changing

**Clear Qt cache:**
```bash
rm -rf ~/.cache/personnel_management
```

### Performance Issues

**Check system resources:**
```bash
# CPU/Memory usage
top -p $(pgrep personnel_management)

# GPU rendering
QSG_INFO=1 ./personnel_management
```

## Getting Help

- **Documentation**: See the `docs/` folder for detailed guides
- **Issues**: Report bugs on [GitHub Issues](https://github.com/kyokospl/personnel-management/issues)
- **API Docs**: http://localhost:8082/docs/

## Next Steps

Now that you have the application running:

1. **Explore the UI** - Try all CRUD operations
2. **Read the Architecture docs** - Understand how it works
3. **Customize configuration** - Point to your own API server
4. **Contribute** - See CONTRIBUTING.md for guidelines

---

**Happy managing! 🎉**