// Description: A simple program to count the number of reads mapped to each chromosome in one or more SAM files.
// written in with the help of DeepSeek.
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <unistd.h>

#define MAX_CHROMOSOMES 100
#define MAX_FILES 1000
#define MAX_CHROM_NAME_LEN 100
#define UNMAPPED_NAME "*unmapped*"

// SAM flag bits
#define SECONDARY_ALIGNMENT 0x100

typedef struct {
    char name[MAX_CHROM_NAME_LEN];
    long counts[MAX_FILES];
} ChromosomeCount;

void print_usage(const char *program_name) {
    fprintf(stderr, "Usage: %s [options] file1.sam [file2.sam ...]\n", program_name);
    fprintf(stderr, "Options:\n");
    fprintf(stderr, "  -o <file>    Output file name (default: stdout)\n");
    fprintf(stderr, "  -l <length>  Minimum alignment length to count\n");
    fprintf(stderr, "  -q <qual>    Minimum mapping quality to count\n");
    fprintf(stderr, "  -h           Show this help message\n");
}

int is_primary_alignment(int flag) {
    return !(flag & SECONDARY_ALIGNMENT);
}

// main function
#ifdef MAKE_STANDALONE
int main(int argc, char **argv)
{
#else
int main_count (int argc, char **argv)
{
#endif
// int main(int argc, char *argv[]) {
    char *output_file = NULL;
    int min_length = 0;
    int min_qual = 0;
    int count_unmapped = 1;  // Count unmapped reads by default

    // Parse command line options
    int opt;
    while ((opt = getopt(argc, argv, "o:l:q:h")) != -1) {
        switch (opt) {
            case 'o':
                output_file = optarg;
                break;
            case 'l':
                min_length = atoi(optarg);
                if (min_length < 0) {
                    fprintf(stderr, "Error: Minimum length must be >= 0\n");
                    return 1;
                }
                break;
            case 'q':
                min_qual = atoi(optarg);
                if (min_qual < 0) {
                    fprintf(stderr, "Error: Minimum quality must be >= 0\n");
                    return 1;
                }
                break;
            case 'h':
                print_usage(argv[0]);
                return 0;
            default:
                print_usage(argv[0]);
                return 1;
        }
    }

    if (optind >= argc) {
        fprintf(stderr, "Error: No input files specified\n");
        print_usage(argv[0]);
        return 1;
    }

    int num_files = argc - optind;
    ChromosomeCount chrom_counts[MAX_CHROMOSOMES] = {0};
    int num_chromosomes = 0;

    // Initialize unmapped counts entry
    if (count_unmapped) {
        strcpy(chrom_counts[num_chromosomes].name, UNMAPPED_NAME);
        num_chromosomes++;
    }

    // Process each SAM file
    for (int file_idx = 0; file_idx < num_files; file_idx++) {
        FILE *sam_file = fopen(argv[optind + file_idx], "r");
        if (!sam_file) {
            perror("Error opening SAM file");
            continue;
        }

        char line[1024];
        while (fgets(line, sizeof(line), sam_file)) {
            // Skip header lines (start with @)
            if (line[0] == '@') continue;

            // Parse SAM line
            char *token = strtok(line, "\t");
            if (!token) continue;  // Skip empty lines

            // Get the FLAG field (2nd token)
            // strtok(NULL, "\t");  // Skip QNAME
            char *flag_str = strtok(NULL, "\t");
            if (!flag_str) continue;
            int flag = atoi(flag_str);

            // Skip secondary alignments
            if (!is_primary_alignment(flag)) continue;

            // Get the RNAME field (3rd token)
            char *chrom = strtok(NULL, "\t");
            if (!chrom) continue;

            // Get the POS field (4th token)
            char *pos_str = strtok(NULL, "\t");
            if (!pos_str) continue;

            // Get the MAPQ field (5th token)
            char *mapq_str = strtok(NULL, "\t");
            if (!mapq_str) continue;
            int mapq = atoi(mapq_str);

            // Get the CIGAR field (6th token)
            char *cigar = strtok(NULL, "\t");
            if (!cigar) continue;

            // Skip if quality filter is not met
            if (mapq < min_qual) continue;

            // Calculate alignment length from CIGAR string
            int align_length = 0;
            char *c = cigar;
            while (*c) {
                if (isdigit(*c)) {
                    int num = 0;
                    while (isdigit(*c)) {
                        num = num * 10 + (*c - '0');
                        c++;
                    }
                    if (*c == 'M' || *c == 'D' || *c == 'N' || *c == '=' || *c == 'X') {
                        align_length += num;
                    }
                    c++;
                } else {
                    c++;
                }
            }

            // Skip if length filter is not met
            if (align_length < min_length) continue;

            // Handle unmapped reads
            if (strcmp(chrom, "*") == 0) {
                if (!count_unmapped) continue;
                chrom = UNMAPPED_NAME;
            }

            // Find or add chromosome in our list
            int found = 0;
            for (int i = 0; i < num_chromosomes; i++) {
                if (strcmp(chrom_counts[i].name, chrom) == 0) {
                    chrom_counts[i].counts[file_idx]++;
                    found = 1;
                    break;
                }
            }

            if (!found) {
                if (num_chromosomes >= MAX_CHROMOSOMES) {
                    fprintf(stderr, "Warning: Exceeded maximum number of chromosomes (%d)\n", MAX_CHROMOSOMES);
                    break;
                }
                strncpy(chrom_counts[num_chromosomes].name, chrom, MAX_CHROM_NAME_LEN - 1);
                chrom_counts[num_chromosomes].name[MAX_CHROM_NAME_LEN - 1] = '\0';
                chrom_counts[num_chromosomes].counts[file_idx] = 1;
                num_chromosomes++;
            }
        }

        fclose(sam_file);
    }

    // Open output file or use stdout
    FILE *out = stdout;
    if (output_file) {
        out = fopen(output_file, "w");
        if (!out) {
            perror("Error opening output file");
            return 1;
        }
    }

    // Print header
    fprintf(out, "Chromosome");
    for (int i = 0; i < num_files; i++) {
        fprintf(out, "\t%s", argv[optind + i]);
    }
    fprintf(out, "\n");

    // Print counts for each chromosome
    for (int i = 0; i < num_chromosomes; i++) {
        fprintf(out, "%s", chrom_counts[i].name);
        for (int j = 0; j < num_files; j++) {
            fprintf(out, "\t%ld", chrom_counts[i].counts[j]);
        }
        fprintf(out, "\n");
    }

    if (output_file) {
        fclose(out);
    }

    return 0;
}