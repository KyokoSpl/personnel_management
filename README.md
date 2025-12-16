# Personnel Management System

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Qt Version](https://img.shields.io/badge/Qt-6.2+-green.svg)](https://www.qt.io/)
[![C++ Standard](https://img.shields.io/badge/C%2B%2B-17-blue.svg)](https://isocpp.org/)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Windows%20%7C%20macOS-lightgrey.svg)](https://github.com/kyokospl/personnel-management)

A modern, cross-platform Personnel Management System frontend built with **C++17** and **Qt6/QML**, featuring a beautiful **Material Design 3** user interface.

![Personnel Management Screenshot](docs/images/screenshot.png)

## ✨ Features

### Core Functionality
- **🏢 Department Management** - Create, read, update, and delete departments
- **👥 Employee Management** - Full CRUD operations with department/salary grade relationships
- **💰 Salary Grade Management** - Manage salary structures and compensation levels
- **🔗 REST API Integration** - Seamless connection to backend services

### User Interface
- **🎨 Material Design 3** - Modern purple-themed UI following Google's latest design guidelines
- **🌙 Dark/Light Mode** - Full theme switching support
- **📱 Responsive Layout** - Adapts to different window sizes
- **🔤 Material Icons** - Embedded font icons (no system dependencies required)
- **✨ Beautiful Dialogs** - Pre-filled edit forms with proper validation

### Technical Highlights
- **📦 Self-Contained** - All resources embedded in the binary
- **🚀 Cross-Platform** - Runs on Linux, Windows, and macOS
- **⚡ High Performance** - Native C++ with Qt's optimized rendering
- **🔧 Easy Configuration** - Environment variables and `.env` file support

## 📋 Table of Contents

- [Requirements](#-requirements)
- [Quick Start](#-quick-start)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Building from Source](#-building-from-source)
- [Packaging](#-packaging)
- [Project Structure](#-project-structure)
- [Architecture](#-architecture)
- [API Documentation](#-api-documentation)
- [Contributing](#-contributing)
- [License](#-license)

## 📦 Requirements

### Runtime Dependencies
- Qt6 Runtime Libraries (6.2 or higher)
  - Qt6Core
  - Qt6Gui
  - Qt6Quick
  - Qt6QuickControls2
  - Qt6Network

### Build Dependencies
- **CMake** 3.21 or higher
- **C++17** compatible compiler:
  - GCC 8+ (Linux)
  - Clang 7+ (Linux/macOS)
  - MSVC 2019+ (Windows)
  - AppleClang 12+ (macOS)
- **Qt6 Development Headers** (6.2+)

## 🚀 Quick Start

### One-Line Build (Linux/macOS)

```bash
./build.sh
```

### Manual Build

```bash
mkdir build && cd build
cmake ..
cmake --build .
./personnel_management
```

### Pre-built Packages

Download pre-built packages from the [Releases](https://github.com/kyokospl/personnel-management/releases) page:

| Platform | Package Type | Download |
|----------|--------------|----------|
| Fedora/RHEL | RPM | `personnel-management-*.rpm` |
| Debian/Ubuntu | DEB | `personnel-management_*.deb` |
| Arch Linux | PKGBUILD | AUR package |
| Windows | ZIP | `personnel-management-*-windows.zip` |
| Linux (Portable) | AppImage | `personnel-management-*.AppImage` |

## 📥 Installation

### Ubuntu/Debian

```bash
# Install dependencies
sudo apt update
sudo apt install qt6-base-dev qt6-declarative-dev libqt6quickcontrols2-6

# Install from .deb
sudo dpkg -i personnel-management_*.deb
```

### Fedora/RHEL

```bash
# Install dependencies
sudo dnf install qt6-qtbase qt6-qtdeclarative qt6-qtquickcontrols2

# Install from .rpm
sudo dnf install personnel-management-*.rpm
```

### Arch Linux

```bash
# From AUR (if published)
yay -S personnel-management

# Or build from PKGBUILD
cd packages/arch
makepkg -si
```

### Windows

1. Download the ZIP package from releases
2. Extract to desired location
3. Run `personnel-management.bat` or `bin/personnel_management.exe`

### macOS

```bash
# Install Qt6 via Homebrew
brew install qt6

# Build from source
mkdir build && cd build
cmake -DCMAKE_PREFIX_PATH="$(brew --prefix qt6)" ..
cmake --build .
```

## ⚙️ Configuration

### Environment Variables

The application can be configured using environment variables or a `.env` file:

| Variable | Default | Description |
|----------|---------|-------------|
| `API_BASE_URL` | `http://212.132.110.72:8082` | Backend API base URL |
| `API_PREFIX` | `/api` | API route prefix |
| `ROUTE_DEPARTMENTS` | `/departments` | Departments endpoint |
| `ROUTE_EMPLOYEES` | `/employees` | Employees endpoint |
| `ROUTE_SALARY_GRADES` | `/salary-grades` | Salary grades endpoint |

### .env File

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

The application searches for `.env` in:
1. Current working directory
2. Application directory
3. Parent directory

## 🔨 Building from Source

### Linux

```bash
# Ubuntu/Debian
sudo apt install build-essential cmake qt6-base-dev qt6-declarative-dev qt6-quickcontrols2-dev

# Fedora
sudo dnf install gcc-c++ cmake qt6-qtbase-devel qt6-qtdeclarative-devel

# Arch Linux
sudo pacman -S base-devel cmake qt6-base qt6-declarative

# Build
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
cmake --build . -j$(nproc)
```

### Windows

```bash
# Using Qt Creator
# 1. Open CMakeLists.txt
# 2. Configure with MSVC kit
# 3. Build

# Using Command Line (with Qt environment)
mkdir build && cd build
cmake -DCMAKE_PREFIX_PATH="C:\Qt\6.x.x\msvc2019_64" -DCMAKE_BUILD_TYPE=Release ..
cmake --build . --config Release
```

### macOS

```bash
brew install qt6 cmake
mkdir build && cd build
cmake -DCMAKE_PREFIX_PATH="$(brew --prefix qt6)" -DCMAKE_BUILD_TYPE=Release ..
cmake --build .
```

### CMake Options

| Option | Default | Description |
|--------|---------|-------------|
| `CMAKE_BUILD_TYPE` | `Debug` | Build type (Debug/Release/RelWithDebInfo) |
| `CMAKE_PREFIX_PATH` | - | Qt installation path |
| `CMAKE_INSTALL_PREFIX` | `/usr` | Installation prefix |
| `BUILD_TESTING` | `OFF` | Enable building tests |

## 📦 Packaging

The project includes a comprehensive packaging script supporting multiple platforms:

```bash
# Build packages for all platforms
./package.sh --all

# Build specific platforms
./package.sh fedora debian

# Clean and rebuild everything
./package.sh --clean --all

# Build only (no packaging)
./package.sh --build-only

# Create GitHub release
./package.sh --release v0.2.0
```

### Supported Package Formats

| Platform | Command | Output |
|----------|---------|--------|
| Fedora RPM | `./package.sh fedora` | `packages/fedora/*.rpm` |
| Debian DEB | `./package.sh debian` | `packages/debian/*.deb` |
| Arch Linux | `./package.sh arch` | `packages/arch/PKGBUILD` |
| Windows ZIP | `./package.sh windows` | `packages/windows/*.zip` |
| AppImage | `./package.sh appimage` | `packages/appimage/*.AppImage` |

For detailed packaging instructions, see [docs/PACKAGING.md](docs/PACKAGING.md).

## 📁 Project Structure

```
personnel_management/
├── CMakeLists.txt              # CMake build configuration
├── build.sh                    # Quick build script
├── package.sh                  # Multi-platform packaging script
├── LICENSE                     # MIT License
├── README.md                   # This file
│
├── include/                    # C++ Header files
│   ├── config.h                # Configuration management
│   ├── api/
│   │   └── apiclient.h         # REST API client
│   ├── models/
│   │   ├── department.h        # Department data model
│   │   ├── employee.h          # Employee data model
│   │   └── salarygrade.h       # Salary grade data model
│   └── gui/
│       ├── personnelapp.h      # Main application controller
│       └── material3colors.h   # Material 3 color palette
│
├── src/                        # C++ Source files
│   ├── main.cpp                # Application entry point
│   ├── api/
│   │   └── apiclient.cpp       # API client implementation
│   ├── models/
│   │   ├── department.cpp
│   │   ├── employee.cpp
│   │   └── salarygrade.cpp
│   └── gui/
│       ├── personnelapp.cpp
│       └── material3colors.cpp
│
├── resources/                  # Application resources
│   ├── fonts.qrc               # Font resource file
│   ├── resources.qrc           # Main resource file
│   ├── fonts/
│   │   └── MaterialIcons-Regular.ttf
│   ├── icons/
│   │   └── icon.png
│   └── qml/                    # QML UI files
│       ├── main.qml            # Main window
│       ├── views/              # View components
│       │   ├── DepartmentsView.qml
│       │   ├── EmployeesView.qml
│       │   └── SalaryGradesView.qml
│       ├── components/         # Reusable components
│       │   ├── MaterialButton.qml
│       │   ├── MaterialCard.qml
│       │   ├── MaterialComboBox.qml
│       │   ├── MaterialIcon.qml
│       │   ├── MaterialTextField.qml
│       │   └── SearchableEmployeeComboBox.qml
│       └── dialogs/            # Dialog components
│           ├── ConfirmDialog.qml
│           ├── DepartmentEditDialog.qml
│           ├── EmployeeEditDialog.qml
│           └── SalaryGradeEditDialog.qml
│
├── docs/                       # Documentation
│   ├── QUICKSTART.md
│   ├── ARCHITECTURE.md
│   ├── API.md
│   ├── PACKAGING.md
│   ├── CONTRIBUTING.md
│   └── CHANGELOG.md
│
└── scripts/                    # Utility scripts
    └── populate_database.py    # Database population script
```

## 🏗️ Architecture

### Technology Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| **UI Framework** | Qt Quick/QML | Declarative UI with Material Design |
| **Core Logic** | C++17 | Business logic and data handling |
| **HTTP Client** | QNetworkAccessManager | REST API communication |
| **Data Binding** | Q_PROPERTY | Seamless C++/QML integration |
| **Async Model** | Qt Signals/Slots | Event-driven architecture |
| **JSON Handling** | QJsonDocument | API request/response parsing |
| **Build System** | CMake | Cross-platform builds |

### Design Patterns

- **MVC Architecture** - Models, Views (QML), Controllers (C++)
- **Singleton Pattern** - Configuration and API client instances
- **Observer Pattern** - Qt's signal/slot mechanism
- **Property Binding** - Reactive UI updates via Q_PROPERTY

### Data Flow

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   QML UI    │◄──►│  C++ Models │◄──►│  API Client │
│  (Views)    │    │ (Q_PROPERTY)│    │  (Network)  │
└─────────────┘    └─────────────┘    └─────────────┘
       │                  │                  │
       │                  │                  │
       ▼                  ▼                  ▼
┌─────────────────────────────────────────────────┐
│              Qt Event Loop                       │
│         (Signals & Slots Processing)             │
└─────────────────────────────────────────────────┘
```

For detailed architecture documentation, see [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## 📡 API Documentation

The application connects to a REST API backend. See the API documentation at:
- **Swagger UI**: http://212.132.110.72:8082/docs/
- **OpenAPI Spec**: http://212.132.110.72:8082/openapi.json

### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/departments` | List all departments |
| POST | `/api/departments` | Create a department |
| GET | `/api/departments/{id}` | Get department by ID |
| PUT | `/api/departments/{id}` | Update department |
| DELETE | `/api/departments/{id}` | Delete department |
| GET | `/api/employees` | List all employees |
| POST | `/api/employees` | Create an employee |
| GET | `/api/employees/{id}` | Get employee by ID |
| PUT | `/api/employees/{id}` | Update employee |
| DELETE | `/api/employees/{id}` | Delete employee |
| GET | `/api/salary-grades` | List all salary grades |
| POST | `/api/salary-grades` | Create a salary grade |
| GET | `/api/salary-grades/{id}` | Get salary grade by ID |
| PUT | `/api/salary-grades/{id}` | Update salary grade |
| DELETE | `/api/salary-grades/{id}` | Delete salary grade |

For detailed API documentation, see [docs/API.md](docs/API.md).

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guidelines](docs/CONTRIBUTING.md) before submitting a Pull Request.

### Development Setup

1. Fork the repository
2. Clone your fork: `git clone https://github.com/your-username/personnel-management.git`
3. Create a feature branch: `git checkout -b feature/amazing-feature`
4. Make your changes
5. Run tests: `cmake --build build --target test`
6. Commit: `git commit -m 'Add amazing feature'`
7. Push: `git push origin feature/amazing-feature`
8. Open a Pull Request

### Code Style

- Follow Qt coding conventions
- Use meaningful variable and function names
- Document public APIs with comments
- Write unit tests for new features

## 📝 Changelog

See [docs/CHANGELOG.md](docs/CHANGELOG.md) for a list of changes in each version.

### Current Version: 0.2.0

#### What's New
- Full CRUD operations for all entities
- Material Design 3 UI with dark/light themes
- Embedded Material Icons font
- Environment-based configuration
- Multi-platform packaging support
- GitHub release automation

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Qt Project](https://www.qt.io/) - Cross-platform application framework
- [Material Design](https://material.io/) - Design system by Google
- [Material Icons](https://fonts.google.com/icons) - Icon font

## 📧 Contact

- **Maintainer**: Kyoko Kiese
- **Email**: kyokokiese@proton.me
- **Project URL**: https://github.com/kyokospl/personnel-management

---

<p align="center">
  Made with ❤️ for the LF11A Project
</p>