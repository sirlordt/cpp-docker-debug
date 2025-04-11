# C/C++ Docker Development Environment with VS Code Debugging

This project sets up a Docker-based development environment for C and C++ programming with VS Code debugging support. It allows you to compile and debug C/C++ code inside a Docker container while using VS Code on your host system.

## Features

- Ubuntu 22.04 based Docker container with C/C++ development tools
- GDB and GDBServer for remote debugging
- VS Code configuration for seamless debugging experience
- Sample C and C++ programs to test the setup
- Makefile for easy building

## Prerequisites

- Docker and Docker Compose installed on your system
- Visual Studio Code with the following extensions:
  - [C/C++ Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools)
  - [Docker Extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker) (optional but recommended)

## Setup Instructions

1. **Build and start the Docker container**:

   ```bash
   cd cpp-docker-debug
   docker compose up -d --build
   ```

2. **Open the project in VS Code**:

   ```bash
   code .
   ```

3. **Build the sample programs**:

   **Option 1**: Use the provided script:
   ```bash
   # For C++ program
   ./build.sh cpp
   
   # For C program
   ./build.sh c
   
   # For both programs
   ./build.sh all
   ```
   
   **Option 2**: In VS Code, press `Ctrl+Shift+B` (or `Cmd+Shift+B` on macOS) to run the default build task, or select from the available build tasks:
   - Build C++ Project
   - Build C Project

4. **Start debugging**:

   1. Start the debugger:
      - Press F5 or go to Run > Start Debugging
      - Select "Debug C++ in Docker" or "Debug C in Docker" from the configuration dropdown
      - The system will automatically build the project and start the debug server before launching the debugger

   2. Set breakpoints in your code and debug as usual

   **Note**: If you prefer to manually control the build and debug server process, you can still use the provided script:
   ```bash
   # For C++ program
   ./start-debug.sh cpp
   
   # For C program
   ./start-debug.sh c
   ```
   
   Or use VS Code tasks from the Terminal menu (Terminal > Run Task...):
   - "Build C++ Project" or "Build C Project" to build the programs
   - "Start C++ Debug Server" or "Start C Debug Server" to start the debug servers

## Project Structure

- `Dockerfile`: Defines the Docker container with all necessary tools
- `docker-compose.yml`: Configures the Docker service with proper settings for debugging
- `src/`: Contains the source code
  - `main.cpp`: Sample C++ program
  - `sample.c`: Sample C program
  - `Makefile`: For building the programs
- `.vscode/`: VS Code configuration
  - `launch.json`: Debugger configuration
  - `tasks.json`: Build and debug server tasks
  - `c_cpp_properties.json`: IntelliSense configuration
- Helper scripts:
  - `build.sh`: Script to build C/C++ programs
  - `run.sh`: Script to run programs without debugging
  - `start-debug.sh`: Script to start the debug server
  - `cleanup.sh`: Script to clean up Docker container and build artifacts

## Running Without Debugging

If you just want to run the programs without debugging, you can use the provided run script:

```bash
# Run C++ program
./run.sh cpp

# Run C program
./run.sh c
```

This will build and run the program in one step, displaying the output in the terminal.

## Debugging Workflow

1. Make changes to your C/C++ code
2. Launch the debugger with F5 and select the appropriate configuration ("Debug C++ in Docker" or "Debug C in Docker")
3. Debug your application with breakpoints, variable inspection, etc.

The system will automatically build the project and start the debug server before launching the debugger.

## Notes

- The Docker container exposes port 7777 for GDB remote debugging
- The source code is mounted as a volume, so changes made on the host are immediately available in the container
- Default user credentials in the container are:
  - Username: developer
  - Password: password

## Cleanup

When you're done with the project, you can clean up the Docker container and build artifacts using the provided cleanup script:

```bash
./cleanup.sh
```

This will:
1. Stop and remove the Docker container
2. Clean up build artifacts (compiled binaries and object files)
