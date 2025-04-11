#!/bin/bash

# Script to debug the program step by step using gdb from the command line

# Check if gdbserver is running
if ! ./check-gdbserver.sh > /dev/null; then
    echo "gdbserver is not running. Starting it..."
    ./start-debug.sh cpp
    sleep 2
fi

# Create a temporary GDB commands file
cat > gdb_commands.txt << EOF
# Connect to gdbserver
target remote localhost:7777

# Set breakpoints
break main
break 27
break 33
break 45

# Run the program
continue

# At main, print some info and continue
info breakpoints
backtrace
next
next
next

# Continue to the next breakpoint
continue

# At breakpoint_function, print some info and continue
info breakpoints
backtrace
next
next
next

# Continue to the next breakpoint
continue

# At the next breakpoint, print some info and continue
info breakpoints
backtrace
next
next
next

# Continue to the next breakpoint
continue

# At the final breakpoint, print some info
info breakpoints
backtrace

# Quit GDB
quit
EOF

# Run GDB with the commands file
echo "Starting GDB and connecting to gdbserver..."
gdb -x gdb_commands.txt

# Clean up
rm gdb_commands.txt
