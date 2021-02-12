# bwa-samtools-web
Move [bwa](http://bio-bwa.sourceforge.net/) and [samtools](http://www.htslib.org/) to the web with [WebAssembly](https://webassembly.org/) for CRISPR NGS checking. I have put it in my blog site: https://junli.netlify.app/apps/make-bam-files-with-bwa-and-samtools/

I compiled `bwa-0.7.17` and `samtools 1.11` by learning the patches and scripts from [biowasm](https://github.com/biowasm).

## Updates

1. 2021-02-07: added `fastp 0.20.1` (JavaScript and wasm files were downloaded from https://cdn.biowasm.com/) and you can use it here: https://junli.netlify.app/apps/filter-fastq-files-with-fastp/. Turns out the author of biowasm, Robert Aboukhalil, has already built an website for fastp: http://fastq.bio/

## Modifications

1. I only kept `bwa` functions `index` and `mem` and `samtools` functions `sort` and `index` to reduce the wasm file size. These functions are enough for me to make the indexed bams.
2. For some reason, the command line `-o` option did not work well for both `bwa mem` and `samtools sort`. So I modified the corresponding c files to use the last argument as the output file name.
3. I did not figure out how to use `pthread` in the browsers, which causes non-functional `bwa mem` and `samtools sort`, so I just disabled `pthread` steps (removing `pthread_create` and `pthread_join` steps).