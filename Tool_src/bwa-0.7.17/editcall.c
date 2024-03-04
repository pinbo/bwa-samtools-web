#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <unistd.h>
#include <zlib.h>
#include "kstring.h"
#include "khash.h"
#include "kvec.h"
#include "kseq.h"


// to compile a standalone app
// gcc -Wall -g -O2 editcall.c kstring.c  -o editcall -lz -DMAKE_STANDALONE
// for included in bwa
// 
typedef char *kgets_func(char *, int, void *);
int kgetline(kstring_t *s, kgets_func *fgets_fn, void *fp)
{
	size_t l0 = s->l;

	while (s->l == l0 || s->s[s->l-1] != '\n') {
		if (s->m - s->l < 200) ks_resize(s, s->m + 200);
		if (fgets_fn(s->s + s->l, s->m - s->l, fp) == NULL) break;
		s->l += strlen(s->s + s->l);
	}

	if (s->l == l0) return EOF;

	if (s->l > l0 && s->s[s->l-1] == '\n') {
		s->l--;
		if (s->l > l0 && s->s[s->l-1] == '\r') s->l--;
	}
	s->s[s->l] = '\0';
	return 0;
}

// typedef kvec_t(int) kvecn; // int or char vector
typedef kvec_t(char *) kvecs; // string vector

// split by substring (not char), return an array of substring
char ** splitsub(char *str, const char *delim, int *n)
{
    kvecs array;
    kv_init(array);
    size_t dl = strlen(delim); // delim length
    kv_push(char *, array, str);
    *n = 1;
    char *p, *tmp;
    p = tmp = str;
    while (p != NULL){
        p = strstr(tmp, delim);
        if (p == NULL) return array.a;
        *p = '\0';
        tmp = p + dl;
        // printf("tmp is %s \n", tmp);
        kv_push(char *, array, tmp);
        *n += 1;
    }
    return array.a;
}

// max of two numbers
int max(int a, int b){
  int m;
  if (a > b) m = a;
  else m = b;
  return m;
}

// string slice
void slice(const char *str, char *result, size_t start, size_t end)
{
    strncpy(result, str + start, end - start);
    result[end - start] = 0;
}

KSEQ_INIT(gzFile, gzread)
KHASH_MAP_INIT_STR(fasta, char *)      // instantiate structs and methods
KHASH_MAP_INIT_STR(str, int)      // instantiate structs and methods
KHASH_MAP_INIT_STR(dep, int *)      // hashmap for depth: chrom -> array of depth on the sequence

// fn parse_line (line: &str, map: &mut HashMap<String, isize>, no_small_indels: bool, debug: bool) 
khash_t(fasta) * read_fasta(char *infile){
  gzFile fp;
	kseq_t *seq;
	int l;
	fp = gzopen(infile, "r");
	seq = kseq_init(fp);
  khint_t k;
  int absent;
  khash_t(fasta) *h; // hash for mutations
  h = kh_init(fasta);

	while ((l = kseq_read(seq)) >= 0) {
    for (int i = 0; i < seq->seq.l; ++i) {
      seq->seq.s[i] = toupper(seq->seq.s[i]);
    }
    k = kh_put(fasta, h, seq->name.s, &absent);
    if (absent) {
      kh_key(h, k) = strdup(seq->name.s); // strdup will malloc, so need to be freed
      kh_val(h, k) = strdup(seq->seq.s);
    }
	}
	// printf("return value: %d\n", l);
	kseq_destroy(seq);
	gzclose(fp);
	return h;
}


// int exclamationCheck = strchr(str, '!') != NULL;
typedef struct {
    kvec_t(char) vop; // M, S etc
    kvec_t(int) vlen; // length
} cigar_info;

