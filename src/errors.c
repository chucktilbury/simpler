
/*
 *  Errors
 *
 *  This contains the functions that show errors and warnings that result from
 *  parsing as well as those that result from things like memory allocation
 *  issues.
 */
#include "common.h"

static struct errors
{
    int level;
    FILE* fp;
    int errors;
    int warnings;
} errors;

/*
 *  Initialize the errors and logging system.
 */
void init_errors(int level, FILE* stre)
{
    errors.level = level;
    errors.fp = stre;  // If this is NULL, then stderr will be
    // used.
    errors.errors = 0;
    errors.warnings = 0;
}

void inc_error_count(void) { errors.errors++; }

void inc_warning_count(void) { errors.warnings++; }

void set_error_level(int lev) { errors.level = lev; }

int get_error_level(void) { return errors.level; }

void set_error_stream(FILE* fp) { errors.fp = fp; }

FILE* get_error_stream(void) { return errors.fp; }

int get_num_errors(void) { return errors.errors; }

int get_num_warnings(void) { return errors.warnings; }

void syntax(char* str, ...)
{
    va_list args;
    const char* name = get_file_name();
    int lnum = get_line_number();
    int cnum = get_col_number();

    if(NULL != name)
        fprintf(stderr, "Syntax: %s: %d: %d: ", name, lnum, cnum);
    else
        fprintf(stderr, "Syntax: ");

    va_start(args, str);
    vfprintf(stderr, str, args);
    va_end(args);
    fprintf(stderr, "\n");
    errors.errors++;
}

void scanner_error(char* str, ...)
{
    va_list args;
    const char* name = get_file_name();
    int lnum = get_line_number();
    int cnum = get_col_number();

    if(NULL != name)
        fprintf(stderr, "Scanner Error: %s: %d: %d: ", name, lnum, cnum);
    else
        fprintf(stderr, "Scanner Error: ");

    va_start(args, str);
    vfprintf(stderr, str, args);
    va_end(args);
    fprintf(stderr, "\n");
    errors.errors++;
}

void warning(char* str, ...)
{
    va_list args;
    const char* name = get_file_name();
    int lnum = get_line_number();
    int cnum = get_col_number();

    if(NULL != name)
        fprintf(stderr, "Warning: %s: %d: %d: ", name, lnum, cnum);
    else
        fprintf(stderr, "Warning: ");

    va_start(args, str);
    vfprintf(stderr, str, args);
    va_end(args);
    fprintf(stderr, "\n");
    errors.warnings++;
}

void debug(int lev, char* str, ...)
{
    va_list args;
    FILE* ofp;

    if(lev <= errors.level)
    {
        if(NULL != errors.fp)
            ofp = errors.fp;
        else
            ofp = stderr;

        fprintf(ofp, "DBG: ");
        va_start(args, str);
        vfprintf(ofp, str, args);
        va_end(args);
        fprintf(ofp, "\n");
    }
}

void fatal_error(char* str, ...)
{
    va_list args;

    fprintf(stderr, "FATAL ERROR: ");
    va_start(args, str);
    vfprintf(stderr, str, args);
    va_end(args);
    fprintf(stderr, "\n");

    exit(1);
}


void debug_trace(int lev, const char *str, ...) {

    va_list args;
    FILE *ofp;

    if(lev <= errors.level) {
        if(NULL != errors.fp)
            ofp = errors.fp;
        else
            ofp = stderr;

        fprintf(ofp, "TRACE: %s: %d: %d: ", get_file_name(), get_line_number(), get_col_number());
        va_start(args, str);
        vfprintf(ofp, str, args);
        va_end(args);
        fprintf(ofp, "\n");
    }
}

void debug_mark(int lev, const char *file, int line, const char *func) {

    FILE *ofp;

    if(lev <= errors.level) {
        if(NULL != errors.fp)
            ofp = errors.fp;
        else
            ofp = stderr;

        fprintf(ofp, "MARK: (%s, %d) %s: %d: %d: %s\n", file, line, get_file_name(), get_line_number(), get_col_number(), func);
        //fprintf(ofp, "      %s: %d\n", file, line);
    }
}
