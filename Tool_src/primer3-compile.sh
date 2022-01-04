# 2022-01-04 for version 2.5.0
# patch first, cd the src folder to compile

emmake make
# the last step will produce an error, run the below to recompile the last step
em++ -Wall -O2 -std=c++11 -lstdc++ -o primer3_core.js primer3_boulder_main.o format_output.o read_boulder.o print_boulder.o libprimer3.a libdpal.a libthal.a libthalpara.a liboligotm.a libamplicontm.a libmasker.a -lm -s FORCE_FILESYSTEM=1 -s EXPORTED_RUNTIME_METHODS=["callMain"] -s ALLOW_MEMORY_GROWTH=1 -s ASSERTIONS=1 -s TOTAL_MEMORY=64MB -s EXIT_RUNTIME=0
