// Simplified util.h for RV32IM (no FPU)
// This file replaces common/util.h

#ifndef __UTIL_H
#define __UTIL_H

#include <stdint.h>

extern void setStats(int enable);

#define static_assert(cond) switch(0) { case 0: case !!(long)(cond): ; }

// Integer verification only (no float/double)
static int verify(int n, const volatile int* test, const int* verify_data)
{
    int i;
    for (i = 0; i < n; i++) {
        if (test[i] != verify_data[i])
            return i + 1;
    }
    return 0;
}

// Simplified stats macro (no printf, just runs the code)
#define stats(code, iter) do { \
    setStats(1); \
    code; \
    setStats(0); \
  } while(0)

#endif // __UTIL_H
