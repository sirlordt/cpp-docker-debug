#!/bin/bash

# Script to build C/C++ programs in the Docker container

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if the container is running
if ! docker ps | grep -q cpp-dev-container; then
    echo "Starting Docker container..."
    docker-compose up -d
    
    # Wait for container to be fully up
    sleep 3
fi

# Function to display usage
usage() {
    echo "Usage: $0 [c|cpp|all]"
    echo "  c    - Build C program (sample)"
    echo "  cpp  - Build C++ program (main)"
    echo "  all  - Build both C and C++ programs"
    exit 1
}

# Check arguments
if [ $# -ne 1 ]; then
    usage
fi

case "$1" in
    c)
        echo "Building C program..."
        docker exec -u developer cpp-dev-container bash -c 'cd /home/developer/workspace && mkdir -p build && cd build && conan install .. --output-folder=. --build=missing && cmake .. -DCMAKE_TOOLCHAIN_FILE=conan_toolchain.cmake -DCMAKE_BUILD_TYPE=Debug && cmake --build . --target sample'
        echo "C program built successfully."
        ;;
    cpp)
        echo "Building C++ program..."
        docker exec -u developer cpp-dev-container bash -c 'cd /home/developer/workspace && mkdir -p build && cd build && conan install .. --output-folder=. --build=missing && cmake .. -DCMAKE_TOOLCHAIN_FILE=conan_toolchain.cmake -DCMAKE_BUILD_TYPE=Debug && cmake --build . --target main'
        echo "C++ program built successfully."
        ;;
    all)
        echo "Building all programs..."
        docker exec -u developer cpp-dev-container bash -c 'cd /home/developer/workspace && mkdir -p build && cd build && conan install .. --output-folder=. --build=missing && cmake .. -DCMAKE_TOOLCHAIN_FILE=conan_toolchain.cmake -DCMAKE_BUILD_TYPE=Debug && cmake --build .'
        echo "All programs built successfully."
        ;;
    *)
        usage
        ;;
esac
