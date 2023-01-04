# need to install emsdk
# https://emscripten.org/docs/getting_started/downloads.html

cd bwa-0.7.17

make clean

emmake make

## seems emscripten did not work well with pthread, so I removed all the pthread functions in fastmap.c and pthread.c
# to make bwa mem work
# add the 4th argument as output filename for bwa mem
# emcc -O2 bwa2.o -o ../build/bwa2.html -s FORCE_FILESYSTEM=1 -s EXPORTED_RUNTIME_METHODS=["callMain"] -s ALLOW_MEMORY_GROWTH=1 -lworkerfs.js --preload-file examples/@/bwa2/examples/
emcc -O2 bwa2.o -o bwa2.js -s FORCE_FILESYSTEM=1 -s EXPORTED_RUNTIME_METHODS=["callMain"] -s ALLOW_MEMORY_GROWTH=1
# make patch
# git diff old-git new-git folder
git log .
git diff 122146e0086857630d40e216a21280711482d899 da7615d98affd2567f49a098614509266493683b bwa-0.7.17/ > bwa.patch.txt



# update:
- 2023-01-03: add mate mapping quality (MQ) in the output
- 2022-05-10: add exactSNP as `bwa call` and editcall as `bwa editcall`
