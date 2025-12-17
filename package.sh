#!/bin/bash
# Personnel Management System - Multi-platform Packaging Script
# Supports: Fedora (RPM), ArchLinux (PKGBUILD), Debian (DEB), Windows (ZIP/EXE), AppImage
# Also supports GitHub release creation via gh CLI

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Project information
PROJECT_NAME="personnel-management"
PROJECT_VERSION="0.2.0"
PROJECT_DESCRIPTION="Personnel Management System - Qt6/QML Frontend Application"
PROJECT_MAINTAINER="Kyoko Kiese <kyokokiese@proton.me>"
PROJECT_URL="https://github.com/kyokospl/personnel-management"
LICENSE="MIT"

# GitHub information (auto-detected from git remote if not set)
GITHUB_OWNER=""
GITHUB_REPO=""

# Build directory
BUILD_DIR="build"
BUILD_DIR_WIN="build-windows"
PACKAGE_DIR="packages"
DIST_DIR="dist"
RELEASE_NOTES_FILE="RELEASE_NOTES.md"
GITHUB_ARTIFACTS_DIR="github-artifacts"

# MinGW toolchain
MINGW_PREFIX="x86_64-w64-mingw32"

# Function to print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}========================================${NC}"
}

# Function to check dependencies
check_dependencies() {
    local platform=$1
    print_info "Checking dependencies for $platform packaging..."

    case $platform in
        fedora)
            if ! command -v rpmbuild &> /dev/null; then
                print_error "rpmbuild not found. Install with: sudo dnf install rpm-build rpmdevtools"
                return 1
            fi
            ;;
        arch)
            if ! command -v makepkg &> /dev/null; then
                print_error "makepkg not found. Install base-devel package group."
                return 1
            fi
            ;;
        debian)
            if ! command -v dpkg-deb &> /dev/null; then
                print_error "dpkg-deb not found. Install with: sudo apt install dpkg-dev"
                return 1
            fi
            ;;
        windows)
            if ! command -v ${MINGW_PREFIX}-g++ &> /dev/null; then
                print_error "MinGW-w64 cross-compiler not found (${MINGW_PREFIX}-g++)."
                print_info "Install on Arch Linux:"
                print_info "  sudo pacman -S mingw-w64-gcc"
                print_info "  # For Qt6, install from AUR:"
                print_info "  paru -S mingw-w64-qt6-base mingw-w64-qt6-declarative"
                print_info ""
                print_info "Install on Fedora:"
                print_info "  sudo dnf install mingw64-gcc-c++ mingw64-qt6-qtbase mingw64-qt6-qtdeclarative"
                return 1
            fi
            ;;
        github-artifacts)
            if ! command -v gh &> /dev/null; then
                print_error "GitHub CLI (gh) not found."
                print_info "Install with:"
                print_info "  Fedora: sudo dnf install gh"
                print_info "  Debian/Ubuntu: sudo apt install gh"
                print_info "  Arch: sudo pacman -S github-cli"
                return 1
            fi
            if ! command -v unzip &> /dev/null; then
                print_error "unzip not found. Install it first."
                return 1
            fi
            ;;
        release)
            if ! command -v gh &> /dev/null; then
                print_error "GitHub CLI (gh) not found."
                print_info "Install with:"
                print_info "  Fedora: sudo dnf install gh"
                print_info "  Debian/Ubuntu: sudo apt install gh"
                print_info "  Arch: sudo pacman -S github-cli"
                print_info "  macOS: brew install gh"
                print_info ""
                print_info "Then authenticate with: gh auth login"
                return 1
            fi
            if ! gh auth status &> /dev/null; then
                print_error "GitHub CLI is not authenticated. Run: gh auth login"
                return 1
            fi
            ;;
    esac
    return 0
}

# Function to find MinGW Qt6 installation
find_mingw_qt6() {
    local qt6_paths=(
        "/usr/${MINGW_PREFIX}/lib/cmake/Qt6"
        "/usr/lib/mingw64/lib/cmake/Qt6"
        "/opt/mingw64/lib/cmake/Qt6"
        "/usr/${MINGW_PREFIX}/share/qt6"
    )

    for path in "${qt6_paths[@]}"; do
        if [ -f "${path}/Qt6Config.cmake" ] || [ -f "${path}/../Qt6Config.cmake" ]; then
            echo "$(dirname "$path")"
            return 0
        fi
    done

    # Try to find using pkg-config or cmake
    local cmake_qt6=$(${MINGW_PREFIX}-pkg-config --variable=libdir Qt6Core 2>/dev/null || true)
    if [ -n "$cmake_qt6" ]; then
        echo "$cmake_qt6/cmake"
        return 0
    fi

    return 1
}

# Function to detect GitHub repo from git remote
detect_github_repo() {
    if [ -n "$GITHUB_OWNER" ] && [ -n "$GITHUB_REPO" ]; then
        return 0
    fi

    # Try to get from git remote
    local REMOTE_URL=$(git remote get-url origin 2>/dev/null || true)

    if [ -z "$REMOTE_URL" ]; then
        print_error "Could not detect GitHub repository. No git remote 'origin' found."
        return 1
    fi

    # Parse GitHub URL (supports both HTTPS and SSH formats)
    # https://github.com/owner/repo.git
    # git@github.com:owner/repo.git
    if [[ "$REMOTE_URL" =~ github\.com[:/]([^/]+)/([^/.]+)(\.git)?$ ]]; then
        GITHUB_OWNER="${BASH_REMATCH[1]}"
        GITHUB_REPO="${BASH_REMATCH[2]}"
        print_info "Detected GitHub repo: $GITHUB_OWNER/$GITHUB_REPO"
        return 0
    else
        print_error "Could not parse GitHub repository from remote URL: $REMOTE_URL"
        return 1
    fi
}

# Function to build the application (Linux)
build_application() {
    print_header "Building Application (Linux)"

    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"

    print_info "Configuring with CMake..."
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX=/usr \
          ..

    print_info "Compiling..."
    cmake --build . -j$(nproc)

    cd ..
    print_success "Linux application built successfully"
}

