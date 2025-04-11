#!/bin/bash

# Script to launch VS Code debugger directly from command line

# First, make sure the GDB server is running
./manual-debug.sh

# Wait a moment for the GDB server to start
sleep 2

# Launch VS Code debugger directly
code --open-url "vscode://ms-vscode.cpptools/debug/launch?name=Manual%20Debug%20C%2B%2B"

echo "VS Code debugger should now be connecting to the GDB server."
