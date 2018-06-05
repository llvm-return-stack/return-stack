#!/bin/bash

if [ -z "$JOBS" ]; then
  JOBS=4
fi

WS="$PWD/../.."
BUILD="$WS/build-x86_64-linux-gnu"
SYSROOT="$BUILD/sysroot"
SRC="$WS/glibc"
OUT="$BUILD/glibc"

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

make -j$JOBS && make install DESTDIR="$OUT/install"

if [ -d "install" ]; then
  cp -r "install/"* "$SYSROOT"
fi

