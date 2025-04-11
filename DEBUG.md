# Debugging C/C++ in Docker with VSCode

This guide explains how to debug C/C++ programs running inside a Docker container using VSCode.

## Setup

The project includes several scripts to help with debugging:

- `start-debug.sh`: Starts gdbserver in the background
- `check-gdbserver.sh`: Checks if gdbserver is running
- `stop-gdbserver.sh`: Stops gdbserver
- `check-debug-port.sh`: Checks if port 7777 is available and frees it if necessary

## Debugging with Background gdbserver

This method starts gdbserver in the background and then connects to it with VSCode:

1. First, make sure no gdbserver is running:
   ```bash
   ./stop-gdbserver.sh
   ```

2. Start gdbserver in the background:
   ```bash
   ./start-debug.sh cpp  # For C++ program
   # OR
   ./start-debug.sh c    # For C program
   ```

3. Verify that gdbserver is running:
   ```bash
   ./check-gdbserver.sh
   ```

4. In VSCode, set breakpoints in your code (e.g., lines 16 and 22 in main.cpp)

5. Select the "Debug C++ with Background Server" configuration from the Run and Debug menu

6. Start debugging by clicking the green play button or pressing F5

7. The debugger should stop at your breakpoints

8. When you're done debugging, stop gdbserver:
   ```bash
   ./stop-gdbserver.sh
   ```

## Troubleshooting

If the debugger doesn't stop at your breakpoints:

1. Make sure gdbserver is running:
   ```bash
   ./check-gdbserver.sh
   ```

2. Check if the program is being compiled with debug symbols:
   ```bash
   docker exec -u developer cpp-dev-container bash -c 'cd /home/developer/workspace/src && make clean && make CXXFLAGS="-g -O0" main'
   ```

3. Restart gdbserver:
   ```bash
   ./stop-gdbserver.sh
   ./start-debug.sh cpp
   ```

4. Try using the "stopAtEntry" feature to make sure the debugger is connecting properly. The debugger should stop at the beginning of the main function.

5. Check the Debug Console in VSCode for any error messages.

## Alternative Debugging Methods

The project also includes two other debugging configurations:

1. **Debug C++ in Docker**: This uses the "Build and Start C++ Debug Server" task to start gdbserver. It will wait for gdbserver to start before connecting.

2. **Manual Debug C++**: This is for when you've manually started gdbserver (not using our scripts).

These methods may be useful in certain situations, but the "Debug C++ with Background Server" configuration is recommended for use with our scripts.
