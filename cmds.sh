##### My summary
1. seems only preloaded folder can be written by the programs.
2. Only the prloaded folder can be transfered between workers (maybe only the preload folder can be the target)
3. Samtools problem: samtools sort did not sort (may be the print is not synchronous), so the sorted bam cannot be indexed. Good thing is it can use the -o option to write to disk
4. BWA problem: bwa mem not working, only process the reference but not the fastq files; bwa aln -f to file not working and I cannot redirec the binary output to files. Seems the stdout of the filesystme only print text well.



##### samtools
# samtools sort: give unsorted output possibly due to the asyn javascript writing.    
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
samtools.ls("/samtools/examples/toy.fa").then(d => console.log(d))

# check whether -o option works
samtools.exec("view -Sb /samtools/examples/toy.sam -o /samtools/examples/toy.bam")
    .then((d) => console.log(d.stdout, "ERRRRRRR", d.stderr));

## check bwa mem again
bwa.exec("index /bwa2/examples/references.fa").then(() => bwa.ls("/bwa2/example")).then(d => console.log(d))

bwa.exec("mem -o /bwa2/example/out2.sam /bwa2/example/references.fa /bwa2/example/2_R1_001.fastq.gz /bwa2/example/2_R2_001.fastq.gz")
    .then((d) => console.log(d.stdout, "ERRRRR", d.stderr));


bwa.exec("mem -o /bwa2/example/out1.sam /bwa2/example/references.fa /bwa2/example/1_R1_001.fastq.gz /bwa2/example/1_R2_001.fastq.gz ")
    .then((d) => console.log(d.stdout, "ERRRRR", d.stderr));




bwa.exec("mem /bwa2/example/references.fa /data/2_R1_001.fastq.gz /data/2_R2_001.fastq.gz")
    .then((d) => console.log(d.stdout, "ERRRRR", d.stderr));


bwa.exec("mem /data/references.fa /data/1_R1_001.fastq.gz /data/1_R2_001.fastq.gz")
    .then((d) => console.log(d.stdout, "ERRRRR", d.stderr));



## test samtools
samtools.ls("/samtools/examples").then(d => console.log(d))
samtools.exec("sort /samtools/examples/1.sam -o /samtools/examples/out1.bam").then(d => console.log(d.stdout, "ERRRRRRR", d.stderr));

samtools.ls("/samtools/examples").then(d => console.log(d))

samtools.exec("index /samtools/examples/out1.bam /data/out1.bam.bai").then(d => console.log(d.stdout, "ERRRRRRR", d.stderr));

samtools.exec("index /data/out2.bam /samtools/examples/out2.bam.bai").then(d => console.log(d.stdout, "ERRRRRRR", d.stderr));

samtools.downloadBinary("/samtools/examples/out2.bam.bai").then(d => saveAs(d, "download.bam"));
samtools.downloadBinary("/samtools/examples/1.sorted.bam").then(d => saveAs(d, "download.bam"));


### load data manually
samtools.ls("/data").then(console.log)
samtools.exec("sort /data/out2.sam -o /samtools/examples/out2.bam").then(d => console.log(d.stdout, "ERRRRRRR", d.stderr));
samtools.ls("/samtools/examples").then(console.log)

samtools.exec("index /samtools/examples/out2.bam").then(d => console.log(d.stdout, "ERRRRRRR", d.stderr));

samtools.exec("index /data/out2.bam /samtools/examples/out2.bam.bai").then(d => console.log(d.stdout, "ERRRRRRR", d.stderr));

samtools.downloadBinary("1.bam").then(d => saveAs(d, "out1.bam"));

##
samtools.ls("/data").then(console.log)
samtools.exec("sort /data/out2.sam -o /data/out2.bam").then(d => console.log(d.stdout, "ERRRRRRR", d.stderr));
samtools.ls("/samtools/examples").then(console.log)


## test bwa
bwa.ls("/bwa2/examples").then(d => console.log(d))
bwa.exec("index /bwa2/examples/references.fa").then((d) => console.log(d.stdout, "ERRRRR", d.stderr)).then(() => bwa.ls("/bwa2/examples")).then(d => console.log(d))

bwa.exec("mem /bwa2/examples/references.fa /bwa2/examples/2_S2_L001_R1_001.fastq.gz /bwa2/examples/2_S2_L001_R2_001.fastq.gz")
    .then((d) => console.log(d.stdout, "ERRRRR", d.stderr));

bwa.exec("mem -o /data/test.sam /bwa2/examples/references.fa /bwa2/examples/2_S2_L001_R1_001.fastq.gz /bwa2/examples/2_S2_L001_R2_001.fastq.gz")
    .then((d) => console.log(d.stdout, "ERRRRR", d.stderr));






bwa.exec("mem /bwa2/examples/references.fa /bwa2/examples/2_S2_L001_R1_001.fastq.gz /bwa2/examples/2_S2_L001_R2_001.fastq.gz")
    .then(d => {
        console.log(d.stderr, "\nEnd of stderr");
        let file = new stdInfo("/bwa2/examples/R1.sai", d.stdout);
        return file;
    })
    .then(d => bwa.write(d));
    
bwa.downloadText("/bwa2/examples/R1.sai").then(d => saveAs(d, "R1.sam"));



## set working environment
bwa.setwd("/bwa2/examples/").then(d => console.log(d));
bwa.exec("index references.fa").then((d) => console.log(d.stdout, "ERRRRR", d.stderr)).then(() => bwa.ls("/bwa2/examples")).then(d => console.log(d));
bwa.exec("mem -o out2.sam references.fa 2_S2_L001_R1_001.fastq.gz 2_S2_L001_R2_001.fastq.gz")
    .then((d) => console.log(d.stdout, "ERRRRR", d.stderr));

bwa.exec("aln -o R1.sai  references.fa 2_S2_L001_R1_001.fastq.gz")
    .then((d) => console.log(d.stdout, "ERRRRR\n", d.stderr));




bwa.ls("/data").then(console.log)








