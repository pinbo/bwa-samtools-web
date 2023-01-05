# need to install emsdk
# https://emscripten.org/docs/getting_started/downloads.html
# if the latest version is not working, install 3.1.0
./emsdk install 3.1.0
./emsdk activate 3.1.0
source "/home/junli/GitHub/emsdk/emsdk_env.sh"


## compile
cd bwa-0.7.17

make clean



emmake make bwa2 CC=emcc AR=emar CFLAGS="-O2 -msse -msse2 -msimd128 -s USE_ZLIB=1" LDFLAGS="-s FORCE_FILESYSTEM=1 -s EXPORTED_RUNTIME_METHODS=[\"callMain\"] -s ALLOW_MEMORY_GROWTH=1" # -s ERROR_ON_UNDEFINED_SYMBOLS=0"
# simple version: not working as above although I have changed the makefile
#emmake make bwa2 LDFLAGS="-s USE_ZLIB=1 -s FORCE_FILESYSTEM=1 -s EXPORTED_RUNTIME_METHODS=[\"callMain\"] -s ALLOW_MEMORY_GROWTH=1 -s ERROR_ON_UNDEFINED_SYMBOLS=0 -O2"

## seems emscripten did not work well with pthread, so I removed all the pthread functions in fastmap.c and pthread.c
# to make bwa mem work
# add the 4th argument as output filename for bwa mem
# emcc -O2 bwa2.o -o ../build/bwa2.html -s FORCE_FILESYSTEM=1 -s EXPORTED_RUNTIME_METHODS=["callMain"] -s ALLOW_MEMORY_GROWTH=1 -lworkerfs.js --preload-file examples/@/bwa2/examples/

## previous cmd, need to add -r for creating bwa2.o
#emmake make
#emcc -O2 bwa2.o -o bwa2.js -s FORCE_FILESYSTEM=1 -s EXPORTED_RUNTIME_METHODS=["callMain"] -s ALLOW_MEMORY_GROWTH=1

# make patch
# git diff old-git new-git folder
git log .
git diff 122146e0086857630d40e216a21280711482d899 da7615d98affd2567f49a098614509266493683b bwa-0.7.17/ > bwa.patch.txt



# update:
- 2023-01-03: add mate mapping quality (MQ) in the output
- 2022-05-10: add exactSNP as `bwa call` and editcall as `bwa editcall`
