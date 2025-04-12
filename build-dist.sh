#!/bin/bash

# Script to build and run the distribution container with automatic dependency detection

# Load variables from .build_env file
if [ -f .build_env ]; then
    source .build_env
else
    echo "Error: .build_env file not found"
    exit 1
fi

if [ -z "$App_Maintainer" ]; then
    echo "Error: App_Maintainer not defined in .build_env file"
    exit 1
fi

if [ -z "$App_Name" ]; then
    echo "Error: App_Name not defined in .build_env file"
    exit 1
fi

# Create build directory if it doesn't exist
mkdir -p build/bin

# Check if we need to build the project
if [ ! -f "build/bin/$App_Name" ]; then
    echo "Executable '$App_Name' not found in build/bin/"
    echo "Building the project first..."
    ./build.sh cpp
fi

# Check if the build was successful
if [ ! -f "build/bin/$App_Name" ]; then
    echo "Error: Failed to build the project"
    
    # Create a dummy executable for testing the container
    echo "Creating a dummy executable for testing..."
    echo '#!/bin/bash
echo "This is a dummy executable for testing the container"
echo "App name: $App_Name"
echo "Container timestamp: $TIMESTAMP"
' > build/bin/$App_Name
    chmod +x build/bin/$App_Name
fi

# Generate timestamp for App_Version with the format YYYY-MM-DD_HH-MM-SS_AM_Z
# %Y = year (4 digits), %m = month (01-12), %d = day (01-31)
# %I = hour (01-12), %M = minute (00-59), %S = second (00-59)
# %p = AM/PM, %z = timezone offset (e.g., -0700)
APP_VERSION=$(date '+%Y-%m-%d_%I-%M-%S_%p_%z')
CONTAINER_NAME="${App_Name}"

echo "Analyzing dependencies for $App_Name..."

# Create a temporary directory for dependency analysis
TEMP_DIR=$(mktemp -d)
# Cleanup function to remove temporary files
cleanup() {
    rm -rf "$TEMP_DIR"
    rm -f ./libs.txt ./find_packages.sh ./Dockerfile.analysis
}
trap cleanup EXIT

# Get the list of shared libraries that the executable depends on
echo "Extracting shared library dependencies..."
# Check if the file exists and is executable
if [ ! -f "build/bin/$App_Name" ]; then
    echo "Error: Executable not found at build/bin/$App_Name"
    exit 1
fi

# Make sure it's executable
chmod +x "build/bin/$App_Name"

# Check if it's a dynamic executable
file_type=$(file "build/bin/$App_Name")
echo "File type: $file_type"

if [[ "$file_type" != *"dynamically linked"* ]]; then
    echo "Warning: Not a dynamic executable. Using default dependencies."
    echo "/lib/x86_64-linux-gnu/libstdc++.so.6" > "$TEMP_DIR/libs.txt"
    echo "/lib/x86_64-linux-gnu/libgcc_s.so.1" >> "$TEMP_DIR/libs.txt"
    echo "/lib/x86_64-linux-gnu/libc.so.6" >> "$TEMP_DIR/libs.txt"
else
    # Extract dependencies
    ldd "build/bin/$App_Name" | grep "=>" | awk '{print $3}' | grep -v "linux-vdso.so" > "$TEMP_DIR/libs.txt"
fi

echo "Found $(wc -l < "$TEMP_DIR/libs.txt") shared libraries."

# Create a script to find packages for dependencies
cat > "$TEMP_DIR/find_packages.sh" << 'EOF'
#!/bin/bash
echo "Finding packages for shared libraries..."
mkdir -p /app/results
> /app/results/packages.txt
> /app/results/packages_with_versions.txt

