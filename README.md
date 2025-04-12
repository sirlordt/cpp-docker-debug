# C/C++ Debugging in Docker via SSH

This project demonstrates how to debug C/C++ programs inside a Docker container using SSH for communication between VSCode and GDB.

## Overview

This approach offers several advantages:
- Code is compiled and debugged in the same environment (Docker container)
- Direct communication between VSCode and GDB inside the container
- No need to copy binaries between the container and host
- Breakpoints work reliably in VSCode

## Project Structure

- `src/`: Source code directory
  - `main.cpp`: Sample C++ program
  - `sample.c`: Sample C program
  - `Makefile`: Makefile for building the programs
- `Dockerfile`: Docker configuration for the development environment
- `docker-compose.yml`: Docker Compose configuration
- `.vscode/`: VSCode configuration
  - `launch.json`: Debug configurations
  - `tasks.json`: Build tasks
- Scripts:
  - `setup-ssh-debug.sh`: Setup script for SSH debugging
  - `test-ssh.sh`: Test SSH connection
  - `test-gdb-ssh.sh`: Test GDB debugging via SSH
- Documentation:
  - `SSH_DEBUG.md`: Documentation in English
  - `SSH_DEBUG_ES.md`: Documentation in Spanish

## Getting Started

### Prerequisites

- Docker and Docker Compose
- Visual Studio Code with C/C++ extension
- sshpass (will be installed automatically by the setup script if needed)

### Setup

1. Clone this repository
2. Run the setup script:
   ```bash
   ./setup-ssh-debug.sh
   ```
   This script will:
   - Create the ~/.ssh directory and set appropriate permissions
   - Add the Docker container's host key to known_hosts
   - Install sshpass if not already installed
   - Verify that the Docker container is running
   - Check that the SSH server is running in the container
   - Test the SSH connection
   - Build the C++ program

### Debugging

1. Set breakpoints in your code by clicking in the left margin (gutter)
2. Select the "Debug C++ in Docker via SSH" configuration from the Run and Debug menu
3. Start debugging by clicking the green play button or pressing F5

The debugger will:
- Automatically build the code in Docker
- Connect to the container via SSH
- Launch GDB inside the container
- Attach to the program
- Stop at your breakpoints

## Documentation

For more detailed information, see:
- [SSH Debugging Guide (English)](SSH_DEBUG.md)
- [SSH Debugging Guide (Spanish)](SSH_DEBUG_ES.md)

## License

This project is licensed under the MIT License - see the LICENSE file for details.
