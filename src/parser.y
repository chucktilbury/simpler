
%{
#include "common.h"

#define TOKSTR get_tok_str()
void yyerror(const char* s);
%}
%define parse.error verbose
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

module_item_list: module_item {
            MSG("module_item_list->module_item (init)");
        }
    | module_item_list module_item {
            MSG("module_item_list->module_item (add)");
        }
    ;

module_item
    : variable_definition {
            MSG("module_item->data_definition");
        }
    | import_statement ';' {
            MSG("module_item->import_statement");
        }
    | proc_definition
    | entry_definition
    ;

import_statement
    : IMPORT formatted_string {
            MSG("import_statement");
        }
    ;

    /**************************************************************************
     *  Generic support definitions
     *************************************************************************/

bool_value
    : TRUE { MSG("bool_value->TRUE"); }
    | FALSE { MSG("bool_value->FALSE"); }
    ;

compound_name
    : SYMBOL { MSG("compound_name (init)"); }
    | compound_name '.' SYMBOL { MSG("compound_name (add)"); }
    ;

number
    : UNUM { MSG("number->UNUM"); }
    | INUM { MSG("number->INUM"); }
    | FNUM { MSG("number->FNUM"); }
    | SIZEOF '(' compound_name ')' { MSG("number->SIZEOF"); }
    ;

formatted_string
    : QSTRG { MSG("formatted_string (no format)"); }
    | QSTRG ':' '(' generic_value_list ')' { MSG("formatted_string (with format)"); }
    ;

generic_value
    : bool_value { MSG(""); }
    | compound_name { MSG(""); }
    | number  { MSG(""); }
    | formatted_string { MSG(""); }
    ;

generic_value_list
    : generic_value { MSG(""); }
    | generic_value_list ',' generic_value { MSG(""); }
    ;

    /**************************************************************************
     *  Rules relates to variable definitions and references
     *************************************************************************/

variable_declaration
    : STRING compound_name ';' { MSG(""); }
    | BOOL compound_name ';' { MSG(""); }
    | UINT compound_name ';' { MSG(""); }
    | INT compound_name ';' { MSG(""); }
    | FLOAT compound_name ';' { MSG(""); }
    | LIST compound_name ';' { MSG(""); }
    | DICT compound_name ';' { MSG(""); }
    | STRUCT compound_name ';' { MSG(""); }
    | TUPLE compound_name ';' { MSG(""); }
    ;

variable_definition
    : string_definition { MSG(""); }
    | bool_definition { MSG(""); }
    | int_definition { MSG(""); }
    | float_definition { MSG(""); }
    | struct_definition { MSG(""); }
    | list_definition { MSG(""); }
    | dict_definition { MSG(""); }
    | tuple_definition { MSG(""); }
    | variable_declaration { MSG(""); }
    ;

variable_reference
    : compound_name { MSG(""); }
    | list_reference { MSG(""); }
    | dict_reference { MSG(""); }
    ;

variable_assignment_item
    : generic_value { MSG(""); }
    | list_assignment { MSG(""); }
    | dict_assignment { MSG(""); }
    | tuple_assignment { MSG(""); }
    ;

variable_assignment
    : variable_reference '=' variable_assignment_item ';' { MSG(""); }
    ;

string_definition
    : STRING compound_name '=' formatted_string ';' { MSG(""); }
    ;

bool_definition
    : BOOL compound_name '=' bool_value ';' { MSG(""); }
    ;

int_definition
    : INT compound_name '=' expression ';' { MSG(""); }
    | UINT compound_name '=' expression ';' { MSG(""); }
    ;

float_definition
    : FLOAT compound_name '=' expression ';' { MSG(""); }
    ;

    /**************************************************************************
     *  List productions
     *************************************************************************/

list_name
    : LIST compound_name { MSG(""); }
    ;

list_item
    : generic_value { MSG(""); }
    | list_assignment { MSG(""); }
    | dict_assignment { MSG(""); }
    | tuple_assignment  { MSG(""); }
    ;

list_assignment_list
    : list_item { MSG(""); }
    | list_assignment_list ',' list_item { MSG(""); }

list_assignment
    : '[' list_assignment_list ']' { MSG(""); }
    ;

list_definition // also accept "LIST compound_name ;" via variable_definition rule
    : list_name '[' ']' ';' { MSG(""); }
    | list_name '[' ']' '=' list_assignment ';' { MSG(""); }
    | list_name '=' list_assignment ';' { MSG(""); }
    ;

list_reference_list
    : '[' expression ']' { MSG(""); }
    | list_reference_list '[' expression ']' { MSG(""); }
    ;