cigar_info split_cigar (char *cigar) {
  cigar_info r;// = {vop, vlen };
  kv_init(r.vop);
  kv_init(r.vlen);
  char *numbers = "0123456789";
  char tmp[6] = "";
  int n = 0;
  for (int i = 0; i < strlen(cigar); i++) {
    int isNum = strchr(numbers, cigar[i]) != NULL;
    if (isNum) {
        tmp[n] = cigar[i];
        n++;
    } else {
      kv_push(char, r.vop, cigar[i]); // append
      kv_push(int, r.vlen, atoi(tmp));
      // tmp[0] = 0; // wrong way
      memset(tmp, 0, sizeof(tmp)); // reset tmp
      n = 0;
    }
  }

  return r;
}

// get depth of all positions in all templates
int get_depth(char *cigar, int *dep_array, int ref_pos){//khash_t(dep) *dh, 
  cigar_info r = split_cigar(cigar);
  int ref_pos1 = ref_pos; // left start
  int ref_pos2 = ref_pos; // right end
  for (int i =0; i < r.vop.n; i++) {
    int num = r.vlen.a[i];
    char op = r.vop.a[i];
    if (op == 'M' || op == '=' || op == 'X'){
      ref_pos2 += num;
      for (int j=ref_pos1; j<ref_pos2; j++){
        dep_array[j] += 1;
      }
      ref_pos1 = ref_pos2;
    } else if (op == 'D' || op == 'N') {
      ref_pos2 += num;
      ref_pos1 = ref_pos2;
    }
  }
  kv_destroy(r.vop);
  kv_destroy(r.vlen);

  return 0;
}

// compare two string to find mutations
// s1 and s2 should have the same length
int putsnps(char *s1, char *s2, khash_t(str) *h, char * chrom, int ref_pos)
{
  size_t dl = strlen(s1); // delim length
  int i, absent;
//   kstring_t kk = { 0, 0, NULL }; // should move inside the loop
  khint_t k;
  for (i=0; i<dl; i++){
    if (s1[i]!=s2[i]) {
      kstring_t kk = { 0, 0, NULL };
      ksprintf(&kk, "%s\t%d\t%d\t%c\t%c\t0\tsnp", chrom, ref_pos+i+1, ref_pos+i+1, s1[i], s2[i]);
      // fprintf(stderr, "kk.s in putsnps is %s\n", kk.s);
      k = kh_put(str, h, kk.s, &absent);
      if (!absent) {
        kh_value(h, k) += 1; // set the value
        free(kk.s);
      } else {
        kh_value(h, k) = 1;
      }
    }
  }
  return 0;
}

int putindels(char *ref_seq, char *read_seq, khash_t(str) *h, char *chrom, int ref_pos, int read_pos, int indel_size)
{ 
  kstring_t kk = { 0, 0, NULL };
  if (indel_size > 0){// insertion
    char alt_seq[indel_size+3];
    slice(read_seq, alt_seq, read_pos-1, read_pos+indel_size+1);
    ksprintf(&kk, "%s\t%d\t%d\t%c%c\t%s\t%d\tins", chrom, ref_pos, ref_pos+1, ref_seq[ref_pos-1],ref_seq[ref_pos], alt_seq, indel_size);
  } else {//deletion
    char alt_seq[-indel_size+3];
    slice(ref_seq, alt_seq, ref_pos, ref_pos-indel_size+2);
    ksprintf(&kk, "%s\t%d\t%d\t%s\t%c%c\t%d\tdel", chrom, ref_pos+1, ref_pos-indel_size+2, alt_seq, ref_seq[ref_pos],ref_seq[ref_pos-indel_size+1], indel_size);
  }
//   printf("kk.s in putindels is %s\n", kk.s);
  khint_t k;
  int absent;
  k = kh_put(str, h, kk.s, &absent);
  if (!absent) {
    kh_value(h, k) += 1; // set the value
    free(kk.s);
  } else {
    kh_value(h, k) = 1;
  }
  return 0;
}

