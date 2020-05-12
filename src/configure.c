/*
 * Stand-alone command line parser.
 *
 * Command parameters have the format of "-x arg". In this, 'x' can be any letter or number
 * and they are case sensitive. Command switches are exactly 2 characters and may NOT be
 * combined. In other words, the arg "-xasc12" is parsed as "-x", "asc12". This is not
 * optimal, and may change. It would be better to have command args any arbitrary length,
 * but that is not easy to fix with this implementation.
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>

#include "configure.h"

static char cmd_line_buffer[1024*64];
static char list_buffer[1024*8];
static char prog_name[1024];

static int count_struct(void) {

    int i;

    for(i = 0; _global_config[i].type != CONFIG_TYPE_END; i++)
        /* nothing */ ;
    return i;
}

static int preprocess_command_line(int argc, char** argv) {

    int num = 0;

    memset(cmd_line_buffer, 0, sizeof(cmd_line_buffer));
    memset(list_buffer, 0, sizeof(list_buffer));
    memset(prog_name, 0, sizeof(prog_name));

    strcpy(prog_name, argv[0]);

    for(int idx = 1; idx < argc; idx++) {
        if(argv[idx][0] == '-') {
            strncat(cmd_line_buffer, argv[idx], 2);
            if(argv[idx][2] != 0) {
                strcat(cmd_line_buffer, " ");
                strcat(cmd_line_buffer, &argv[idx][2]);
                num++;
            }
            strcat(cmd_line_buffer, " ");
            num++;
        }
        else {
            strcat(cmd_line_buffer, argv[idx]);
            strcat(cmd_line_buffer, " ");
            num++;
        }
    }
    return num;
}

// this expects to be called on an even token boundary.
static void process_token(const char* tok) {

    int flag = 0;

    // find the token in the data
    if(tok[0] == '-') {
        for(int i = 0; _global_config[i].type != CONFIG_TYPE_END; i++) {
            if(_global_config[i].arg == NULL)
                continue;

            if(!strcmp(tok, _global_config[i].arg)) {
                switch(_global_config[i].type) {
                    case CONFIG_TYPE_NUM: {
                            char* str = strtok(NULL, " ");
                            int num = (int)strtol(str, NULL, 0);
                            if(num == 0 && errno != 0) {
                                fprintf(stderr, "CMD ERROR: Cannot convert string \"%s\" to a number\n", str);
                                show_use();
                            }
                            _global_config[i].value.number = num;
                            _global_config[i].touched++;
                        }
                        break;
                    case CONFIG_TYPE_LIST:
                    case CONFIG_TYPE_STR: {
                            char* str = strtok(NULL, " ");
                            _global_config[i].value.string = str; // pointer into the buffer
                            _global_config[i].touched++;
                        }
                        break;
                    case CONFIG_TYPE_BOOL:
                        _global_config[i].value.number = (_global_config[i].value.number & 0x01) ^ 0x01;
                        _global_config[i].touched++;
                        break;
                    case CONFIG_TYPE_HELP:
                        show_use();
                        break;
                    default:
                        fprintf(stderr, "INTERNAL ERROR: Cannot parse command line\n");
                        exit(1);
                }
                flag++;
                break;
            }
        }
    }
    else {
        if(strlen(list_buffer) > 0)
            strcat(list_buffer, ":");
        strcat(list_buffer, tok);
        flag++;
    }

    if(!flag) {
        fprintf(stderr, "CMD ERROR: Unknown command parameter: \"%s\"\n", tok);
        show_use();
    }
}

