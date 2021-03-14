# need to install emsdk
# https://emscripten.org/docs/getting_started/downloads.html

cd bwa-0.7.17

make clean

emmake make

## seems emscripten did not work well with pthread, so I removed all the pthread functions in fastmap.c and pthread.c
# to make bwa mem work
# add the 4th argument as output filename for bwa mem
emcc -O2 bwa2.o -o ../build/bwa2.html -s FORCE_FILESYSTEM=1 -s EXTRA_EXPORTED_RUNTIME_METHODS=["callMain"] -s ALLOW_MEMORY_GROWTH=1 -lworkerfs.js --preload-file examples/@/bwa2/examples/

# make patch
# git diff old-git new-git folder
git diff 122146e0086857630d40e216a21280711482d899 f80267ae13be4b9e1b8462f8907858182664ccf7 bwa-0.7.17/ > bwa.patch.txt




