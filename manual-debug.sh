#!/bin/bash

# Script to manually start GDB server in the container and prepare for debugging

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

# Start GDB server in the background
echo "Starting GDB server on port 7777..."
docker exec -u developer -d cpp-dev-container bash -c 'cd /home/developer/workspace/src && make main && gdbserver :7777 ./main'

echo "GDB server started. Now you can connect to it using the 'Manual Debug C++' configuration."
echo "Run the following command to launch VS Code debugger:"
echo "code --open-url \"vscode://ms-vscode.cpptools/debug/launch?name=Manual%20Debug%20C%2B%2B\""
