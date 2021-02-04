# need to install emsdk
# https://emscripten.org/docs/getting_started/downloads.html

cd samtools-1.11
# make a dirctory for output
makedir -p build

make clean
# configure first
emconfigure ./configure --without-curses CFLAGS="-g -Wall -O2 -s USE_ZLIB=1 -s USE_BZIP2=1" --disable-lzma

## Remove pthread_create functions in bam_sort.c
# kept only index and sort functions in bamtk.c to reduce size
emmake make CC=emcc AR=emar CFLAGS="-g -Wall -O2"
emcc -O2 samtools.o -o ./build/samtools.html -s FORCE_FILESYSTEM=1 -s EXTRA_EXPORTED_RUNTIME_METHODS=["callMain"] -s ALLOW_MEMORY_GROWTH=1 -s ERROR_ON_UNDEFINED_SYMBOLS=0 -lworkerfs.js --preload-file examples/@/samtools/examples/
