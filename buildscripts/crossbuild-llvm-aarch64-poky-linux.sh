#!/bin/bash

if [ -z "$JOBS" ]; then
  JOBS=$(nproc)
fi

WS="$PWD/../.."
BUILD="$WS/build-arch64-poky-linux"
SYSROOT="$BUILD/sysroot"
SRC="$WS/llvm"
OUT="$BUILD/llvm"

mkdir "$BUILD" &> /dev/null
mkdir "$SYSROOT" &> /dev/null

rm -rf "$OUT" &> /dev/null
mkdir "$OUT"
cd "$OUT"

FLAGS="-march=armv8-a -mcpu=cortex-a53 -mlittle-endian -mabi=lp64"
cmake -G Ninja "$SRC" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER=/usr/bin/aarch64-linux-gnu-gcc \
  -DCMAKE_C_FLAGS="$FLAGS" \
  -DCMAKE_CROSSCOMPILING=True \
  -DCMAKE_CXX_COMPILER=/usr/bin/aarch64-linux-gnu-g++ \
  -DCMAKE_CXX_FLAGS="$FLAGS" \
  -DCMAKE_INSTALL_PREFIX="$OUT/install" \
  -DLLVM_DEFAULT_TARGET_TRIPLE=aarch64-poky-linux \
  -DLLVM_ENABLE_TERMINFO=False \
  -DLLVM_TARGET_ARCH=AArch64 \
  -DLLVM_TARGETS_TO_BUILD=AArch64

ninja -j$JOBS && ninja install

if [ -d "install" ]; then
  cp -r "install/"* "$SYSROOT"
fi

