#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../argparser.h"

int main(int argc, char** argv) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <schema> [prog_name]\n", argv[0]);
        fprintf(stderr, "Example: %s \"j#,f,w*\" demo\n", argv[0]);
        return 1;
    }

    const char* schema = argv[1];
    const char* prog_name = (argc >= 3) ? argv[2] : "program";

    const char* header_out = "args.h";
    const char* source_out = "args.c";

    int rc = generate_args_files(schema, header_out, source_out, prog_name);
    if (rc != 0) {
        fprintf(stderr, "Failed to generate args files (rc=%d)\n", rc);
        return rc;
    }
    printf("Generated %s and %s for schema '%s' (prog: %s)\n", header_out, source_out, schema, prog_name);
    return 0;
}
