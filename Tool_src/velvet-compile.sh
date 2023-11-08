# need to install emsdk
# https://emscripten.org/docs/getting_started/downloads.html
# if the latest version is not working, install 3.1.47
# ./emsdk install 3.1.47
# ./emsdk activate 3.1.47
source "/home/junli/GitHub/emsdk/emsdk_env.sh"

# download velvet from here
# https://github.com/dzerbino/velvet/archive/refs/tags/v1.2.10.tar.gz
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
# the 2nd loaded tool not wroking due to FS errors
# found the reason: remove() function in run.c & access() function in run2.c do not work in PROXYFS file system (not the first loaded)
# comment out all remove() lines in run.c and load velvetg first works
# or comment out the access() line in run2.c and load velveth first: it will not affect my pipeline, but may affect if there is a binary file
# Final way: to check the existance of the file with fopen
# if ((file = fopen(seqFilename, "rb")) != NULL) {// Junli: access function did not work in PROXYFS file system
#        fclose(file);
# also increase the kmer choice to 127 (for PE250)
# Update 2023-11-07: emsdk 3.1.47 fixed the bug, and no patches needed.
emmake make MAXKMERLENGTH=127 CC=emcc CFLAGS="-Wall -s USE_ZLIB=1" LDFLAGS="$EM_FLAGS"

## compile for original aioli
# emmake make MAXKMERLENGTH=127 CC=emcc CFLAGS="-Wall -s USE_ZLIB=1" LDFLAGS="-s FORCE_FILESYSTEM=1 -s EXPORTED_RUNTIME_METHODS=[\"callMain\"] -s ALLOW_MEMORY_GROWTH=1"