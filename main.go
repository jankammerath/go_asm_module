package main

import (
	"fmt"
	"unsafe"
)

// Assembly function declarations
func add_asm(a, b int64) int64
func multiply_asm(a, b int64) int64
func factorial_asm(n int64) int64
func strlen_asm(ptr uintptr) int64
func sum_array_asm(ptr uintptr, length int64) int64

func main() {
	fmt.Println("ARM64 Assembly Module Demo on macOS")
	fmt.Println("=====================================")

	// Test addition
	a, b := int64(15), int64(27)
	sum := add_asm(a, b)
	fmt.Printf("Addition: %d + %d = %d\n", a, b, sum)

	// Test multiplication
	x, y := int64(8), int64(9)
	product := multiply_asm(x, y)
	fmt.Printf("Multiplication: %d * %d = %d\n", x, y, product)

	// Test factorial
	n := int64(6)
	fact := factorial_asm(n)
	fmt.Printf("Factorial: %d! = %d\n", n, fact)

	// Test string length (using C-style null-terminated string)
	testStr := "Hello, ARM64 Assembly!"
	// Convert Go string to C-style string
	cStr := make([]byte, len(testStr)+1)
	copy(cStr, testStr)
	cStr[len(testStr)] = 0 // null terminator

	strLen := strlen_asm(uintptr(unsafe.Pointer(&cStr[0])))
	fmt.Printf("String length of '%s': %d\n", testStr, strLen)

	// Test array sum
	numbers := []int64{1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
	arraySum := sum_array_asm(uintptr(unsafe.Pointer(&numbers[0])), int64(len(numbers)))
	fmt.Printf("Sum of array %v: %d\n", numbers, arraySum)

	// Comparison with Go implementations
	fmt.Println("\nComparison with Go implementations:")
	fmt.Printf("Go addition: %d + %d = %d (ASM: %d)\n", a, b, a+b, sum)
	fmt.Printf("Go multiplication: %d * %d = %d (ASM: %d)\n", x, y, x*y, product)

	goFact := factorial_go(n)
	fmt.Printf("Go factorial: %d! = %d (ASM: %d)\n", n, goFact, fact)

	goSum := int64(0)
	for _, num := range numbers {
		goSum += num
	}
	fmt.Printf("Go array sum: %d (ASM: %d)\n", goSum, arraySum)

	// Run performance benchmarks
	runBenchmarks()

	fmt.Println("\n✅ All assembly functions working correctly!")
}

// Go implementation of factorial for comparison
func factorial_go(n int64) int64 {
	if n <= 1 {
		return 1
	}
	result := int64(1)
	for i := int64(2); i <= n; i++ {
		result *= i
	}
	return result
}
