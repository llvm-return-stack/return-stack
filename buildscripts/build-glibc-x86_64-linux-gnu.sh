#!/bin/bash

if [ -z "$JOBS" ]; then
  JOBS=$(nproc)
fi

SCRIPT_PATH="$(cd "$(dirname "$0")" ; pwd -P)"
WS="$SCRIPT_PATH/../.."
BUILD="$WS/build-x86_64-linux-gnu"
SYSROOT="$BUILD/sysroot"
SRC="$WS/glibc"
OUT="$BUILD/glibc"
INSTALL="$OUT/install"

mkdir "$BUILD" &> /dev/null
mkdir "$SYSROOT" &> /dev/null

rm -rf "$OUT" &> /dev/null
mkdir "$OUT"
cd "$OUT"

export CFLAGS="-O2 -Wno-error -ffixed-r15"
export CXXFLAGS="${CFLAGS}"
export libc_cv_slibdir="/lib/x86_64-linux-gnu"
export libc_cv_rtlddir="/lib/x86_64-linux-gnu"
"$SRC/configure" \
  --prefix=/usr \
  --libdir=/usr/lib/x86_64-linux-gnu

make -j$JOBS && make install DESTDIR="$INSTALL"

if [ -d "$INSTALL" ]; then
  cp -r "$INSTALL/"* "$SYSROOT"
fi

