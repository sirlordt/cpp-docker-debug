#!/bin/bash

# Script to check if gdbserver is running inside the Docker container

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

echo "Checking if gdbserver is running inside the container..."

# Try to find gdbserver process using ps, focusing on the actual gdbserver command, not the bash process that started it
GDBSERVER_PROCESS=$(docker exec -u developer cpp-dev-container bash -c "ps aux | grep 'gdbserver' | grep -v 'bash -c' | grep -v grep || echo 'Not running'")

if [[ "$GDBSERVER_PROCESS" == *"Not running"* ]]; then
    echo "gdbserver is NOT running inside the container."
    exit 1
else
    echo "gdbserver IS running inside the container:"
    echo "$GDBSERVER_PROCESS"
    
    # Extract PID (only the first one if multiple lines are returned)
    PID=$(echo "$GDBSERVER_PROCESS" | head -1 | awk '{print $2}')
    echo "Process ID: $PID"
    
    # Check which port it's listening on
    PORT_INFO=$(docker exec -u developer cpp-dev-container bash -c "ls -l /proc/$PID/fd 2>/dev/null | grep socket || echo 'Port info not available'")
    echo "Port information: $PORT_INFO"
    
    # Check process details
    echo "Process details:"
    CMD_LINE=$(docker exec -u developer cpp-dev-container bash -c "cat /proc/$PID/cmdline 2>/dev/null | tr '\0' ' ' || echo 'Process details not available'")
    echo "$CMD_LINE"
    
    # Check if it's listening on port 7777
    if [[ "$GDBSERVER_PROCESS" == *":7777"* ]]; then
        echo "gdbserver is listening on port 7777."
    else
        echo "gdbserver might be running but not listening on port 7777."
    fi
    
    exit 0
fi
