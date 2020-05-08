/*
 *  External interface to the parts of the scanner that get called from
 *  application code.
 */
#ifndef _SCANNER_H_
#define _SCANNER_H_

char* get_file_name(void);
int get_line_number(void);
int get_col_number(void);
void open_file(char* fname);
const char* get_tok_str(void);
int get_token(char* str, size_t size);

/*
 * Defined by flex. Call one time to isolate a symbol and then use the global
 * symbol struct to access the symbol.
 */
extern int yylex(void);
extern int yyparse(void);
extern FILE* yyin;

// void yyerror(char *s, ...);
// void yyerror(const char* s);

#endif /* _SCANNER_H_ */
