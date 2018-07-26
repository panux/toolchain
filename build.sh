#!/bin/bash

# print help
help() {
    echo "Usage: $0 <arch> [package]"
}

# help option
if [ "-h" == "$1" ] || [ "--help" == "$1" ]; then
    help
    exit 0
fi

# check for sufficient arguments
if [[ $# < 1 ]]; then
    echo "Error: not enough arguments."
    help
    exit 1
fi

PACKAGES=(musl)
export ARCH="$1"
shift

TOOL_DIR="$PWD/tools/$ARCH"
if [ ! -d "$TOOL_DIR" ]; then
    mkdir "$TOOL_DIR"
fi

if [ -z "$MAKEFLAGS" ]; then
    export MAKEFLAGS="-j8"
fi

set -e

fetch() {
    ./fetch.sh "$@"
}

buildenv() {
    if [ -e "build/$1-$2" ]; then
        rm -rf "build/$1-$2"
    fi
    mkdir "build/$1-$2"
    echo "build/$1-$2"
}

MUSL_VERSION=1.1.18
musl() {
    fetch https://www.musl-libc.org/releases/musl-$MUSL_VERSION.tar.gz src/musl-$MUSL_VERSION.tar.gz
    BDIR=$(buildenv musl "$ARCH")
    tar -xf src/musl-$MUSL_VERSION.tar.gz -C "$BDIR"
    (
        cd "$BDIR/musl-$MUSL_VERSION"
        ./configure --prefix=/usr --syslibdir=/usr/lib
        make "$MAKEFLAGS"
        make "$MAKEFLAGS" install DESTDIR="$TOOL_DIR"
    )
}

if [[ $# < 1 ]]; then
    for i in $PACKAGES; do
        $i
    done
else
    for i in $@; do
        $i
    done
fi
