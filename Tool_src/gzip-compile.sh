# ./emsdk install latest (v '4.0.7' works)
# ./emsdk activate latest

# 1. Download gzip 1.12 from here
wget https://ftp.gnu.org/gnu/gzip/gzip-1.12.zip
# 2. unzip and cd the folder
unzip gzip-1.12.zip
cd gzip-1.12
emconfigure ./configure # --disable-year2038 # emsdk v4.0.7 has no errors without disabling year2038.
# modify the Makefile and the gzip.c based on the patch file.
# the patch file line number dependes on the emsdk version.
emmake make