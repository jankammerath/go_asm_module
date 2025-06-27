#!/bin/bash

# ARM64 Assembly Module Build Script for macOS
# This script builds the Go project with ARM64 assembly integration

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project information
PROJECT_NAME="go_asm_module"
BUILD_DIR="build"
BINARY_NAME="go_asm_module"

echo -e "${BLUE}ARM64 Assembly Module Build Script${NC}"
echo -e "${BLUE}===================================${NC}"

# Function to print status messages
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're on macOS ARM64
check_platform() {
    print_status "Checking platform compatibility..."
    
    if [[ "$(uname)" != "Darwin" ]]; then
        print_error "This build script is designed for macOS only"
        exit 1
    fi
    
    if [[ "$(uname -m)" != "arm64" ]]; then
        print_warning "This project is optimized for ARM64 (Apple Silicon)"
        print_warning "Building anyway, but assembly code will only work on ARM64"
    fi
    
    print_status "Platform check passed"
}

# Check Go installation and version
check_go() {
    print_status "Checking Go installation..."
    
    if ! command -v go &> /dev/null; then
        print_error "Go is not installed or not in PATH"
        exit 1
    fi
    
    GO_VERSION=$(go version | cut -d' ' -f3)
    print_status "Found Go version: $GO_VERSION"
    
    # Check minimum Go version (1.18+)
    if ! go version | grep -qE "go1\.(1[8-9]|[2-9][0-9]|[0-9]{3,})"; then
        print_warning "Go 1.18+ recommended for best ARM64 assembly support"
    fi
}

# Verify source files
check_sources() {
    print_status "Verifying source files..."
    
    required_files=("main.go" "math_arm64.s" "benchmark.go" "go.mod")
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            print_error "Required file missing: $file"
            exit 1
        fi
        print_status "✓ Found $file"
    done
}

# Clean previous builds
clean_build() {
    print_status "Cleaning previous builds..."
    
    if [[ -d "$BUILD_DIR" ]]; then
        rm -rf "$BUILD_DIR"
        print_status "Removed $BUILD_DIR directory"
    fi
    
    if [[ -f "$BINARY_NAME" ]]; then
        rm -f "$BINARY_NAME"
        print_status "Removed existing binary"
    fi
    
    # Clean Go build cache for this module
    go clean -cache -modcache -i -r
    print_status "Cleaned Go build cache"
}

# Create build directory
setup_build_dir() {
    print_status "Setting up build directory..."
    mkdir -p "$BUILD_DIR"
}

# Validate assembly syntax
validate_assembly() {
    print_status "Validating ARM64 assembly syntax..."
    
    # Try to build the project to check for assembly syntax errors
    if ! go build -o /dev/null . 2>/dev/null; then
        print_error "Assembly/Build validation failed"
        print_status "Running detailed build to show errors..."
        go build -o /dev/null . 2>&1 | head -20
        return 1
    fi
    
    print_status "Assembly syntax validation passed"
}

# Build with different configurations
build_debug() {
    print_status "Building debug version..."
    
    go build -v -x -gcflags="-N -l" -o "$BUILD_DIR/${BINARY_NAME}_debug" .
    
    if [[ $? -eq 0 ]]; then
        print_status "✓ Debug build successful: $BUILD_DIR/${BINARY_NAME}_debug"
    else
        print_error "Debug build failed"
        return 1
    fi
}

build_release() {
    print_status "Building optimized release version..."
    
    go build -v -ldflags="-s -w" -o "$BUILD_DIR/$BINARY_NAME" .
    
    if [[ $? -eq 0 ]]; then
        print_status "✓ Release build successful: $BUILD_DIR/$BINARY_NAME"
    else
        print_error "Release build failed"
        return 1
    fi
}

# Build with assembly output for inspection
build_with_assembly_output() {
    print_status "Building with assembly output for inspection..."
    
    mkdir -p "$BUILD_DIR/assembly_output"
    
    # Generate assembly listing
    go build -gcflags="-S" . 2> "$BUILD_DIR/assembly_output/compiler_output.txt"
    
    # Generate object dump
    if [[ -f "$BUILD_DIR/$BINARY_NAME" ]]; then
        go tool objdump "$BUILD_DIR/$BINARY_NAME" > "$BUILD_DIR/assembly_output/objdump.txt" 2>/dev/null || true
        go tool objdump -s "add_asm|multiply_asm|factorial_asm" "$BUILD_DIR/$BINARY_NAME" > "$BUILD_DIR/assembly_output/asm_functions.txt" 2>/dev/null || true
    fi
    
    print_status "Assembly output saved to $BUILD_DIR/assembly_output/"
}

