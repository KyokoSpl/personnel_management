# Personnel Management System v1.0.0

A modern, cross-platform Personnel Management System frontend built with **C++17** and **Qt6/QML**, featuring a beautiful **Material Design 3** user interface.

## 📦 Downloads

| Platform | Package Type | Installation |
|----------|--------------|--------------|
| 🐧 **Fedora/RHEL** | RPM | See instructions below |
| 🐧 **Debian/Ubuntu** | DEB | See instructions below |
| 🐧 **Arch Linux** | PKGBUILD + Tarball | See instructions below |
| 🪟 **Windows** | Setup Installer | Download and run setup.exe |
| 🐧 **Linux (Any)** | AppImage (portable) | Download and execute |

---

## 🚀 Installation Instructions

### Windows
1. Download **personnel-management-1.0.0-setup.exe** from the Assets section below
2. Run the installer
3. Follow the installation wizard
4. Launch from Start Menu or Desktop shortcut

**Requirements:** Windows 10 or later (64-bit)

---

### Fedora / RHEL / CentOS / openSUSE
```bash
# Download the RPM file from the Assets section below, then:
sudo dnf install ./personnel-management-1.0.0-1.x86_64.rpm

# Or on older systems:
sudo rpm -ivh personnel-management-1.0.0-1.x86_64.rpm
```

After installation, launch from your application menu or run:
```bash
personnel-management
```

---

### Debian / Ubuntu / Linux Mint / Pop!_OS
```bash
# Download the DEB file from the Assets section below, then:
sudo apt install ./personnel-management_1.0.0.deb

# Or manually:
sudo dpkg -i personnel-management_1.0.0.deb
sudo apt install -f  # Fix any missing dependencies
```

After installation, launch from your application menu or run:
```bash
personnel-management
```

---

### Arch Linux / Manjaro / EndeavourOS
```bash
# Download BOTH files from the Assets section:
# - personnel-management-1.0.0.tar.gz (source tarball)
# - PKGBUILD

# Place them in the same directory, then:
makepkg -si

# This will build and install the package with dependencies
```

After installation, launch from your application menu or run:
```bash
personnel-management
```

**Note**: The PKGBUILD expects the tarball to be in the same directory. Do not extract the tarball manually.

---

### Windows 10/11
1. Download **personnel-management-1.0.0-windows.zip** from the Assets section
2. Extract the ZIP file to a folder (e.g., `C:\Program Files\PersonnelManagement`)
3. Run **personnel_management.exe** from the `bin` folder

**No installation required** - all Qt dependencies are included!

Optional: Create a desktop shortcut to `bin\personnel_management.exe`

---

### AppImage (Universal Linux - Any Distribution)
```bash
# Download the AppImage from the Assets section:
wget https://github.com/KyokoSpl/personnel_management/releases/download/v1.0.0/personnel-management-1.0.0-x86_64.AppImage

# Make it executable:
chmod +x personnel-management-1.0.0-x86_64.AppImage

# Run it:
./personnel-management-1.0.0-x86_64.AppImage
```

**No installation required** - works on any Linux distribution with FUSE support!

To integrate with your system:
```bash
# Optional: Install AppImageLauncher for better desktop integration
# Debian/Ubuntu: sudo apt install appimagelauncher
# Arch: sudo pacman -S appimagelauncher
```

---

## 📝 What's New

### Changes since v0.5.2

- bumped up version (65dc3da)
- fix: NSIS gets version from CMakeLists.txt, improve dialog button spacing (91479e3)

**Commits**: 2

---

## ⚙️ Configuration

The application connects to the backend API server. You can customize this by creating a `.env` file in the application directory:

```bash
API_BASE_URL=http://your-server:8082
API_PREFIX=/api
```

**Default API server**: `http://localhost:8082`

**Configuration file location**:
- **Linux**: Same directory as the executable or `~/.config/personnel_management/.env`
- **Windows**: Same directory as `personnel_management.exe`

---

## 💻 System Requirements

### Linux
- **Qt6 Runtime**: 6.2 or later (automatically installed with packages)
- **OpenGL**: OpenGL 2.1+ support
- **Display**: X11 or Wayland
- **RAM**: 256 MB minimum, 512 MB recommended

### Windows
- **OS**: Windows 10 (64-bit) or later
- **Runtime**: Visual C++ Redistributable 2019+ (included in package)
- **RAM**: 256 MB minimum, 512 MB recommended

---

## 🔐 Checksums (SHA256)

```
personnel-management-1.0.0-x86_64.AppImage
PKGBUILD
personnel-management-1.0.0.tar.gz
personnel-management_1.0.0.deb
personnel-management-1.0.0-1.fc42.x86_64.rpm
personnel-management-1.0.0-1.fc42.src.rpm
```

---

**Full Changelog**: https://github.com/KyokoSpl/personnel_management/blob/main/docs/CHANGELOG.md
