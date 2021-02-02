#!/bin/bash

# TODO: 

cd src/

make clean

# Also, use autoheader/autoconf to generate config.h.in and configure
#autoheader
#autoconf -Wno-syntax
#emconfigure ./configure --without-curses CFLAGS="-s USE_ZLIB=1 -s USE_BZIP2=1" --disable-lzma
emmake make CC=emcc AR=emar \
    CFLAGS="-O2 -s USE_ZLIB=1 -s USE_BZIP2=1" \
    LDFLAGS="-s ERROR_ON_UNDEFINED_SYMBOLS=0"

# Generate .wasm/.js files
emcc -O2 samtools.o \
    -o ../build/samtools.html \
    $EM_FLAGS \
    -s USE_BZIP2=1 \
    -s ERROR_ON_UNDEFINED_SYMBOLS=0 \
    --preload-file examples/@/samtools/examples/
    


## test less flags 2021-01-27
emconfigure ./configure --without-curses --disable-lzma

emmake make CC=emcc AR=emar CFLAGS="-g -Wall -O2 -s FORCE_FILESYSTEM=1 -s ALLOW_MEMORY_GROWTH=1" 

emcc -O2 samtools.o -o ../build/samtools.html -s FORCE_FILESYSTEM=1 -s EXTRA_EXPORTED_RUNTIME_METHODS=["callMain"] -lworkerfs.js -s ALLOW_MEMORY_GROWTH=1 -s ERROR_ON_UNDEFINED_SYMBOLS=0 --preload-file examples/@/samtools/examples/

## recompile without the lworkerfs 2021-01-29
emmake make CC=emcc AR=emar CFLAGS="-g -Wall -O2 -s ALLOW_MEMORY_GROWTH=1" 

emcc -O2 samtools.o -o ../build/samtools.html -s EXTRA_EXPORTED_RUNTIME_METHODS=["callMain"] -s ALLOW_MEMORY_GROWTH=1 -s ERROR_ON_UNDEFINED_SYMBOLS=0 --preload-file examples/@/samtools/examples/

# no lworkerfs does not change the bad sort results
# but I cannot easily load files
# so reuse lworkerfs

## 2021-02-01 enable pthread: I have to use allow memory growth otherwise errors
emmake make CC=emcc AR=emar CFLAGS="-g -Wall -O2 -s USE_PTHREADS=1"
emcc -O2 samtools.o -o ../build/samtools.html -s EXTRA_EXPORTED_RUNTIME_METHODS=["callMain"] -s USE_PTHREADS=1 -s PTHREAD_POOL_SIZE=2 -s ALLOW_MEMORY_GROWTH=1 -s ERROR_ON_UNDEFINED_SYMBOLS=0 --preload-file examples/@/samtools/examples/

## working one: remove pthread_create functions in bam_sort.c
emmake make CC=emcc AR=emar CFLAGS="-g -Wall -O2"
emcc -O2 samtools.o -o ../build/samtools.html -s EXTRA_EXPORTED_RUNTIME_METHODS=["callMain"] -s ALLOW_MEMORY_GROWTH=1 -s ERROR_ON_UNDEFINED_SYMBOLS=0 --preload-file examples/@/samtools/examples/