// fn parse_cigar (cigar: &str, ref_pos: isize, same_strand: bool, read_len: isize)
int * parse_snp(char *cigar, char *ref_seq, char *read_seq, khash_t(str) *h, char *chrom, int ref_pos, int debug){
  cigar_info r = split_cigar(cigar);
  int read_pos1 = 0; // left start
  int read_pos2 = 0; // right end
  int ref_pos1 = ref_pos; // left start
  int ref_pos2 = ref_pos; // right end
  int nmatch = 0; // number of M, if match showed up, then no more S or H
  for (int i =0; i < r.vop.n; i++) {
    int num = r.vlen.a[i];
    char op = r.vop.a[i];
    if (op == 'M' || op == '=' || op == 'X'){
      read_pos2 += num;
      ref_pos2 += num;
      nmatch += 1;
      char ref_slice[num+1];
      char read_slice[num+1];
      slice(ref_seq, ref_slice, ref_pos1, ref_pos2);
      slice(read_seq, read_slice, read_pos1, read_pos2);
      if (debug){
        fprintf(stderr, "ref_seq  is %s\n", ref_seq);
        fprintf(stderr, "ref_pos1, ref_pos2 are %d and %d\n", ref_pos1, ref_pos2);
        fprintf(stderr, "read_pos1, read_pos2 are %d and %d\n", read_pos1, read_pos2);
        fprintf(stderr, "ref_slice  is %s\n", ref_slice);
        fprintf(stderr, "read_slice is %s\n", read_slice);
      }
      putsnps(ref_slice, read_slice, h, chrom, ref_pos1);
      read_pos1 = read_pos2; // for next match
      ref_pos1 = ref_pos2;
    } else if (op == 'S'){ //|| op == 'H') {
      if (nmatch == 0) {
        read_pos1 += num;
        read_pos2 += num;
      }
    } else if (op == 'I'){
      read_pos2 += num;
      putindels(ref_seq, read_seq, h, chrom, ref_pos1, read_pos1, num);
      read_pos1 = read_pos2;
    } else if (op == 'D' || op == 'N') {
      ref_pos2 += num;
      putindels(ref_seq, read_seq, h, chrom, ref_pos1-1, read_pos1-1, -num);
      ref_pos1 = ref_pos2;
    }
  }
  kv_destroy(r.vop);
  kv_destroy(r.vlen);

  return 0;
}

// fn parse_cigar (cigar: &str, ref_pos: isize, same_strand: bool, read_len: isize)
int * parse_cigar(char *cigar, int ref_pos, int same_strand, size_t read_len){
  cigar_info r = split_cigar(cigar);
  int read_pos1 = 0; // left start
  int read_pos2 = -1; // right end
  int ref_pos1 = ref_pos; // left start
  int ref_pos2 = ref_pos - 1; // right end
  int nmatch = 0; // number of M, if match showed up, then no more S or H
  for (int i =0; i < r.vop.n; i++) {
    int num = r.vlen.a[i];
    char op = r.vop.a[i];
    if (op == 'M' || op == '=' || op == 'X'){
      read_pos2 += num;
      ref_pos2 += num;
      nmatch += 1;
    } else if (op == 'S' || op == 'H') {
      if (nmatch == 0) {
        read_pos1 += num;
        read_pos2 += num;
      }
    } else if (op == 'I'){
      read_pos2 += num;
    } else if (op == 'D' || op == 'N') {
      ref_pos2 += num - 1;
    }
  }
  static int rr[4];
  if (same_strand) {
    rr[0] = read_pos1; rr[1]=read_pos2; rr[2]= ref_pos1; rr[3] = ref_pos2;
  } else {
    rr[0] = read_len - read_pos2 - 1; rr[1] = read_len - read_pos1 - 1; rr[2] = ref_pos1; rr[3] = ref_pos2;
  }
  // destroy
  kv_destroy(r.vop);
  kv_destroy(r.vlen);

  return rr;
}


