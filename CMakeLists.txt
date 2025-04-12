cmake_minimum_required(VERSION 3.15)
project(cpp-docker-debug VERSION 1.0.0 LANGUAGES C CXX)

# Include Conan-generated CMake files (Conan 2.x) first
if(EXISTS "${CMAKE_BINARY_DIR}/conan_toolchain.cmake")
    include("${CMAKE_BINARY_DIR}/conan_toolchain.cmake")
endif()

# Set C++ standard for the project (will be used for targets that don't specify their own)
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Set C standard
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

# Add src subdirectory
add_subdirectory(src)
