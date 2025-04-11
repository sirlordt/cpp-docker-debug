#!/bin/bash

# Script to update the launch.json file with breakpoints from VSCode

# Path to VSCode settings file that contains breakpoints
VSCODE_SETTINGS="${HOME}/.config/Code/User/workspaceStorage"

# Find the most recent workspace storage directory
WORKSPACE_DIR=$(find "${VSCODE_SETTINGS}" -type d -name "*" -exec stat -c "%Y %n" {} \; | sort -nr | head -n 1 | cut -d' ' -f2-)

# Check if we found a workspace directory
if [ -z "${WORKSPACE_DIR}" ]; then
    echo "Could not find VSCode workspace storage directory."
    exit 1
fi

echo "Found workspace storage directory: ${WORKSPACE_DIR}"

# Look for breakpoints file
BREAKPOINTS_FILE="${WORKSPACE_DIR}/state.vscdb"

if [ ! -f "${BREAKPOINTS_FILE}" ]; then
    echo "Could not find breakpoints file: ${BREAKPOINTS_FILE}"
    exit 1
fi

echo "Found breakpoints file: ${BREAKPOINTS_FILE}"

# Extract breakpoints using sqlite3 (if available)
if command -v sqlite3 &> /dev/null; then
    echo "Extracting breakpoints using sqlite3..."
    BREAKPOINTS=$(sqlite3 "${BREAKPOINTS_FILE}" "SELECT value FROM ItemTable WHERE key LIKE '%breakpoints%'")
    
    # Check if we got any breakpoints
    if [ -z "${BREAKPOINTS}" ]; then
        echo "No breakpoints found in the database."
        exit 1
    fi
    
    # Parse the JSON to extract file paths and line numbers
    echo "Parsing breakpoints..."
    echo "${BREAKPOINTS}" > breakpoints.json
    
    # Use jq to extract file paths and line numbers (if available)
    if command -v jq &> /dev/null; then
        FILES_AND_LINES=$(jq -r '.[] | select(.enabled==true) | "\(.source.path):\(.line)"' breakpoints.json 2>/dev/null)
        
        if [ -z "${FILES_AND_LINES}" ]; then
            echo "Could not parse breakpoints using jq."
            echo "Please install jq or manually add breakpoints to launch.json."
            rm breakpoints.json
            exit 1
        fi
        
        # Generate setup commands for launch.json
        echo "Generating setup commands for launch.json..."
        SETUP_COMMANDS=""
        
        while IFS= read -r line; do
            FILE=$(echo "${line}" | cut -d':' -f1)
            LINE=$(echo "${line}" | cut -d':' -f2)
            
            # Extract just the filename from the path
            FILENAME=$(basename "${FILE}")
            
            SETUP_COMMANDS="${SETUP_COMMANDS}                {
                    \"description\": \"Set breakpoint at ${FILENAME}:${LINE}\",
                    \"text\": \"-break-insert -f ${FILENAME}:${LINE}\",
                    \"ignoreFailures\": true
                },
"
        done <<< "${FILES_AND_LINES}"
        
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
        
        echo "launch.json updated with breakpoints from VSCode."
        rm breakpoints.json
    else
        echo "jq is not installed. Please install jq or manually add breakpoints to launch.json."
        rm breakpoints.json
        exit 1
    fi
else
    echo "sqlite3 is not installed. Please install sqlite3 or manually add breakpoints to launch.json."
    exit 1
fi
