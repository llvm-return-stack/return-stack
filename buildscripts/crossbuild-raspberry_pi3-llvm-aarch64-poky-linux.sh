#!/bin/bash

silent() {
  "$@" &>/dev/null
}

if [ -z "$JOBS" ]; then
  JOBS=$(nproc)
fi

[ -z "$CROSS_GCC" ] && CROSS_GCC=$(command -v aarch64-linux-gnu-gcc)
if ! [ -x "$CROSS_GCC" ]; then
  echo "GNU C compiler for the ARM64 architecture not found"
  exit 1
fi

[ -z "$CROSS_GXX" ] && CROSS_GXX=$(command -v aarch64-linux-gnu-g++)
if ! [ -x "$CROSS_GXX" ]; then
  echo "GNU C++ compiler for the ARM64 architecture not found"
  exit 1
fi

SCRIPT_PATH="$(cd "$(dirname "$0")" ; pwd -P)"
WS="$SCRIPT_PATH/../.."
BUILD="$WS/build-raspberry_pi3-aarch64-poky-linux"
SYSROOT="$BUILD/sysroot"
SRC="$WS/llvm"
OUT_NATIVE="$BUILD/llvm-native"
OUT_CROSS="$BUILD/llvm"

silent mkdir -p "$BUILD"
silent mkdir -p "$SYSROOT"

silent rm -rf "$OUT_NATIVE"
silent mkdir -p "$OUT_NATIVE"
cd "$OUT_NATIVE"

[ $? -eq 0 ] && cmake -G Ninja "$SRC" \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_TARGETS_TO_BUILD=X86

[ $? -eq 0 ] && ninja llvm-tblgen && ninja clang-tblgen

if ! [ $? -eq 0 ]; then
  exit 1
fi

silent rm -rf "$OUT_CROSS"
silent mkdir -p "$OUT_CROSS"
cd "$OUT_CROSS"

FLAGS="-march=armv8-a -mcpu=cortex-a53 -mlittle-endian -mabi=lp64"
[ $? -eq 0 ] && cmake -G Ninja "$SRC" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER="$CROSS_GCC" \
  -DCMAKE_C_FLAGS="$FLAGS" \
  -DCMAKE_CROSSCOMPILING=True \
  -DCMAKE_CXX_COMPILER="$CROSS_GXX" \
  -DCMAKE_CXX_FLAGS="$FLAGS" \
  -DCMAKE_INSTALL_PREFIX="$SYSROOT" \
  -DCLANG_TABLEGEN="$OUT_NATIVE/bin/clang-tblgen" \
  -DLLVM_DEFAULT_TARGET_TRIPLE=aarch64-poky-linux \
  -DLLVM_ENABLE_TERMINFO=False \
  -DLLVM_TABLEGEN="$OUT_NATIVE/bin/llvm-tblgen" \
  -DLLVM_TARGET_ARCH=AArch64 \
  -DLLVM_TARGETS_TO_BUILD=AArch64

[ $? -eq 0 ] && ninja -j$JOBS && ninja install

