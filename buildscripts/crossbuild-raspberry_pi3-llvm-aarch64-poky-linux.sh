#!/bin/bash

silent() {
  "$@" &>/dev/null
}

if [ -z "$JOBS" ]; then
  JOBS=$(nproc)
fi

SCRIPT_PATH="$(cd "$(dirname "$0")" ; pwd -P)"
WS="$SCRIPT_PATH/../.."
BUILD="$WS/build-raspberry_pi3-aarch64-poky-linux"
SYSROOT="$BUILD/sysroot"
SRC="$WS/llvm"
OUT="$BUILD/llvm"

silent mkdir -p "$BUILD"
silent mkdir -p "$SYSROOT"

silent rm -rf "$OUT"
silent mkdir -p "$OUT"
cd "$OUT"

FLAGS="-march=armv8-a -mcpu=cortex-a53 -mlittle-endian -mabi=lp64"
[ $? -eq 0 ] && cmake -G Ninja "$SRC" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER=/usr/bin/aarch64-linux-gnu-gcc \
  -DCMAKE_C_FLAGS="$FLAGS" \
  -DCMAKE_CROSSCOMPILING=True \
  -DCMAKE_CXX_COMPILER=/usr/bin/aarch64-linux-gnu-g++ \
  -DCMAKE_CXX_FLAGS="$FLAGS" \
  -DCMAKE_INSTALL_PREFIX="$SYSROOT" \
  -DLLVM_DEFAULT_TARGET_TRIPLE=aarch64-poky-linux \
  -DLLVM_ENABLE_TERMINFO=False \
  -DLLVM_TARGET_ARCH=AArch64 \
  -DLLVM_TARGETS_TO_BUILD=AArch64

[ $? -eq 0 ] && ninja -j$JOBS && ninja install