list_reference
    : compound_name list_reference_list { MSG(""); }
    ;

    /**************************************************************************
     *  Dict productions
     *************************************************************************/

dict_name
    : DICT compound_name { MSG(""); }
    ;

dict_assignment_item
    : compound_name ':' generic_value { MSG(""); }
    | compound_name ':' dict_assignment { MSG(""); }
    | compound_name ':' list_assignment { MSG(""); }
    | compound_name ':' tuple_assignment { MSG(""); }
    ;

dict_assignment_list
    : dict_assignment_item { MSG(""); }
    | dict_assignment_list ',' dict_assignment_item { MSG(""); }
    ;

dict_assignment
    : '{' dict_assignment_list '}' { MSG(""); }
    ;

dict_definition // also accept "DICT compound_name ;" via variable_definition
    : dict_name '[' ']' ';' { MSG(""); }
    | dict_name '[' ']' '=' dict_assignment ';' { MSG(""); }
    | dict_name '=' dict_assignment ';' { MSG(""); }
    ;

dict_reference_list
    : '[' formatted_string ']' { MSG(""); }
    | dict_reference_list '[' formatted_string ']' { MSG(""); }
    ;

dict_reference
    : compound_name dict_reference_list { MSG(""); }
    ;

    /**************************************************************************
     *  Tuple productions
     *
     *  Note that a tuple reference is made with the same syntax as a list
     *  reference.
     *************************************************************************/

tuple_name
    : TUPLE compound_name { MSG(""); }
    ;

tuple_assignment_item
    : generic_value { MSG(""); }
    | dict_assignment { MSG(""); }
    | list_assignment { MSG(""); }
    | tuple_assignment { MSG(""); }
    ;

tuple_assignment_list
    : tuple_assignment_item { MSG(""); }
    | tuple_assignment_list ',' tuple_assignment_item { MSG(""); }
    ;

tuple_assignment
    : '(' tuple_assignment_list ')' { MSG(""); }
    ;

tuple_definition // see variable_declaration
    : tuple_name '=' tuple_assignment ';' { MSG(""); }
    ;

    /**************************************************************************
     *  Struct productions
     *
     *  Note that a struct is referenced through a compound_name
     *************************************************************************/

struct_name
    : STRUCT compound_name { MSG(""); }
    ;

struct_items
    : variable_declaration { MSG("struct_items->variable_declaration (init)"); }
    | struct_items variable_declaration { MSG("struct_items->variable_declaration (add)"); }
    ;

struct_definition
    : struct_name '{' struct_items '}' ';' { MSG("struct_definition"); }
    | struct_name '{' struct_items '}' '=' {MSG("assignemnt");} struct_assignment ';' { MSG("struct_definition with assignment"); }

struct_assignment_item
    : '.' compound_name '=' generic_value { MSG("struct_assignment_item->generic_value"); }
    | '.' compound_name '=' struct_assignment { MSG("struct_assignment_item->struct_assignment"); }
    ;

struct_assignment_list
    : struct_assignment_item { MSG("struct_assignment_list->struct_assignment_item"); }
    | struct_assignment_list ',' struct_assignment_item { MSG("struct_assignment_list->struct_assignment_list"); }
    ;

struct_assignment
    :  '{' struct_assignment_list '}' { MSG("struct_assignment"); }
    ;


    /**************************************************************************
     *  Rules related to expressions
     *************************************************************************/

expression
    : number { MSG("expression->number"); }
    | variable_reference { MSG("expression->variable_reference"); }
    | proc_reference { MSG("expression->proc_reference"); }
    | expression '+' expression { MSG("expression-> '+' "); }
    | expression '-' expression { MSG("expression-> '-' "); }
    | expression '/' expression { MSG("expression-> '/' "); }
    | expression '*' expression { MSG("expression-> '*' "); }
    | expression '%' expression { MSG("expression-> '%' "); }
    | expression AND expression { MSG("expression->AND"); }
    | expression OR expression { MSG("expression->OR"); }
    | expression LT expression { MSG("expression->LT"); }
    | expression GT expression { MSG("expression->GT"); }
    | expression EQ expression { MSG("expression->EQ"); }
    | expression NE expression { MSG("expression->NE"); }
    | expression LE expression { MSG("expression->LE"); }
    | expression GE expression { MSG("expression->GE"); }
    | expression '&' expression { MSG("expression-> '&' "); }
    | expression '|' expression { MSG("expression-> '|' "); }
    | expression '^' expression { MSG("expression-> '^' "); }
    | expression BROL expression { MSG("expression->BROL"); }
    | expression BROR expression { MSG("expression->BROR"); }
    | expression BSHL expression { MSG("expression->BSHL"); }
    | expression BSHR expression { MSG("expression->BSHR"); }
    | expression NOT expression { MSG("expression->NOT"); }
    | '-' expression %prec NEG { MSG("expression->unary '-'"); }
    | NOT expression { MSG("expression->unary NOT"); }
    | '~' expression { MSG("expression->unary '~' "); }
    | '(' expression ')'  { MSG("expression->(expression)"); }
    ;


    /**************************************************************************
     *  Rules related to procedure definition and declarations
     *************************************************************************/

