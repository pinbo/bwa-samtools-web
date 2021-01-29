samtools.exec("mem -o /bwa2/example/1.sam /bwa2/example/references.fa /bwa2/example/2_R1_001.fastq.gz /bwa2/example/2_R2_001.fastq.gz")
    .then((d) => console.log(d.stdout, d.stderr));
    
    
Usage: samtools index [-bc] [-m INT] <in.bam> [out.index]
Options:
  -b       Generate BAI-format index for BAM files [default]
  -c       Generate CSI-format index for BAM files
  -m INT   Set minimum interval size for CSI indices to 2^INT [14]
  -@ INT   Sets the number of threads [none]


samtools index -c /data/out_99.sorted.bam /samtools/examples/out_99.sorted.bam.csi
ls /samtools/examples

samtools.exec("mem")
    .then((d) => console.log(d.stdout, d.stderr));
    
    
samtools.exec("mem -o /bwa2/example/out1.sam /bwa2/example/references.fa /bwa2/example/2_R1_001.fastq.gz /bwa2/example/2_R2_001.fastq.gz")
    .then((d) => console.log(d.stdout, "ERRRRR", d.stderr));
    


bwa.ls("/bwa2/example").then(d => console.log(d))

samtools.exec("mem /bwa2/example/references.fa /bwa2/example/2_R1_001.fastq.gz /bwa2/example/2_R2_001.fastq.gz")
    .then((d) => console.log(d.stdout));
    
    
let samtools = new Aioli("samtools/latest");
samtools
.init()
.then(() => samtools.ls("/"))
.then(d => console.log(d));

# not working for /data folder
Aioli.transfer("/data/references.fa", Aioli.workers[0], Aioli.workers[1]).then(d => console.log(d))



# below works, seems still only works for preloaded folder
Aioli.transfer("/samtools/examples/ex1.fa", "/bwa2/example/ex1.fa", Aioli.workers[1], Aioli.workers[0]).then(d => console.log(d))

# check folder contents
samtools.ls("/samtools/examples").then(d => console.log(d))
bwa.ls("/bwa2/examples").then(d => console.log(d))

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
samtools.exec("view -Sb /data/1.sam -o /samtools/examples/1.bam").then(d => console.log(d.stdout, "ERRRRRRR", d.stderr));
samtools.exec("sort /samtools/examples/1.bam -o /samtools/examples/1.sorted.bam").then(d => console.log(d.stdout, "ERRRRRRR", d.stderr));

samtools.exec("index /samtools/examples/1.sorted.bam /samtools/examples/1.sorted.bam.bai").then(d => console.log(d.stdout, "ERRRRRRR", d.stderr));

samtools.download("/samtools/examples/1.sorted.bam").then(d => saveAs(d, "download4.bam"));

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













