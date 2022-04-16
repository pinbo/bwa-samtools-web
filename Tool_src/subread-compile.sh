
## build
cd subread-2.0.1/src
emmake make -f Makefile.Linux clean
emmake make -f Makefile.Linux
cd ../bin
emcc -O3 subread-align.o -o subread-align.html -s FORCE_FILESYSTEM=1 -s EXPORTED_RUNTIME_METHODS=["callMain"] -s ALLOW_MEMORY_GROWTH=1
emcc -O3 subread-buildindex.o -o subread-buildindex.html -s FORCE_FILESYSTEM=1 -s EXPORTED_RUNTIME_METHODS=["callMain"] -s ALLOW_MEMORY_GROWTH=1 -s MAXIMUM_MEMORY=4GB
emcc -O3 exactSNP.o -o exactSNP.html -s FORCE_FILESYSTEM=1 -s EXPORTED_RUNTIME_METHODS=["callMain"] -s ALLOW_MEMORY_GROWTH=1

## errror for align: Uncaught RuntimeError: table index is out of bounds
# fixed by add -s MAXIMUM_MEMORY=4GB

## modifications
git log
# git diff old-git new-git folder
git diff ebd303896564b928572d78f63a1978fb78f6939f 588e40ade8b4e05a4c9c804024dbf26e1b0b686f subread-2.0.1/src/ > subread.patch.txt
# index-builder.c
	free_mem = 1.5*1024*1024*1024;
    total_mem = 2.*1024*1024*1024;
    reduced memory allocation: from 2GB to 256Mb since my reference is very small.

# core-indel.c
# reduc memory usage
context->config.reads_per_chunk = 5*1024*1024; // Junli change from 20 to 5: this reduced the memeory usage
