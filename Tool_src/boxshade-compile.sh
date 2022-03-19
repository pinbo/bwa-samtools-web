# 2022-03-19 for version 3.31
# get the source here: https://github.com/pinbo/boxshade

# compile
emmake make CC="emcc" EXE=".js" LIBS="-lm -s FORCE_FILESYSTEM=1 -s EXPORTED_RUNTIME_METHODS=[\"callMain\"] -s ALLOW_MEMORY_GROWTH=1 -s ASSERTIONS=1 --preload-file settings@/"

# test
boxshade.exec("-in=test.aln -par=box_pep.par -sim=box_pep.sim -grp=box_pep.grp -def -out=test_box_js.eps -dev=2")
boxshade.downloadBinary("test_box_js.eps").then(d => saveAs(d, "download.eps"));

# or rtf
boxshade.exec("-in=test.aln -def -out=test_box_js.rtf -dev=4")
