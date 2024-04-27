#!/bin/bash

# ██╗  ██╗███████╗ █████╗ ██████╗ ██████╗ ██╗   ██╗██╗     ███████╗███████╗
# ██║  ██║██╔════╝██╔══██╗██╔══██╗██╔══██╗██║   ██║██║     ██╔════╝██╔════╝
# ███████║█████╗  ███████║██████╔╝██████╔╝██║   ██║██║     ███████╗█████╗  
# ██╔══██║██╔══╝  ██╔══██║██╔═══╝ ██╔═══╝ ██║   ██║██║     ╚════██║██╔══╝  
# ██║  ██║███████╗██║  ██║██║     ██║     ╚██████╔╝███████╗███████║███████╗
# ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝      ╚═════╝ ╚══════╝╚══════╝╚══════╝

# ███╗   ███╗███████╗███╗   ███╗ ██████╗ ██████╗ ██╗   ██╗                 
# ████╗ ████║██╔════╝████╗ ████║██╔═══██╗██╔══██╗╚██╗ ██╔╝                 
# ██╔████╔██║█████╗  ██╔████╔██║██║   ██║██████╔╝ ╚████╔╝                  
# ██║╚██╔╝██║██╔══╝  ██║╚██╔╝██║██║   ██║██╔══██╗  ╚██╔╝                   
# ██║ ╚═╝ ██║███████╗██║ ╚═╝ ██║╚██████╔╝██║  ██║   ██║                    
# ╚═╝     ╚═╝╚══════╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝                    

# ██████╗ ██████╗  ██████╗ ███████╗██╗██╗     ███████╗██████╗              
# ██╔══██╗██╔══██╗██╔═══██╗██╔════╝██║██║     ██╔════╝██╔══██╗             
# ██████╔╝██████╔╝██║   ██║█████╗  ██║██║     █████╗  ██████╔╝             
# ██╔═══╝ ██╔══██╗██║   ██║██╔══╝  ██║██║     ██╔══╝  ██╔══██╗             
# ██║     ██║  ██║╚██████╔╝██║     ██║███████╗███████╗██║  ██║             
# ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝             


# If we are root, demote to the user
if (( $EUID == 0 )); then
    echo "Tried to run build as root, demoting to user🚨..."
    su $SUDO_USER -c "$0 $*"
    exit
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
pushd $SCRIPT_DIR > /dev/null

# Check args to see if we do a full build or a partial build
# If the arg is "full", clean the build first
if [ $# -gt 0 ]; then
    if [ "$1" == "full" ]; then
        rm -rf build
    fi
fi

echo "Building allocator🚧..."
echo "========================================================================="

# Check if `build` directory exists
if [ ! -d "build" ]; then
    mkdir build
fi

# Compile the allocator
pushd build > /dev/null
echo "Building in $(pwd)🏗️"

cmake .. || { echo "Failed to run cmake❌"; exit 1; }
# Run make and check if it was successful
make || { echo "Failed to build allocator❌"; exit 1; }

if [ ! -f "libbkmalloc.so" ]; then
    echo "libbkmalloc.so not found❌"
    exit 1
fi

if [ ! -f "libheappulse.so" ]; then
    echo "libheappulse.so not found❌"
    exit 1
fi

# If the files already exist, delete them
rm -f ../libbkmalloc.so
rm -f ../libheappulse.so

cp libbkmalloc.so ../libbkmalloc.so
cp libheappulse.so ../libheappulse.so

popd > /dev/null

echo "Successfully built allocator $(pwd)✅"
echo "libbkmalloc.so and libheappulse.so are in $(pwd)✅"

popd > /dev/null