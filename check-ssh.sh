#!/bin/bash

# Script to check if SSH is working in the Docker container

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
if docker exec cpp-dev-container pgrep sshd > /dev/null; then
    echo "SSH is running in the container."
else
    echo "SSH is not running in the container. Starting it..."
    docker exec cpp-dev-container /usr/sbin/sshd
    
    # Check again
    if docker exec cpp-dev-container pgrep sshd > /dev/null; then
        echo "SSH is now running in the container."
    else
        echo "Failed to start SSH in the container."
        exit 1
    fi
fi

# Get the container's IP address
CONTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' cpp-dev-container)

echo "SSH is available at:"
echo "  - Host: localhost"
echo "  - Port: 2222"
echo "  - Username: developer"
echo "  - Password: password"
echo ""
echo "You can connect using:"
echo "  ssh developer@localhost -p 2222"
echo ""
echo "Or for VSCode debugging, use the 'Debug C++ in Docker via SSH' configuration."
