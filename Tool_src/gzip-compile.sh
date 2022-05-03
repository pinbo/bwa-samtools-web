# 1. Download gzip 1.12 from here
wget https://ftp.gnu.org/gnu/gzip/gzip-1.12.zip
# 2. unzip and cd the folder
cd gzip-1.12
emconfigure ./configure --disable-year2038
# modify the Makefile and the gzip.c based on the patch file.
