#ifndef ARG_PARSER_H
#define ARG_PARSER_H

#include <stdio.h>

// Enum to define the type of argument
typedef enum {
    ARG_TYPE_BOOL,
    ARG_TYPE_INT,
    ARG_TYPE_STRING
} ArgType;

// Struct to hold information about a single command-line option
typedef struct ArgOption {
    char name;
    ArgType type;
    struct ArgOption* next;
} ArgOption;

// Struct to hold the parsed value of an argument
typedef struct ArgValue {
    char name;
    ArgType type;
    union {
        int int_val;
        char* str_val;
        int bool_val;
    } value;
    struct ArgValue* next;
} ArgValue;

// Global head of the schema list, populated by the parser
extern ArgOption* arg_schema_head;

// Function to parse the schema string
int parse_schema(const char* schema);

// Function to parse argv based on the schema
ArgValue* parse_arguments(int argc, char** argv, ArgOption* schema);

// Utility functions
void print_schema(ArgOption* schema);
void print_parsed_args(ArgValue* values);
void free_schema(ArgOption* schema);
void free_parsed_args(ArgValue* values);

#endif // ARG_PARSER_H
