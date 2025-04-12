# Debugging C/C++ Programs in Docker via SSH

This guide explains how to debug C/C++ programs directly inside the Docker container using SSH for communication between VSCode and GDB.

## Overview

This approach offers several advantages:
- Code is compiled and debugged in the same environment (Docker container)
- Direct communication between VSCode and GDB inside the container
- No need to copy binaries between the container and host
- Breakpoints work reliably in VSCode

## Prerequisites

The Docker container is already configured with:
- SSH server installed and configured
- Port 22 in the container mapped to port 2222 on the host
- A user named 'developer' with password 'password'

## Initial Setup

### Option 1: Automatic Setup (Recommended)

Use the `setup-ssh-debug.sh` script to automatically configure everything needed:

```bash
./setup-ssh-debug.sh
```

This script:
- Creates the ~/.ssh directory and sets appropriate permissions
- Adds the Docker container's host key to known_hosts
- Installs sshpass if not already installed
- Verifies that the Docker container is running
- Checks that the SSH server is running in the container
- Tests the SSH connection
- Builds the C++ program

### Option 2: Manual Setup

If you prefer to configure everything manually, follow these steps:

#### 1. Prepare the SSH environment on the host

For SSH debugging to work correctly, we need to configure some things on the host system:

```bash
# Create the ~/.ssh directory if it doesn't exist and set appropriate permissions
mkdir -p ~/.ssh && chmod 700 ~/.ssh

# Add the Docker container's host key to known_hosts
ssh-keyscan -p 2222 localhost >> ~/.ssh/known_hosts
```

#### 2. Install sshpass

For automatic password authentication, we need to install `sshpass`:

```bash
sudo apt-get update && sudo apt-get install -y sshpass
```

### Helper Scripts

The project includes several scripts to facilitate this workflow:

- `setup-ssh-debug.sh`: Automatically configures everything needed for SSH debugging
- `test-ssh.sh`: Verifies that the SSH connection to the container works correctly
- `test-gdb-ssh.sh`: Tests debugging with GDB via SSH
- Other scripts from previous approaches are still available if needed

## Workflow

### 1. Verify the SSH Connection

Use the `test-ssh.sh` script to verify that SSH is working in the container:

```bash
./test-ssh.sh
```

This script:
- Creates the ~/.ssh directory if it doesn't exist
- Adds the container's host key to known_hosts
- Installs sshpass if not installed
- Verifies that the Docker container is running
- Checks that the SSH server is running in the container
- Provides connection information

You can also test the SSH connection manually:

```bash
sshpass -p "password" ssh developer@localhost -p 2222
```

### 2. Debug the Program via SSH

In VSCode:

1. Set breakpoints in your code by clicking in the left margin (gutter)
2. Select the "Debug C++ in Docker via SSH" configuration from the Run and Debug menu
3. Start debugging by clicking the green play button or pressing F5

The debugger will:
- Automatically build the code in Docker
- Connect to the container via SSH
- Launch GDB inside the container
- Attach to the program
- Stop at your breakpoints

### 3. Edit and Repeat

After making changes to your code:

1. The debugger will automatically rebuild the code in Docker when you start debugging again
2. You can also manually build the code using the "Build C++ in Docker" task

## How It Works

This approach uses VSCode's "pipe transport" feature to communicate with GDB over SSH:

1. VSCode launches an SSH connection to the container using sshpass for automatic authentication
2. Commands are sent to GDB inside the container through the SSH connection
3. GDB inside the container has direct access to the program and its symbols
4. Breakpoints and other debugging features work reliably because there's no intermediate layer like gdbserver

### Technical Configuration in launch.json

The configuration in `launch.json` uses `sshpass` for automatic authentication:

```json
"pipeTransport": {
    "pipeCwd": "${workspaceFolder}",
    "pipeProgram": "sshpass",
    "pipeArgs": [
        "-p",
        "password",
        "ssh",
        "-p", 
        "2222", 
        "-o", 
        "StrictHostKeyChecking=no",
        "-o",
        "UserKnownHostsFile=/dev/null",
        "developer@localhost"
    ],
    "debuggerPath": "/usr/bin/gdb"
}
```

## Troubleshooting

If you encounter issues:

1. Make sure the Docker container is running:
   ```bash
   docker ps | grep cpp-dev-container
   ```

2. If the container is not running, start it:
   ```bash
   docker-compose up -d
   ```

3. Verify that SSH is working:
   ```bash
   ./test-ssh.sh
   ```

4. Test debugging with GDB via SSH:
   ```bash
   ./test-gdb-ssh.sh
   ```

5. If you can't connect via SSH, check the Docker logs:
   ```bash
   docker logs cpp-dev-container
   ```

6. Make sure the SSH server is running in the container:
   ```bash
   docker exec cpp-dev-container pgrep sshd
   ```

7. If the SSH server is not running, start it:
   ```bash
   docker exec cpp-dev-container /usr/sbin/sshd
   ```

8. If you're having issues with SSH authentication, make sure:
   - The ~/.ssh directory exists and has the correct permissions
   - The container's host key is in known_hosts
   - sshpass is installed

## Comparison with Other Approaches

This project now supports three different debugging approaches:

1. **SSH Approach (this guide)**:
   - Debug directly inside the container via SSH
   - Pros: Direct communication with GDB, reliable breakpoints
   - Cons: Requires SSH setup

2. **Local Binary Approach**:
   - Compile in Docker, copy binary to host, debug locally
   - Pros: Simple, reliable breakpoints
   - Cons: Binary runs in a different environment than where it was compiled

3. **gdbserver Approach**:
   - Use gdbserver inside the container
   - Pros: Debug in the same environment as compilation
   - Cons: Less reliable breakpoints due to indirect communication

Choose the approach that best fits your needs and workflow.
