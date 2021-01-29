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
#direct sort to bam
samtools.exec("sort /samtools/examples/1.sam -o /samtools/examples/1.sorted.bam").then(d => console.log(d.stdout, "ERRRRRRR", d.stderr));

#
samtools.exec("view -Sb /samtools/examples/1.sam -o /samtools/examples/1.bam").then(d => console.log(d.stdout, "ERRRRRRR", d.stderr));
samtools.exec("sort /samtools/examples/1.bam -o /samtools/examples/1.sorted.bam").then(d => console.log(d.stdout, "ERRRRRRR", d.stderr));

samtools.exec("index /samtools/examples/1.sorted.bam /samtools/examples/1.sorted.bam.bai").then(d => console.log(d.stdout, "ERRRRRRR", d.stderr));

samtools.downloadBinary("/samtools/examples/1.sorted.bam").then(d => saveAs(d, "download.bam"));

samtools.exec("sort /data/1.sam -O=SAM").then((d) => console.log(d.stdout, d.stderr, "End of stderr"))

samtools.exec("sort /data/1.sam -O=SAM")
    .then((d) => {
        console.log(d.stderr, "End of stderr");
        let file = new stdInfo("/samtools/examples/1.sorted.sam", d.stdout);
        return file;
    })
    .then(d => samtools.write(d));

samtools.exec("sort /data/1.sam")
    .then((d) => {
        console.log(d.stderr, "End of stderr");
        let file = new stdInfo("/samtools/examples/1.sorted.bam", d.stdout);
        return file;
    })
    .then(d => samtools.write(d));


## test bwa
bwa.ls("/bwa2/examples").then(d => console.log(d))
bwa.exec("index /bwa2/examples/references.fa").then((d) => console.log(d.stdout, "ERRRRR", d.stderr)).then(() => bwa.ls("/bwa2/examples")).then(d => console.log(d))

bwa.exec("mem /bwa2/examples/references.fa /bwa2/examples/2_S2_L001_R1_001.fastq.gz /bwa2/examples/2_S2_L001_R2_001.fastq.gz")
    .then((d) => console.log(d.stdout, "ERRRRR", d.stderr));


bwa.exec("mem /bwa2/examples/references.fa /data/2_S2_L001_R1_001.fastq /data/2_S2_L001_R2_001.fastq")
    .then((d) => console.log(d.stdout, "ERRRRR", d.stderr));


bwa.exec("mem -o /bwa2/examples/out2.sam /bwa2/example/references.fa /bwa2/example/2_R1_001.fastq.gz /bwa2/example/2_R2_001.fastq.gz")
    .then((d) => console.log(d.stdout, "ERRRRR", d.stderr));


## use bwa aln

bwa.exec("index /bwa2/examples/references.fa").then((d) => console.log(d.stdout, "ERRRRR", d.stderr)).then(() => bwa.ls("/bwa2/examples")).then(d => console.log(d))


bwa.exec("aln -f /bwa2/examples/R1.sai  /bwa2/examples/references.fa /bwa2/examples/2_S2_L001_R1_001.fastq.gz")
    .then((d) => console.log(d.stdout, "ERRRRR\n", d.stderr));
bwa.exec("aln -f /bwa2/examples/R2.sai  /bwa2/examples/references.fa /bwa2/examples/2_S2_L001_R2_001.fastq.gz")
    .then((d) => console.log(d.stdout, "ERRRRR\n", d.stderr));

# no filename

# R1

# single end
#bwa samse [-n max_occ] [-f out.sam] [-r RG_line] <prefix> <in.sai> <in.fq>
bwa.exec("samse /bwa2/examples/references.fa /bwa2/examples/R1.sai /bwa2/examples/2_S2_L001_R1_001.fastq.gz")
    .then((d) => console.log(d.stdout, "ERRRRR", d.stderr));
    

bwa.exec("aln /bwa2/examples/references.fa /bwa2/examples/2_S2_L001_R1_001.fastq.gz")
    .then(d => {
        console.log(d.stderr, "\nEnd of stderr");
        let file = new stdInfo("/bwa2/examples/R1.sai", d.stdout);
        return file;
    })
    .then(d => bwa.write(d));



bwa.exec("aln -f /bwa2/examples/R1.sai /bwa2/examples/references.fa /bwa2/examples/2_S2_L001_R1_001.fastq.gz)
    .then((d) => console.log(d.stdout, "\nERRRRR\n", d.stderr));

bwa.ls("/bwa2/examples").then(d => console.log(d))

bwa.downloadBinary("/bwa2/examples/mystdout").then(d => saveAs(d, "R1.sai"));

bwa.download("/dev/stdout").then(d => saveAs(d, "stdout.txt"));



bwa.exec("mem -o /bwa2/examples/2.sam  /bwa2/examples/references.fa /bwa2/examples/2_S2_L001_R1_001.fastq.gz /bwa2/examples/2_S2_L001_R2_001.fastq.gz")
    .then((d) => console.log(d.stdout, "ERRRRR\n", d.stderr));













