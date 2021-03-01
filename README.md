# bwa-samtools-web
Move [bwa](http://bio-bwa.sourceforge.net/) and [samtools](http://www.htslib.org/) to the web with [WebAssembly](https://webassembly.org/) for CRISPR NGS checking. I have put it in my blog site: https://junli.netlify.app/apps/make-bam-files-with-bwa-and-samtools/

I compiled `bwa-0.7.17` and `samtools 1.11` by learning the patches and scripts from [biowasm](https://github.com/biowasm).

## Notes
1. To put these tools on your own website, put the folder "aioli" and other tool folders (such as bwa and samtools) in the same folder on your server. Modify the `urlModule:` to your server address in line 60 of "aioli/lastest/aioli.js".
2. You can also source the file from my website to use the modified version of the `bwa` and `samtools` in this repository.
```html
<script src="https://junli.netlify.app/tools/aioli/latest/aioli.js"></script>
<script>
let samtools = new Aioli("samtools/latest");
document.write("Loading...");
samtools
    // Initialize samtools
    .init()
    // Run "samtools sort" to see the help
    .then(() => samtools.exec("sort"))
    // Output result
    .then(d => document.write(`<pre>${d.stdout}\n${d.stderr}</pre>`));
</script>
```
3. Check the example htmls (such as test-fastp.html) to see how to use each tool.
4. If you want to test them on your computer, you need to run a local HTTP server. With python:
``` sh
# go to the depository folder or open a terminal there
cd path/to/this-repository
# Python 3.x
python3 -m http.server
# On windows try "python" instead of "python3", or "py -3"
# Python 2.X
python -m SimpleHTTPServer
```
5. More tools are available at [biowasm](https://github.com/biowasm/biowasm) repository.

## Updates

- 2021-02-28: replaced  `fastp 0.20.1` (add `interleaved_out` option and compiled based on https://github.com/biowasm/biowasm/tree/main/tools/fastp)
- 2021-02-07: added `fastp 0.20.1` (JavaScript and wasm files were downloaded from https://cdn.biowasm.com/) and you can use it here: https://junli.netlify.app/apps/filter-fastq-files-with-fastp/. Turns out the author of biowasm, Robert Aboukhalil, has already built an website for fastp: http://fastq.bio/

## Modifications

1. I only kept `bwa` functions `index` and `mem` and `samtools` functions `sort` and `index` to reduce the wasm file size. These functions are enough for me to make the indexed bams.
2. For some reason, the command line `-o` option did not work well for both `bwa mem` and `samtools sort`. So I modified the corresponding c files to use the last argument as the output file name.
3. I did not figure out how to use `pthread` in the browsers, which causes non-functional `bwa mem` and `samtools sort`, so I just disabled `pthread` steps (removing `pthread_create` and `pthread_join` steps).
4. I modified the `aioli.js` from [biowasm](https://github.com/biowasm/biowasm) to use the default [file system](https://emscripten.org/docs/api_reference/Filesystem-API.html) and added more functions.