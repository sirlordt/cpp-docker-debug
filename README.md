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
  - `CMakeLists.txt`: CMake configuration for building the programs
- `CMakeLists.txt`: Main CMake configuration
- `conanfile.txt`: Conan configuration for dependency management
- `Dockerfile`: Docker configuration for the development environment
- `docker-compose.yml`: Docker Compose configuration
- `.vscode/`: VSCode configuration
  - `launch.json`: Debug configurations
  - `tasks.json`: Build tasks
- Scripts:
  - `setup-ssh-debug.sh`: Setup script for SSH debugging
  - `build.sh`: Script for building the programs
  - `run.sh`: Script for running the programs
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

The Docker environment includes:
- CMake (latest version 3.28.3)
- Conan (latest version 2.x, installed with pip)
- GDB and other development tools

### Project Configuration

The project name is defined in the `.env` file in the root directory:

```
PROJECT_NAME=my_cpp_app
```

This name is used for:
- The main executable name
- The distribution container name
- The path within the distribution container

### Dependency Management with Conan

This project uses Conan 2.x for dependency management. The `conanfile.txt` file in the root directory defines the project dependencies and generators:

```
[requires]
# Add your dependencies here, for example:
# boost/1.79.0
# fmt/9.1.0

[generators]
CMakeDeps
CMakeToolchain

[options]
# Specify options for packages here
```

To add a new dependency:

1. Add it to the `[requires]` section in `conanfile.txt`
2. Update the CMakeLists.txt to find and link the package:
   ```cmake
   find_package(PackageName REQUIRED)
   target_link_libraries(your_target PackageName::PackageName)
   ```

### Build System with CMake

The project uses CMake as the build system. The main `CMakeLists.txt` file in the root directory sets up the project, and the `src/CMakeLists.txt` file defines the executables.

The build process is integrated with Conan, which generates the necessary CMake files for dependency management.

### Distribution Container

The project includes a distribution container that packages the compiled executable with all necessary runtime dependencies. This container is based on Ubuntu and is designed for deployment.

To build the distribution container:

```bash
./build-dist.sh
```

This script:
1. Reads the project name from the `.env` file
2. Builds the project if needed
3. Creates a container with a timestamp-based name (e.g., `my_cpp_app-2025-04-11-06-49-01PM-TZ`)
4. Copies the executable to `/app/my_cpp_app/my_cpp_app` inside the container
5. Installs necessary runtime dependencies

The container can be run with:

```bash
docker run --rm my_cpp_app-TIMESTAMP
```

Or with an interactive shell:

```bash
docker run --rm -it my_cpp_app-TIMESTAMP /bin/bash
```

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
