#!/bin/bash

# Script to connect to an already running GDB server in the container

# Check if GDB server is running on port 7777
if ! nc -z localhost 7777 &>/dev/null; then
    echo "No GDB server detected on port 7777."
    echo "Would you like to start one? (y/n)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "Starting GDB server..."
        docker exec -u developer -d cpp-dev-container bash -c 'cd /home/developer/workspace/src && make main && gdbserver :7777 ./main'
        sleep 2
    else
        echo "Exiting without starting GDB server."
        exit 1
    fi
fi

# Launch VS Code debugger directly
echo "Connecting to GDB server on localhost:7777..."
code --open-url "vscode://ms-vscode.cpptools/debug/launch?name=Manual%20Debug%20C%2B%2B"

echo "VS Code debugger should now be connecting to the GDB server."
