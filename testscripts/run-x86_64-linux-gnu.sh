#!/bin/bash

WS="$PWD/../.."
SYSROOT="$WS/build-x86_64-linux-gnu/sysroot"
TEST="$WS/test"

export CC="$SYSROOT/bin/clang"
export CXX="$SYSROOT/bin/clang++"
export SYSROOT="$SYSROOT"

export LDSO_PATH="$SYSROOT/lib/x86_64-linux-gnu/ld-2.27.so"
export LIBC_PATH="$SYSROOT/lib/x86_64-linux-gnu"
export LIBGCC_PATH="$SYSROOT/lib64"

cd "$TEST" && ./run.sh

