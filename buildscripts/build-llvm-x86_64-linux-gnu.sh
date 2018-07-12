#!/bin/bash

if [ -z "$JOBS" ]; then
  JOBS=$(nproc)
fi

SCRIPT_PATH="$(cd "$(dirname "$0")" ; pwd -P)"
WS="$SCRIPT_PATH/../.."
BUILD="$WS/build-x86_64-linux-gnu"
SYSROOT="$BUILD/sysroot"
SRC="$WS/llvm"
OUT="$BUILD/llvm"
INSTALL="$OUT/install"

mkdir "$BUILD" &> /dev/null
mkdir "$SYSROOT" &> /dev/null

rm -rf "$OUT" &> /dev/null
mkdir "$OUT"
cd "$OUT"

cmake -G Ninja "$SRC" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$INSTALL" \
  -DLLVM_TARGETS_TO_BUILD='X86'

ninja -j$JOBS && ninja install

if [ -d "$INSTALL" ]; then
  cp -r "$INSTALL/"* "$SYSROOT"
fi

