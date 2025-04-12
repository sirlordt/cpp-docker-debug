#!/bin/bash

# Script to clean up the project by removing unnecessary files

echo "Cleaning up the project..."

# Files to remove
FILES_TO_REMOVE=(
    "check-gdbserver.sh"
    "stop-gdbserver.sh"
    "start-debug.sh"
    "check-debug-port.sh"
    "update-breakpoints.sh"
    "set-breakpoints.sh"
    "debug-step-by-step.sh"
    "debug-with-gdb.sh"
    "connect-to-gdb.sh"
    "direct-debug.sh"
    "launch-debug.sh"
    "manual-debug.sh"
    "vscode-direct-debug.sh"
    "DEBUG.md"
    "LOCAL_DEBUG.md"
    "compile-in-docker.sh"
    "src/gdb_commands.txt"
)

# Remove files
for file in "${FILES_TO_REMOVE[@]}"; do
    if [ -f "$file" ]; then
        echo "Removing $file..."
        rm "$file"
    fi
done

echo "Project cleanup complete!"
echo ""
echo "Remaining files for SSH debugging:"
echo "- setup-ssh-debug.sh: Setup script for SSH debugging"
echo "- test-ssh.sh: Test SSH connection"
echo "- test-gdb-ssh.sh: Test GDB debugging via SSH"
echo "- SSH_DEBUG.md: Documentation in English"
echo "- SSH_DEBUG_ES.md: Documentation in Spanish"
echo "- .vscode/launch.json: Launch configurations for debugging"
echo "- .vscode/tasks.json: Tasks for building and running"
echo ""
echo "To start debugging:"
echo "1. Run ./setup-ssh-debug.sh to set up SSH debugging"
echo "2. Set breakpoints in your code"
echo "3. Select 'Debug C++ in Docker via SSH' from the Run and Debug menu"
echo "4. Start debugging by clicking the green play button or pressing F5"
