#!/bin/bash

if [ -z "$JOBS" ]; then
  JOBS=$(nproc)
fi

SCRIPT_PATH="$(cd "$(dirname "$0")" ; pwd -P)"
WS="$SCRIPT_PATH/../.."
BUILD="$WS/build-arch64-poky-linux"
SYSROOT="$BUILD/sysroot"
SRC="$WS/glibc"
OUT="$BUILD/glibc"

mkdir "$BUILD" &> /dev/null
mkdir "$SYSROOT" &> /dev/null

rm -rf "$OUT" &> /dev/null
mkdir "$OUT"
cd "$OUT"

export CFLAGS="-O2 -Wno-error -ffixed-x28"
export CXXFLAGS="${CFLAGS}"
export libc_cv_slibdir="/lib"
export libc_cv_rtlddir="/lib"
"$SRC/configure" \
  --prefix=/usr \
  --libdir=/usr/lib \
  --host=aarch64-linux-gnu

make -j$JOBS && make install DESTDIR="$OUT/install"

if [ -d "install" ]; then
  cp -r "install/"* "$SYSROOT"
fi

