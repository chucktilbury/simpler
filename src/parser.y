
%{
#include "common.h"

#define TOKSTR get_tok_str()
void yyerror(const char* s);
%}
    //%define parse.error verbose
%define parse.error custom
%locations
%debug
%defines

%token SYMBOL UNUM FNUM INUM QSTRG PROC
%token NOTHING IMPORT STRUCT ENTRY YIELD
%token IF TRUE
%token ELSE WHILE DO FALSE RETURN
%token SWITCH CASE BREAK CONTINUE AND OR DEFAULT
%token NOT EQ NE LE GE BSHL BSHR BROL
%token BROR INC DEC GT LT ALLOCATE DISPOSE SIZEOF TYPEOF
%token STRING BOOL UINT INT FLOAT LIST DICT TUPLE

%left AND OR
%left '&' '|' '^'
%left EQ NE
%left LT GT LE GE
%left BROL BROR BSHL BSHR
%left '+' '-'
%left '*' '/' '%'
%left NEG
%right NOT '~'

%%

    /**************************************************************************
        Top level definitions
     *************************************************************************/

module_item_list: module_item { TRACE("module_item_list->module_item (init)"); }
    | module_item_list module_item { TRACE("module_item_list->module_item (add)"); }
    ;

module_item
    : variable_definition { TRACE("module_item->data_definition"); }
    | import_statement ';' { TRACE("module_item->import_statement"); }
    | proc_definition { TRACE("module_item->proc_definition"); }
    | entry_definition { TRACE("module_item->entry_definition"); }
    ;

import_statement
    : IMPORT formatted_string { TRACE("import_statement"); }
    ;

    /**************************************************************************
     *  Generic support definitions
     *************************************************************************/

bool_value
    : TRUE { TRACE("bool_value->TRUE"); }
    | FALSE { TRACE("bool_value->FALSE"); }
    ;

compound_name
    : SYMBOL { TRACE("compound_name (init)"); }
    | compound_name '.' SYMBOL { TRACE("compound_name (add)"); }
    ;

number
    : UNUM { TRACE("number->UNUM"); }
    | INUM { TRACE("number->INUM"); }
    | FNUM { TRACE("number->FNUM"); }
    | SIZEOF '(' compound_name ')' { TRACE("number->SIZEOF"); }
    ;

formatted_string
    : QSTRG { TRACE("formatted_string (no format)"); }
    | QSTRG ':' '(' generic_value_list ')' { TRACE("formatted_string (with format)"); }
    ;

generic_value
    : bool_value { TRACE("generic_value->bool_value"); }
    | compound_name { TRACE("generic_value->compound_name"); }
    | number  { TRACE("generic_value->number"); }
    | formatted_string { TRACE("generic_value->formatted_string"); }
    ;

generic_value_list
    : generic_value { TRACE("generic_value_list (init)"); }
    | generic_value_list ',' generic_value { TRACE("generic_value_list (add)"); }
    ;

    /**************************************************************************
     *  Rules relates to variable definitions and references
     *************************************************************************/

variable_declaration
    : STRING compound_name ';' { TRACE("variable_declaration->STRING"); }
    | BOOL compound_name ';' { TRACE("variable_declaration->BOOL"); }
    | UINT compound_name ';' { TRACE("variable_declaration->UINT"); }
    | INT compound_name ';' { TRACE("variable_declaration->INT"); }
    | FLOAT compound_name ';' { TRACE("variable_declaration->FLOAT"); }
    | list_name ';' { TRACE("variable_declaration->list_name"); }
    | dict_name ';' { TRACE("variable_declaration->dict_name"); }
    | struct_name ';' { TRACE("variable_declaration->struct_name"); }
    | tuple_name ';' { TRACE("variable_declaration->tuple_name"); }
    ;

variable_definition
    : string_definition { TRACE("variable_definition->string_definition"); }
    | bool_definition { TRACE("variable_definition->bool_definition"); }
    | int_definition { TRACE("variable_definition->int_definition"); }
    | float_definition { TRACE("variable_definition->float_definition"); }
    | struct_definition { TRACE("variable_definition->struct_definition"); }
    | list_definition { TRACE("variable_definition->list_definition"); }
    | dict_definition { TRACE("variable_definition->dict_definition"); }
    | tuple_definition { TRACE("variable_definition->tuple_definition"); }
    | variable_declaration { TRACE("variable_definition->variable_declaration"); }
    ;