int configure(int argc, char** argv) {

    int args = preprocess_command_line(argc, argv);
    if(args != 0) {
        char* tok = strtok(cmd_line_buffer, " ");
        do {
            process_token(tok);
            tok = strtok(NULL, " ");
        } while(tok != NULL);

        if(strlen(list_buffer) > 0) {
            _global_config[count_struct()-1].value.string = list_buffer;
            _global_config[count_struct()-1].touched++;
        }
    }

    for(int i = 0; _global_config[i].type != CONFIG_TYPE_END; i++) {
        if(_global_config[i].required != 0 && _global_config[i].touched == 0) {
            fprintf(stderr, "CMD ERROR: required parameter \"%s\" (%s) is missing\n",
                        _global_config[i].arg? _global_config[i].arg: "none",
                        _global_config[i].name);
            show_use();
        }
    }

    return args;
}

void* get_config(const char* name) {

    void* retv = NULL;

    if(!strcmp(name, "PROG_NAME"))
        retv = (void*)prog_name;
    else {
        for(int i = 0; _global_config[i].type != CONFIG_TYPE_END; i++) {
            if(!strcmp(name, _global_config[i].name)) {
                switch(_global_config[i].type) {
                    case CONFIG_TYPE_NUM:
                    case CONFIG_TYPE_BOOL:
                        retv = (void*)&_global_config[i].value.number;
                        break;
                    case CONFIG_TYPE_LIST:
                    case CONFIG_TYPE_STR:
                        retv = (void*)_global_config[i].value.string;
                        break;
                    default:
                        fprintf(stderr, "INTERNAL ERROR: Cannot parse command line\n");
                        exit(1);
                }
            }
        }
    }

    return retv;
}

// given the parameter name, iterate the list. If the name is not NULL, then the
// list is reset to the beginning. See strtok(). If the name is not a list, then
// simply return the value as a string.
char* iterate_config(const char* name) {

    static char* buf = NULL;
    char* tok = NULL;

    if(name != NULL) {
        if(buf != NULL) {
            free(buf);
            buf = NULL;
        }

        if(!strcmp(name, "PROG_NAME")) {
            buf = strdup(prog_name);
            tok = strtok(buf, ":");
        }
        else {
            for(int i = 0; _global_config[i].type != CONFIG_TYPE_END; i++) {
                if(!strcmp(name, _global_config[i].name)) {
                    switch(_global_config[i].type) {
                        case CONFIG_TYPE_NUM:
                        case CONFIG_TYPE_BOOL: {
                            char s[1024];
                            snprintf(s, sizeof(s), "%d", _global_config[i].value.number);
                            buf = strdup(s);
                            tok = strtok(buf, ":");
                            }
                            break;
                        case CONFIG_TYPE_LIST:
                        case CONFIG_TYPE_STR:
                            buf = strdup(_global_config[i].value.string);
                            tok = strtok(buf, ":");
                            break;
                        default:
                            fprintf(stderr, "INTERNAL ERROR: Cannot iterate command line\n");
                            exit(1);
                    }
                    break;
                }
            }
        }

        if(buf == NULL) {
            fprintf(stderr, "INTERNAL ERROR: Cannot iterate config name \"%s\"\n", name);
            exit(1);
        }
    }
    else if(buf != NULL) {
        tok = strtok(NULL, ":");
        if(tok == NULL) {
            free(buf);
            buf = NULL;
        }
    }
    // else tok is NULL. Do noting.

    return tok;
}

