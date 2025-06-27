# ARM64 Assembly Module for Go on macOS

This project demonstrates how to integrate ARM64 assembly code with Go programs on macOS 15.5. It showcases various assembly functions and their integration with Go.

## Project Structure

```
.
├── go.mod              # Go module file
├── main.go             # Main Go program
├── math_arm64.s        # ARM64 assembly functions
└── README.md          # This file
```

## Assembly Functions

The project includes the following ARM64 assembly functions:

### 1. `add_asm(a, b int64) int64`
- Performs addition of two 64-bit integers
- Demonstrates basic arithmetic operations in ARM64

### 2. `multiply_asm(a, b int64) int64`
- Performs multiplication of two 64-bit integers
- Shows how to use the MUL instruction

### 3. `factorial_asm(n int64) int64`
- Calculates factorial using iterative approach
- Demonstrates loops, conditionals, and branching in ARM64

### 4. `strlen_asm(ptr uintptr) int64`
- Calculates length of null-terminated C-style string
- Shows memory access and byte operations

### 5. `sum_array_asm(ptr uintptr, length int64) int64`
- Sums all elements in an array of int64 values
- Demonstrates array traversal and memory addressing

## Key ARM64 Assembly Concepts

### Registers Used
- `R0-R5`: General-purpose registers for data manipulation
- `FP`: Frame pointer for accessing function parameters and return values
- `SB`: Static base pointer for global symbols

### Instructions Demonstrated
- `MOVD`: Move 64-bit data between registers/memory
- `MOVBU`: Move byte (unsigned) from memory to register
- `ADD/SUB`: Arithmetic operations
- `MUL`: Multiplication
- `CMP`: Compare values
- `B/BEQ/BGE/BGT/BLE`: Branch instructions (conditional/unconditional)
- `LSL`: Logical shift left
- `RET`: Return from function

### Function Calling Convention
- Parameters passed via stack frame (`+offset(FP)`)
- Return values stored in designated stack locations
- `NOSPLIT` flag prevents stack splitting
- `$0-N` indicates stack frame size and argument space

## Building and Running

```bash
# Build the project
go build -v

# Run the executable
./go_asm_module
```

## Requirements

- macOS 15.5 (or compatible ARM64 macOS version)
- Go 1.24.2 or later
- ARM64 processor (Apple Silicon Mac)

## Assembly File Details

The assembly file (`math_arm64.s`) follows Go's assembly syntax:

- `//go:build arm64`: Build constraint for ARM64 architecture
- `#include "textflag.h"`: Include necessary flags
- `TEXT ·function_name(SB), NOSPLIT, $framesize-argsize`: Function declaration
- Parameter access via `name+offset(FP)`
- Return value via `ret+offset(FP)`

## Educational Value

This project demonstrates:

1. **Integration**: How to seamlessly integrate assembly with Go
2. **Performance**: Direct hardware control for performance-critical operations
3. **Understanding**: Low-level understanding of ARM64 architecture
4. **Debugging**: Comparison between Go and assembly implementations

## Notes

- Assembly functions use Go's calling convention
- Memory safety considerations when using `unsafe.Pointer`
- Build constraints ensure ARM64-specific assembly is only used on compatible platforms
- Functions are optimized for demonstration rather than maximum performance

## Platform Compatibility

This code is specifically designed for ARM64 architecture on macOS. For other platforms, you would need:
- Different assembly files (e.g., `math_amd64.s` for x86-64)
- Appropriate build constraints
- Platform-specific instruction sets
