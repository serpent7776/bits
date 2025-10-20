# Example Makefile to demonstrate arg parser codegen and usage

# Toolchain
CC := gcc
CFLAGS := -Wall -Wextra -g -I.. -I.
LDFLAGS :=

# Defaults (can be overridden: make SCHEMA="a,b#,c*" PROG_NAME=myprog)
# IMPORTANT: In Makefiles, '#' starts a comment in variable assignments.
 # Escape special characters in the default schema so it survives make parsing.
 # Users can still override from CLI without escapes, e.g.: make SCHEMA='j#,f,w*'
SCHEMA ?= j\#,f,w\*
 # Remove any protective backslashes when passing into the program
SCHEMA_LIT := $(subst \*,*,$(subst \#,#,$(SCHEMA)))
PROG_NAME ?= demo

# Targets
GEN := genargs
DEMO := demo

# Common objects built from parent sources (compiled locally)
COMMON_OBJS := argparser.o schema_parser.tab.o schema_lexer.lex.o

.PHONY: all clean run regen

all: $(DEMO)

# 1) Build the small generator driver
$(GEN): genargs.o $(COMMON_OBJS)
	$(CC) -o $@ $^ $(LDFLAGS)

# 2) Use the generator to emit args.h/args.c from the schema
args.h args.c: $(GEN)
	./$(GEN) "$(SCHEMA_LIT)" "$(PROG_NAME)"

# 3) Build the demo app that uses generated files
$(DEMO): main.o args.o
	$(CC) -o $@ $^ $(LDFLAGS)

# Object compilation rules
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# main depends on the generated header
main.o: args.h

# Compile objects from parent directory sources (stay in example/ for outputs)
argparser.o: ../argparser.c ../argparser.h ../arg_parser.h ../schema_parser.tab.h
	$(CC) $(CFLAGS) -c ../argparser.c -o $@

schema_parser.tab.o: ../schema_parser.tab.c ../arg_parser.h
	$(CC) $(CFLAGS) -c ../schema_parser.tab.c -o $@

schema_lexer.lex.o: ../schema_lexer.lex.c ../arg_parser.h ../schema_parser.tab.h
	$(CC) $(CFLAGS) -c ../schema_lexer.lex.c -o $@

# Regenerate code after changing SCHEMA or PROG_NAME
regen: $(GEN)
	rm -f args.h args.c args.o $(DEMO)
	./$(GEN) "$(SCHEMA_LIT)" "$(PROG_NAME)"
	$(MAKE) $(DEMO)

# Convenience run target (pass ARGS="..." to test)
run: $(DEMO)
	./$(DEMO) $(ARGS)

clean:
	rm -f $(GEN) $(DEMO) *.o args.h args.c
