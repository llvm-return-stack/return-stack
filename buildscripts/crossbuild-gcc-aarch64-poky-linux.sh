#!/bin/bash

if [ -z "$JOBS" ]; then
  JOBS=$(nproc)
fi

WS="$PWD/../.."
BUILD="$WS/build-arch64-poky-linux"
SYSROOT="$BUILD/sysroot"
SRC="$WS/gcc"
OUT="$BUILD/gcc"

mkdir "$BUILD" &> /dev/null
mkdir "$SYSROOT" &> /dev/null

rm -rf "$OUT" &> /dev/null
mkdir "$OUT"
cd "$OUT"

export CFLAGS="-O2 -ffixed-x28"
export CXXFLAGS="${CFLAGS}"
"$SRC/configure" \
  --enable-languages=c,c++ \
  --host=aarch64-linux-gnu \
  --target=aarch64-linux-gnu \
  --prefix="$OUT/install"

make -j$JOBS && make install

if [ -d "install" ]; then
  cp -r "install/"* "$SYSROOT"
fi

