#!/bin/bash

# Script to run C/C++ programs in the Docker container without debugging

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
    echo "  c    - Run C program (sample)"
    echo "  cpp  - Run C++ program (main)"
    exit 1
}

# Check arguments
if [ $# -ne 1 ]; then
    usage
fi

case "$1" in
    c)
        echo "Building and running C program..."
        docker exec -u developer cpp-dev-container bash -c 'cd /home/developer/workspace/src && make sample && ./sample'
        ;;
    cpp)
        echo "Building and running C++ program..."
        docker exec -u developer cpp-dev-container bash -c 'cd /home/developer/workspace/src && make main && ./main'
        ;;
    *)
        usage
        ;;
esac
