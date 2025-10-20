#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h> // For getopt
#include "arg_parser.h"
#include "schema_parser.tab.h" // for yyparse and token types

// From the lexer
extern int yylex(void);
extern void yy_scan_string(const char*);

int parse_schema(const char* schema) {
    yy_scan_string(schema);
    return yyparse();
}

void print_schema(ArgOption* schema) {
    printf("Argument Schema:\n");
    for (ArgOption* opt = schema; opt != NULL; opt = opt->next) {
        printf("  -%c: ", opt->name);
        switch (opt->type) {
            case ARG_TYPE_BOOL:   printf("boolean\n"); break;
            case ARG_TYPE_INT:    printf("integer\n"); break;
            case ARG_TYPE_STRING: printf("string\n"); break;
        }
    }
}

void print_parsed_args(ArgValue* values) {
    printf("Parsed Arguments:\n");
    for (ArgValue* val = values; val != NULL; val = val->next) {
        printf("  -%c: ", val->name);
        switch (val->type) {
            case ARG_TYPE_BOOL:
                printf("%s\n", val->value.bool_val ? "true" : "false");
                break;
            case ARG_TYPE_INT:
                printf("%d\n", val->value.int_val);
                break;
            case ARG_TYPE_STRING:
                printf("'%s'\n", val->value.str_val);
                break;
        }
    }
}

void free_schema(ArgOption* schema) {
    while (schema) {
        ArgOption* next = schema->next;
        free(schema);
        schema = next;
    }
}

void free_parsed_args(ArgValue* values) {
    while (values) {
        ArgValue* next = values->next;
        if (values->type == ARG_TYPE_STRING && values->value.str_val) {
            free(values->value.str_val);
        }
        free(values);
        values = next;
    }
}

ArgOption* find_option(ArgOption* schema, char name) {
    for (ArgOption* opt = schema; opt != NULL; opt = opt->next) {
        if (opt->name == name) {
            return opt;
        }
    }
    return NULL;
}

ArgValue* parse_arguments(int argc, char** argv, ArgOption* schema) {
    ArgValue* head = NULL;
    ArgValue* tail = NULL;

    for (int i = 1; i < argc; ++i) {
        if (argv[i][0] != '-') {
            fprintf(stderr, "Warning: Skipping non-option argument '%s'\n", argv[i]);
            continue;
        }

        char opt_name = argv[i][1];
        ArgOption* option_def = find_option(schema, opt_name);

        if (!option_def) {
            fprintf(stderr, "Error: Unknown option '-%c'\n", opt_name);
            free_parsed_args(head);
            return NULL;
        }

        ArgValue* new_val = (ArgValue*)calloc(1, sizeof(ArgValue));
        new_val->name = opt_name;
        new_val->type = option_def->type;

        switch (option_def->type) {
            case ARG_TYPE_BOOL:
                new_val->value.bool_val = 1;
                break;
            case ARG_TYPE_INT:
                if (i + 1 >= argc) {
                    fprintf(stderr, "Error: Option -%c requires an integer argument.\n", opt_name);
                    free(new_val);
                    free_parsed_args(head);
                    return NULL;
                }
                new_val->value.int_val = atoi(argv[++i]);
                break;
            case ARG_TYPE_STRING:
                if (i + 1 >= argc) {
                    fprintf(stderr, "Error: Option -%c requires a string argument.\n", opt_name);
                    free(new_val);
                    free_parsed_args(head);
                    return NULL;
                }
                new_val->value.str_val = strdup(argv[++i]);
                break;
        }

        if (!head) {
            head = tail = new_val;
        } else {
            tail->next = new_val;
            tail = new_val;
        }
    }
    return head;
}


int main(int argc, char** argv) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <schema> [arguments]\n", argv[0]);
        fprintf(stderr, "Example: %s \"j#,f,w*\" -j 123 -f -w hello\n", argv[0]);
        return 1;
    }

    const char* schema_str = argv[1];
    printf("Parsing schema: \"%s\"\n", schema_str);

    if (parse_schema(schema_str) != 0) {
        fprintf(stderr, "Failed to parse schema.\n");
        return 1;
    }

    print_schema(arg_schema_head);

    // Adjust argc and argv for the argument parser
    int new_argc = argc - 1;
    char** new_argv = argv + 1;

    ArgValue* parsed_values = parse_arguments(new_argc, new_argv, arg_schema_head);

    if (parsed_values) {
        print_parsed_args(parsed_values);
    }

    // Cleanup
    free_schema(arg_schema_head);
    free_parsed_args(parsed_values);

    return 0;
}
