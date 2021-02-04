##### My summary
1. seems only preloaded folder can be written by the programs.
2. Only the prloaded folder can be transfered between workers (maybe only the preload folder can be the target)
3. Samtools problem: samtools sort did not sort (may be the print is not synchronous), so the sorted bam cannot be indexed. Good thing is it can use the -o option to write to disk
4. BWA problem: bwa mem not working, only process the reference but not the fastq files; bwa aln -f to file not working and I cannot redirec the binary output to files. Seems the stdout of the filesystme only print text well.

### update:
1. Everything works after removing pthread and changing output file name as an argument instead of "-o" flag.
2. I also only used the default file system MEMFS (https://emscripten.org/docs/api_reference/Filesystem-API.html), which allows both writing and reading. The WORKERFS file system used originally by Aioli provides read-only access to File and Blob objects, so I cannot make new files there.

##### samtools

let samtools = new Aioli("samtools/latest");
samtools
.init()
.then(() => samtools.ls("/"))
.then(d => console.log(d));


# below works, seems still only works for preloaded folder
Aioli.transfer("/samtools/examples/ex1.fa", "/bwa2/example/ex1.fa", Aioli.workers[1], Aioli.workers[0]).then(d => console.log(d))

# check folder contents
samtools.ls("/samtools/examples").then(d => console.log(d))
bwa.ls("/bwa2/examples").then(d => console.log(d))

# check file content with cat
samtools.cat("/samtools/examples/toy.fa").then(console.log)



## sam to bam
samtools.ls("/samtools/examples").then(d => console.log(d))
# I modified samtools sort to use the 2nd argument as output name without -o flag, which did not work well.
#samtools.exec("sort /samtools/examples/1.sam -o /samtools/examples/out1.bam").then(d => console.log(d.stdout, "ERRRRRRR", d.stderr));
samtools.exec("sort /samtools/examples/1.sam -o /samtools/examples/out1.bam").then(d => console.log(d.stdout, "ERRRRRRR", d.stderr));

samtools.ls("/samtools/examples").then(d => console.log(d))

samtools.exec("index /samtools/examples/out1.bam").then(d => console.log(d.stdout, "ERRRRRRR", d.stderr));

# download
samtools.downloadBinary("/samtools/examples/1.sorted.bam").then(d => saveAs(d, "download.bam"));


### manually loaded data are in /data folder
# if you use WORKERFS file system, you need write your results into the preloaded folder, here is /samtools/examples
samtools.ls("/data").then(console.log)
#samtools.exec("sort /data/out2.sam /samtools/examples/out2.bam").then(d => console.log(d.stdout, "ERRRRRRR", d.stderr));
#samtools.exec("index /samtools/examples/out2.bam").then(d => console.log(d.stdout, "ERRRRRRR", d.stderr));
#samtools.exec("index /data/out2.bam /samtools/examples/out2.bam.bai").then(d => console.log(d.stdout, "ERRRRRRR", d.stderr));
samtools.exec("sort /data/out2.sam /data/out2.bam").then(d => console.log(d.stdout, "ERRRRRRR", d.stderr));
samtools.exec("index /data/out2.bam").then(d => console.log(d.stdout, "ERRRRRRR", d.stderr));
samtools.downloadBinary("out2.bam").then(d => saveAs(d, "out2.bam"));

## test bwa
bwa.ls("/data").then(d => console.log(d))
bwa.exec("index /data/references.fa").then((d) => console.log(d.stdout, "ERRRRR", d.stderr)).then(() => bwa.ls("/data")).then(d => console.log(d))
# no need -o, directly give the output name after the 2nd fastq file
bwa.exec("mem /data/references.fa /data/2_S2_L001_R1_001.fastq.gz /data/2_S2_L001_R2_001.fastq.gz /data/test.sam")
    .then((d) => console.log(d.stdout, "ERRRRR", d.stderr));

## set working environment
bwa.setwd("/data").then(d => console.log(d));
bwa.exec("index references.fa").then((d) => console.log(d.stdout, "ERRRRR", d.stderr)).then(() => bwa.ls("/bwa2/examples")).then(d => console.log(d));
bwa.exec("mem references.fa 2_S2_L001_R1_001.fastq.gz 2_S2_L001_R2_001.fastq.gz out2.sam")
    .then((d) => console.log(d.stdout, "ERRRRR", d.stderr));
bwa.ls("/data").then(console.log)








