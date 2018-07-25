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
SRC="$WS/glibc"
OUT="$BUILD/glibc"

silent mkdir -p "$BUILD"
silent mkdir -p "$SYSROOT"

silent rm -rf "$OUT"
silent mkdir -p "$OUT"
cd "$OUT"

if [ $? -eq 0 ]; then
  export CFLAGS="-O2 -Wno-error -ffixed-x28"
  export CXXFLAGS="${CFLAGS}"
  export libc_cv_slibdir="/lib"
  export libc_cv_rtlddir="/lib"
  "$SRC/configure" \
    --prefix=/usr \
    --libdir=/usr/lib \
    --host=aarch64-linux-gnu
fi

[ $? -eq 0 ] && make -j$JOBS && make install DESTDIR="$SYSROOT"

