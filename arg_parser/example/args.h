#ifndef GENERATED_ARGS_H
#define GENERATED_ARGS_H

#include <stdbool.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct Args {
    bool has_j;
    int j;
    bool f;
    bool has_w;
    char* w;
} Args;

// Parse command line according to the compiled-in schema.
// Returns 0 on success, non-zero on error.
int parse_args(int argc, char** argv, Args* out, const char* prog_name);

// Print usage string matching the schema.
void print_usage(const char* prog_name);

// Free any dynamically allocated fields in Args.
void free_args(Args* a);

#ifdef __cplusplus
}
#endif

#endif // GENERATED_ARGS_H