// fn parse_line (line: &str, map: &mut HashMap<String, isize>, no_small_indels: bool, debug: bool) 
int parse_line(kstring_t *ks, khash_t(str) *h, int debug, khash_t(fasta) *fh, khash_t(dep) *dh, int no_snp_call, int min_mq){
  int n, i;
  // char *line = ks->s;
  char **ff = splitsub(ks->s, "\t", &n);
  char *read_id = ff[0];
  int flag = atoi(ff[1]);
  char *chrom = ff[2];
  int pos  = atoi(ff[3]) - 1; // 0 based
  int mq = atoi(ff[4]); // mapping quality
  char *cigar  = ff[5];
  char *read_seq= ff[9];
  size_t read_len = strlen(read_seq);
  char *strand = flag & 0x10 ? "-" : "+";
  if (strcmp(cigar, "*") == 0 || mq < min_mq ) { // no mapping or mapping quality less than the threshold
    free(ff);
    return 0;
  }
  // check whether both reads are mapped in the same chromosome in case some reads are multi-mapped
    // big deletions
  char *sa_info = NULL;
  char *xa_info = NULL;
  for (i = 11; i < n; ++i){
    if (strstr(ff[i], "SA:Z") != NULL) {
      sa_info = ff[i];
    } else if (strstr(ff[i], "XA:Z") != NULL) {
        xa_info = ff[i];
        break;
      }
  }

  // SA information
  char *sa_chrom = NULL;
  char *sa_strand = NULL;
  char *sa_cigar = NULL;
  int sa_pos = 0, sa_mapq = 0;
  // big deletions or inversions
  if (sa_info != NULL && strstr(cigar, "H") == NULL){
    char *token = strtok(sa_info, ":"); // first string
    token = strtok(NULL, ":"); // 2nd string
    token = strtok(NULL, ":"); // 3rd string
    char **ff2 = splitsub(token, ",", &n);
    sa_chrom  = ff2[0];
    sa_pos  = atoi(ff2[1]) - 1; // 0-based this is close to the border on the left, may need to adjust
    sa_strand = ff2[2];
    sa_cigar  = ff2[3];
    sa_mapq = atoi(ff2[4]); // mapping quality, need to use `bwa mem -q`
    free(ff2);
  }
  char *mate_chrom = ff[6]; // = means on the same chromosome
  int mapq = atoi(ff[4]); // mapping quality
  free(ff);
  char *target_chrom = NULL; // the correct chromosome based on mate or SA
  if (mapq == 0 && strcmp(mate_chrom, "=") != 0 && strstr(ks->s, "MQ:i") != NULL)
    target_chrom = mate_chrom;
  else if (mapq == 0 && sa_mapq > 0 && strcmp(chrom, sa_chrom) != 0)
    target_chrom = sa_chrom;
  //fprintf(stderr, "Read is %s\nmate_chrom is %s\nsa_chrom is %s\nchrom is %s\ntarget_chrom is %s\n", read_id, mate_chrom, sa_chrom, chrom, target_chrom);
  if (target_chrom != NULL && xa_info != NULL){ // target chromosome needs to change and XA:Z tag is present
    int nXA; // number of multi mapped regions in XA tag
    char **ffxa = splitsub(xa_info, ";", &nXA);
    char *real_hit = NULL;
    for (i = 0; i < nXA; ++i){
      if (strstr(ffxa[i], target_chrom) != NULL) {
        real_hit = ffxa[i];
        break;
      }
    }
    // replace mapping information with real hit
    // XA:Z:gene_5b,+394,42S74M,0;
    if (real_hit != NULL) {
      char **ff3 = splitsub(real_hit, ",", &nXA);
      chrom = target_chrom;
      int tmppos  = atoi(ff3[1]); // +300 or -300
      strand = tmppos < 0 ? "-" : "+";
      pos = abs(tmppos) - 1; // 0 based
      // cigar  = ff3[2]; // no need to change, always the same as original cigar except H and S difference
      free(ff3);
    }
    // free strings
    free(ffxa);
  }
  // check
  //fprintf(stderr, "Corrected chrom is %s\n", chrom);
  // cigar_info r = split_cigar(cigar);
  // SNPs and small indels
  khint_t k;
  char *ref_seq = NULL;
  if (fh != NULL) {
    k = kh_get(fasta, fh, chrom);
    ref_seq = kh_val(fh, k);
    // get depth
    k = kh_get(dep, dh, chrom);
    int *dep_array = kh_val(dh, k);
    get_depth(cigar, dep_array, pos);
  }
  if (!no_snp_call){
    parse_snp(cigar, ref_seq, read_seq, h, chrom, pos, debug);
  }

  // big deletions or inversions
  if (sa_info != NULL && strstr(cigar, "H") == NULL){
    int all_pos1[4];
    int all_pos2 [4];
    if (strcmp(chrom,sa_chrom)==0 && strcmp(strand, sa_strand) ==0) { // potential big deletion, could be insertion too, but update later
      if (sa_pos > pos) { // SA is on the right
        memcpy(all_pos1, parse_cigar(cigar, pos, 1, read_len), 4 * sizeof(int));
        memcpy(all_pos2, parse_cigar(sa_cigar, sa_pos, 1, read_len), 4 * sizeof(int));
      } else {
        memcpy(all_pos2, parse_cigar(cigar, pos, 1, read_len), 4 * sizeof(int));
        memcpy(all_pos1, parse_cigar(sa_cigar, sa_pos, 1, read_len), 4 * sizeof(int));
      }
      if (debug){
        fprintf(stderr, "potential big deletion\n%s\t%s\n", read_id, chrom);
        fprintf(stderr, "all_pos1: [%d, %d, %d, %d]\n", all_pos1[0], all_pos1[1], all_pos1[2], all_pos1[3]);
        fprintf(stderr, "all_pos2: [%d, %d, %d, %d]\n", all_pos2[0], all_pos2[1], all_pos2[2], all_pos2[3]);
      }
      if (all_pos1[0] > all_pos2[1] || all_pos1[3] >= all_pos2[2] || all_pos1[1] >= all_pos2[1]) {return 0;}
      int read_pos1 = all_pos1[1];
      int ref_pos1  = all_pos1[3];
      int read_pos2 = all_pos2[0];
      int ref_pos2  = all_pos2[2];
      int shift = read_pos1 >= read_pos2 ? read_pos1 - read_pos2 + 1 : 0;
      int del_end_pos = ref_pos2 + shift;
      if (ref_pos1 < del_end_pos) {
        if (read_pos2+shift+1 > read_len) {
            return 0;
        }
        char alt_seq[read_pos2+shift+1-read_pos1];
        slice(read_seq, alt_seq, read_pos1, read_pos2+shift+1);
        // printf("alt_seq is %s\n", alt_seq);
        int mut_size = del_end_pos - ref_pos1 - 1;
        char ref_slice[mut_size+3];
        ref_slice[0] = 0;
        if (fh != NULL){
          slice(ref_seq, ref_slice, ref_pos1, del_end_pos+1);
        }
        kstring_t kk = { 0, 0, NULL };
        ksprintf(&kk, "%s\t%d\t%d\t%s\t%s\t%d\tbig_indel", chrom, ref_pos1+1, del_end_pos+1, ref_slice, alt_seq, mut_size);
        int absent;
        k = kh_put(str, h, kk.s, &absent);
        if (!absent) {
          kh_value(h, k) += 1; // set the value
          free(kk.s);
        } else {
          kh_value(h, k) = 1;
        }
      }
    }else if (strcmp(chrom,sa_chrom)==0 && strcmp(strand, sa_strand) !=0) {// inversions
      if (sa_pos > pos) { // SA is on the right
        memcpy(all_pos1, parse_cigar(cigar, pos, 1, read_len), 4 * sizeof(int));
        memcpy(all_pos2, parse_cigar(sa_cigar, sa_pos, 0, read_len), 4 * sizeof(int));
      } else {
        memcpy(all_pos2, parse_cigar(cigar, pos, 0, read_len), 4 * sizeof(int));
        memcpy(all_pos1, parse_cigar(sa_cigar, sa_pos, 1, read_len), 4 * sizeof(int));
      }
      if (debug){
        fprintf(stderr, "potential inversion\n%s\t%s\n", read_id, chrom);
        fprintf(stderr, "all_pos1: [%d, %d, %d, %d]\n", all_pos1[0], all_pos1[1], all_pos1[2], all_pos1[3]);
        fprintf(stderr, "all_pos2: [%d, %d, %d, %d]\n", all_pos2[0], all_pos2[1], all_pos2[2], all_pos2[3]);
      }
      int read_pos1 = all_pos1[1];
      int read_pos2 = all_pos2[0];
      int ref_pos1  = all_pos1[3];
      int ref_pos2  = all_pos2[3];
      int shift = read_pos1 >= read_pos2 ? read_pos1 - read_pos2 + 1 : 0;
      int del_end_pos = ref_pos2 - shift;
      if (all_pos1[0] > all_pos2[0]){ // count from right
          read_pos1 = all_pos1[0];
          read_pos2 = all_pos2[1];
          ref_pos1  = all_pos1[2];
          ref_pos2  = all_pos2[2];
          shift = read_pos2 >= read_pos1 ? read_pos2 - read_pos1 + 1 : 0;
          del_end_pos = ref_pos2 + shift;
      }
      if (ref_pos1 < del_end_pos) {
        int mut_size = del_end_pos - ref_pos1 - 1;
        char ref_slice[mut_size+3];
        ref_slice[0] = 0;
        if (fh != NULL){
          slice(ref_seq, ref_slice, ref_pos1, del_end_pos+1);
        }
        kstring_t kk = { 0, 0, NULL };
        ksprintf(&kk, "%s\t%d\t%d\t%s\tinversion\t%d\tinv", chrom, ref_pos1+1, del_end_pos+1, ref_slice, mut_size);
        int absent;
        k = kh_put(str, h, kk.s, &absent);
        if (!absent) {
          kh_value(h, k) += 1; // set the value
          free(kk.s);
        } else {
          kh_value(h, k) = 1;
        }
      }
    }
  }

  return 0;
}

