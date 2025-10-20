#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#include "argparser.h"
#include "arg_parser.h"           // ArgOption, ArgType, arg_schema_head, parse_schema
#include "schema_parser.tab.h"    // yyparse

// From the lexer
extern void yy_scan_string(const char*);

static int build_optstring(const ArgOption* schema, char* optstring, size_t optstring_cap) {
    size_t pos = 0;

    // Optional leading ':' to get silent error handling from getopt
    if (pos + 1 < optstring_cap) {
        optstring[pos++] = ':';
    } else {
        return -1;
    }

    for (const ArgOption* opt = schema; opt; opt = opt->next) {
        if (pos + 2 >= optstring_cap) return -1; // leave room for potential ':' and NUL
        optstring[pos++] = opt->name;
        switch (opt->type) {
            case ARG_TYPE_BOOL:
                break;
            case ARG_TYPE_INT:
                if (pos + 1 >= optstring_cap) return -1;
                optstring[pos++] = ':'; // requires argument
                break;
            case ARG_TYPE_STRING:
                if (pos + 1 >= optstring_cap) return -1;
                optstring[pos++] = ':'; // requires argument
                break;
        }
    }

    if (pos >= optstring_cap) return -1;
    optstring[pos] = '\0';
    return 0;
}

static int write_args_header(const char* header_path, const ArgOption* schema, const char* prog_name) {
    FILE* f = fopen(header_path, "w");
    if (!f) {
        fprintf(stderr, "Failed to open %s for writing: %s\n", header_path, strerror(errno));
        return -1;
    }

    fprintf(f,
        "#ifndef GENERATED_ARGS_H\n"
        "#define GENERATED_ARGS_H\n\n"
        "#include <stdbool.h>\n"
        "#include <stddef.h>\n\n"
        "#ifdef __cplusplus\nextern \"C\" {\n#endif\n\n");

    // Struct definition
    fprintf(f, "typedef struct Args {\n");
    for (const ArgOption* opt = schema; opt; opt = opt->next) {
        switch (opt->type) {
            case ARG_TYPE_BOOL:
                fprintf(f, "    bool %c;\n", opt->name);
                break;
            case ARG_TYPE_INT:
                fprintf(f, "    bool has_%c;\n", opt->name);
                fprintf(f, "    int %c;\n", opt->name);
                break;
            case ARG_TYPE_STRING:
                fprintf(f, "    bool has_%c;\n", opt->name);
                fprintf(f, "    char* %c;\n", opt->name);
                break;
        }
    }
    fprintf(f, "} Args;\n\n");

    // API
    fprintf(f,
        "// Parse command line according to the compiled-in schema.\n"
        "// Returns 0 on success, non-zero on error.\n"
        "int parse_args(int argc, char** argv, Args* out, const char* prog_name);\n\n"
        "// Print usage string matching the schema.\n"
        "void print_usage(const char* prog_name);\n\n"
        "// Free any dynamically allocated fields in Args.\n"
        "void free_args(Args* a);\n\n");

    fprintf(f,
        "#ifdef __cplusplus\n}\n#endif\n\n"
        "#endif // GENERATED_ARGS_H\n");

    fclose(f);
    return 0;
}

// no-op

static const char* path_basename(const char* path) {
    if (!path) return "args.h";
    const char* slash = strrchr(path, '/');
    return slash ? slash + 1 : path;
}

