# need to install emsdk
# https://emscripten.org/docs/getting_started/downloads.html
# if the latest version is not working, install 4.0.10
# ./emsdk install 4.0.10
# ./emsdk activate 4.0.10
source ~/Github/emsdk/emsdk_env.sh


# download bcftools-1.21, because 1.22 needs more libraries
# no patches needed.

#     -s ASSERTIONS=1
EM_FLAGS=$(cat <<EOF
	-s USE_ZLIB=1
	-s INVOKE_RUN=0
	-s FORCE_FILESYSTEM=1
	-s EXPORTED_RUNTIME_METHODS=["callMain","FS","PROXYFS","WORKERFS"]
	-s MODULARIZE=1
	-s ENVIRONMENT="web,worker"
	-s ALLOW_MEMORY_GROWTH=1
	-lworkerfs.js -lproxyfs.js
EOF
)
EM_FLAGS=$(echo $EM_FLAGS)

## compile for aioli v3
emconfigure ./configure CFLAGS="-s USE_ZLIB=1 -s USE_BZIP2=1" --disable-lzma

EM_FLAGS=$(cat <<EOF
        -s USE_ZLIB=1
        -s INVOKE_RUN=0
        -s FORCE_FILESYSTEM=1
        -s EXPORTED_RUNTIME_METHODS=["callMain","FS","PROXYFS","WORKERFS"]
        -s MODULARIZE=1
        -s ENVIRONMENT="web,worker"
        -s ALLOW_MEMORY_GROWTH=1
        -lworkerfs.js -lproxyfs.js
EOF
)
EM_FLAGS=$(echo $EM_FLAGS)  # Remove whitespace



# patch main.c, maybe not necessary for the new emscripten
int main(int argc, char *argv[])
{
+    int ret = 0; optind = 1; opterr = 1; optopt = 0;


# then compile
emmake make bcftools CC=emcc AR=emar \
    CFLAGS="-O2 -s USE_ZLIB=1 -s USE_BZIP2=1" \
    LDFLAGS="$EM_FLAGS -s ERROR_ON_UNDEFINED_SYMBOLS=0 -O2"
    
# change bcftools to bcftools.js

# below just compile tabix, but you can just use bcftools tabix
cd htslib-1.21
emmake make tabix CC=emcc AR=emar     CFLAGS="-O2 -s USE_ZLIB=1 -s USE_BZIP2=1"     LDFLAGS="$EM_FLAGS -s ERROR_ON_UNDEFINED_SYMBOLS=0 -O2"

