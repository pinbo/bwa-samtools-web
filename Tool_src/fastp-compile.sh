# need to install emsdk
# https://emscripten.org/docs/getting_started/downloads.html

cd fastp-0.20.1

make clean

emmake make

## removed all the thread functions peprocessor.cpp and seprocessor.cpp based on the patch file at https://github.com/biowasm/biowasm/tree/main/tools/fastp
# add an additional argument "--interleaved_out" to save out1 as an interleaved file
# update 12-23-2021: added -s MAXIMUM_MEMORY=4GB
# emcc -O3 fastp.o -o fastp.html -s FORCE_FILESYSTEM=1 -s EXPORTED_RUNTIME_METHODS=["callMain"] -s ALLOW_MEMORY_GROWTH=1 -lworkerfs.js -s MAXIMUM_MEMORY=4GB -s ASSERTIONS=1


## use alio-v1
emmake make TARGET="fastp.js" LIBS="-O3 -s USE_ZLIB=1 -s FORCE_FILESYSTEM=1 -s EXPORTED_RUNTIME_METHODS=[\"callMain\"] -s ALLOW_MEMORY_GROWTH=1 -s MAXIMUM_MEMORY=4GB -s ASSERTIONS=1"

## use ailio-v2
emmake make TARGET="fastp.js" LIBS="-O3 -s USE_ZLIB=1 -s FORCE_FILESYSTEM=1 -s EXPORTED_RUNTIME_METHODS=[\"callMain\",\"FS\",\"PROXYFS\",\"WORKERFS\"] -s ALLOW_MEMORY_GROWTH=1 -s MODULARIZE=1 -lworkerfs.js -lproxyfs.js -s ASSERTIONS=1"

## make patch file
# seems my original folder is already a modified version
# Please download the original file
cd fastp-0.20.1
git log .
# git diff old-git new-git folder
git diff 012ac2b5557011a5b069b9ea73ca291d0dc7850c 43f1191843934777fd65239fec082b42a7a97c5c . > ../fastp-0.20.1.patch
