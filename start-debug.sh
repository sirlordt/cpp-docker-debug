#!/bin/bash

# Script to help start the debug server for C/C++ programs

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
    echo "  c    - Start debug server for C program (sample)"
    echo "  cpp  - Start debug server for C++ program (main)"
    exit 1
}

# Check arguments
if [ $# -ne 1 ]; then
    usage
fi

case "$1" in
    c)
        echo "Building C program..."
        docker exec -u developer cpp-dev-container bash -c 'cd /home/developer/workspace/src && make sample'
        
        echo "Starting debug server for C program in the background..."
        echo "Connect with VS Code debugger using 'Debug C++ with Background Server' configuration"
        docker exec -u developer cpp-dev-container bash -c 'cd /home/developer/workspace/src && gdbserver --debug :7777 ./sample > /tmp/gdbserver.log 2>&1 &'
        
        # Wait a moment for gdbserver to start
        sleep 2
        
        # Check if gdbserver is running
        if docker exec -u developer cpp-dev-container bash -c 'ps aux | grep "gdbserver" | grep -v "grep" | grep -v "bash -c" > /dev/null'; then
            echo "gdbserver is now running in the background."
            echo "Use ./check-gdbserver.sh to verify its status."
            echo "Use ./stop-gdbserver.sh to stop it when you're done debugging."
        else
            echo "Error: Failed to start gdbserver. Check container logs for details."
            exit 1
        fi
        ;;
    cpp)
        echo "Building C++ program..."
        docker exec -u developer cpp-dev-container bash -c 'cd /home/developer/workspace/src && make main'
        
        echo "Starting debug server for C++ program in the background..."
        echo "Connect with VS Code debugger using 'Debug C++ with Background Server' configuration"
        docker exec -u developer cpp-dev-container bash -c 'cd /home/developer/workspace/src && gdbserver --debug :7777 ./main > /tmp/gdbserver.log 2>&1 &'
        
        # Wait a moment for gdbserver to start
        sleep 2
        
        # Check if gdbserver is running
        if docker exec -u developer cpp-dev-container bash -c 'ps aux | grep "gdbserver" | grep -v "grep" | grep -v "bash -c" > /dev/null'; then
            echo "gdbserver is now running in the background."
            echo "Use ./check-gdbserver.sh to verify its status."
            echo "Use ./stop-gdbserver.sh to stop it when you're done debugging."
        else
            echo "Error: Failed to start gdbserver. Check container logs for details."
            exit 1
        fi
        ;;
    *)
        usage
        ;;
esac
