#!/bin/bash

# Script to clean up Docker container and build artifacts

echo "This script will clean up the Docker container and build artifacts."
echo "Press Ctrl+C to cancel or any other key to continue..."
read -n 1 -s

# Stop and remove the Docker container
echo "Stopping and removing Docker container..."
docker-compose down

# Clean build artifacts
echo "Cleaning build artifacts..."
if [ -d "src" ]; then
    # Check if the container exists and is running
    if docker ps -a | grep -q cpp-dev-container; then
        docker exec -u developer cpp-dev-container bash -c 'cd /home/developer/workspace/src && make clean'
    else
        # If container is not running, we can't use it to clean
        # Just remove the binaries directly
        rm -f src/main src/sample src/*.o
    fi
fi

echo "Cleanup complete!"
