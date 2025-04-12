cmake_minimum_required(VERSION 3.15)

# Set output directory for executables
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# C++ executable
add_executable(main main.cpp)
target_compile_options(main PRIVATE -g -Wall)

# C executable
add_executable(sample sample.c)
target_compile_options(sample PRIVATE -g -Wall)

# If you add dependencies with Conan, link them here
# Example:
# find_package(fmt REQUIRED)
# target_link_libraries(main fmt::fmt)