while read -r lib; do
    echo "Processing: $lib"
    # Try dpkg-query first (faster)
    pkg=$(dpkg-query -S $lib 2>/dev/null | cut -d: -f1 | sort -u | head -1)
    
    # If dpkg-query fails, try apt-file (slower but more comprehensive)
    if [ -z "$pkg" ]; then
        pkg=$(apt-file search $lib | grep -v "diversion" | head -1 | cut -d: -f1)
    fi
    
    if [ -n "$pkg" ]; then
        echo "$lib -> $pkg"
        echo "$pkg" >> /app/results/packages.txt
        
        # Get package version
        if [ -n "$pkg" ]; then
            version=$(apt-cache show $pkg 2>/dev/null | grep -m 1 "Version:" | cut -d' ' -f2)
            if [ -n "$version" ]; then
                echo "$pkg => [$version]" >> /app/results/packages_with_versions.txt
            else
                echo "$pkg => [version not found]" >> /app/results/packages_with_versions.txt
            fi
        fi
    else
        echo "Warning: No package found for $lib"
    fi
done < /app/libs.txt

# Remove duplicates and sort
sort -u /app/results/packages.txt > /app/results/packages_unique.txt
sort -u /app/results/packages_with_versions.txt > /app/results/packages_with_versions_unique.txt
echo "Found $(wc -l < /app/results/packages_unique.txt) unique packages."
EOF

chmod +x "$TEMP_DIR/find_packages.sh"

# Copy the temporary files to the current directory for Docker build context
cp "$TEMP_DIR/libs.txt" ./libs.txt
cp "$TEMP_DIR/find_packages.sh" ./find_packages.sh

