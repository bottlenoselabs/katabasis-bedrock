#!/bin/bash
# NOTE: This script builds the various C/C++ shared libraries (.dll/.so/.dylib) for the purposes of P/Invoke with C#.
# INPUT:
#   $1: The target operating system to build the shared library for. Possible values are "host", "windows", "linux", "macos".
#   $2: The target architecture to build the shared library for. Possible values are "default", "x86_64", "arm64".
# OUTPUT: The built shared library if successful, or nothing upon first failure.

DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
. $DIRECTORY/ext/scripts/c/library/input.sh

TARGET_BUILD_OS=`get_target_build_os "$1"`
TARGET_BUILD_ARCH=`get_target_build_arch "$TARGET_BUILD_OS" "$2"`

if [[ "$TARGET_BUILD_OS" == "windows" && "$TARGET_BUILD_ARCH" == "x86_64" ]]; then
    RID=win-x64
elif [[ "$TARGET_BUILD_OS" == "linux" && "$TARGET_BUILD_ARCH" == "x86_64" ]]; then
    RID=linux-x64
elif [[ "$TARGET_BUILD_OS" == "macos" && "$TARGET_BUILD_ARCH" == "x86_64" ]]; then
    RID=osx-x64
elif [[ "$TARGET_BUILD_OS" == "macos" && "$TARGET_BUILD_ARCH" == "arm64" ]]; then
    RID=osx-arm64
elif [[ "$TARGET_BUILD_OS" == "macos" && "$TARGET_BUILD_ARCH" == "x86_64;arm64" ]]; then
    RID=osx
else 
    echo "Unknown Runtime Identifier for '$TARGET_BUILD_OS' and '$TARGET_BUILD_ARCH'."
    exit 1
fi
LIBS_DIR=$DIRECTORY/lib/$RID
mkdir -p $LIBS_DIR

# Build SDL
echo "Building SDL..."
$DIRECTORY/ext/sdl-cs/library.sh $TARGET_BUILD_OS $TARGET_BUILD_ARCH
if [[ $? -ne 0 ]]; then exit $?; fi
mv -v $DIRECTORY/ext/sdl-cs/lib/* $LIBS_DIR
# if [[ $? -ne 0 ]]; then exit $?; fi
if [[ "$TARGET_BUILD_OS" == "windows" ]]; then
    SDL_LIBRARY_FILE_PATH="$LIBS_DIR/SDL2.dll"
elif [[ "$TARGET_BUILD_OS" == "macos" ]]; then
    SDL_LIBRARY_FILE_PATH="$LIBS_DIR/libSDL2.dylib"
elif [[ "$TARGET_BUILD_OS" == "linux" ]]; then
    SDL_LIBRARY_FILE_PATH="$LIBS_DIR/libSDL2.so"
fi
# echo "Building SDL finished!"

# Build FNA3D
echo "Building FNA3D... $SDL_LIBRARY_FILE_PATH"
$DIRECTORY/ext/FNA3D-cs/library.sh $TARGET_BUILD_OS $TARGET_BUILD_ARCH $DIRECTORY/ext/sdl-cs/ext/SDL/include $SDL_LIBRARY_FILE_PATH
if [[ $? -ne 0 ]]; then exit $?; fi
mv -v $DIRECTORY/ext/FNA3D-cs/lib/* $LIBS_DIR
if [[ $? -ne 0 ]]; then exit $?; fi
echo "Building FNA3D finished!"

# Build FAudio
echo "Building FAudio..."
$DIRECTORY/ext/FAudio-cs/library.sh $TARGET_BUILD_OS $TARGET_BUILD_ARCH $DIRECTORY/ext/sdl-cs/ext/SDL/include $SDL_LIBRARY_FILE_PATH
if [[ $? -ne 0 ]]; then exit $?; fi
mv -v $DIRECTORY/ext/FAudio-cs/lib/* $LIBS_DIR
if [[ $? -ne 0 ]]; then exit $?; fi
echo "Building FAudio finished!"

# Build cimgui
echo "Building imgui..."
$DIRECTORY/ext/imgui-cs/library.sh $TARGET_BUILD_OS $TARGET_BUILD_ARCH
if [[ $? -ne 0 ]]; then exit $?; fi
mv -v $DIRECTORY/ext/imgui-cs/lib/* $LIBS_DIR
if [[ $? -ne 0 ]]; then exit $?; fi
echo "Building imgui finished!"

function download_fna_libraries() {
    echo "Downloading latest FNA libraries..."
    FNA_LIBS_DIR=$DIRECTORY/fnalibs
    curl -L https://github.com/deccer/FNA-libs/archive/refs/heads/main.zip > "$DIRECTORY/fnalibs.zip"
    if [ $? -eq 0 ]; then
        echo "Finished downloading!"
    else
        >&2 echo "ERROR: Unable to download successfully."
        exit 1
    fi

    # Decompressing
    echo "Decompressing FNA libraries ..."
    FNA_LIBS_DIR=$DIRECTORY/fnalibs
    mkdir -p $FNA_LIBS_DIR
    unzip $DIRECTORY/fnalibs.zip -d $FNA_LIBS_DIR
    if [ $? -eq 0 ]; then
        echo "Finished decompressing!"
        rm $DIRECTORY/fnalibs.zip
    else
        >&2 echo "ERROR: Unable to decompress successfully."
        exit 1
    fi

    # Move files to specific places...
    echo "Moving files ..."
    if [[ "$TARGET_BUILD_OS" == "windows" ]]; then
        mv $FNA_LIBS_DIR/x64/libtheorafile.dll $LIBS_DIR/libtheorafile.dll
    elif [[ "$TARGET_BUILD_OS" == "macos" ]]; then
        mv $FNA_LIBS_DIR/osx/libMoltenVK.dylib $LIBS_DIR/libMoltenVK.dylib #FNA3D
        mv $FNA_LIBS_DIR/osx/libvulkan.1.dylib $LIBS_DIR/libvulkan.dylib #FNA3D
        mv $FNA_LIBS_DIR/osx/libtheorafile.dylib $LIBS_DIR/libtheorafile.dylib
    elif [[ "$TARGET_BUILD_OS" == "linux" ]]; then
        mv $FNA_LIBS_DIR/lib64/libtheorafile.so $LIBS_DIR/libtheorafile.so
    fi
    echo "Finished moving files!"

    ## Delete uncompressed folder
    rm -rf $FNA_LIBS_DIR
}

download_fna_libraries