static int write_args_source(const char* source_path, const ArgOption* schema, const char* prog_name, const char* header_path) {
    char optstring[256];
    if (build_optstring(schema, optstring, sizeof(optstring)) != 0) {
        fprintf(stderr, "Failed to build getopt string from schema.\n");
        return -1;
    }

    FILE* f = fopen(source_path, "w");
    if (!f) {
        fprintf(stderr, "Failed to open %s for writing: %s\n", source_path, strerror(errno));
        return -1;
    }

    // Includes
    fprintf(f,
        "#include <stdio.h>\n"
        "#include <stdlib.h>\n"
        "#include <string.h>\n"
        "#include <unistd.h>\n"
        "#include \"%s\"\n\n",
        path_basename(header_path));

    // Hardcode optstring
    fprintf(f, "static const char* k_optstring = \"%s\";\n\n", optstring);

    // print_usage
    fprintf(f, "void print_usage(const char* prog_name) {\n");
    fprintf(f, "    if (!prog_name) prog_name = \"%s\";\n", prog_name ? prog_name : "program");
    fprintf(f, "    fprintf(stderr, \"Usage: %%s [options]\\n\", prog_name);\n");
    {
        const ArgOption* opt;
        for (opt = schema; opt; opt = opt->next) {
            switch (opt->type) {
                case ARG_TYPE_BOOL:
                    fprintf(f, "    fprintf(stderr, \"  -%c\\n\");\n", opt->name);
                    break;
                case ARG_TYPE_INT:
                    fprintf(f, "    fprintf(stderr, \"  -%c <int>\\n\");\n", opt->name);
                    break;
                case ARG_TYPE_STRING:
                    fprintf(f, "    fprintf(stderr, \"  -%c <string>\\n\");\n", opt->name);
                    break;
            }
        }
    }
    fprintf(f, "}\n\n");

    // free_args
    fprintf(f, "void free_args(Args* a) {\n");
    fprintf(f, "    if (!a) return;\n");
    for (const ArgOption* opt = schema; opt; opt = opt->next) {
        if (opt->type == ARG_TYPE_STRING) {
            fprintf(f, "    if (a->has_%c && a->%c) { free(a->%c); a->%c = NULL; }\n", opt->name, opt->name, opt->name, opt->name);
        }
    }
    fprintf(f, "}\n\n");

    // parse_args
    fprintf(f,
        "int parse_args(int argc, char** argv, Args* out, const char* prog_name) {\n"
        "    if (!out) return -1;\n"
        "    memset(out, 0, sizeof(*out));\n"
        "    int opt;\n"
        "    opterr = 0; // we'll handle errors\n"
        "    while ((opt = getopt(argc, argv, k_optstring)) != -1) {\n"
        "        switch (opt) {\n");

    for (const ArgOption* opt = schema; opt; opt = opt->next) {
        switch (opt->type) {
            case ARG_TYPE_BOOL:
                fprintf(f,
                    "        case '%c':\n"
                    "            out->%c = true;\n"
                    "            break;\n",
                    opt->name, opt->name);
                break;
            case ARG_TYPE_INT:
                fprintf(f, "        case '%c': {\n", opt->name);
                fprintf(f, "            if (!optarg) { fprintf(stderr, \"-%c requires an integer.\\n\"); return -2; }\n", opt->name);
                fprintf(f, "            char* endp = NULL;\n");
                fprintf(f, "            long v = strtol(optarg, &endp, 10);\n");
                fprintf(f, "            if (!endp || *endp != '\\0') { fprintf(stderr, \"Invalid integer for -%c: %%s\\n\", optarg); return -2; }\n", opt->name);
                fprintf(f, "            out->%c = (int)v; out->has_%c = true;\n", opt->name, opt->name);
                fprintf(f, "            break; }\n");
                break;
            case ARG_TYPE_STRING:
                fprintf(f, "        case '%c':\n", opt->name);
                fprintf(f, "            if (!optarg) { fprintf(stderr, \"-%c requires a string.\\n\"); return -2; }\n", opt->name);
                fprintf(f, "            out->%c = strdup(optarg); out->has_%c = true;\n", opt->name, opt->name);
                fprintf(f, "            break;\n");
                break;
        }
    }

    // default and error handling
    fprintf(f,
        "        case '?':\n"
        "        case ':':\n"
        "            print_usage(prog_name);\n"
        "            return -3;\n"
        "        default:\n"
        "            print_usage(prog_name);\n"
        "            return -4;\n"
        "        }\n"
        "    }\n"
        "    return 0;\n"
        "}\n");

    fclose(f);
    return 0;
}

int generate_args_files(const char* schema,
                        const char* header_path,
                        const char* source_path,
                        const char* prog_name) {
    if (!schema || !header_path || !source_path) {
        fprintf(stderr, "generate_args_files: invalid arguments.\n");
        return -1;
    }

    // Parse schema into arg_schema_head using existing parser
    yy_scan_string(schema);
    if (yyparse() != 0) {
        fprintf(stderr, "Schema parsing failed.\n");
        return -2;
    }

    if (write_args_header(header_path, arg_schema_head, prog_name ? prog_name : "program") != 0) {
        return -3;
    }
    if (write_args_source(source_path, arg_schema_head, prog_name ? prog_name : "program", header_path) != 0) {
        return -4;
    }

    return 0;
}
