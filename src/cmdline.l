%{
#include "common.h"
#define MAX_IN 1000

int verbose = 0;
char *outfile = NULL;

int infile_cnt = 0;
char *infile[MAX_IN] = { 0 };

void usage();
int myinput(char *buf, int max);
#undef YY_INPUT
#define YY_INPUT(buf,result,max) ((result) = myinput((buf),(max)))
%}

%s FNAME
%option nounput noinput
    //%option noyywrap

%%

[ \t]+

-h          { usage(); }
"-?"        { usage(); }

-v          { verbose = 1; }
-verbose    { verbose = 1; }

-o          { BEGIN FNAME; }
<FNAME>[^ ]+ { outfile = strdup(yytext); BEGIN 0; }

[^ ]+       { infile[infile_cnt++] = strdup(yytext); }


%%

void usage()
{
    printf("Use: ./simple <options> file1 file2 ...\n"
        "Options:\n"
        "    -h,-?        : print this message\n"
        "    -v,-verbose  : print copious output to indicate state\n"
        "    -o <file>    : write output to <file>\n");
}

static char **targv;
static char **arglim;

static unsigned int offset = 0;

int myinput(char *buf, int max)
{
    int len, copylen=0;

    if (targv >= arglim)
        return 0; /* EOF */

    len = strlen(*targv)-offset;
    if(len >= max)
        copylen = max-1;
    else
        copylen = len;

    if(len>0)
        memcpy(buf, targv[0]+offset, copylen);

    if(targv[0][offset+copylen] == '\0') {
        buf[copylen] = ' ';
        copylen++;
        offset = 0;
        targv++;
    }

    return copylen;
}

int cmd_wrap() {
    return 1;
}

int get_cmd_line(int argc, char** argv)
{
    arglim = argv + argc;
    targv = argv + 1;

    cmd_lex();

    if(!infile[0])
    {
        usage();
        fatal_error("no input files specified"); // does not return
        return 0;
    }

    return infile_cnt; // number of files to input
}
