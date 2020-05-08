
#include "common.h"

#ifdef __TESTING_STACK_C__
#define fatal_error(...)              \
    do                                \
    {                                 \
        fprintf(stderr, __VA_ARGS__); \
        exit(1);                      \
    } while(0)
#endif

#define min(a, b) (((a) > (b)) ? (b) : (a))

stack_t* create_stack(void)
{
    stack_t* stack = (stack_t*)calloc(1, sizeof(stack_t));

    if(stack == NULL) fatal_error("cannot allocate memory for stack_t data structure");

    return stack;
}

void destroy_stack(stack_t* stack)
{
    if(stack != NULL)
    {
        int res;

        do
        {
            res = pop_stack(stack, NULL, 0);
        } while(res >= 0);
        free(stack);
    }
}

int push_stack(stack_t* stack, void* data, size_t size, int type)
{
    if(stack == NULL)
        return STACK_INVALID;

    stack_item_t* item = calloc(1, sizeof(stack_item_t));

    if(item == NULL) fatal_error("cannot allocate memry for stack item");

    item->data = malloc(size);
    if(item->data == NULL) fatal_error("cannot allocate %lu bytes for stack data", size);

    memcpy(item->data, data, size);
    item->type = type;
    item->size = size;

    if(stack->items != NULL) item->next = stack->items;
    stack->items = item;
    return STACK_NO_ERROR;
}

int pop_stack(stack_t* stack, void* data, size_t size)
{
    if(stack == NULL)
        return STACK_INVALID;

    stack_item_t* item = stack->items;

    if(item == NULL) return STACK_EMPTY;
    stack->items = item->next;

    if(item->data != NULL && data != NULL) memcpy(data, item->data, min(size, item->size));

    int type = item->type;

    free(item->data);
    free(item);

    return type;
}

int peek_stack(stack_t* stack, void* data, size_t size)
{
    if(stack == NULL)
        return STACK_INVALID;

    stack_item_t* item = stack->items;

    if(item == NULL) return STACK_EMPTY;

    if(item->data != NULL) memcpy(data, item->data, min(size, item->size));

    return item->type;
}

#ifdef __TESTING_STACK_C__

char* strs[] = {"foo",      "bar",     "baz",   "bacon",     "eggs",     "potatoes", "onions",    "knuckles", "are",
                "dragging", "hoops",   "of",    "chocolate", "almonds",  "with",     "sprinkles", "and",      "cyanide",
                "log",      "balls",   "eaten", "by",        "unicorns", "as",       "pink",      "stripes",  "given",
                "to",       "nuclear", "pound", "cake",      "candles",  "snards",   "snipes",    NULL};

int main(void)
{
    stack_t* stack = create_stack();
    char buffer[128];
    int type;

    printf("\npush a few items\n");
    for(int i = 0; strs[i] != NULL; i++)
    {
        push_stack(stack, strs[i], strlen(strs[i]) + 1, i);
        printf("add: %s type: %d\n", strs[i], i);
    }
    printf("\npeek an item\n");
    type = peek_stack(stack, buffer, sizeof(buffer));
    printf("buffer: %s type: %d\n", buffer, type);
    type = peek_stack(stack, buffer, sizeof(buffer));
    printf("buffer: %s type: %d\n", buffer, type);

    printf("\npop a few items\n");
    type = pop_stack(stack, buffer, sizeof(buffer));
    printf("buffer: %s type: %d\n", buffer, type);
    type = pop_stack(stack, buffer, sizeof(buffer));
    printf("buffer: %s type: %d\n", buffer, type);
    type = pop_stack(stack, buffer, sizeof(buffer));
    printf("buffer: %s type: %d\n", buffer, type);

    printf("\npeek an item\n");
    type = peek_stack(stack, buffer, sizeof(buffer));
    printf("buffer: %s type: %d\n", buffer, type);

    printf("\ndestroy the stack\n");
    destroy_stack(stack);
}

#endif
