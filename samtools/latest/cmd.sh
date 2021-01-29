#!/bin/bash

## recompile without the lworkerfs 2021-01-29
emmake make CC=emcc AR=emar CFLAGS="-g -Wall -O2 -s ALLOW_MEMORY_GROWTH=1" 

emcc -O2 samtools.o -o ../build/samtools.html -s EXTRA_EXPORTED_RUNTIME_METHODS=["callMain"] -s ALLOW_MEMORY_GROWTH=1 -s ERROR_ON_UNDEFINED_SYMBOLS=0 --preload-file examples/@/samtools/examples/
