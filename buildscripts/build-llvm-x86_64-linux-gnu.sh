#!/bin/bash

if [ -z "$JOBS" ]; then
  JOBS=4
fi

WS="$PWD/../.."
BUILD="$WS/build-x86_64-linux-gnu"
SYSROOT="$BUILD/sysroot"
SRC="$WS/llvm"
OUT="$BUILD/llvm"

mkdir "$BUILD" &> /dev/null
mkdir "$SYSROOT" &> /dev/null

rm -rf "$OUT" &> /dev/null
mkdir "$OUT"
cd "$OUT"

cmake -G Ninja "$SRC" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$OUT/install" \
  -DLLVM_TARGETS_TO_BUILD='X86'

ninja -j$JOBS && ninja install

if [ -d "install" ]; then
  cp -r "install/"* "$SYSROOT"
fi