variable_reference
    : compound_name { TRACE("variable_reference->compound_name"); }
    | list_reference { TRACE("variable_reference->list_reference"); }
    | dict_reference { TRACE("variable_reference->dict_reference"); }
    ;

variable_assignment_item
    : generic_value { TRACE("variable_assignment_item->generic_value"); }
    | list_assignment { TRACE("variable_assignment_item->list_assignment"); }
    | dict_assignment { TRACE("variable_assignment_item->dict_assignment"); }
    | tuple_assignment { TRACE("variable_assignment_item->tuple_assignment"); }
    | struct_assignment { TRACE("variable_assignment_item->struct_assignment"); }
    ;

variable_assignment
    : variable_reference '=' variable_assignment_item ';' { TRACE("variable_assignment"); }
    ;

string_definition
    : STRING compound_name '=' formatted_string ';' { TRACE("string_definition"); }
    ;

bool_definition
    : BOOL compound_name '=' bool_value ';' { TRACE("bool_definition"); }
    ;

int_definition
    : INT compound_name '=' expression ';' { TRACE("int_definition->INT"); }
    | UINT compound_name '=' expression ';' { TRACE("int_definition->UINT"); }
    ;

float_definition
    : FLOAT compound_name '=' expression ';' { TRACE("float_definition"); }
    ;

    /**************************************************************************
     *  List productions
     *************************************************************************/

list_name
    : LIST compound_name { TRACE("list_name"); }
    ;

list_item
    : generic_value { TRACE("list_item->generic_value"); }
    | list_assignment { TRACE("list_item->list_assignment"); }
    | dict_assignment { TRACE("list_item->dict_assignment"); }
    | tuple_assignment { TRACE("list_item->tuple_assignment"); }
    //| error { TRACE("list_item->error"); }
    ;

list_assignment_list
    : list_item { TRACE("list_assignment_list (init)"); }
    | list_assignment_list ',' list_item { TRACE("list_assignment_list (add)"); }

list_assignment
    : '[' list_assignment_list ']' { TRACE("list_assignment"); }
    ;

list_definition // also accept "LIST compound_name ;" via variable_definition rule
    : list_name '[' ']' ';' { TRACE("list_definition->no assignment"); }
    | list_name '[' ']' '=' list_assignment ';' { TRACE("list_definition->list_assignment with brackets"); }
    | list_name '=' list_assignment ';' { TRACE("list_definition->list_assignment no brackets"); }
    ;

list_reference_list
    : '[' expression ']' { TRACE("list_reference_list (init)"); }
    | list_reference_list '[' expression ']' { TRACE("list_reference_list (add)"); }
    ;

list_reference
    : compound_name list_reference_list { TRACE("list_reference"); }
    ;

    /**************************************************************************
     *  Dict productions
     *************************************************************************/

dict_name
    : DICT compound_name { TRACE("dict_name"); }
    ;

dict_assignment_item
    : compound_name ':' generic_value { TRACE("dict_assignment_item->generic_value"); }
    | compound_name ':' dict_assignment { TRACE("dict_assignment_item->dict_assignment"); }
    | compound_name ':' list_assignment { TRACE("dict_assignment_item->list_assignment"); }
    | compound_name ':' tuple_assignment { TRACE("dict_assignment_item->tuple_assignment"); }
    | error { TRACE("dict_assignment_item->error"); }
    ;

dict_assignment_list
    : dict_assignment_item { TRACE("dict_assignment_list (init)"); }
    | dict_assignment_list ',' dict_assignment_item { TRACE("dict_assignment_list (add)"); }
    ;

dict_assignment
    : '{' dict_assignment_list '}' { TRACE("dict_assignment"); }
    ;

dict_definition // also accept "DICT compound_name ;" via variable_definition
    : dict_name '[' ']' ';' { TRACE("dict_name->no assignment"); }
    | dict_name '[' ']' '=' dict_assignment ';' { TRACE("dict_name->dict_assignment with brackets"); }
    | dict_name '=' dict_assignment ';' { TRACE("dict_name->dict_assignment without brackets"); }
    ;

