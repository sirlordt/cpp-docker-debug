#!/bin/bash

# Script to stop gdbserver process inside the Docker container

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if the container is running
if ! docker ps | grep -q cpp-dev-container; then
    echo "Error: cpp-dev-container is not running."
    exit 1
fi

echo "Searching for gdbserver process inside the container..."

# Try to find gdbserver process using ps, focusing on the actual gdbserver command, not the bash process that started it
GDBSERVER_PROCESS=$(docker exec -u developer cpp-dev-container bash -c "ps aux | grep 'gdbserver' | grep -v 'bash -c' | grep -v grep || echo 'Not running'")

if [[ "$GDBSERVER_PROCESS" == *"Not running"* ]]; then
    echo "gdbserver is NOT running inside the container."
    exit 0
else
    echo "gdbserver IS running inside the container:"
    echo "$GDBSERVER_PROCESS"
    
    # Extract PID (only the first one if multiple lines are returned)
    PID=$(echo "$GDBSERVER_PROCESS" | head -1 | awk '{print $2}')
    echo "Process ID: $PID"
    
    echo "Killing gdbserver process with PID $PID..."
    
    # Kill the process
    KILL_RESULT=$(docker exec -u developer cpp-dev-container bash -c "kill -9 $PID 2>&1 || echo 'Failed to kill process'")
    
    if [[ "$KILL_RESULT" == *"Failed"* ]]; then
        echo "Failed to kill process: $KILL_RESULT"
        exit 1
    else
        echo "gdbserver process terminated successfully."
        
        # Verify that the process is no longer running
        sleep 1
        VERIFY=$(docker exec -u developer cpp-dev-container bash -c "ps -p $PID || echo 'Process terminated'")
        
        if [[ "$VERIFY" == *"Process terminated"* ]]; then
            echo "Verified: The gdbserver process is no longer running."
        else
            echo "Warning: The process might still be running. Details:"
            echo "$VERIFY"
        fi
        
        exit 0
    fi
fi
