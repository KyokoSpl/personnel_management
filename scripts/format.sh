#!/bin/bash

# Format all C++ code in the project using clang-format
# Usage: ./scripts/format.sh [--check]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

CHECK_ONLY=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --check)
            CHECK_ONLY=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--check]"
            echo ""
            echo "Format all C++ source files in the project."
            echo ""
            echo "Options:"
            echo "  --check    Check formatting without modifying files"
            echo "  --help     Show this help message"
            exit 0
            ;;
    esac
done

# Check if clang-format is installed
if ! command -v clang-format &> /dev/null; then
    echo -e "${RED}Error: clang-format is not installed${NC}"
    echo "Install it with:"
    echo "  Ubuntu/Debian: sudo apt-get install clang-format"
    echo "  Fedora/RHEL:   sudo dnf install clang-tools-extra"
    echo "  Arch:          sudo pacman -S clang"
    echo "  macOS:         brew install clang-format"
    exit 1
fi

# Find clang-format version
CLANG_FORMAT_VERSION=$(clang-format --version | grep -oP '\d+\.\d+' | head -1)
echo -e "${GREEN}Using clang-format version: $CLANG_FORMAT_VERSION${NC}"

cd "$PROJECT_ROOT"

# Find all C++ files
echo "Searching for C++ files..."
CPP_FILES=$(find src include tests -type f \( -name "*.cpp" -o -name "*.h" \) 2>/dev/null || true)

if [ -z "$CPP_FILES" ]; then
    echo -e "${YELLOW}No C++ files found${NC}"
    exit 0
fi

FILE_COUNT=$(echo "$CPP_FILES" | wc -l)
echo "Found $FILE_COUNT C++ files"

if [ "$CHECK_ONLY" = true ]; then
    echo -e "${YELLOW}Checking code formatting (no changes will be made)...${NC}"

    ISSUES_FOUND=false
    while IFS= read -r file; do
        if ! clang-format --dry-run --Werror "$file" 2>&1 | grep -q "warning:"; then
            continue
        else
            echo -e "${RED}✗${NC} $file needs formatting"
            ISSUES_FOUND=true
        fi
    done <<< "$CPP_FILES"

    if [ "$ISSUES_FOUND" = true ]; then
        echo ""
        echo -e "${RED}Formatting issues found!${NC}"
        echo "Run './scripts/format.sh' to fix them automatically."
        exit 1
    else
        echo -e "${GREEN}✓ All files are properly formatted${NC}"
        exit 0
    fi
else
    echo "Formatting files..."

    FORMATTED_COUNT=0
    while IFS= read -r file; do
        echo -e "${GREEN}✓${NC} Formatting $file"
        clang-format -i "$file"
        FORMATTED_COUNT=$((FORMATTED_COUNT + 1))
    done <<< "$CPP_FILES"

    echo ""
    echo -e "${GREEN}Successfully formatted $FORMATTED_COUNT files${NC}"
    exit 0
fi
