#!/bin/bash

if [ -z "$JOBS" ]; then
  JOBS=$(nproc)
fi

SCRIPT_PATH="$(cd "$(dirname "$0")" ; pwd -P)"
WS="$SCRIPT_PATH/../.."
BUILD="$WS/build-x86_64-linux-gnu"
SYSROOT="$BUILD/sysroot"
SRC="$WS/gcc"
OUT="$BUILD/gcc"
INSTALL="$OUT/install"

mkdir "$BUILD" &> /dev/null
mkdir "$SYSROOT" &> /dev/null

rm -rf "$OUT" &> /dev/null
mkdir "$OUT"
cd "$OUT"

export CFLAGS="-O2 -ffixed-r15"
export CXXFLAGS="${CFLAGS}"
"$SRC/configure" \
  --enable-languages=c,c++ \
  --prefix="$INSTALL"

make -j$JOBS && make install

if [ -d "$INSTALL" ]; then
  cp -r "$INSTALL/"* "$SYSROOT"
fi

