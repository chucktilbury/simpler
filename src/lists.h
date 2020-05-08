#ifndef __LISTS_H__
#define __LISTS_H__
#include <stdint.h>
#include <stdlib.h>
enum
{
    LIST_INVALID = -1,
    LIST_NOT_FOUND = -2,
    LIST_BAD_INDEX = -3,
    LIST_NO_ERROR = 0,
};

/**
 * @brief Structure for a managed array.
 */
typedef struct
{
    size_t nitems;     // number of items currently in the array
    size_t capacity;   // capacity in items
    size_t item_size;  // size of each item
    uint8_t* buffer;   // raw buffer where the items are kept
} list_t;

list_t* create_list(size_t size);
void destroy_list(list_t* array);
void append_list(list_t* array, void* item);
int get_list_index(list_t* array, int index, void* buffer);
uint8_t* get_list_ptr(list_t* array);

#endif
