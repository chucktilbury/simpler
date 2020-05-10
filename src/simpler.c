#include <stdio.h>
#include <stdlib.h>

#include "common.h"
#include "parser.h"

#include "llvm-c/BitReader.h"
#include "llvm-c/BitWriter.h"
#include "llvm-c/Core.h"


LLVMModuleRef Module;
LLVMContextRef Context;
LLVMTypeRef int32bit;
LLVMTypeRef int32bitptr;

extern char *outfile;
extern char *infile[];
int get_cmd_line(int argc, char** argv);
extern int yydebug;

int main(int argc, char **argv)
{
    init_errors(10, stdout);
    yydebug = 0;

    int file_count =  get_cmd_line(argc, argv);

    if(outfile == NULL)
        outfile = strdup("out.bc");

    for(int i = 0; i < file_count; i++)
    {
        open_file(infile[i]);
        yyparse();
    }

    int errors = get_num_errors();
    if(errors != 0)
        printf("\nparse failed: %d errors: %d warnings\n", errors, get_num_warnings());
    else
        printf("\nparse succeeded: %d errors: %d warnings\n", errors, get_num_warnings());

    return errors;
}