# Function to download Windows build from GitHub Actions
download_windows_artifact() {
    print_header "Downloading Windows Build from GitHub Actions"

    check_dependencies github-artifacts || return 1

    # Auto-detect GitHub repo
    detect_github_repo || return 1

    mkdir -p "$GITHUB_ARTIFACTS_DIR"

    print_info "Repository: $GITHUB_OWNER/$GITHUB_REPO"
    print_info "Fetching latest successful workflow run..."

    # Try different workflow names (ci.yml, CI.yml, build.yml, etc.)
    local WORKFLOW_NAMES=("ci.yml" "CI.yml" "build.yml" "main.yml" "")
    local RUN_ID=""

    for workflow in "${WORKFLOW_NAMES[@]}"; do
        if [ -n "$workflow" ]; then
            RUN_ID=$(gh run list \
                --repo "$GITHUB_OWNER/$GITHUB_REPO" \
                --workflow "$workflow" \
                --status success \
                --limit 1 \
                --json databaseId \
                --jq '.[0].databaseId' 2>/dev/null)
        else
            # Try without workflow filter (get any successful run)
            RUN_ID=$(gh run list \
                --repo "$GITHUB_OWNER/$GITHUB_REPO" \
                --status success \
                --limit 1 \
                --json databaseId \
                --jq '.[0].databaseId' 2>/dev/null)
        fi

        if [ -n "$RUN_ID" ] && [ "$RUN_ID" != "null" ]; then
            print_info "Found workflow run: $RUN_ID"
            break
        fi
    done

    if [ -z "$RUN_ID" ] || [ "$RUN_ID" = "null" ]; then
        print_error "No successful workflow runs found."
        print_info ""
        print_info "Possible causes:"
        print_info "  1. No CI workflow has run successfully yet"
        print_info "  2. The repository doesn't have GitHub Actions enabled"
        print_info "  3. You don't have access to the repository"
        print_info ""
        print_info "To trigger a CI build:"
        print_info "  git push origin main"
        print_info ""
        print_info "To check workflow runs:"
        print_info "  gh run list --repo $GITHUB_OWNER/$GITHUB_REPO"
        return 1
    fi

    # Try to download Windows artifact directly
    # Try different artifact names that might be used
    local ARTIFACT_NAMES=("personnel-management-windows" "windows-build" "windows" "build-windows")
    local ARTIFACT_FOUND=false

    print_info "Attempting to download Windows artifact..."

    for artifact_name in "${ARTIFACT_NAMES[@]}"; do
        print_info "  Trying artifact: $artifact_name"
        if gh run download "$RUN_ID" \
            --repo "$GITHUB_OWNER/$GITHUB_REPO" \
            --name "$artifact_name" \
            --dir "$GITHUB_ARTIFACTS_DIR/windows" 2>/dev/null; then
            print_success "Downloaded artifact: $artifact_name"
            ARTIFACT_FOUND=true
            break
        fi
    done

    if [ "$ARTIFACT_FOUND" = false ]; then
        print_error "Could not download Windows artifact."
        print_info ""
        print_info "Tried artifact names: ${ARTIFACT_NAMES[*]}"
        print_info ""
        print_info "To see available artifacts, run:"
        print_info "  gh run view $RUN_ID --repo $GITHUB_OWNER/$GITHUB_REPO"
        return 1
    fi

    # Verify the download
    if [ -f "$GITHUB_ARTIFACTS_DIR/windows/personnel_management.exe" ]; then
        print_success "Windows executable downloaded successfully!"
        print_info "Location: $GITHUB_ARTIFACTS_DIR/windows/personnel_management.exe"
        return 0
    elif ls "$GITHUB_ARTIFACTS_DIR/windows/"*.exe &>/dev/null 2>&1; then
        print_success "Windows executable downloaded successfully!"
        print_info "Location: $GITHUB_ARTIFACTS_DIR/windows/"
        return 0
    else
        print_error "Windows executable not found in downloaded artifact."
        print_info "Contents of download:"
        ls -la "$GITHUB_ARTIFACTS_DIR/windows/" 2>/dev/null || echo "  (empty)"
        return 1
    fi
}

# Function to build Windows executable using MinGW cross-compilation
build_windows() {
    print_header "Building Windows Executable (Cross-compilation)"

    check_dependencies windows || return 1

    # Find Qt6 for MinGW
    local QT6_PATH=$(find_mingw_qt6)
    if [ -z "$QT6_PATH" ]; then
        print_error "Could not find MinGW Qt6 installation."
        print_info "Install Qt6 for MinGW from AUR:"
        print_info "  paru -S mingw-w64-qt6-base mingw-w64-qt6-declarative mingw-w64-qt6-quickcontrols2"
        return 1
    fi

    print_info "Found MinGW Qt6 at: $QT6_PATH"

    mkdir -p "$BUILD_DIR_WIN"
    cd "$BUILD_DIR_WIN"

    # Create toolchain file for cross-compilation
    cat > mingw-toolchain.cmake << EOF
set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR x86_64)

set(CMAKE_C_COMPILER ${MINGW_PREFIX}-gcc)
set(CMAKE_CXX_COMPILER ${MINGW_PREFIX}-g++)
set(CMAKE_RC_COMPILER ${MINGW_PREFIX}-windres)

set(CMAKE_FIND_ROOT_PATH /usr/${MINGW_PREFIX})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

set(CMAKE_PREFIX_PATH "${QT6_PATH}")
EOF

    print_info "Configuring with CMake for Windows..."
    cmake -DCMAKE_TOOLCHAIN_FILE=mingw-toolchain.cmake \
          -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_PREFIX_PATH="$QT6_PATH" \
          .. 2>&1 || {
        print_error "CMake configuration failed."
        print_info "Make sure MinGW Qt6 packages are installed:"
        print_info "  paru -S mingw-w64-qt6-base mingw-w64-qt6-declarative"
        cd ..
        return 1
    }

    print_info "Compiling for Windows..."
    cmake --build . -j$(nproc) 2>&1 || {
        print_error "Windows build failed."
        cd ..
        return 1
    }

    cd ..
    print_success "Windows executable built successfully"
}