void show_use(void) {

    fprintf(stderr, "Use: %s <parameters>\n", prog_name);
    for(int i = 0; _global_config[i].type != CONFIG_TYPE_END; i++) {
        switch(_global_config[i].type) {
            case CONFIG_TYPE_NUM:
                fprintf(stderr, "\n  %2s <num>  %s\n",
                        _global_config[i].arg != NULL? _global_config[i].arg: "",
                        _global_config[i].help);
                fprintf(stderr, "     val: %d required: %s\n",
                        _global_config[i].value.number,
                        _global_config[i].required? "TRUE": "FALSE");
                break;
            case CONFIG_TYPE_STR:
                fprintf(stderr, "\n  %2s <str>  %s\n",
                        _global_config[i].arg != NULL? _global_config[i].arg: "",
                        _global_config[i].help);
                fprintf(stderr, "     val: %s required: %s\n",
                        _global_config[i].value.string,
                        _global_config[i].required? "TRUE": "FALSE");
                break;
            case CONFIG_TYPE_BOOL:
            case CONFIG_TYPE_HELP:
                fprintf(stderr, "\n  %2s <bool> %s\n",
                        _global_config[i].arg != NULL? _global_config[i].arg: "",
                        _global_config[i].help);
                fprintf(stderr, "     val: %s required: %s\n",
                        _global_config[i].value.number? "TRUE": "FALSE",
                        _global_config[i].required? "TRUE": "FALSE");

                break;
            case CONFIG_TYPE_LIST:
                fprintf(stderr, "\n  %2s <list> %s\n",
                        _global_config[i].arg != NULL? _global_config[i].arg: "",
                        _global_config[i].help);
                fprintf(stderr, "     required: %s\n",
                        _global_config[i].required? "TRUE": "FALSE");
                if(_global_config[i].value.string != NULL)
                    fprintf(stderr, "     %s\n", _global_config[i].value.string);
                else
                    fprintf(stderr, "     <empty>\n");
                break;
            default:
                fprintf(stderr, "INTERNAL ERROR: Cannot parse command line\n");
                exit(1);

        }
    }
    fprintf(stderr, "\n");
    exit(1);
}

#ifdef __TESTING_CONFIGURE_C__

/*
 * Sanity check this functionality.
 *
 * example:
 * ./cfg -o filename.fn -i f1.c:f2.c:f3.c -v 10
 *    -or-
 * ./cfg -ofilename.fn -if1.c:f2.c:f3.c -v10
 *
 */

BEGIN_CONFIG
    CONFIG_NUM("-v", "VERBOSE", "Control the verbosity", 0, 0)
    CONFIG_STR("-o", "OUT_FILE", "Name the output file", 1, NULL)
    CONFIG_BOOL("-b", "BOOL_VAL", "Demostrate a boolean value", 0, 0)
    CONFIG_LIST("-i", "INPUT_FILES", "List of files to be compiled", 1, NULL)
    CONFIG_LIST("-s", "FILE_SEARCH", "Set the search path list", 0, "./:./include")
END_CONFIG

int main(int argc, char** argv) {

    int n = configure(argc, argv);
    printf("num_parms: %d\n", n);
    printf("verbosity: %d\n", *(int*)get_config("VERBOSE"));
    printf("file_search: %s\n", (char*)get_config("FILE_SEARCH"));
    printf("file_list: %s\n", (char*)get_config("INPUT_FILES"));
    printf("out file: %s\n", (char*)get_config("OUT_FILE"));
    printf("prog_name: %s\n", (char*)get_config("PROG_NAME"));
    printf("bool_val: %d\n", GET_CONFIG_BOOL("BOOL_VAL"));

    printf("\nVERBOSE: ");
    for(char* str = iterate_config("VERBOSE"); str != NULL; str = iterate_config(NULL))
        printf("%s ", str);
    printf("\n");

    printf("PROG_NAME: ");
    for(char* str = iterate_config("PROG_NAME"); str != NULL; str = iterate_config(NULL))
        printf("%s ", str);
    printf("\n");

    printf("FILE_SEARCH: ");
    for(char* str = iterate_config("FILE_SEARCH"); str != NULL; str = iterate_config(NULL))
        printf("%s ", str);
    printf("\n");

    printf("INPUT_FILES: ");
    for(char* str = iterate_config("INPUT_FILES"); str != NULL; str = iterate_config(NULL))
        printf("%s ", str);
    printf("\n");

    printf("OUT_FILE: ");
    for(char* str = iterate_config("OUT_FILE"); str != NULL; str = iterate_config(NULL))
        printf("%s ", str);
    printf("\n");

    printf("BOOL_VAL: ");
    for(char* str = iterate_config("BOOL_VAL"); str != NULL; str = iterate_config(NULL))
        printf("%s ", str);
    printf("\n");

    //show_use();
}

#endif
