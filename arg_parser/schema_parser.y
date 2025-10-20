%{
#include <stdio.h>
#include <stdlib.h>
#include "arg_parser.h"

// Function prototypes for the lexer
int yylex(void);
void yyerror(const char *s);

// Global head of the schema list
ArgOption* arg_schema_head = NULL;
%}

// Bison declarations
%union {
    char name;
    ArgOption* option;
}

// Token definitions
%token <name> T_OPTION_NAME
%token T_INT_TYPE
%token T_STRING_TYPE
%token T_COMMA

// Type for non-terminals
%type <option> option_spec
%type <option> option_list

%%

schema:
    /* empty schema is valid */
    | option_list {
        arg_schema_head = $1;
    }
    ;

option_list:
    option_spec {
        $$ = $1;
    }
    | option_list T_COMMA option_spec {
        // Append the new option to the end of the list
        ArgOption* current = $1;
        while (current->next != NULL) {
            current = current->next;
        }
        current->next = $3;
        $$ = $1;
    }
    ;

option_spec:
    T_OPTION_NAME {
        $$ = (ArgOption*)malloc(sizeof(ArgOption));
        $$->name = $1;
        $$->type = ARG_TYPE_BOOL;
        $$->next = NULL;
    }
    | T_OPTION_NAME T_INT_TYPE {
        $$ = (ArgOption*)malloc(sizeof(ArgOption));
        $$->name = $1;
        $$->type = ARG_TYPE_INT;
        $$->next = NULL;
    }
    | T_OPTION_NAME T_STRING_TYPE {
        $$ = (ArgOption*)malloc(sizeof(ArgOption));
        $$->name = $1;
        $$->type = ARG_TYPE_STRING;
        $$->next = NULL;
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Parser Error: %s\n", s);
}
