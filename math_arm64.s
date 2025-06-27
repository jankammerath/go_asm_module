//go:build arm64

#include "textflag.h"

// func add_asm(a, b int64) int64
TEXT ·add_asm(SB), NOSPLIT, $0-24
    MOVD a+0(FP), R0      // Load first argument into R0
    MOVD b+8(FP), R1      // Load second argument into R1
    ADD  R0, R1, R2       // Add R0 and R1, store result in R2
    MOVD R2, ret+16(FP)   // Store result in return value
    RET

// func multiply_asm(a, b int64) int64
TEXT ·multiply_asm(SB), NOSPLIT, $0-24
    MOVD a+0(FP), R0      // Load first argument into R0
    MOVD b+8(FP), R1      // Load second argument into R1
    MUL  R0, R1, R2       // Multiply R0 and R1, store result in R2
    MOVD R2, ret+16(FP)   // Store result in return value
    RET

// func factorial_asm(n int64) int64
TEXT ·factorial_asm(SB), NOSPLIT, $0-16
    MOVD n+0(FP), R0      // Load argument into R0
    MOVD $1, R1           // Initialize result to 1
    CMP  $0, R0           // Compare n with 0
    BLE  done             // If n <= 0, return 1
    
loop:
    MUL  R0, R1, R1       // result *= n
    SUB  $1, R0, R0       // n--
    CMP  $0, R0           // Compare n with 0
    BGT  loop             // If n > 0, continue loop
    
done:
    MOVD R1, ret+8(FP)    // Store result in return value
    RET

// func strlen_asm(ptr uintptr) int64
TEXT ·strlen_asm(SB), NOSPLIT, $0-16
    MOVD ptr+0(FP), R0    // Load string pointer into R0
    MOVD $0, R1           // Initialize counter to 0
    
strlen_loop:
    MOVBU (R0), R2        // Load byte at address R0 into R2 (unsigned)
    CMP  $0, R2           // Compare with null terminator
    BEQ  strlen_done      // If null, we're done
    ADD  $1, R1, R1       // Increment counter
    ADD  $1, R0, R0       // Move to next byte
    B    strlen_loop      // Continue loop
    
strlen_done:
    MOVD R1, ret+8(FP)    // Store result in return value
    RET

// func sum_array_asm(ptr uintptr, length int64) int64
TEXT ·sum_array_asm(SB), NOSPLIT, $0-24
    MOVD ptr+0(FP), R0    // Load array pointer into R0
    MOVD length+8(FP), R1 // Load array length into R1
    MOVD $0, R2           // Initialize sum to 0
    MOVD $0, R3           // Initialize index to 0
    
sum_loop:
    CMP  R1, R3           // Compare index with length
    BGE  sum_done         // If index >= length, we're done
    LSL  $3, R3, R4       // Multiply index by 8 (size of int64)
    ADD  R0, R4, R4       // Calculate address of element
    MOVD (R4), R5         // Load element into R5
    ADD  R2, R5, R2       // Add element to sum
    ADD  $1, R3, R3       // Increment index
    B    sum_loop         // Continue loop
    
sum_done:
    MOVD R2, ret+16(FP)   // Store result in return value
    RET