# Function to create Fedora RPM package
package_fedora() {
    print_header "Creating Fedora RPM Package"

    check_dependencies fedora || return 1

    local RPM_BUILD_DIR="$HOME/rpmbuild"
    mkdir -p "$RPM_BUILD_DIR"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

    local SPEC_FILE="$RPM_BUILD_DIR/SPECS/${PROJECT_NAME}.spec"
    cat > "$SPEC_FILE" << EOF
Name:           ${PROJECT_NAME}
Version:        ${PROJECT_VERSION}
Release:        1%{?dist}
Summary:        ${PROJECT_DESCRIPTION}

License:        ${LICENSE}
URL:            ${PROJECT_URL}
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  cmake >= 3.21
BuildRequires:  gcc-c++
BuildRequires:  qt6-qtbase-devel
BuildRequires:  qt6-qtdeclarative-devel

Requires:       qt6-qtbase
Requires:       qt6-qtdeclarative
Requires:       qt6-qtquickcontrols2

%description
Personnel Management System is a modern Qt6/QML application for managing
employees, departments, and salary grades in an organization.

%prep
%autosetup

%build
mkdir -p %{_vpath_builddir}
cd %{_vpath_builddir}
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%{_prefix} -DBUILD_TESTING=OFF ..
make %{?_smp_mflags}

%install
cd %{_vpath_builddir}
make install DESTDIR=%{buildroot}
ln -sf personnel_management %{buildroot}%{_bindir}/personnel-management
mkdir -p %{buildroot}%{_datadir}/applications
cat > %{buildroot}%{_datadir}/applications/personnel-management.desktop << 'DESKTOP'
[Desktop Entry]
Name=Personnel Management
Comment=Personnel Management System
Exec=personnel-management
Icon=personnel-management
Terminal=false
Type=Application
Categories=Office;Database;
DESKTOP

%files
%license LICENSE
%doc README.md
%{_bindir}/personnel_management
%{_bindir}/personnel-management
%{_datadir}/personnel_management/
%{_datadir}/applications/personnel-management.desktop

%changelog
* $(LC_TIME=C date "+%a %b %d %Y") ${PROJECT_MAINTAINER} - ${PROJECT_VERSION}-1
- Release ${PROJECT_VERSION}
EOF

    print_info "Creating source tarball..."
    local TARBALL="$RPM_BUILD_DIR/SOURCES/${PROJECT_NAME}-${PROJECT_VERSION}.tar.gz"
    tar --exclude='.git' --exclude='build' --exclude='build-windows' --exclude='packages' --exclude='dist' \
        --transform "s,^,${PROJECT_NAME}-${PROJECT_VERSION}/," -czf "$TARBALL" .

    print_info "Building RPM package..."
    if rpmbuild -ba "$SPEC_FILE" 2>&1 || rpmbuild -ba --nodeps "$SPEC_FILE" 2>&1; then
        mkdir -p "$PACKAGE_DIR/fedora"
        cp "$RPM_BUILD_DIR/RPMS/x86_64/${PROJECT_NAME}-${PROJECT_VERSION}"*.rpm "$PACKAGE_DIR/fedora/" 2>/dev/null || true
        cp "$RPM_BUILD_DIR/SRPMS/${PROJECT_NAME}-${PROJECT_VERSION}"*.src.rpm "$PACKAGE_DIR/fedora/" 2>/dev/null || true
        print_success "Fedora RPM package created: $PACKAGE_DIR/fedora/"
    else
        print_error "RPM build failed"
        return 1
    fi
}

