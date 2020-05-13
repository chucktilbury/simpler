
#include <argp.h>

#include "common.h"
#include "parser.h"

#include "llvm-c/BitReader.h"
#include "llvm-c/BitWriter.h"
#include "llvm-c/Core.h"

BEGIN_CONFIG
    CONFIG_NUM("-v", "VERBOSE", "Set the verbosity from 0 to 50", 0, 0)
    CONFIG_STR("-o", "OUTFILE", "Specify the file name to output", 1, NULL)
    CONFIG_LIST("-i", "INFILES", "Specify a list of input files separated by \":\"", 1, NULL)
    CONFIG_LIST("-p", "FPATH", "Specify directories to search for imports", 0, ".:include")
END_CONFIG


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
    configure(argc, argv);

    int verbose = GET_CONFIG_NUM("VERBOSE");
    init_errors(verbose, stdout);
    if(verbose > 10)
        yydebug = 1;
    else
        yydebug = 0;

    for(char* str = iterate_config("INFILES"); str != NULL; str = iterate_config("INFILES"))
    {
        open_file(str);
        yyparse();
    }

    int errors = get_num_errors();
    if(errors != 0)
        printf("\nparse failed: %d errors: %d warnings\n", errors, get_num_warnings());
    else
        printf("\nparse succeeded: %d errors: %d warnings\n", errors, get_num_warnings());

    return errors;
}
