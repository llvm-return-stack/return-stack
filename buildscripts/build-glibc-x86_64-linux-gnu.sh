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
SRC="$WS/glibc"
OUT="$BUILD/glibc"

silent mkdir -p "$BUILD"
silent mkdir -p "$SYSROOT"

silent rm -rf "$OUT"
silent mkdir -p "$OUT"
cd "$OUT"

if [ $? -eq 0 ]; then
  export CFLAGS="-O2 -Wno-error -ffixed-r15"
  export CXXFLAGS="${CFLAGS}"
  export libc_cv_slibdir="/lib/x86_64-linux-gnu"
  export libc_cv_rtlddir="/lib/x86_64-linux-gnu"
  "$SRC/configure" \
    --prefix=/usr \
    --libdir=/usr/lib/x86_64-linux-gnu
fi

[ $? -eq 0 ] && make -j$JOBS && make install DESTDIR="$SYSROOT"