dict_reference_list
    : '[' formatted_string ']' { TRACE("dict_reference_list (init)"); }
    | dict_reference_list '[' formatted_string ']' { TRACE("dict_reference_list (add)"); }
    ;

dict_reference
    : compound_name dict_reference_list { TRACE("dict_reference"); }
    ;

    /**************************************************************************
     *  Tuple productions
     *
     *  Note that a tuple reference is made with the same syntax as a list
     *  reference.
     *************************************************************************/

tuple_name
    : TUPLE compound_name { TRACE("tuple_name"); }
    ;

tuple_assignment_item
    : generic_value { TRACE("tuple_assignment_item->generic_value"); }
    | dict_assignment { TRACE("tuple_assignment_item->dict_assignment"); }
    | list_assignment { TRACE("tuple_assignment_item->list_assignment"); }
    | tuple_assignment { TRACE("tuple_assignment_item->tuple_assignment"); }
    | error {TRACE("tuple_assignment_item->error");}
    ;

tuple_assignment_list
    : tuple_assignment_item { TRACE("tuple_assignment_list (init)"); }
    | tuple_assignment_list ',' tuple_assignment_item { TRACE("tuple_assignment_list (add)"); }
    ;

tuple_assignment
    : '(' tuple_assignment_list ')' { TRACE("tuple_assignment"); }
    ;

tuple_definition // see variable_declaration
    : tuple_name '=' tuple_assignment ';' { TRACE("tuple_definition"); }
    ;

    /**************************************************************************
     *  Struct productions
     *
     *  Note that a struct is referenced through a compound_name
     *************************************************************************/

struct_name
    : STRUCT compound_name { TRACE("struct_name"); }
    ;

struct_items
    : variable_declaration { TRACE("struct_items->variable_declaration"); }
    | proc_declaration { TRACE("struct_items->proc_declaration"); }
    | list_definition { TRACE("struct_items->list_definition"); }
    | dict_definition { TRACE("struct_items->dict_definition"); }
    | tuple_definition { TRACE("struct_items->tuple_definition"); }
    | error ';' {TRACE("error"); }
    ;

struct_item_list
    : struct_items { TRACE("struct_item_list (init)"); }
    | struct_item_list struct_items { TRACE("struct_item_list (add)"); }
    ;

struct_definition
    : struct_name '{' struct_item_list '}' ';' { TRACE("struct_definition"); }
    | struct_name '{' struct_item_list '}' '=' struct_assignment ';' { TRACE("struct_definition with assignment"); }
    ;

struct_assignment_name
    : '.' compound_name  { TRACE("struct_assignment_name"); }
    ;

struct_assignment_value
    : bool_value { TRACE("struct_assignment_value->generic_value"); }
    | formatted_string { TRACE("struct_assignment_value->generic_value"); }
    | expression { TRACE("struct_assignment_value->generic_value"); }
    | struct_assignment { TRACE("struct_assignment_value->struct_assignment"); }
    ;

struct_assignment_item
    : struct_assignment_name '=' struct_assignment_value { TRACE("struct_assignment_item"); }
    ;

struct_assignment_list
    : struct_assignment_item { TRACE("struct_assignment_list (init)"); }
    | struct_assignment_list ',' struct_assignment_item { TRACE("struct_assignment_list (add)"); }
    ;

struct_assignment
    :  '{' struct_assignment_list '}' { TRACE("struct_assignment"); }
    ;


    /**************************************************************************
     *  Rules related to expressions
     *************************************************************************/

