# need to install emsdk
# https://emscripten.org/docs/getting_started/downloads.html
# if the latest version is not working, install 3.1.0
./emsdk install 3.1.0
./emsdk activate 3.1.0
source "/home/junli/GitHub/emsdk/emsdk_env.sh"

# version 0.7
emcc main.cpp source/index.cpp source/ksw2_extz2_sse.c source/xxhash.c source/ssw_cpp.cpp source/ssw.c source/pc.cpp source/aln.cpp -lz -lpthread -o strobealign.js -O3 -msimd128 -msse -msse2  -s EXTRA_EXPORTED_RUNTIME_METHODS=["callMain"] -s ALLOW_MEMORY_GROWTH=1


# diff
# git diff old-git new-git folder
git diff 71f2695d00843320afcd119f5971075205a0fa70 deecd3b9afc7d317b0b5575aef732ddb03a1678a . > strobeAlign.patch


# version 0.12.0 2024-03-03
# still has problems when running multiple samples and for "-h" command
emcmake cmake -B build -DCMAKE_C_FLAGS="-msse4.2 -msimd128 -s USE_ZLIB=1" -DCMAKE_CXX_FLAGS="-msse4.2 -msimd128 -s USE_ZLIB=1" -DCMAKE_EXE_LINKER_FLAGS="-s FORCE_FILESYSTEM=1 -s EXPORTED_RUNTIME_METHODS=[\"callMain\"] -s ALLOW_MEMORY_GROWTH=1"

emmake make -j -C build

# diff
# git diff old-git new-git folder
git log .
git diff b4d21d957389ea0b705b3bd0865394b8c595ab0b 647f914202b34ca1a4e58f28f4407a803c106108 > strobeAlign_0.12.0.patch