# Run tests
run_tests() {
    print_status "Running functionality tests..."
    
    if [[ -f "$BUILD_DIR/$BINARY_NAME" ]]; then
        print_status "Testing release binary..."
        "$BUILD_DIR/$BINARY_NAME" > "$BUILD_DIR/test_output.txt" 2>&1
        
        if [[ $? -eq 0 ]]; then
            print_status "✓ Release binary test passed"
            # Show a summary of the output
            echo -e "${BLUE}Test Output Summary:${NC}"
            head -15 "$BUILD_DIR/test_output.txt"
            echo "..."
            tail -5 "$BUILD_DIR/test_output.txt"
        else
            print_error "Release binary test failed"
            cat "$BUILD_DIR/test_output.txt"
            return 1
        fi
    fi
}

# Generate build info
generate_build_info() {
    print_status "Generating build information..."
    
    cat > "$BUILD_DIR/build_info.txt" << EOF
ARM64 Assembly Module Build Information
======================================

Build Date: $(date)
Platform: $(uname -s) $(uname -m)
Go Version: $(go version)
Git Commit: $(git rev-parse --short HEAD 2>/dev/null || echo "N/A")
Git Branch: $(git branch --show-current 2>/dev/null || echo "N/A")

Build Configuration:
- Debug Build: ${BUILD_DIR}/${BINARY_NAME}_debug
- Release Build: ${BUILD_DIR}/${BINARY_NAME}
- Assembly Output: ${BUILD_DIR}/assembly_output/

Source Files:
$(ls -la *.go *.s 2>/dev/null || echo "Source files not found")

Binary Information:
$(if [[ -f "$BUILD_DIR/$BINARY_NAME" ]]; then
    echo "Release Binary Size: $(ls -lh "$BUILD_DIR/$BINARY_NAME" | awk '{print $5}')"
    echo "Release Binary MD5: $(md5 -q "$BUILD_DIR/$BINARY_NAME" 2>/dev/null || echo "N/A")"
fi)

$(if [[ -f "$BUILD_DIR/${BINARY_NAME}_debug" ]]; then
    echo "Debug Binary Size: $(ls -lh "$BUILD_DIR/${BINARY_NAME}_debug" | awk '{print $5}')"
    echo "Debug Binary MD5: $(md5 -q "$BUILD_DIR/${BINARY_NAME}_debug" 2>/dev/null || echo "N/A")"
fi)
EOF

    print_status "Build info saved to $BUILD_DIR/build_info.txt"
}

# Main build process
main() {
    echo
    print_status "Starting build process..."
    
    check_platform
    check_go
    check_sources
    
    if [[ "$1" == "clean" ]]; then
        clean_build
        print_status "Clean completed"
        exit 0
    fi
    
    clean_build
    setup_build_dir
    validate_assembly
    
    # Build both versions
    build_debug
    build_release
    
    # Generate additional outputs
    build_with_assembly_output
    generate_build_info
    
    # Test the builds
    run_tests
    
    echo
    print_status "Build process completed successfully!"
    echo -e "${GREEN}Artifacts created in $BUILD_DIR/:${NC}"
    ls -la "$BUILD_DIR/"
    
    echo
    echo -e "${BLUE}Usage:${NC}"
    echo -e "  Run release version: ./$BUILD_DIR/$BINARY_NAME"
    echo -e "  Run debug version:   ./$BUILD_DIR/${BINARY_NAME}_debug"
    echo -e "  View build info:     cat $BUILD_DIR/build_info.txt"
    echo -e "  View assembly:       cat $BUILD_DIR/assembly_output/asm_functions.txt"
}

# Handle script arguments
case "${1:-}" in
    "clean")
        main clean
        ;;
    "help"|"-h"|"--help")
        echo "ARM64 Assembly Module Build Script"
        echo
        echo "Usage: $0 [command]"
        echo
        echo "Commands:"
        echo "  (none)    - Full build process"
        echo "  clean     - Clean build artifacts only"
        echo "  help      - Show this help message"
        echo
        echo "This script will:"
        echo "  1. Validate platform and dependencies"
        echo "  2. Check source file integrity"
        echo "  3. Validate ARM64 assembly syntax"
        echo "  4. Build debug and release versions"
        echo "  5. Generate assembly output for inspection"
        echo "  6. Run functionality tests"
        echo "  7. Create build information summary"
        ;;
    *)
        main "$@"
        ;;
esac
