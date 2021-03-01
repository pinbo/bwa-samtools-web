# need to install emsdk
# https://emscripten.org/docs/getting_started/downloads.html

cd fastp-0.20.1

make clean

emmake make

## removed all the thread functions peprocessor.cpp and seprocessor.cpp based on the patch file at https://github.com/biowasm/biowasm/tree/main/tools/fastp
# add an additional argument "--interleaved_out" to save out1 as an interleaved file
emcc -O3 fastp.o -o fastp.html -s FORCE_FILESYSTEM=1 -s EXTRA_EXPORTED_RUNTIME_METHODS=["callMain"] -s ALLOW_MEMORY_GROWTH=1 -lworkerfs.js