// main function
#ifdef MAKE_STANDALONE
int main(int argc, char **argv)
{
#else
int main_editcall (int argc, char **argv)
{
#endif
  int min_cov = 1;
  int min_mq = 0;
  int debug = 0;
  int no_snp_call = 0;
  int c;
  char *fasta_file = NULL;
  char *outfile = NULL;
  int no_header = 0;

  opterr = 0;

  while ((c = getopt (argc, argv, "bdnc:f:o:q:")) != -1)
    switch (c)
      {
      case 'd':
        debug = 1;
        break;
      case 'b':
        no_header = 1;
        break;
      case 'n':
        no_snp_call = 1;
        break;
      case 'c':
        min_cov = atoi(optarg);
        break;
      case 'q':
        min_mq = atoi(optarg);
        break;
      case 'f':
        fasta_file = optarg;
        break;
      case 'o':
        outfile = optarg;
        break;
      case '?':
        if (optopt == 'c' || optopt == 'f' || optopt == 'o')
          fprintf (stderr, "Option -%c requires an argument.\n", optopt);
        else if (isprint (optopt))
          fprintf (stderr, "Unknown option `-%c'.\n", optopt);
        else
          fprintf (stderr, "Unknown option character `\\x%x'.\n", optopt);
        return 1;
      default:
        abort ();
      }

  fprintf (stderr, "debug = %d, min_cov = %d\n", debug, min_cov);

  FILE *input, *output;
  if (optind < argc) input = fopen(argv[optind], "r");
  else input = stdin;
  if (outfile != NULL) output = fopen(outfile, "w");
  else output = stdout;

  // read fasta
  khash_t(fasta) *fh = NULL;
  if (!no_snp_call) {
    if (fasta_file == NULL){
        fprintf(stderr, "Please provide a fasta file with template sequences (-f your_sequence.fa)\n");
        fprintf(stderr,
        "Usage: editcall [options] -f ref.fasta <aln.sam>\n"
        "or:    samtools view aln.bam | editcall [options] -f ref.fasta\n"
        "Options:\n"
        "  -n                    no call for snps and small indels  \n"
        "  -b no header          do not print header \n"
        "  -d debug              print extra information for debugging \n"
        "  -c coverage [int]     minimum coverage for a variant (defualt 1)\n"
        "  -q mapping quality [int]     minimum mapping quality for a read to count in when calling variants (defualt 0)\n"
        "  -f fasta file name    your reference sequences\n"
        "  -o output file name   output file name (default: stdout)\n");
        return 1;
    }
    fh = read_fasta(fasta_file);
  }
  // hashmap for depth on each position
  khash_t(dep) *dh = kh_init(dep);
  khint_t k, k2;
  int absent;
  if (fh != NULL){
    for (k = 0; k < kh_end(fh); ++k)
      if (kh_exist(fh, k)){
        const char *kk = kh_key(fh, k);
        char *vv = kh_val(fh, k);
        int n = strlen(vv);
        int *tmp = malloc(n * sizeof(int));
        // memset( tmp, 0, n*sizeof(int) );
        for (int i=0; i<n; i++) tmp[i] = 0;
        k2 = kh_put(dep, dh, kk, &absent);
        kh_value(dh, k2) = tmp;
      }
  }

  kstring_t ks = { 0, 0, NULL };
  khash_t(str) *h; // hash for mutations
  h = kh_init(str);
  if (input) {
    for (ks.l = 0; kgetline(&ks, (kgets_func *)fgets, input) == 0; ks.l = 0){
      // printf("new line is %s\n",  ks.s);
      if (ks.s[0] == '@') continue; // skip headers
      parse_line(&ks, h, debug, fh, dh, no_snp_call, min_mq);
    }
    fclose(input);
  }
	free(ks.s);
  //print output
  int n;
  if (! no_header)
    fprintf(output, "chrom\tref_start\tref_end\tref\talt\tsize\ttype\tmutCov\ttotalCov\tmutPercent\n");
  for (k = kh_begin(h); k != kh_end(h); ++k) { // traverse
    	if (!kh_exist(h,k)) continue;
    	char *kk = (char *) kh_key(h, k);
    	int vv = kh_val(h, k);
    	if (vv >= min_cov) {
        fprintf(output, "%s\t%d", kk, vv);
        if (fh != NULL){
          char **tmp2 = splitsub(kk, "\t", &n); // need to free
          char *chrom = tmp2[0];
          int ref_start = atoi(tmp2[1]) - 1; // 0 based
          int ref_end = atoi(tmp2[2]) - 1;
          k2 = kh_get(dep, dh, chrom);
          int *tmparray = kh_val(dh, k2);
          int d1 = tmparray[ref_start];
          int d2 = tmparray[ref_end];
          int d3 = max(d1, d2); // max depth on reference
          float pct = 100.0 * vv / d3;
          fprintf(output, "\t%d\t%.1f", d3, pct);
          free(tmp2);
        }
        fprintf(output, "\n");
      }
      free(kk);
  }
  fclose(output);

  // free memory
  kh_destroy(str, h);
  
  // free fasta hash
  if (fh != NULL){
    for (k = 0; k < kh_end(fh); ++k)
      if (kh_exist(fh, k)){
        free((char*)kh_key(fh, k));
        free((char*)kh_val(fh, k));
      }
    kh_destroy(fasta, fh);
    // seems I have to use another loop for each khash
    for (k = 0; k < kh_end(dh); ++k)
      if (kh_exist(dh, k)){
        free((int*)kh_val(dh, k));
      }
    kh_destroy(dep, dh);
  }
  return 0;
}