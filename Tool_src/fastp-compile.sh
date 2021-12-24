# need to install emsdk
# https://emscripten.org/docs/getting_started/downloads.html

cd fastp-0.20.1

make clean

emmake make

## removed all the thread functions peprocessor.cpp and seprocessor.cpp based on the patch file at https://github.com/biowasm/biowasm/tree/main/tools/fastp
# add an additional argument "--interleaved_out" to save out1 as an interleaved file
# update 12-23-2021: added -s MAXIMUM_MEMORY=4GB
emcc -O3 fastp.o -o fastp.html -s FORCE_FILESYSTEM=1 -s EXPORTED_RUNTIME_METHODS=["callMain"] -s ALLOW_MEMORY_GROWTH=1 -lworkerfs.js -s MAXIMUM_MEMORY=4GB -s ASSERTIONS=1

emcc -O3 fastp.o -o fastp.html -s FORCE_FILESYSTEM=1 -s EXPORTED_RUNTIME_METHODS=["callMain","FS"] -s ALLOW_MEMORY_GROWTH=1 -s MAXIMUM_MEMORY=4GB -s ASSERTIONS=1


emmake make TARGET="fastp.js" LIBS="-O3 -s USE_ZLIB=1 -s FORCE_FILESYSTEM=1 -s EXPORTED_RUNTIME_METHODS=[\"callMain\"] -s ALLOW_MEMORY_GROWTH=1 -lworkerfs.js -s MAXIMUM_MEMORY=4GB -s ASSERTIONS=1"


/home/junli/Documents/github/emsdk/upstream/emscripten/em++ -r ./obj/adaptertrimmer.o ./obj/basecorrector.o ./obj/duplicate.o ./obj/evaluator.o ./obj/fastareader.o ./obj/fastqreader.o ./obj/filter.o ./obj/filterresult.o ./obj/htmlreporter.o ./obj/jsonreporter.o ./obj/main.o ./obj/nucleotidetree.o ./obj/options.o ./obj/overlapanalysis.o ./obj/peprocessor.o ./obj/polyx.o ./obj/processor.o ./obj/read.o ./obj/seprocessor.o ./obj/sequence.o ./obj/stats.o ./obj/threadconfig.o ./obj/umiprocessor.o ./obj/unittest.o ./obj/writer.o ./obj/writerthread.o -o fastp.js  -O3 -s FORCE_FILESYSTEM=1 -s EXPORTED_RUNTIME_METHODS=["callMain"] -s ALLOW_MEMORY_GROWTH=1 -lworkerfs.js -s MAXIMUM_MEMORY=4GB -s ASSERTIONS=1 
