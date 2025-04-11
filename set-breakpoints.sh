#!/bin/bash

# Script to update the launch.json file with breakpoints at specific lines in main.cpp

# Check if arguments are provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <line_number1> [line_number2] [line_number3] ..."
    echo "Example: $0 27 33 45"
    exit 1
fi

# Generate setup commands for launch.json
echo "Generating setup commands for launch.json..."
SETUP_COMMANDS=""

for LINE in "$@"; do
    SETUP_COMMANDS="${SETUP_COMMANDS}                {
                    \"description\": \"Set breakpoint at main.cpp:${LINE}\",
                    \"text\": \"-break-insert -f main.cpp:${LINE}\",
                    \"ignoreFailures\": true
                },
"
done

# Remove the trailing comma and newline
SETUP_COMMANDS="${SETUP_COMMANDS%,*}"

# Update launch.json
echo "Updating launch.json..."

# Create a temporary file
TMP_FILE=$(mktemp)

# Read launch.json and replace the setupCommands section
sed -n '1,/setupCommands/p' .vscode/launch.json > "${TMP_FILE}"
echo "            \"setupCommands\": [
                {
                    \"description\": \"Enable pretty-printing for gdb\",
                    \"text\": \"-enable-pretty-printing\",
                    \"ignoreFailures\": true
                },
                {
                    \"description\": \"Set Disassembly Flavor to Intel\",
                    \"text\": \"-gdb-set disassembly-flavor intel\",
                    \"ignoreFailures\": true
                },
                {
                    \"description\": \"Enable pending breakpoints\",
                    \"text\": \"-gdb-set breakpoint pending on\",
                    \"ignoreFailures\": true
                },
                {
                    \"description\": \"Enable non-stop mode\",
                    \"text\": \"-gdb-set non-stop on\",
                    \"ignoreFailures\": true
                },
                {
                    \"description\": \"Enable target async mode\",
                    \"text\": \"-gdb-set target-async on\",
                    \"ignoreFailures\": true
                },
                {
                    \"description\": \"Skip standard library files\",
                    \"text\": \"-interpreter-exec console \\\"skip -gfi /usr/include/c++/*\\\"\",
                    \"ignoreFailures\": true
                },
${SETUP_COMMANDS}
            ]," >> "${TMP_FILE}"

# Add the rest of the file
sed -n '/setupCommands/,/sourceFileMap/d;/sourceFileMap/,$p' .vscode/launch.json >> "${TMP_FILE}"

# Replace the original file
mv "${TMP_FILE}" .vscode/launch.json

echo "launch.json updated with breakpoints at lines: $@"
