# need to install emsdk
# https://emscripten.org/docs/getting_started/downloads.html

cd bwa-0.7.17

make clean

emmake make

## seems emscripten did not work well with pthread, so I removed all the pthread functions in fastmap.c and pthread.c
# to make bwa mem work
# add the 4th argument as output filename for bwa mem
emcc -O2 bwa2.o -o ../build/bwa2.html -s FORCE_FILESYSTEM=1 -s EXTRA_EXPORTED_RUNTIME_METHODS=["callMain"] -s ALLOW_MEMORY_GROWTH=1 -lworkerfs.js --preload-file examples/@/bwa2/examples/






