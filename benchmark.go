package main

import (
	"fmt"
	"time"
)

const iterations = 10000000

func BenchmarkAddASM() {
	start := time.Now()
	for i := 0; i < iterations; i++ {
		add_asm(int64(i), int64(i+1))
	}
	duration := time.Since(start)
	fmt.Printf("ASM Addition: %d iterations in %v (%.2f ns/op)\n",
		iterations, duration, float64(duration.Nanoseconds())/float64(iterations))
}

func BenchmarkAddGo() {
	start := time.Now()
	for i := 0; i < iterations; i++ {
		_ = int64(i) + int64(i+1)
	}
	duration := time.Since(start)
	fmt.Printf("Go Addition: %d iterations in %v (%.2f ns/op)\n",
		iterations, duration, float64(duration.Nanoseconds())/float64(iterations))
}

func BenchmarkMultiplyASM() {
	start := time.Now()
	for i := 0; i < iterations; i++ {
		multiply_asm(int64(i%1000), int64((i+1)%1000))
	}
	duration := time.Since(start)
	fmt.Printf("ASM Multiplication: %d iterations in %v (%.2f ns/op)\n",
		iterations, duration, float64(duration.Nanoseconds())/float64(iterations))
}

func BenchmarkMultiplyGo() {
	start := time.Now()
	for i := 0; i < iterations; i++ {
		_ = int64(i%1000) * int64((i+1)%1000)
	}
	duration := time.Since(start)
	fmt.Printf("Go Multiplication: %d iterations in %v (%.2f ns/op)\n",
		iterations, duration, float64(duration.Nanoseconds())/float64(iterations))
}

func runBenchmarks() {
	fmt.Println("\nPerformance Benchmarks:")
	fmt.Println("======================")

	BenchmarkAddGo()
	BenchmarkAddASM()
	fmt.Println()
	BenchmarkMultiplyGo()
	BenchmarkMultiplyASM()
}
