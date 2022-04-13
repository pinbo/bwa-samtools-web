# version 0.7
emcc main.cpp source/index.cpp source/ksw2_extz2_sse.c source/xxhash.c source/ssw_cpp.cpp source/ssw.c source/pc.cpp source/aln.cpp -lz -lpthread -o strobealign.js -O3 -msimd128 -msse -msse2  -s EXTRA_EXPORTED_RUNTIME_METHODS=["callMain"] -s ALLOW_MEMORY_GROWTH=1


# diff
# git diff old-git new-git folder
git diff 71f2695d00843320afcd119f5971075205a0fa70 deecd3b9afc7d317b0b5575aef732ddb03a1678a . > strobeAlign.patch