#!/bin/bash

# Script to test SSH connection with the same parameters used in launch.json

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

echo "Testing SSH connection to the Docker container..."
sshpass -p "password" ssh -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null developer@localhost "echo 'SSH connection successful!' && cd /home/developer/workspace/src && ls -la"

# Check the exit code
if [ $? -eq 0 ]; then
    echo "SSH connection test successful!"
else
    echo "SSH connection test failed!"
    echo "Make sure the Docker container is running and SSH is properly configured."
    echo "You can try running the container with:"
    echo "  docker-compose up -d"
    echo "And check if SSH is running with:"
    echo "  docker exec cpp-dev-container pgrep sshd"
    echo "If SSH is not running, you can start it with:"
    echo "  docker exec cpp-dev-container /usr/sbin/sshd"
    echo "If you're having issues with SSH authentication, try:"
    echo "  mkdir -p ~/.ssh && chmod 700 ~/.ssh"
    echo "  ssh-keyscan -p 2222 localhost >> ~/.ssh/known_hosts"
fi
