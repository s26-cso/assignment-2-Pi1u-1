#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>

int main(int argc, char const *argv[])
{
    char op[10];
    int a, b;

    while (1)
    {
        int x = scanf("%s %d %d", op, &a, &b);
        if (x != 3)
        {
            printf("Invalid input\n");
            break;
        }

        // construct library name: lib<op>.so
        char libname[20];
        strcpy(libname, "lib");
        strcat(libname, op);
        strcat(libname, ".so");

        // load library
        void *lib = dlopen(libname, RTLD_LAZY);
        if (!lib)
        {
            printf("Error\n");
            continue;
        }

        // get function pointer
        int (*func)(int, int);
        func = dlsym(lib, op);

        if (!func)
        {
            printf("Error\n");
            dlclose(lib);
            continue;
        }

        // call function
        int result = func(a, b);
        printf("%d\n", result);

        // free library
        dlclose(lib);
    }
    return 0;
}