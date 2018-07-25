#!/bin/bash

silent() {
  "$@" &>/dev/null
}

if [ -z "$JOBS" ]; then
  JOBS=$(nproc)
fi

SCRIPT_PATH="$(cd "$(dirname "$0")" ; pwd -P)"
WS="$SCRIPT_PATH/../.."
BUILD="$WS/build-x86_64-linux-gnu"
SYSROOT="$BUILD/sysroot"
SRC="$WS/gcc"
OUT="$BUILD/gcc"

silent mkdir -p "$BUILD"
silent mkdir -p "$SYSROOT"

silent rm -rf "$OUT"
silent mkdir -p "$OUT"
cd "$OUT"

if [ $? -eq 0 ]; then
  export CFLAGS="-O2 -ffixed-r15"
  export CXXFLAGS="${CFLAGS}"
  "$SRC/configure" \
    --disable-multilib \
    --enable-languages=c,c++ \
    --prefix="$SYSROOT"
fi

[ $? -eq 0 ] && make -j$JOBS && make install

