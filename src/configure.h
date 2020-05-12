#ifndef __CONFIGURE_H__
#define __CONFIGURE_H__
#include <stdio.h>
typedef enum {
    CONFIG_TYPE_NUM,
    CONFIG_TYPE_STR,
    CONFIG_TYPE_BOOL,
    CONFIG_TYPE_LIST,
    CONFIG_TYPE_HELP,
    CONFIG_TYPE_END,
} config_type_t;

typedef struct _configuration {
    char* arg;  // The cmd arg, such as "-a"
    char* name; // Name as it would be found in the environment, such as "NAME"
    char* help; // Help string to print
    config_type_t type; // Type of the value in the union
    char required; // if this is set, the parameter is required
    union {     // union can hold a number or a string
        int number;
        char* string;
    } value;
    char touched;
} configuration_t;

#define BEGIN_CONFIG configuration_t _global_config[] = { \
            {"-h", "HELP_FLAG", "Print the help and exit", CONFIG_TYPE_HELP, 0, .value.number=0, 0},
#define END_CONFIG {NULL, NULL, NULL, CONFIG_TYPE_END, 0, .value.number=-1, 0}};

#define CONFIG_NUM(arg, name, help, req, val) {arg, name, help, CONFIG_TYPE_NUM, req, .value.number=val, 0},
#define CONFIG_STR(arg, name, help, req, val) {arg, name, help, CONFIG_TYPE_STR, req, .value.string=val, 0},
#define CONFIG_BOOL(arg, name, help, req, val) {arg, name, help, CONFIG_TYPE_BOOL, req, .value.number=val, 0},
#define CONFIG_LIST(arg, name, help, req, val) {arg, name, help, CONFIG_TYPE_LIST, req, .value.string=val, 0},

/*
 * Example configuration
BEGIN_CONFIG
    CONFIG_NUM("-a", "SOME_ARG", "This is the help text", 0, 19)
    CONFIG_NUM("-b", "SOME_ARG", "This is the help text", 0, 21)
    CONFIG_NUM("-c", "SOME_ARG", "This is the help text", 0, 20)
    CONFIG_STR("-a", "SOME_ARG", "This is the help text", 0, "default_value")
    CONFIG_STR("-c", "SOME_ARG", "This is the help text", 0, "default_value")
    CONFIG_STR("-d", "SOME_ARG", "This is the help text", 1, "default_value")
END_CONFIG
 */

#define GET_CONFIG_NUM(n)   (*(int*)get_config(n))
#define GET_CONFIG_STR(n)   ((char*)get_config(n))
#define GET_CONFIG_BOOL(n)  (*(int*)get_config(n))
#define GET_CONFIG_LIST(n)  ((char*)get_config(n))

extern configuration_t _global_config[];

int configure(int argc, char** argv);
void* get_config(const char* name);
char* iterate_config(const char* name);
void show_use(void);

#endif
