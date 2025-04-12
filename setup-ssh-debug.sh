#!/bin/bash

# Script to set up SSH debugging for C/C++ programs in Docker

echo "Setting up SSH debugging for C/C++ programs in Docker..."

# Create ~/.ssh directory if it doesn't exist and set permissions
echo "Creating ~/.ssh directory and setting permissions..."
mkdir -p ~/.ssh && chmod 700 ~/.ssh

# Add the Docker container's host key to known_hosts
echo "Adding Docker container's host key to known_hosts..."
ssh-keyscan -p 2222 localhost >> ~/.ssh/known_hosts 2>/dev/null

# Check if sshpass is installed
if ! command -v sshpass &> /dev/null; then
    echo "sshpass is not installed. Installing it now..."
    sudo apt-get update && sudo apt-get install -y sshpass
else
    echo "sshpass is already installed."
fi

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

# Check if SSH is running in the container
echo "Checking if SSH is running in the container..."
if ! docker exec cpp-dev-container pgrep sshd > /dev/null; then
    echo "SSH is not running in the container. Starting it..."
    docker exec cpp-dev-container /usr/sbin/sshd
    
    # Check again
    if ! docker exec cpp-dev-container pgrep sshd > /dev/null; then
        echo "Failed to start SSH in the container."
        exit 1
    fi
fi

# Test SSH connection
echo "Testing SSH connection..."
if sshpass -p "password" ssh -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null developer@localhost "echo 'SSH connection successful!'" > /dev/null; then
    echo "SSH connection test successful!"
else
    echo "SSH connection test failed!"
    exit 1
fi

# Build the C++ program
echo "Building C++ program..."
docker exec -u developer cpp-dev-container bash -c 'cd /home/developer/workspace/src && make main'

echo "Setup complete!"
echo ""
echo "You can now debug your C++ program using the 'Debug C++ in Docker via SSH' configuration in VSCode."
echo "1. Set breakpoints in your code"
echo "2. Select the 'Debug C++ in Docker via SSH' configuration from the Run and Debug menu"
echo "3. Start debugging by clicking the green play button or pressing F5"
echo ""
echo "For more information, see SSH_DEBUG.md"
