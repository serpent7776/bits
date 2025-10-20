#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "args.h"

static const char* k_optstring = ":fj:w:";

void print_usage(const char* prog_name) {
    if (!prog_name) prog_name = "example";
    fprintf(stderr, "Usage: %s [options]\n", prog_name);
    fprintf(stderr, "  -f\n");
    fprintf(stderr, "  -j <int>\n");
    fprintf(stderr, "  -w <string>\n");
}

void free_args(Args* a) {
    if (!a) return;
    if (a->has_w && a->w) { free(a->w); a->w = NULL; }
}

int parse_args(int argc, char** argv, Args* out, const char* prog_name) {
    if (!out) return -1;
    memset(out, 0, sizeof(*out));
    int opt;
    opterr = 0; // we'll handle errors
    while ((opt = getopt(argc, argv, k_optstring)) != -1) {
        switch (opt) {
        case 'f':
            out->f = true;
            break;
        case 'j': {
            if (!optarg) { fprintf(stderr, "-j requires an integer.\n"); return -2; }
            char* endp = NULL;
            long v = strtol(optarg, &endp, 10);
            if (!endp || *endp != '\0') { fprintf(stderr, "Invalid integer for -j: %s\n", optarg); return -2; }
            out->j = (int)v; out->has_j = true;
            break; }
        case 'w':
            if (!optarg) { fprintf(stderr, "-w requires a string.\n"); return -2; }
            out->w = strdup(optarg); out->has_w = true;
            break;
        case '?':
        case ':':
            print_usage(prog_name);
            return -3;
        default:
            print_usage(prog_name);
            return -4;
        }
    }
    return 0;
}
