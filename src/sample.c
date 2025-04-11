#include <stdio.h>

// A function to calculate factorial
int factorial(int n) {
    if (n <= 1) {
        return 1;
    }
    
    int result = n;
    // Good place to set a breakpoint
    printf("Computing factorial: n = %d\n", n);
    
    return result * factorial(n - 1);
}

int main() {
    printf("C Debugging Demo\n");
    
    int number = 5;
    printf("Calculating factorial of %d\n", number);
    
    // Calculate factorial
    int result = factorial(number);
    
    // Print the result
    printf("The factorial of %d is: %d\n", number, result);
    
    return 0;
}
