#ifndef ARG_GENERATOR_H
#define ARG_GENERATOR_H

#include <stddef.h>

// Generate args.h and args.c from a compact schema string.
// Example schema: "j#,f,w*" where:
//  - letter alone => boolean flag (e.g., f)
//  - letter#      => integer option requiring an argument (e.g., j)
//  - letter*      => string option requiring an argument (e.g., w)
//
// header_path/source_path: output file paths for the generated files.
// prog_name: program name to display in generated usage; if NULL, defaults to "program".
// Returns 0 on success, non-zero on error.
int generate_args_files(const char* schema,
                        const char* header_path,
                        const char* source_path,
                        const char* prog_name);

#endif // ARG_GENERATOR_H
