#!/bin/bash

# Script to check if port 7777 is already in use in the Docker container
# If it is, kill the process using that port

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

echo "Checking if port 7777 is already in use..."

# Try multiple methods to check if port 7777 is in use
# Method 1: Using ss (if available)
if docker exec -u developer cpp-dev-container bash -c "command -v ss > /dev/null"; then
    PORT_CHECK=$(docker exec -u developer cpp-dev-container bash -c "ss -tuln | grep :7777 || echo 'Port available'")
    if [[ "$PORT_CHECK" != *"Port available"* ]]; then
        echo "Port 7777 is in use according to ss check."
        PORT_IN_USE=true
    fi
fi

# Method 2: Using lsof (if available)
if docker exec -u developer cpp-dev-container bash -c "command -v lsof > /dev/null"; then
    PORT_CHECK=$(docker exec -u developer cpp-dev-container bash -c "lsof -i :7777 || echo 'Port available'")
    if [[ "$PORT_CHECK" != *"Port available"* ]]; then
        echo "Port 7777 is in use according to lsof check."
        PORT_IN_USE=true
    fi
fi

# Method 3: Using netstat (if available)
if docker exec -u developer cpp-dev-container bash -c "command -v netstat > /dev/null"; then
    PORT_CHECK=$(docker exec -u developer cpp-dev-container bash -c "netstat -tuln | grep :7777 || echo 'Port available'")
    if [[ "$PORT_CHECK" != *"Port available"* ]]; then
        echo "Port 7777 is in use according to netstat check."
        PORT_IN_USE=true
    fi
fi

# Method 4: Check /proc/net/tcp directly (should work on most Linux systems)
PORT_CHECK=$(docker exec -u developer cpp-dev-container bash -c "grep -i ':1E61' /proc/net/tcp || echo 'Port available'")
if [[ "$PORT_CHECK" != *"Port available"* ]]; then
    echo "Port 7777 is in use according to /proc/net/tcp check."
    PORT_IN_USE=true
fi

if [ "${PORT_IN_USE:-false}" = true ]; then
    echo "Port 7777 is already in use. Attempting to kill the process..."
else
    echo "Port 7777 is available."
    exit 0
fi

# Try multiple methods to find the PID of the process using port 7777
PID=""

# Method 1: Using lsof (if available)
if [ -z "$PID" ] && docker exec -u developer cpp-dev-container bash -c "command -v lsof > /dev/null"; then
    PID=$(docker exec -u developer cpp-dev-container bash -c "lsof -i :7777 -t || echo ''")
    if [ ! -z "$PID" ]; then
        echo "Found PID using lsof: $PID"
    fi
fi

# Method 2: Using ss (if available)
if [ -z "$PID" ] && docker exec -u developer cpp-dev-container bash -c "command -v ss > /dev/null"; then
    PID=$(docker exec -u developer cpp-dev-container bash -c "ss -tuln 'sport = :7777' | grep -v Recv-Q | awk '{print \$6}' | cut -d':' -f1 || echo ''")
    if [ ! -z "$PID" ]; then
        echo "Found PID using ss: $PID"
    fi
fi

# Method 3: Using fuser (if available)
if [ -z "$PID" ] && docker exec -u developer cpp-dev-container bash -c "command -v fuser > /dev/null"; then
    PID=$(docker exec -u developer cpp-dev-container bash -c "fuser 7777/tcp 2>/dev/null || echo ''")
    if [ ! -z "$PID" ]; then
        echo "Found PID using fuser: $PID"
    fi
fi

# Method 4: Using ps to find gdbserver process
if [ -z "$PID" ]; then
    PID=$(docker exec -u developer cpp-dev-container bash -c "ps aux | grep 'gdbserver :7777' | grep -v grep | awk '{print \$2}' || echo ''")
    if [ ! -z "$PID" ]; then
        echo "Found PID using ps: $PID"
    fi
fi

# If we still couldn't find the PID
if [ -z "$PID" ]; then
    echo "Could not find PID using any method. Please check manually."
    # Since we couldn't find the PID, let's assume the port might still be available
    # and continue with the debugging session
    exit 0
fi
    
# If we found a PID, try to kill the process
if [ ! -z "$PID" ]; then
    echo "Found process with PID $PID. Killing process..."
    
    # Kill the process
    KILL_RESULT=$(docker exec -u developer cpp-dev-container bash -c "kill -9 $PID 2>&1 || echo 'Failed to kill process'")
    
    if [[ "$KILL_RESULT" == *"Failed"* ]]; then
        echo "Failed to kill process: $KILL_RESULT"
        exit 1
    else
        echo "Successfully killed process using port 7777."
        
        # Wait a moment for the port to be released
        sleep 1
        exit 0
    fi
fi

# If we reach here, either the port was available or we couldn't find/kill the process
# In either case, we'll let the debugging session continue
exit 0