# Function to create ArchLinux PKGBUILD
package_arch() {
    print_header "Creating Arch Linux Package"

    check_dependencies arch || return 1

    mkdir -p "$PACKAGE_DIR/arch"

    cat > "$PACKAGE_DIR/arch/PKGBUILD" << EOF
# Maintainer: ${PROJECT_MAINTAINER}
pkgname=${PROJECT_NAME}
pkgver=${PROJECT_VERSION}
pkgrel=1
pkgdesc="${PROJECT_DESCRIPTION}"
arch=('x86_64')
url="${PROJECT_URL}"
license=('${LICENSE}')
depends=('qt6-base' 'qt6-declarative')
makedepends=('cmake' 'git')
source=("\${pkgname}-\${pkgver}.tar.gz")
sha256sums=('SKIP')

build() {
    cd "\${srcdir}/\${pkgname}-\${pkgver}"
    cmake -B build -S . -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -DBUILD_TESTING=OFF
    cmake --build build
}

package() {
    cd "\${srcdir}/\${pkgname}-\${pkgver}"
    DESTDIR="\${pkgdir}" cmake --install build
    install -dm755 "\${pkgdir}/usr/share/\${pkgname}/qml"
    cp -r resources/qml/* "\${pkgdir}/usr/share/\${pkgname}/qml/"
    install -Dm644 /dev/stdin "\${pkgdir}/usr/share/applications/\${pkgname}.desktop" << DESKTOP
[Desktop Entry]
Name=Personnel Management
Comment=Personnel Management System
Exec=personnel_management
Icon=personnel-management
Terminal=false
Type=Application
Categories=Office;Database;
DESKTOP
    install -Dm644 README.md "\${pkgdir}/usr/share/doc/\${pkgname}/README.md"
}
EOF

    print_info "Creating source tarball for ArchLinux..."
    local TEMP_DIR=$(mktemp -d)
    local TARGET_DIR="$TEMP_DIR/${PROJECT_NAME}-${PROJECT_VERSION}"
    local ORIGINAL_DIR="$(pwd)"
    mkdir -p "$TARGET_DIR/scripts"

    cp -r src include resources CMakeLists.txt "$TARGET_DIR/"
    cp README.md LICENSE build.sh "$TARGET_DIR/" 2>/dev/null || true

    cd "$TEMP_DIR"
    tar -czf "${PROJECT_NAME}-${PROJECT_VERSION}.tar.gz" "${PROJECT_NAME}-${PROJECT_VERSION}"
    mv "${PROJECT_NAME}-${PROJECT_VERSION}.tar.gz" "$ORIGINAL_DIR/$PACKAGE_DIR/arch/"
    cd "$ORIGINAL_DIR"
    rm -rf "$TEMP_DIR"

    cd "$PACKAGE_DIR/arch"
    makepkg --printsrcinfo > .SRCINFO
    cd "$ORIGINAL_DIR"

    print_success "ArchLinux PKGBUILD created: $PACKAGE_DIR/arch/"
}

# Function to create Debian DEB package
package_debian() {
    print_header "Creating Debian DEB Package"

    check_dependencies debian || return 1

    local DEB_DIR="$PACKAGE_DIR/debian/${PROJECT_NAME}_${PROJECT_VERSION}"
    rm -rf "$DEB_DIR"

    mkdir -p "$DEB_DIR/DEBIAN"
    mkdir -p "$DEB_DIR/usr/bin"
    mkdir -p "$DEB_DIR/usr/share/${PROJECT_NAME}"
    mkdir -p "$DEB_DIR/usr/share/applications"
    mkdir -p "$DEB_DIR/usr/share/doc/${PROJECT_NAME}"

    cat > "$DEB_DIR/DEBIAN/control" << EOF
Package: ${PROJECT_NAME}
Version: ${PROJECT_VERSION}
Section: misc
Priority: optional
Architecture: amd64
Depends: libqt6core6, libqt6gui6, libqt6qml6, libqt6quick6, libqt6network6, qml6-module-qtquick, qml6-module-qtquick-controls
Maintainer: ${PROJECT_MAINTAINER}
Description: ${PROJECT_DESCRIPTION}
 Personnel Management System is a modern Qt6/QML application for managing
 employees, departments, and salary grades in an organization.
Homepage: ${PROJECT_URL}
EOF

    cp "$BUILD_DIR/personnel_management" "$DEB_DIR/usr/bin/"
    chmod +x "$DEB_DIR/usr/bin/personnel_management"
    ln -sf personnel_management "$DEB_DIR/usr/bin/${PROJECT_NAME}"

    cp -r resources/qml "$DEB_DIR/usr/share/${PROJECT_NAME}/"

    cat > "$DEB_DIR/usr/share/applications/${PROJECT_NAME}.desktop" << EOF
[Desktop Entry]
Name=Personnel Management
Comment=Personnel Management System
Exec=personnel_management
Icon=personnel-management
Terminal=false
Type=Application
Categories=Office;Database;
EOF

    cp README.md "$DEB_DIR/usr/share/doc/${PROJECT_NAME}/"

    dpkg-deb --build "$DEB_DIR"

    print_success "Debian DEB package created: $PACKAGE_DIR/debian/${PROJECT_NAME}_${PROJECT_VERSION}.deb"
}

# Function to create Windows package
package_windows() {
    print_header "Creating Windows Package"

    local WIN_DIR="$PACKAGE_DIR/windows/${PROJECT_NAME}-${PROJECT_VERSION}-windows"
    rm -rf "$WIN_DIR"
    mkdir -p "$WIN_DIR/bin"
    mkdir -p "$WIN_DIR/qml"
    mkdir -p "$WIN_DIR/platforms"
    mkdir -p "$WIN_DIR/imageformats"

    local WINDOWS_EXE_FOUND=false
    local USE_GITHUB_ARTIFACT=false

    # Check for GitHub Actions artifact first (preferred - has all Qt DLLs)
    if [ -d "$GITHUB_ARTIFACTS_DIR/windows" ]; then
        if [ -f "$GITHUB_ARTIFACTS_DIR/windows/personnel_management.exe" ]; then
            print_info "Using Windows build from GitHub Actions artifact..."
            USE_GITHUB_ARTIFACT=true
            WINDOWS_EXE_FOUND=true

            # Copy everything from the artifact (includes Qt DLLs from windeployqt)
            cp -r "$GITHUB_ARTIFACTS_DIR/windows/"* "$WIN_DIR/bin/" 2>/dev/null || true

            # Move exe to bin if it's in root
            if [ -f "$WIN_DIR/bin/personnel_management.exe" ]; then
                print_success "Windows executable and dependencies copied from GitHub artifact"
            fi
        elif ls "$GITHUB_ARTIFACTS_DIR/windows/"*.exe &>/dev/null 2>&1; then
            print_info "Using Windows build from GitHub Actions artifact..."
            USE_GITHUB_ARTIFACT=true
            WINDOWS_EXE_FOUND=true
            cp -r "$GITHUB_ARTIFACTS_DIR/windows/"* "$WIN_DIR/bin/" 2>/dev/null || true
            print_success "Windows executable and dependencies copied from GitHub artifact"
        fi
    fi

    # Fall back to local MinGW cross-compiled build
    if [ "$WINDOWS_EXE_FOUND" = false ] && [ -f "$BUILD_DIR_WIN/personnel_management.exe" ]; then
        print_info "Using locally cross-compiled Windows executable..."
        cp "$BUILD_DIR_WIN/personnel_management.exe" "$WIN_DIR/bin/"
        WINDOWS_EXE_FOUND=true

        # Copy Qt DLLs if available
        local QT6_BIN="/usr/${MINGW_PREFIX}/bin"
        local QT6_PLUGINS="/usr/${MINGW_PREFIX}/lib/qt6/plugins"

        if [ -d "$QT6_BIN" ]; then
            print_info "Copying Qt6 DLLs..."
            for dll in Qt6Core Qt6Gui Qt6Qml Qt6Quick Qt6Network Qt6QuickControls2 Qt6QmlModels Qt6OpenGL; do
                [ -f "$QT6_BIN/${dll}.dll" ] && cp "$QT6_BIN/${dll}.dll" "$WIN_DIR/bin/"
            done
        fi

        # Copy MinGW runtime DLLs
        for dll in libgcc_s_seh-1 libstdc++-6 libwinpthread-1; do
            [ -f "$QT6_BIN/${dll}.dll" ] && cp "$QT6_BIN/${dll}.dll" "$WIN_DIR/bin/"
            [ -f "/usr/${MINGW_PREFIX}/bin/${dll}.dll" ] && cp "/usr/${MINGW_PREFIX}/bin/${dll}.dll" "$WIN_DIR/bin/"
        done

        # Copy platform plugins
        if [ -d "$QT6_PLUGINS/platforms" ]; then
            cp "$QT6_PLUGINS/platforms/qwindows.dll" "$WIN_DIR/platforms/" 2>/dev/null || true
        fi

        print_success "Local Windows build packaged (may need additional DLLs)"
    fi

    # If still no Windows exe found, show instructions
    if [ "$WINDOWS_EXE_FOUND" = false ]; then
        print_warning "No Windows executable found."
        print_info ""
        print_info "Options to get Windows build:"
        print_info "  1. Download from GitHub Actions (recommended):"
        print_info "     ./package.sh --download-windows"
        print_info ""
        print_info "  2. Cross-compile locally with MinGW:"
        print_info "     ./package.sh --build-windows"
        print_info ""
        return 1
    fi

    # Copy QML files
    cp -r resources/qml/* "$WIN_DIR/qml/"

    # Create batch file launcher
    cat > "$WIN_DIR/${PROJECT_NAME}.bat" << 'BATCH'
@echo off
cd /d "%~dp0"
set QML_IMPORT_PATH=%~dp0qml
set QT_PLUGIN_PATH=%~dp0
start "" "%~dp0bin\personnel_management.exe"
BATCH

    # Create README for Windows users
    cat > "$WIN_DIR/README.txt" << EOF
Personnel Management System v${PROJECT_VERSION}
=============================================

To run the application:
1. Double-click ${PROJECT_NAME}.bat
   OR
2. Run bin\personnel_management.exe directly

Requirements:
- Windows 10 or later (64-bit)
- Visual C++ Redistributable 2019 or later

If the application doesn't start:
1. Install Visual C++ Redistributable from Microsoft
2. Make sure all DLL files are present in the bin folder
3. Check that your Windows version is supported

Configuration:
Create a .env file in the same folder as the executable to customize settings:
  API_BASE_URL=http://your-server:8082
  API_PREFIX=/api

For more information, visit: ${PROJECT_URL}
EOF

    # Copy main documentation
    cp README.md "$WIN_DIR/" 2>/dev/null || true
    cp LICENSE "$WIN_DIR/" 2>/dev/null || true

    # Create ZIP package
    cd "$PACKAGE_DIR/windows"
    if command -v 7z &> /dev/null; then
        7z a -tzip "${PROJECT_NAME}-${PROJECT_VERSION}-windows.zip" "${PROJECT_NAME}-${PROJECT_VERSION}-windows" > /dev/null
    else
        zip -rq "${PROJECT_NAME}-${PROJECT_VERSION}-windows.zip" "${PROJECT_NAME}-${PROJECT_VERSION}-windows"
    fi
    cd - > /dev/null

    print_success "Windows package created: $PACKAGE_DIR/windows/${PROJECT_NAME}-${PROJECT_VERSION}-windows.zip"
}

# Function to create AppImage
package_appimage() {
    print_header "Creating AppImage"

    if ! command -v appimagetool &> /dev/null; then
        print_warning "appimagetool not found. Attempting to download..."
        local APPIMAGETOOL_URL="https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
        if command -v wget &> /dev/null; then
            wget -q "$APPIMAGETOOL_URL" -O /tmp/appimagetool
            chmod +x /tmp/appimagetool
            APPIMAGETOOL="/tmp/appimagetool"
        else
            print_error "Cannot download appimagetool. Install wget or download manually."
            return 1
        fi
    else
        APPIMAGETOOL="appimagetool"
    fi

    local APPDIR="$PACKAGE_DIR/appimage/${PROJECT_NAME}.AppDir"
    rm -rf "$APPDIR"
    mkdir -p "$APPDIR/usr/bin"
    mkdir -p "$APPDIR/usr/share/${PROJECT_NAME}"
    mkdir -p "$APPDIR/usr/share/applications"
    mkdir -p "$APPDIR/usr/share/icons/hicolor/256x256/apps"

    cp "$BUILD_DIR/personnel_management" "$APPDIR/usr/bin/"
    cp -r resources/qml "$APPDIR/usr/share/${PROJECT_NAME}/"

    cat > "$APPDIR/AppRun" << 'EOF'
#!/bin/bash
APPDIR="$(dirname "$(readlink -f "$0")")"
export LD_LIBRARY_PATH="$APPDIR/usr/lib:$LD_LIBRARY_PATH"
export QML_IMPORT_PATH="$APPDIR/usr/share/personnel-management/qml"
exec "$APPDIR/usr/bin/personnel_management" "$@"
EOF
    chmod +x "$APPDIR/AppRun"

    cat > "$APPDIR/${PROJECT_NAME}.desktop" << EOF
[Desktop Entry]
Name=Personnel Management
Comment=Personnel Management System
Exec=personnel_management
Icon=personnel-management
Terminal=false
Type=Application
Categories=Office;Database;
EOF
    cp "$APPDIR/${PROJECT_NAME}.desktop" "$APPDIR/usr/share/applications/"

    # Create a simple icon placeholder
    if [ -f "resources/icons/icon.png" ]; then
        cp "resources/icons/icon.png" "$APPDIR/personnel-management.png"
        cp "resources/icons/icon.png" "$APPDIR/usr/share/icons/hicolor/256x256/apps/personnel-management.png"
    else
        # Create a placeholder icon
        convert -size 256x256 xc:purple -fill white -gravity center -pointsize 48 -annotate 0 "PM" \
            "$APPDIR/personnel-management.png" 2>/dev/null || \
        echo "No icon created (ImageMagick not installed)"
    fi

    cd "$PACKAGE_DIR/appimage"
    ARCH=x86_64 "$APPIMAGETOOL" "${PROJECT_NAME}.AppDir" "${PROJECT_NAME}-${PROJECT_VERSION}-x86_64.AppImage" 2>/dev/null || {
        print_warning "AppImage creation had issues. The AppDir is ready for manual packaging."
    }
    cd - > /dev/null

    if [ -f "$PACKAGE_DIR/appimage/${PROJECT_NAME}-${PROJECT_VERSION}-x86_64.AppImage" ]; then
        print_success "AppImage created: $PACKAGE_DIR/appimage/${PROJECT_NAME}-${PROJECT_VERSION}-x86_64.AppImage"
    else
        print_warning "AppImage may not have been created. Check $PACKAGE_DIR/appimage/"
    fi
}

# Function to get commits since last tag
get_commits_since_last_tag() {
    local current_tag="$1"

    # Get the previous tag
    local prev_tag=$(git describe --tags --abbrev=0 HEAD^ 2>/dev/null || git rev-list --max-parents=0 HEAD)

    if [ -z "$prev_tag" ] || [ "$prev_tag" = "$current_tag" ]; then
        # No previous tag, get all commits
        git log --pretty=format:"- %s (%h)" --no-merges 2>/dev/null | head -50
    else
        # Get commits between tags with better formatting
        echo "### Changes since ${prev_tag}"
        echo ""
        git log "${prev_tag}..HEAD" --pretty=format:"- %s (%h)" --no-merges 2>/dev/null | head -100
        echo ""
        echo ""
        echo "**Commits**: $(git rev-list --count ${prev_tag}..HEAD)"
    fi
}

# Function to generate release notes
generate_release_notes() {
    local TAG="$1"
    local NOTES_FILE="$2"

    print_info "Generating release notes..."

    # Get commits since last release
    local CHANGES=$(get_commits_since_last_tag "$TAG")
    if [ -z "$CHANGES" ]; then
        CHANGES="- Initial release"
    fi

    cat > "$NOTES_FILE" << EOF
# Personnel Management System ${TAG}

A modern, cross-platform Personnel Management System frontend built with **C++17** and **Qt6/QML**, featuring a beautiful **Material Design 3** user interface.

## 📦 Downloads

| Platform | Package Type | Installation |
|----------|--------------|--------------|
| 🐧 **Fedora/RHEL** | RPM | See instructions below |
| 🐧 **Debian/Ubuntu** | DEB | See instructions below |
| 🐧 **Arch Linux** | PKGBUILD + Tarball | See instructions below |
| 🪟 **Windows** | ZIP (portable) | Extract and run |
| 🐧 **Linux (Any)** | AppImage (portable) | Download and execute |

---

## 🚀 Installation Instructions

### Fedora / RHEL / CentOS / openSUSE
\`\`\`bash
# Download the RPM file from the Assets section below, then:
sudo dnf install ./personnel-management-${PROJECT_VERSION}-1.x86_64.rpm

# Or on older systems:
sudo rpm -ivh personnel-management-${PROJECT_VERSION}-1.x86_64.rpm
\`\`\`

After installation, launch from your application menu or run:
\`\`\`bash
personnel-management
\`\`\`

---

### Debian / Ubuntu / Linux Mint / Pop!_OS
\`\`\`bash
# Download the DEB file from the Assets section below, then:
sudo apt install ./personnel-management_${PROJECT_VERSION}.deb

# Or manually:
sudo dpkg -i personnel-management_${PROJECT_VERSION}.deb
sudo apt install -f  # Fix any missing dependencies
\`\`\`

After installation, launch from your application menu or run:
\`\`\`bash
personnel-management
\`\`\`

---

### Arch Linux / Manjaro / EndeavourOS
\`\`\`bash
# Download BOTH files from the Assets section:
# - personnel-management-${PROJECT_VERSION}.tar.gz (source tarball)
# - PKGBUILD

# Place them in the same directory, then:
makepkg -si

# This will build and install the package with dependencies
\`\`\`

After installation, launch from your application menu or run:
\`\`\`bash
personnel-management
\`\`\`

**Note**: The PKGBUILD expects the tarball to be in the same directory. Do not extract the tarball manually.

---

### Windows 10/11
1. Download **personnel-management-${PROJECT_VERSION}-windows.zip** from the Assets section
2. Extract the ZIP file to a folder (e.g., \`C:\\Program Files\\PersonnelManagement\`)
3. Run **personnel_management.exe** from the \`bin\` folder

**No installation required** - all Qt dependencies are included!

Optional: Create a desktop shortcut to \`bin\\personnel_management.exe\`

---

### AppImage (Universal Linux - Any Distribution)
\`\`\`bash
# Download the AppImage from the Assets section:
wget https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}/releases/download/${TAG}/personnel-management-${PROJECT_VERSION}-x86_64.AppImage

# Make it executable:
chmod +x personnel-management-${PROJECT_VERSION}-x86_64.AppImage

# Run it:
./personnel-management-${PROJECT_VERSION}-x86_64.AppImage
\`\`\`

**No installation required** - works on any Linux distribution with FUSE support!

To integrate with your system:
\`\`\`bash
# Optional: Install AppImageLauncher for better desktop integration
# Debian/Ubuntu: sudo apt install appimagelauncher
# Arch: sudo pacman -S appimagelauncher
\`\`\`

---

## 📝 What's New

${CHANGES}

---

## ⚙️ Configuration

The application connects to the backend API server. You can customize this by creating a \`.env\` file in the application directory:

\`\`\`bash
API_BASE_URL=http://your-server:8082
API_PREFIX=/api
\`\`\`

**Default API server**: \`http://212.132.110.72:8082\`

**Configuration file location**:
- **Linux**: Same directory as the executable or \`~/.config/personnel_management/.env\`
- **Windows**: Same directory as \`personnel_management.exe\`

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

\`\`\`
EOF

    # Add checksums for all package files
    for pkg_dir in "$PACKAGE_DIR"/*; do
        if [ -d "$pkg_dir" ]; then
            find "$pkg_dir" -maxdepth 1 -type f \( -name "*.rpm" -o -name "*.deb" -o -name "*.zip" -o -name "*.AppImage" -o -name "*.tar.gz" -o -name "PKGBUILD" \) 2>/dev/null | while read -r file; do
                if [ -f "$file" ]; then
                    sha256sum "$file" | sed 's|.*/||' >> "$NOTES_FILE"
                fi
            done
        fi
    done

    echo '```' >> "$NOTES_FILE"
    echo "" >> "$NOTES_FILE"
    echo "---" >> "$NOTES_FILE"
    echo "" >> "$NOTES_FILE"
    echo "**Full Changelog**: https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}/blob/main/docs/CHANGELOG.md" >> "$NOTES_FILE"

    print_success "Release notes generated: $NOTES_FILE"
}

# Function to create GitHub release
create_github_release() {
    local TAG="$1"

    print_header "Creating GitHub Release: $TAG"

    check_dependencies release || return 1

    # Validate tag format
    if [[ ! "$TAG" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        print_warning "Tag '$TAG' doesn't follow semantic versioning format (vX.Y.Z)"
    fi

    # Check if tag already exists
    if gh release view "$TAG" --repo "$GITHUB_OWNER/$GITHUB_REPO" &> /dev/null; then
        print_warning "Release $TAG already exists."
        read -p "Do you want to delete and recreate it? (y/N): " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            print_info "Deleting existing release..."
            gh release delete "$TAG" --repo "$GITHUB_OWNER/$GITHUB_REPO" --yes 2>/dev/null || true
            git tag -d "$TAG" 2>/dev/null || true
            git push origin ":refs/tags/$TAG" 2>/dev/null || true
        else
            print_error "Release creation cancelled."
            return 1
        fi
    fi

    # Generate release notes
    generate_release_notes "$TAG" "$RELEASE_NOTES_FILE"

    # Collect release assets
    print_info "Collecting release assets..."
    local ASSETS=()

    for pkg_dir in "$PACKAGE_DIR"/*; do
        if [ -d "$pkg_dir" ]; then
            while IFS= read -r -d '' file; do
                if [ -f "$file" ]; then
                    ASSETS+=("$file")
                    print_info "  Found: $(basename "$file")"
                fi
            done < <(find "$pkg_dir" -maxdepth 1 -type f \( -name "*.rpm" -o -name "*.deb" -o -name "*.zip" -o -name "*.AppImage" -o -name "*.tar.gz" -o -name "PKGBUILD" -o -name ".SRCINFO" \) -print0 2>/dev/null)
        fi
    done

    # Add release notes file as an asset
    if [ -f "$RELEASE_NOTES_FILE" ]; then
        ASSETS+=("$RELEASE_NOTES_FILE")
    fi

    if [ ${#ASSETS[@]} -eq 0 ]; then
        print_warning "No package assets found."
        print_info "Run './package.sh --all' first to create packages."
    fi

    # Create the release
    print_info "Creating GitHub release..."

    local RELEASE_BODY=$(cat "$RELEASE_NOTES_FILE")

    if [ ${#ASSETS[@]} -gt 0 ]; then
        gh release create "$TAG" \
            --repo "$GITHUB_OWNER/$GITHUB_REPO" \
            --title "Personnel Management $TAG" \
            --notes "$RELEASE_BODY" \
            "${ASSETS[@]}"
    else
        gh release create "$TAG" \
            --repo "$GITHUB_OWNER/$GITHUB_REPO" \
            --title "Personnel Management $TAG" \
            --notes "$RELEASE_BODY"
    fi

    if [ $? -eq 0 ]; then
        print_success "GitHub release created successfully!"
        print_info "View at: https://github.com/$GITHUB_OWNER/$GITHUB_REPO/releases/tag/$TAG"
    else
        print_error "Failed to create GitHub release."
        return 1
    fi
}

# Function to upload additional assets
upload_assets() {
    local TAG="$1"
    shift
    local ASSETS=("$@")

    print_header "Uploading Assets to Release: $TAG"

    check_dependencies release || return 1

    if ! gh release view "$TAG" --repo "$GITHUB_OWNER/$GITHUB_REPO" &> /dev/null; then
        print_error "Release $TAG does not exist."
        return 1
    fi

    for asset in "${ASSETS[@]}"; do
        if [ -f "$asset" ]; then
            print_info "  Uploading: $(basename "$asset")"
            gh release upload "$TAG" "$asset" --repo "$GITHUB_OWNER/$GITHUB_REPO" --clobber
        else
            print_warning "  File not found: $asset"
        fi
    done

    print_success "Assets uploaded successfully!"
}

# Function to list releases
list_releases() {
    print_header "GitHub Releases"
    check_dependencies release || return 1
    gh release list --repo "$GITHUB_OWNER/$GITHUB_REPO"
}

# Function to delete a release
delete_release() {
    local TAG="$1"

    print_header "Deleting Release: $TAG"

    check_dependencies release || return 1

    if ! gh release view "$TAG" --repo "$GITHUB_OWNER/$GITHUB_REPO" &> /dev/null; then
        print_error "Release $TAG does not exist."
        return 1
    fi

    read -p "Are you sure you want to delete release $TAG? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        gh release delete "$TAG" --repo "$GITHUB_OWNER/$GITHUB_REPO" --yes
        print_success "Release $TAG deleted."

        read -p "Also delete the git tag? (y/N): " confirm_tag
        if [[ "$confirm_tag" =~ ^[Yy]$ ]]; then
            git tag -d "$TAG" 2>/dev/null || true
            git push origin ":refs/tags/$TAG" 2>/dev/null || true
            print_success "Git tag $TAG deleted."
        fi
    else
        print_info "Deletion cancelled."
    fi
}

# Function to clean previous builds
clean() {
    print_info "Cleaning previous builds..."
    rm -rf "$BUILD_DIR" "$BUILD_DIR_WIN" "$PACKAGE_DIR" "$DIST_DIR" "$RELEASE_NOTES_FILE" "$GITHUB_ARTIFACTS_DIR"
    print_success "Clean complete"
}

# Function to show usage
usage() {
    cat << EOF
${CYAN}Personnel Management System - Multi-platform Packaging Script${NC}

${YELLOW}Usage:${NC} $0 [OPTIONS] [PLATFORMS...]

${YELLOW}BUILD OPTIONS:${NC}
    -h, --help              Show this help message
    -c, --clean             Clean previous builds before packaging
    -a, --all               Build packages for all supported platforms
    -b, --build-only        Only build the Linux application, don't package
    --build-windows         Cross-compile Windows executable using MinGW (local)
    --download-windows      Download Windows build from GitHub Actions (recommended)
    --no-build              Skip building (use existing build)

${YELLOW}RELEASE OPTIONS:${NC}
    -r, --release TAG       Create a GitHub release with the specified tag
                            Generates release notes from git commits automatically
    --upload TAG FILES...   Upload additional files to an existing release
    --list-releases         List all GitHub releases
    --delete-release TAG    Delete a GitHub release

${YELLOW}PLATFORMS:${NC}
    fedora              Create Fedora RPM package
    arch                Create ArchLinux PKGBUILD
    debian              Create Debian DEB package
    windows             Create Windows ZIP package (requires --build-windows first)
    appimage            Create AppImage (portable Linux)

${YELLOW}EXAMPLES:${NC}
    $0 --all                            # Build and package for all platforms
    $0 fedora debian                    # Package for Fedora and Debian only
    $0 --clean --all                    # Clean, build, and package everything
    $0 --build-only                     # Only build the Linux application
    $0 --download-windows               # Download Windows build from GitHub Actions
    $0 --download-windows windows       # Download and package Windows version
    $0 --build-windows                  # Cross-compile for Windows locally
    $0 --release v0.2.0                 # Create GitHub release with auto-generated notes
    $0 --clean --all --release v0.2.0   # Full workflow: clean, build, package, release

${YELLOW}WINDOWS BUILD OPTIONS:${NC}

    ${GREEN}Option 1: Download from GitHub Actions (Recommended)${NC}
    # This downloads the pre-built Windows exe with all Qt DLLs included
    $0 --download-windows
    $0 windows

    ${GREEN}Option 2: Local cross-compilation with MinGW${NC}
    # Install MinGW toolchain (Arch Linux)
    sudo pacman -S mingw-w64-gcc
    paru -S mingw-w64-qt6-base mingw-w64-qt6-declarative mingw-w64-qt6-quickcontrols2

    # Build Windows executable
    $0 --build-windows
    $0 windows

${YELLOW}GITHUB RELEASE WORKFLOW:${NC}
    # Full release with all packages (using GitHub Actions Windows build):
    $0 --clean --download-windows --all --release v0.2.0

    # This will:
    # 1. Clean previous builds
    # 2. Download Windows exe from GitHub Actions (with Qt DLLs)
    # 3. Build Linux application locally
    # 4. Create packages for all platforms
    # 5. Generate release notes from git commits
    # 6. Create GitHub release and upload all assets

    # Alternative: Full release with local Windows cross-compilation:
    $0 --clean --build-windows --all --release v0.2.0

${YELLOW}NOTES:${NC}
    - Packages are created in the '$PACKAGE_DIR' directory
    - Release notes are auto-generated from git commits since last tag
    - GitHub releases require 'gh' CLI tool (https://cli.github.com/)
    - Run 'gh auth login' before creating releases

EOF
}

# Main script
main() {
    local platforms=()
    local do_clean=false
    local build_only=false
    local build_windows=false
    local download_windows=false
    local no_build=false
    local all_platforms=false
    local release_tag=""
    local upload_tag=""
    local upload_files=()
    local do_list_releases=false
    local delete_tag=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -c|--clean)
                do_clean=true
                shift
                ;;
            -a|--all)
                all_platforms=true
                shift
                ;;
            -b|--build-only)
                build_only=true
                shift
                ;;
            --build-windows)
                build_windows=true
                shift
                ;;
            --download-windows)
                download_windows=true
                shift
                ;;
            --no-build)
                no_build=true
                shift
                ;;
            -r|--release)
                if [ -z "$2" ] || [[ "$2" == -* ]]; then
                    print_error "Release tag is required. Example: --release v0.2.0"
                    exit 1
                fi
                release_tag="$2"
                shift 2
                ;;
            --upload)
                if [ -z "$2" ] || [[ "$2" == -* ]]; then
                    print_error "Upload requires a tag. Example: --upload v0.2.0 file.zip"
                    exit 1
                fi
                upload_tag="$2"
                shift 2
                while [[ $# -gt 0 ]] && [[ "$1" != -* ]]; do
                    upload_files+=("$1")
                    shift
                done
                ;;
            --list-releases)
                do_list_releases=true
                shift
                ;;
            --delete-release)
                if [ -z "$2" ] || [[ "$2" == -* ]]; then
                    print_error "Delete requires a tag. Example: --delete-release v0.1.0"
                    exit 1
                fi
                delete_tag="$2"
                shift 2
                ;;
            fedora|arch|debian|windows|appimage)
                platforms+=("$1")
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done

    # Handle special commands first
    if [ "$do_list_releases" = true ]; then
        list_releases
        exit 0
    fi

    if [ -n "$delete_tag" ]; then
        delete_release "$delete_tag"
        exit 0
    fi

    if [ -n "$upload_tag" ]; then
        upload_assets "$upload_tag" "${upload_files[@]}"
        exit 0
    fi

    # Set all platforms if requested
    if [ "$all_platforms" = true ]; then
        platforms=(fedora arch debian windows appimage)
    fi

    # If no action specified, show usage
    if [ ${#platforms[@]} -eq 0 ] && [ "$build_only" = false ] && [ "$build_windows" = false ] && [ "$download_windows" = false ] && [ -z "$release_tag" ]; then
        usage
        exit 1
    fi

    print_header "Personnel Management System - Packaging Script"
    print_info "Version: $PROJECT_VERSION"
    echo

    # Clean if requested
    if [ "$do_clean" = true ]; then
        clean
    fi

    # Build Linux application
    if [ "$no_build" = false ] && ([ ${#platforms[@]} -gt 0 ] || [ "$build_only" = true ]); then
        build_application
    fi

    # Download Windows build from GitHub Actions
    if [ "$download_windows" = true ]; then
        download_windows_artifact
    fi

    # Build Windows executable locally (cross-compile)
    if [ "$build_windows" = true ]; then
        build_windows
    fi

    if [ "$build_only" = true ] && [ "$build_windows" = false ] && [ "$download_windows" = false ]; then
        print_success "Build complete. Binary: $BUILD_DIR/personnel_management"
        exit 0
    fi

    # Create packages
    if [ ${#platforms[@]} -gt 0 ]; then
        mkdir -p "$PACKAGE_DIR"

        for platform in "${platforms[@]}"; do
            echo
            case $platform in
                fedora)
                    package_fedora
                    ;;
                arch)
                    package_arch
                    ;;
                debian)
                    package_debian
                    ;;
                windows)
                    package_windows
                    ;;
                appimage)
                    package_appimage
                    ;;
            esac
        done

        echo
        print_success "Packaging complete!"
        print_info "Packages available in: $PACKAGE_DIR/"
        ls -lhR "$PACKAGE_DIR/" 2>/dev/null || true
    fi

    # Create GitHub release if requested
    if [ -n "$release_tag" ]; then
        echo
        create_github_release "$release_tag"
    fi
}

# Run main function
main "$@"
