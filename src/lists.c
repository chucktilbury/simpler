/*
 * This module manages a dynamic list by controling the size of it. It is
 * intended for use by the dynamic LIFO and FIFO modules.
 */
#include "common.h"
#ifdef __TESTING_LIST_MANAGER_C__
#define fatal_error(...)              \
    do                                \
    {                                 \
        fprintf(stderr, __VA_ARGS__); \
        exit(1);                      \
    } while(0)
#endif

/*
 * This resizes the list to grow it. This should always be called before
 * adding aything to it.
 *
 * Aborts the program upon failure.
 */
static void resize_list(list_t* list)
{
    if(list->nitems + 2 > list->capacity)
    {
        list->capacity = list->capacity << 1;
        list->buffer = realloc(list->buffer, list->capacity * list->item_size);

        if(list->buffer == NULL)
            fatal_error("cannot allocate %lu bytes for managed buffer", list->capacity * list->item_size);
    }
}

/*
 * Internal function that calculates a pointer into the buffer, given the index
 * of the intended item. This returns a pointer to the first byte of the item
 * that was stored. It's up to the caller to convert it to a pointer to the data
 * object that it knows about.
 */
static unsigned char* list_at_index(list_t* list, int index)
{
    unsigned char* ptr = &list->buffer[list->item_size * index];

    return ptr;
}

/*
 * Free the list buffer. This is only used when the list will not longer
 * be used, such as when the program ends.
 */
void destroy_list(list_t* list)
{
    if(list->buffer != NULL && list->nitems != 0) free(list->buffer);
    free(list);
}

/*
 * Initially create the list and initialize the contents to initial values.
 * If the list was in use before this, the buffer will be freed.
 *
 * Size is the size of each item that that will be put in the list.
 */
list_t* create_list(size_t size)
{
    list_t* list;

    list = (list_t*)calloc(1, sizeof(list_t));
    if(list == NULL) fatal_error("cannot allocate %lu bytes for managed list", sizeof(list_t));

    list->item_size = size;
    list->capacity = 0x01 << 3;
    list->nitems = 0;
    list->buffer = (uint8_t*)calloc(list->capacity, size);
    if(list->buffer == NULL) fatal_error("cannot allocate %lu bytes for managed list buffer", list->capacity * size);

    return list;
}

/*
 * Store the given item in the given list at the end of the list.
 */
void append_list(list_t* list, void* item)
{
    resize_list(list);
    memcpy(list_at_index(list, list->nitems), item, list->item_size);
    list->nitems++;
}

/*
 * If the index is within the bounds of the list, then return a raw pointer to
 * the element specified. If it is outside the list, or if there is nothing in
 * the list, then return NULL.
 */
int get_list_index(list_t* list, int index, void* buffer)
{
    if(list != NULL)
    {
        if(buffer != NULL)
        {
            if(index >= 0 && index <= (int)list->nitems)
            {
                memcpy(buffer, list_at_index(list, index), list->item_size);
                return LIST_NO_ERROR;  // success
            }
            else
                return LIST_BAD_INDEX;  // failed
        }
    }
    else
        return LIST_INVALID;

    return LIST_BAD_INDEX;  // failed
}

/*
 * Return a pointer to the raw list. This is used when a section is getting
 * written to disk.
 */
uint8_t* get_list_ptr(list_t* list) { return list->buffer; }

#ifdef __TESTING_LIST_MANAGER_C__
/*
 * Simple test using an list of strings.
 */

int main(void)
{
    char* strs[] = {"foo", "bar", "baz", "bacon", "eggs", "potatoes", "onions", "nuclear", "powered", "chicken", NULL};
    list_t* list;
    char* ptr;

    list = create_list(sizeof(char*));
    for(int i = 0; strs[i] != NULL; i++) append_list(list, (void*)&strs[i]);

    for(int i = 0; strs[i] != NULL; i++)
    {
        get_list(list, i, &ptr);
        printf("value: %s\n", ptr);
    }

    printf("nitems: %lu\n", list->nitems);
    printf("item_size: %lu\n", list->item_size);
    printf("capacity: %lu\n", list->capacity);

    printf("null: %d\n", get_list(list, -1, &ptr));
    printf("null: %d\n", get_list(list, 100, &ptr));
    printf("null: %d\n", get_list(list, 8, &ptr));

    for(int i = 0; i < 3; i++)
    {
        pop_list(list, &ptr);
        printf("value: %s\n", ptr);
    }
}

#endif
