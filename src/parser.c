
#include "common.h"

void parse(void)
{
    int tok;
    char str[1024];

    while(EOF != (tok = get_token(str, sizeof(str))))
        printf("%d %s\n", tok, str);
}