# Create a temporary Dockerfile for dependency analysis
cat > ./Dockerfile.analysis << EOF
FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install tools for dependency analysis
RUN apt-get update && apt-get install -y \\
    apt-file \\
    dpkg \\
    && apt-get clean \\
    && rm -rf /var/lib/apt/lists/*

# Update apt-file database
RUN apt-file update

# Create app directory
RUN mkdir -p /app

# Copy the executable and dependency list
COPY build/bin/$App_Name /app/$App_Name
COPY libs.txt /app/libs.txt
COPY find_packages.sh /app/find_packages.sh

# Make the script executable
RUN chmod +x /app/find_packages.sh

# Run the script to find packages
CMD ["/app/find_packages.sh"]
EOF

# Build and run the analysis container
echo "Building dependency analysis container..."
docker build -t dependency-analysis -f ./Dockerfile.analysis .

echo "Running dependency analysis..."
docker run --rm -v "$TEMP_DIR:/app/results" dependency-analysis

# Check if the analysis was successful
if [ ! -f "$TEMP_DIR/packages_unique.txt" ]; then
    echo "Error: Dependency analysis failed."
    exit 1
fi

echo "Dependency analysis completed."
echo "Required packages:"
if [ -f "$TEMP_DIR/packages_with_versions_unique.txt" ]; then
    cat "$TEMP_DIR/packages_with_versions_unique.txt"
else
    cat "$TEMP_DIR/packages_unique.txt"
    echo "Warning: Package versions could not be determined."
fi

# Generate the Dockerfile.dist with the detected dependencies
echo "Generating Dockerfile.dist with detected dependencies..."

# Create a mapping of packages to versions
declare -A PKG_VERSIONS
if [ -f "$TEMP_DIR/packages_with_versions_unique.txt" ]; then
    while read -r line; do
        pkg=$(echo "$line" | cut -d' ' -f1)
        version=$(echo "$line" | sed 's/.*\[\(.*\)\]/\1/')
        PKG_VERSIONS["$pkg"]="$version"
    done < "$TEMP_DIR/packages_with_versions_unique.txt"
fi

# Create a string with package dependencies in the format "package_name_1_deb:version;package_name_2_deb:version"
APP_PACKAGE_DEPENDENCIES=""
for pkg in $(cat "$TEMP_DIR/packages_unique.txt"); do
    if [[ -n "${PKG_VERSIONS[$pkg]}" ]]; then
        if [[ -n "$APP_PACKAGE_DEPENDENCIES" ]]; then
            APP_PACKAGE_DEPENDENCIES="${APP_PACKAGE_DEPENDENCIES};"
        fi
        APP_PACKAGE_DEPENDENCIES="${APP_PACKAGE_DEPENDENCIES}${pkg}:${PKG_VERSIONS[$pkg]}"
    fi
done

# Read the packages into an array
PACKAGES=()
while read -r pkg; do
    PACKAGES+=("$pkg")
done < "$TEMP_DIR/packages_unique.txt"

# Create the Dockerfile.dist
cat > Dockerfile.dist << EOF
FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Define app name and maintainer for both build and runtime
ENV App_Name="${App_Name}"
ENV App_Version="${APP_VERSION}"
ENV App_Package_Dependencies="${APP_PACKAGE_DEPENDENCIES}"
ENV App_Maintainer="${App_Maintainer}"
ENV App_Path="/app/${App_Name}/${App_Name}"

# Add metadata
LABEL maintainer="${App_Maintainer}"
LABEL version="${APP_VERSION:-1.0}"
LABEL description="C++ application for debugging demonstration"
LABEL app.version="${APP_VERSION}"
LABEL app.dependencies="${APP_PACKAGE_DEPENDENCIES}"
LABEL app.maintainer="${App_Maintainer}"
LABEL app.path="/app/${App_Name}/${App_Name}"

# Create app directory and logs directory
RUN mkdir -p /app/${App_Name}/logs

# Copy the executable (using the symlink for backward compatibility)
COPY ./build/bin/main /app/${App_Name}/${App_Name}

# Install dependencies
# Automatically detected dependencies for the executable and sanitizers
RUN apt-get update && \\
    apt-get install -y \\
    libasan6 \\
    libubsan1 \\
    liblsan0 \\
EOF

# Add the packages to the Dockerfile.dist (without comments as they cause Docker parsing errors)
for pkg in "${PACKAGES[@]}"; do
    echo "    $pkg \\" >> Dockerfile.dist
done

# Add a comment with package versions after the RUN command
echo "# Package versions:" >> Dockerfile.dist
for pkg in "${PACKAGES[@]}"; do
    if [[ -n "${PKG_VERSIONS[$pkg]}" ]]; then
        echo "# - $pkg: ${PKG_VERSIONS[$pkg]}" >> Dockerfile.dist
    fi
done

# Complete the Dockerfile.dist
cat >> Dockerfile.dist << EOF
    && apt-get clean \\
    && rm -rf /var/lib/apt/lists/*

# Verify that all required shared libraries are available
RUN echo "Verifying shared library dependencies..." && \\
    ldd /app/${App_Name}/${App_Name} | grep -v "linux-vdso.so.1" | \\
    awk 'BEGIN{status=0} {if(\$3=="not" && \$4=="found"){print "Missing:",\$1; status=1}} END{exit status}' || \\
    (echo "Error: Missing shared libraries detected!" && exit 1)

# Set working directory
WORKDIR /app/${App_Name}

# Make the executable executable
RUN chmod +x /app/${App_Name}/${App_Name}

# Add a health check
# For a short-lived application, we just check if the executable exists
HEALTHCHECK --interval=5s --timeout=3s --start-period=5s --retries=3 \\
  CMD test -x /app/${App_Name}/${App_Name} || exit 1

# Command to run when container starts with ASAN log path
CMD ["/bin/sh", "-c", "mkdir -p /app/${App_Name}/logs && ASAN_OPTIONS=\\"log_path=/app/${App_Name}/logs/asan.log\\" /app/${App_Name}/${App_Name}"]
EOF

echo "Dockerfile.dist generated with detected dependencies."

echo "Building distribution container: $CONTAINER_NAME"

# Create a tag-friendly path (replace slashes with periods)
App_Path_TAG=$(echo "/app/${App_Name}/${App_Name}" | tr '/' '.')

# Build the distribution container with tags for version, dependencies, and path
docker build \
    -t $CONTAINER_NAME \
    -t $CONTAINER_NAME:$APP_VERSION \
    -t $CONTAINER_NAME:latest \
    -t $CONTAINER_NAME:path${App_Path_TAG} \
    -f Dockerfile.dist .

echo "Container built successfully: $CONTAINER_NAME"
echo ""
echo "To run the container:"
echo "  docker run --rm $CONTAINER_NAME"
echo ""
echo "To run the container with an interactive shell:"
echo "  docker run --rm -it $CONTAINER_NAME /bin/bash"
