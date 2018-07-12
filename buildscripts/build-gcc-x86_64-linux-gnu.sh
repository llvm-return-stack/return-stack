#!/bin/bash

if [ -z "$JOBS" ]; then
  JOBS=$(nproc)
fi

WS="$PWD/../.."
BUILD="$WS/build-x86_64-linux-gnu"
SYSROOT="$BUILD/sysroot"
SRC="$WS/gcc"
OUT="$BUILD/gcc"

mkdir "$BUILD" &> /dev/null
mkdir "$SYSROOT" &> /dev/null

rm -rf "$OUT" &> /dev/null
mkdir "$OUT"
cd "$OUT"

export CFLAGS="-O2 -ffixed-r15"
export CXXFLAGS="${CFLAGS}"
"$SRC/configure" \
  --enable-languages=c,c++ \
  --prefix="$OUT/install"

make -j$JOBS && make install

if [ -d "install" ]; then
  cp -r "install/"* "$SYSROOT"
fi

