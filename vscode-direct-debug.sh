#!/bin/bash

# Script to debug C++ directly in VS Code without using Docker's GDB server
# This approach uses a direct launch configuration

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if the container is running
if ! docker ps | grep -q cpp-dev-container; then
    echo "Starting Docker container..."
    docker run -d --name cpp-dev-container -p 2222:22 -p 7777:7777 -v "$(pwd)/src:/home/developer/workspace/src" --cap-add=SYS_PTRACE --security-opt seccomp=unconfined cpp-docker-debug-cpp-dev
    
    # Wait for container to be fully up
    sleep 3
fi

# Build the C++ program
echo "Building C++ program..."
docker exec -u developer cpp-dev-container bash -c 'cd /home/developer/workspace/src && make main'

# Copy the executable to the local filesystem for direct debugging
echo "Copying executable for direct debugging..."
docker cp cpp-dev-container:/home/developer/workspace/src/main ./src/

# Make sure the executable is executable
chmod +x ./src/main

# Launch VS Code debugger with the direct launch configuration
echo "Launching VS Code debugger with direct configuration..."
code --open-url "vscode://ms-vscode.cpptools/debug?config=$(pwd)/.vscode/direct-launch.json"

echo "VS Code debugger should now be starting with the direct configuration."
