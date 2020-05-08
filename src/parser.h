#ifndef __PARSER_H__
#define __PARSER_H__

typedef enum {
    QSTRG = 256,
    SYMBOL,
    UNUM,
    INUM,
    FNUM,
    NOTHING,
    IMPORT,
    PROC,
    VAR,
    TRUE,
    FALSE,
    IF,
    ELSE,
    WHILE,
    DO,
    SWITCH,
    CASE,
    BREAK,
    CONTINUE,
    RETURN,
    DEFAULT,
    TYPE,
    ALLOCATE,
    DISPOSE,
    SIZEOF,
    TYPEOF,
    ENTRY,
    YIELD,
    AND,
    OR,
    NOT,
    EQ,
    NE,
    LE,
    GE,
    LT,
    GT,
    BSHL,
    BSHR,
    BROL,
    BROR,
    INC,
    DEC,
} token_t;

void parse(void);

#endif