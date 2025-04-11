#!/bin/bash

# Script to compile the code inside the Docker container and copy the binary to the host

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
    echo "Usage: $0 [c|cpp]"
    echo "  c    - Compile C program (sample)"
    echo "  cpp  - Compile C++ program (main)"
    exit 1
}

# Check arguments
if [ $# -ne 1 ]; then
    usage
fi

case "$1" in
    c)
        echo "Building C program inside Docker container..."
        docker exec -u developer cpp-dev-container bash -c 'cd /home/developer/workspace/src && make sample'
        
        echo "Copying compiled binary to host..."
        docker cp cpp-dev-container:/home/developer/workspace/src/sample ./src/
        
        # Make the binary executable
        chmod +x ./src/sample
        
        echo "C program compiled and copied to ./src/sample"
        ;;
    cpp)
        echo "Building C++ program inside Docker container..."
        docker exec -u developer cpp-dev-container bash -c 'cd /home/developer/workspace/src && make main'
        
        echo "Copying compiled binary to host..."
        docker cp cpp-dev-container:/home/developer/workspace/src/main ./src/
        
        # Make the binary executable
        chmod +x ./src/main
        
        echo "C++ program compiled and copied to ./src/main"
        ;;
    *)
        usage
        ;;
esac
