#include <iostream>
#include <vector>
#include <unistd.h> // For sleep
#include <signal.h> // For raise
#include <cstdlib> // For system

// A simple function to demonstrate debugging
int sumVector(const std::vector<int>& numbers) {
    int sum = 0;
    for (int num : numbers) {
        sum += num;
        // Good place to set a breakpoint
        std::cout << "Current sum: " << sum << std::endl;
    }
    return sum;
}

/*
// Function to help with debugging
void debug_break() {
    // This will cause a SIGTRAP which the debugger will catch
    raise(SIGTRAP);
}
*/

// Function that the compiler can't optimize away
void breakpoint_function(int line) {
    // Do something that has side effects so the compiler can't optimize it away
    volatile int x = line;
    std::cout << "Breakpoint at line " << line << std::endl;
}

int main() {
    // Sleep for 5 seconds to give time to attach debugger
    sleep(5);
    
    // Call a function that the compiler can't optimize away
    breakpoint_function(27); // Set breakpoint here (line 27)
    
    std::cout << "C++ Debugging Demo 2025-04-12" << std::endl;
    
    // Call a function that the compiler can't optimize away
    breakpoint_function(33); // Set breakpoint here (line 33)
    
    // Create a vector with some numbers
    std::vector<int> numbers = {1, 2, 3, 4, 5};
    
    // Calculate the sum
    int result = sumVector(numbers);
    
    // Print the result
    std::cout << "The sum is: " << result << std::endl;
    
    // Introduce a memory error for sanitizer to detect
    int* ptr = new int[5];
    ptr[5] = 10;  // Out of bounds access
    delete[] ptr;
    
    // Call a function that the compiler can't optimize away
    breakpoint_function(45); // Set breakpoint here (line 45)
    //debug_break(); // This will force a break
    
    return 0;
}