expression
    : number { TRACE("expression->number"); }
    | variable_reference { TRACE("expression->variable_reference"); }
    | proc_reference { TRACE("expression->proc_reference"); }
    | expression '+' expression { TRACE("expression-> '+' "); }
    | expression '-' expression { TRACE("expression-> '-' "); }
    | expression '/' expression { TRACE("expression-> '/' "); }
    | expression '*' expression { TRACE("expression-> '*' "); }
    | expression '%' expression { TRACE("expression-> '%' "); }
    | expression AND expression { TRACE("expression->AND"); }
    | expression OR expression { TRACE("expression->OR"); }
    | expression LT expression { TRACE("expression->LT"); }
    | expression GT expression { TRACE("expression->GT"); }
    | expression EQ expression { TRACE("expression->EQ"); }
    | expression NE expression { TRACE("expression->NE"); }
    | expression LE expression { TRACE("expression->LE"); }
    | expression GE expression { TRACE("expression->GE"); }
    | expression '&' expression { TRACE("expression-> '&' "); }
    | expression '|' expression { TRACE("expression-> '|' "); }
    | expression '^' expression { TRACE("expression-> '^' "); }
    | expression BROL expression { TRACE("expression->BROL"); }
    | expression BROR expression { TRACE("expression->BROR"); }
    | expression BSHL expression { TRACE("expression->BSHL"); }
    | expression BSHR expression { TRACE("expression->BSHR"); }
    | expression NOT expression { TRACE("expression->NOT"); }
    | '-' expression %prec NEG { TRACE("expression->unary '-'"); }
    | NOT expression { TRACE("expression->unary NOT"); }
    | '~' expression { TRACE("expression->unary '~' "); }
    | '(' expression ')'  { TRACE("expression->(expression)"); }
    ;


    /**************************************************************************
     *  Rules related to procedure definition and declarations
     *************************************************************************/

proc_parameter_list
    : compound_name { TRACE("proc_parameter_list (init)"); }
    | proc_parameter_list ',' compound_name { TRACE("proc_parameter_list (add)"); }
    ;

proc_definition
    : PROC compound_name '(' proc_parameter_list ')' proc_body { TRACE("proc_definition"); }
    | PROC compound_name '(' ')' proc_body { TRACE("proc_definition no parameters"); }
    ;

entry_definition
    : PROC ENTRY '(' proc_parameter_list ')' proc_body { TRACE("entry_definition"); }
    | PROC ENTRY '(' ')' proc_body { TRACE("entry_definition no parameters"); }
    ;

proc_reference
    : compound_name '(' generic_value_list ')' { TRACE("proc_reference"); }
    | compound_name '(' ')' { TRACE("proc_reference no parameters"); }
    ;

proc_declaration
    : PROC compound_name '(' proc_parameter_list ')' ';' { TRACE("proc_declaration"); }
    | PROC compound_name '(' ')' ';' { TRACE("proc_declaration no parameters"); }
    ;

    /**************************************************************************
     *  Productions that implement a proc_body
     *************************************************************************/

proc_body_element
    : proc_body { TRACE("proc_body_element->proc_body"); }
    | proc_definition { TRACE("proc_body_element->proc_definition"); }
    | variable_definition { TRACE("proc_body_element->variable_definition"); }
    | if_clause { TRACE("proc_body_element->if_clause"); }
    | while_clause { TRACE("proc_body_element->while_clause"); }
    | do_clause { TRACE("proc_body_element->do_clause"); }
    | switch_clause { TRACE("proc_body_element->switch_clause"); }
    | return_clause { TRACE("proc_body_element->return_clause"); }
    | proc_reference  ';' { TRACE("proc_body_element->proc_reference"); }
    | pre_post_inc ';' { TRACE("proc_body_element->pre_post_inc"); }
    | DISPOSE '(' compound_name ')' ';' { TRACE("proc_body_element->DISPOSE"); }
    | YIELD ';' { TRACE("proc_body_element->YIELD"); }
    | BREAK ';' { TRACE("proc_body_element->BREAK"); }
    | variable_assignment { TRACE("proc_body_element->variable_assignment"); }
    ;

proc_body_element_list
    : proc_body_element { TRACE("proc_body_element_list (init)"); }
    | proc_body_element_list proc_body_element { TRACE("proc_body_element_list (add)"); }
    ;

proc_body
    : '{' '}' { TRACE("empty proc_body"); }
    | '{' proc_body_element_list '}' { TRACE("proc_body"); }
    ;

loop_body_element
    : proc_body_element { TRACE("loop_body_element->proc_body_element"); }
    | CONTINUE ';' { TRACE("loop_body_element->CONTINUE"); }
    ;

loop_body_element_list
    : loop_body_element { TRACE("loop_body_element_list (init)"); }
    | loop_body_element_list loop_body_element { TRACE("loop_body_element_list (add)"); }
    ;

