#!/bin/bash

# Script to directly debug the C++ program using GDB in the container
# This bypasses VS Code entirely and uses GDB directly

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

# Start an interactive shell in the container and run GDB directly
echo "Starting GDB directly in the container..."
echo "Use the following GDB commands:"
echo "  break main.cpp:10    # Set a breakpoint at line 10 in main.cpp"
echo "  run                  # Start the program"
echo "  next                 # Execute next line"
echo "  step                 # Step into function"
echo "  print variable       # Print variable value"
echo "  continue             # Continue execution"
echo "  quit                 # Exit GDB"
echo ""

docker exec -it -u developer cpp-dev-container bash -c 'cd /home/developer/workspace/src && gdb ./main'