proc_parameter_list
    : compound_name { MSG(""); }
    | proc_parameter_list ',' compound_name { MSG(""); }
    ;

proc_definition
    : PROC compound_name '(' proc_parameter_list ')' proc_body { MSG(""); }
    ;

entry_definition
    : PROC ENTRY '(' proc_parameter_list ')' proc_body { MSG(""); }
    ;

proc_reference
    : compound_name '(' generic_value_list ')'
    ;

    /**************************************************************************
     *  Productions that implement a proc_body
     *************************************************************************/

proc_body_element
    : proc_body { MSG(""); }
    | proc_definition { MSG(""); }
    | variable_definition ';' { MSG(""); }
    | if_clause { MSG(""); }
    | while_clause { MSG(""); }
    | do_clause { MSG(""); }
    | switch_clause { MSG(""); }
    | return_clause { MSG(""); }
    | proc_reference  ';' { MSG(""); }
    | pre_post_inc ';' { MSG(""); }
    | DISPOSE '(' compound_name ')' ';' { MSG(""); }
    | YIELD ';' { MSG(""); }
    | BREAK ';' { MSG(""); }
    | variable_assignment { MSG(""); }
    ;

proc_body_element_list
    : proc_body_element { MSG(""); }
    | proc_body_element_list proc_body_element { MSG(""); }
    ;

proc_body
    : '{' '}' { MSG(""); }
    | '{' proc_body_element_list '}' { MSG(""); }
    ;

loop_body_element
    : proc_body_element { MSG(""); }
    | CONTINUE ';' { MSG(""); }
    ;

loop_body_element_list
    : loop_body_element { MSG(""); }
    | loop_body_element_list loop_body_element { MSG(""); }
    ;

loop_body
    : '{' '}' { MSG(""); }
    | '{' loop_body_element_list '}' { MSG(""); }
    ;

else_clause_item
    : ELSE '(' expression ')' proc_body { MSG(""); }
    ;

true_else_clause
    : ELSE proc_body { MSG(""); }
    | ELSE '(' ')' proc_body { MSG(""); }
    ;

else_clause_list
    : else_clause_item { MSG(""); }
    | else_clause_list else_clause_item { MSG(""); }
    ;

if_clause
    : IF '(' expression ')' proc_body { MSG(""); }
    | IF '(' expression ')' proc_body true_else_clause { MSG(""); }
    | IF '(' expression ')' proc_body else_clause_list { MSG(""); }
    | IF '(' expression ')' proc_body else_clause_list true_else_clause { MSG(""); }
    ;

while_clause
    : WHILE loop_body { MSG(""); }
    | WHILE '(' ')' loop_body { MSG(""); }
    | WHILE '(' expression ')' loop_body { MSG(""); }
    | WHILE '(' expression ')' loop_body else_clause_list { MSG(""); }
    ;

do_clause
    : DO loop_body WHILE ';' { MSG(""); }
    | DO loop_body WHILE '(' ')' ';' { MSG(""); }
    | DO loop_body WHILE '(' expression ')' ';' { MSG(""); }
    | DO loop_body WHILE '(' expression ')' else_clause_list { MSG(""); }
    ;

case_clause_item
    : CASE '(' generic_value ')' proc_body { MSG(""); }
    ;

case_clause_item_list
    : case_clause_item { MSG(""); }
    | case_clause_item_list case_clause_item { MSG(""); }
    ;

switch_clause
    : SWITCH '(' expression ')' case_clause_item_list { MSG(""); }
    | SWITCH '(' expression ')' case_clause_item_list DEFAULT proc_body { MSG(""); }
    ;

return_clause
    : RETURN expression ';' { MSG(""); }
    | RETURN ';' { MSG(""); }
    ;

pre_post_inc
    : compound_name INC { MSG(""); }
    | compound_name DEC { MSG(""); }
    | INC compound_name { MSG(""); }
    | DEC compound_name { MSG(""); }
    ;


%%

extern char yytext[];

void yyerror(const char* s)
{
    fflush(stdout);
    fprintf(stderr, "\n%s: line %d: at %d: %s\n\n", get_file_name(), get_line_number(), get_col_number(), s); //yylloc.first_line, s);
    inc_error_count();
}