loop_body
    : '{' '}' { TRACE("empty loop_body"); }
    | '{' loop_body_element_list '}' { TRACE("loop_body"); }
    ;

else_clause_item
    : ELSE '(' expression ')' proc_body { TRACE("else_clause_item"); }
    ;

true_else_clause
    : ELSE proc_body { TRACE("true_else_clause without parens"); }
    | ELSE '(' ')' proc_body { TRACE("true_else_clause with parens"); }
    ;

else_clause_list
    : else_clause_item { TRACE("else_clause_list (init)"); }
    | else_clause_list else_clause_item { TRACE("else_clause_list (add)"); }
    ;

if_clause
    : IF '(' expression ')' proc_body { TRACE("if_clause without else"); }
    | IF '(' expression ')' proc_body true_else_clause { TRACE("if_clause with true else clause"); }
    | IF '(' expression ')' proc_body else_clause_list { TRACE("if_clause with else clause list"); }
    | IF '(' expression ')' proc_body else_clause_list true_else_clause { TRACE("if_clause with else clause list and true else"); }
    ;

while_clause
    : WHILE loop_body { TRACE("true while_clause"); }
    | WHILE '(' ')' loop_body { TRACE("true while_clause with parens"); }
    | WHILE '(' expression ')' loop_body { TRACE("while_clause"); }
    | WHILE '(' expression ')' loop_body else_clause_list { TRACE("while_clause with else clause"); }
    ;

do_clause
    : DO loop_body WHILE ';' { TRACE("true do_clause"); }
    | DO loop_body WHILE '(' ')' ';' { TRACE("true do_clause with parens"); }
    | DO loop_body WHILE '(' expression ')' ';' { TRACE("do_clause"); }
    | DO loop_body WHILE '(' expression ')' else_clause_list { TRACE("do_clause with else"); }
    ;

case_clause_item
    : CASE '(' generic_value ')' proc_body { TRACE("case_clause_item"); }
    ;

case_clause_item_list
    : case_clause_item { TRACE("case_clause_item_list (init)"); }
    | case_clause_item_list case_clause_item { TRACE("case_clause_item_list (add)"); }
    ;

switch_clause
    : SWITCH '(' expression ')' '{' case_clause_item_list '}' { TRACE("switch_clause"); }
    | SWITCH '(' expression ')' '{' case_clause_item_list DEFAULT proc_body '}' { TRACE("switch_clause with default"); }
    ;

return_clause
    : RETURN expression ';' { TRACE("return_clause with expression"); }
    | RETURN ';' { TRACE("return_clause without expression"); }
    ;

pre_post_inc
    : compound_name INC { TRACE("pre_post_inc->postinc"); }
    | compound_name DEC { TRACE("pre_post_inc->postdec"); }
    | INC compound_name { TRACE("pre_post_inc->preinc"); }
    | DEC compound_name { TRACE("pre_post_inc->predec"); }
    ;

%%

extern char yytext[];

void yyerror(const char* s)
{
    fflush(stdout);
    fprintf(stderr, "\n%s: line %d: at %d: %s\n\n", get_file_name(), get_line_number(), get_col_number(), s); //yylloc.first_line, s);
    inc_error_count();
}

int yyreport_syntax_error(const yypcontext_t *ctx)
{
    int res = 0;

    fflush(stdout);
    fprintf(stderr, "Syntax error in %s, line %d.%d:", get_file_name(), get_line_number(), get_col_number());
    inc_error_count();

    // Report the tokens expected at this point.
    {
        enum { TOKENMAX = 5 };
        yysymbol_kind_t expected[TOKENMAX];
        int n = yypcontext_expected_tokens (ctx, expected, TOKENMAX);
        if (n < 0)
            // Forward errors to yyparse.
            res = n;
        else
            for (int i = 0; i < n; ++i)
            fprintf (stderr, "%s %s",
                     i == 0 ? " expected" : " or", yysymbol_name (expected[i]));
    }

    // Report the unexpected token.
    {
        yysymbol_kind_t lookahead = yypcontext_token (ctx);
        if (lookahead != YYSYMBOL_YYEMPTY)
            fprintf (stderr, " before %s", yysymbol_name (lookahead));
    }

    fprintf (stderr, "\n");
    return res;
}
