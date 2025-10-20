# Compiler and flags
CC = gcc
CFLAGS = -Wall -Wextra -pedantic -O2 -ggdb3 -I.

# Executable name
TARGET = arg_parser

# Source files
SOURCES = main.c schema_parser.tab.c schema_lexer.lex.c argparser.c
OBJECTS = $(SOURCES:.c=.o)

# Bison and Flex
BISON = bison
BISON_FLAGS = -d
FLEX = flex
FLEX_FLAGS =

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJECTS)

# Rule to compile .c files to .o files
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Ensure main.c sees the generated header from bison
main.o: schema_parser.tab.h

# Rule to generate C code from Bison grammar
schema_parser.tab.c schema_parser.tab.h: schema_parser.y
	$(BISON) $(BISON_FLAGS) $<

# Rule to generate C code from Flex lexer
schema_lexer.lex.c: schema_lexer.l schema_parser.tab.h
	$(FLEX) $(FLEX_FLAGS) -o $@ $<

# Clean up generated files
clean:
	rm -f $(TARGET) $(OBJECTS)
	rm -f schema_parser.tab.c schema_parser.tab.h schema_lexer.lex.c
