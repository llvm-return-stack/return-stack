#!/bin/bash

silent() {
  "$@" &>/dev/null
}

if [ -z "$JOBS" ]; then
  JOBS=$(nproc)
fi

SCRIPT_PATH="$(cd "$(dirname "$0")" ; pwd -P)"
WS="$SCRIPT_PATH/../.."
BUILD="$WS/build-arch64-poky-linux"
SYSROOT="$BUILD/sysroot"
SRC="$WS/gcc"
OUT="$BUILD/gcc"

silent mkdir -p "$BUILD"
silent mkdir -p "$SYSROOT"

silent rm -rf "$OUT"
silent mkdir -p "$OUT"
cd "$OUT"

if [ $? -eq 0 ]; then
  export CFLAGS="-O2 -ffixed-x28"
  export CXXFLAGS="${CFLAGS}"
  "$SRC/configure" \
    --enable-languages=c,c++ \
    --host=aarch64-linux-gnu \
    --target=aarch64-linux-gnu \
    --prefix="$SYSROOT"
fi

[ $? -eq 0 ] && make -j$JOBS && make install

