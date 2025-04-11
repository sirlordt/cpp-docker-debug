# Debugging C/C++ Programs Compiled in Docker

This guide explains how to compile C/C++ programs inside a Docker container and debug them locally on the host machine.

## Overview

This approach offers several advantages:
- The code is compiled in a consistent environment (Docker container)
- The debugging is done locally on the host machine, which is more convenient and reliable
- No need to run gdbserver inside the container
- Breakpoints work reliably in VSCode

## Setup

The project includes several scripts to help with this workflow:

- `compile-in-docker.sh`: Compiles the code inside the Docker container and copies the binary to the host
- Other utility scripts from the previous approach are still available if needed

## Workflow

### 1. Compile the Code in Docker

Use the `compile-in-docker.sh` script to compile the code inside the Docker container and copy the binary to the host:

```bash
./compile-in-docker.sh cpp  # For C++ program
# OR
./compile-in-docker.sh c    # For C program
```

This script:
- Builds the program inside the Docker container using the Makefile
- Copies the compiled binary to the host's `src` directory
- Makes the binary executable

### 2. Debug the Binary Locally

In VSCode:

1. Set breakpoints in your code by clicking in the gutter (the area to the left of the code)
2. Select the "Debug Local Binary (compiled in Docker)" configuration from the Run and Debug menu
3. Start debugging by clicking the green play button or pressing F5

The debugger will:
- Automatically compile the code in Docker (using the `compile-in-docker.sh` script)
- Launch the local binary with the debugger attached
- Stop at your breakpoints

### 3. Edit and Repeat

After making changes to your code:

1. The debugger will automatically recompile the code in Docker when you start debugging again
2. You can also manually compile the code using `./compile-in-docker.sh cpp`

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

3. Check if the binary was copied correctly:
   ```bash
   ls -l ./src/main
   ```

4. Make sure the binary is executable:
   ```bash
   chmod +x ./src/main
   ```

5. If breakpoints are not working, try setting them before starting the debugger

## Comparison with the Previous Approach

The previous approach (using gdbserver inside the Docker container) is still available if needed:

- Use the "Debug C++ with Background Server" configuration if you prefer that approach
- The scripts `start-debug.sh`, `check-gdbserver.sh`, and `stop-gdbserver.sh` are still available

However, the new approach (compiling in Docker and debugging locally) is recommended for most cases because:

- It's simpler and more reliable
- Breakpoints work more consistently
- You don't need to manage gdbserver processes
