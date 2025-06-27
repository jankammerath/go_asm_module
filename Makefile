# Makefile for ARM64 Assembly Module Project
# Provides convenient build targets for the Go project with ARM64 assembly

.PHONY: all build clean debug release test run help install

# Variables
BINARY_NAME = go_asm_module
BUILD_DIR = build
GO_FILES = $(wildcard *.go)
ASM_FILES = $(wildcard *.s)
LDFLAGS = -ldflags="-s -w"
DEBUG_FLAGS = -gcflags="-N -l"

# Default target
all: build

# Full build process using the build script
build:
	@echo "Running full build process..."
	@./build.sh

# Quick release build
release: clean
	@echo "Building optimized release version..."
	@mkdir -p $(BUILD_DIR)
	@go build -v $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME) .
	@echo "✓ Release build complete: $(BUILD_DIR)/$(BINARY_NAME)"

# Debug build
debug: clean
	@echo "Building debug version..."
	@mkdir -p $(BUILD_DIR)
	@go build -v $(DEBUG_FLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)_debug .
	@echo "✓ Debug build complete: $(BUILD_DIR)/$(BINARY_NAME)_debug"

# Quick build (in current directory)
quick:
	@echo "Quick build in current directory..."
	@go build -o $(BINARY_NAME) .
	@echo "✓ Quick build complete: ./$(BINARY_NAME)"

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)
	@rm -f $(BINARY_NAME)
	@go clean -cache -modcache -i -r
	@echo "✓ Clean complete"

# Test the application
test: release
	@echo "Testing release build..."
	@$(BUILD_DIR)/$(BINARY_NAME)

# Run the application (builds if necessary)
run: quick
	@echo "Running application..."
	@./$(BINARY_NAME)

# Validate assembly syntax
validate:
	@echo "Validating ARM64 assembly syntax..."
	@go build -o /dev/null .
	@echo "✓ Assembly validation passed"

# Show assembly output
assembly: 
	@echo "Generating assembly output..."
	@mkdir -p $(BUILD_DIR)/assembly
	@go build -gcflags="-S" . 2> $(BUILD_DIR)/assembly/compiler_output.txt
	@echo "Assembly output saved to $(BUILD_DIR)/assembly/"

# Show object dump
objdump: release
	@echo "Generating object dump..."
	@mkdir -p $(BUILD_DIR)/assembly
	@go tool objdump $(BUILD_DIR)/$(BINARY_NAME) > $(BUILD_DIR)/assembly/objdump.txt
	@go tool objdump -s "add_asm|multiply_asm|factorial_asm" $(BUILD_DIR)/$(BINARY_NAME) > $(BUILD_DIR)/assembly/asm_functions.txt
	@echo "Object dump saved to $(BUILD_DIR)/assembly/"

# Install to system (copies to /usr/local/bin)
install: release
	@echo "Installing $(BINARY_NAME) to /usr/local/bin..."
	@sudo cp $(BUILD_DIR)/$(BINARY_NAME) /usr/local/bin/
	@echo "✓ Installation complete"

# Show project information
info:
	@echo "ARM64 Assembly Module Project Information"
	@echo "========================================"
	@echo "Go Version: $$(go version)"
	@echo "Platform: $$(uname -s) $$(uname -m)"
	@echo "Source Files:"
	@echo "  Go files: $(GO_FILES)"
	@echo "  Assembly files: $(ASM_FILES)"
	@echo "Build Directory: $(BUILD_DIR)"
	@echo "Binary Name: $(BINARY_NAME)"

# Development watch (requires entr: brew install entr)
watch:
	@echo "Watching for changes... (requires 'entr' - install with 'brew install entr')"
	@find . -name "*.go" -o -name "*.s" | entr -r make run

# Help target
help:
	@echo "ARM64 Assembly Module Build System"
	@echo "=================================="
	@echo ""
	@echo "Available targets:"
	@echo "  all        - Full build process (default)"
	@echo "  build      - Full build using build.sh script"
	@echo "  release    - Quick optimized release build"
	@echo "  debug      - Debug build with symbols"
	@echo "  quick      - Quick build in current directory"
	@echo "  clean      - Remove all build artifacts"
	@echo "  test       - Build and test the application"
	@echo "  run        - Quick build and run"
	@echo "  validate   - Validate ARM64 assembly syntax"
	@echo "  assembly   - Generate assembly compiler output"
	@echo "  objdump    - Generate object dump of binary"
	@echo "  install    - Install binary to /usr/local/bin"
	@echo "  info       - Show project information"
	@echo "  watch      - Watch for changes and rebuild (requires entr)"
	@echo "  help       - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make                 # Full build"
	@echo "  make run            # Quick build and run"
	@echo "  make release test   # Build release and test"
	@echo "  make clean build    # Clean and full build"
