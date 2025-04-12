#!/bin/bash

# Script to test GDB debugging via SSH

# Create ~/.ssh directory if it doesn't exist and set permissions
mkdir -p ~/.ssh && chmod 700 ~/.ssh

# Add the Docker container's host key to known_hosts
echo "Adding Docker container's host key to known_hosts..."
ssh-keyscan -p 2222 localhost >> ~/.ssh/known_hosts 2>/dev/null

# Check if sshpass is installed
if ! command -v sshpass &> /dev/null; then
    echo "sshpass is not installed. Installing it now..."
    sudo apt-get update && sudo apt-get install -y sshpass
fi

echo "Testing GDB debugging via SSH..."

# First, build the C++ program
echo "Building C++ program..."
docker exec -u developer cpp-dev-container bash -c 'cd /home/developer/workspace && mkdir -p build && cd build && conan install .. --output-folder=. --build=missing && cmake .. -DCMAKE_TOOLCHAIN_FILE=conan_toolchain.cmake -DCMAKE_BUILD_TYPE=Debug && cmake --build . --target main'

# Create a temporary GDB commands file
cat > gdb_commands.txt << EOF
# Set breakpoints
break main
break 27
break 33
break 45

# Run the program
run

# Continue after each breakpoint
continue
continue
continue

# Quit GDB
quit
EOF

# Copy the GDB commands file to the Docker container
echo "Copying GDB commands file to Docker container..."
docker cp gdb_commands.txt cpp-dev-container:/home/developer/workspace/build/bin/

# Run GDB via SSH
echo "Running GDB via SSH..."
sshpass -p "password" ssh -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null developer@localhost "cd /home/developer/workspace/build/bin && gdb -x gdb_commands.txt ./main"

# Check the exit code
if [ $? -eq 0 ]; then
    echo "GDB debugging via SSH test successful!"
else
    echo "GDB debugging via SSH test failed!"
    echo "Make sure the Docker container is running and SSH is properly configured."
fi

# Clean up
rm -f gdb_commands.txt
