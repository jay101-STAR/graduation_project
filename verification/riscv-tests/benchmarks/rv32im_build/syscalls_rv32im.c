// Simplified syscalls for RV32IM CPU (no FPU, simplified CSR access)
// Compatible with graduation project CPU

#include <stdint.h>
#include <string.h>
#include <stdarg.h>
#include <limits.h>

// tohost is at fixed address 0x80001000 (graduation project convention)
#define TOHOST_ADDR 0x80001000
#define tohost (*(volatile uint32_t *)TOHOST_ADDR)

// Simplified stats - just use counters if available, otherwise no-op
static uint32_t cycle_start = 0;
static uint32_t instret_start = 0;

// Try to read mcycle CSR, return 0 if not available
static inline uint32_t read_mcycle(void) {
    uint32_t val;
    __asm__ volatile ("csrr %0, mcycle" : "=r"(val) : : );
    return val;
}

// Try to read minstret CSR, return 0 if not available
static inline uint32_t read_minstret(void) {
    uint32_t val;
    __asm__ volatile ("csrr %0, minstret" : "=r"(val) : : );
    return val;
}

void setStats(int enable)
{
    // Simplified: just try to read counters, ignore if not available
    if (enable) {
        // cycle_start = read_mcycle();
        // instret_start = read_minstret();
    } else {
        // Could print stats here if printf is available
    }
}

void __attribute__((noreturn)) tohost_exit(uint32_t code)
{
    // RISC-V test convention: tohost = (code << 1) | 1
    // code = 0 means pass, code > 0 means fail
    tohost = (code << 1) | 1;
    while (1);
}

void exit(int code)
{
    tohost_exit(code);
}

void abort()
{
    exit(128);
}

// Weak handle_trap - can be overridden
uintptr_t __attribute__((weak)) handle_trap(uintptr_t cause, uintptr_t epc, uintptr_t regs[32])
{
    tohost_exit(1337);
    return 0;
}

// Weak thread_entry for single-threaded programs
void __attribute__((weak)) thread_entry(int cid, int nc)
{
    while (cid != 0);
}

// Weak main
int __attribute__((weak)) main(int argc, char** argv)
{
    return -1;
}

// Simplified TLS init
static void init_tls()
{
    // Skip TLS for simplicity
}

// Entry point called from crt
void _init(int cid, int nc)
{
    init_tls();
    thread_entry(0, 1);  // Single core, core ID = 0

    int ret = main(0, 0);
    exit(ret);
}

// Basic memcpy
void* memcpy(void* dest, const void* src, size_t len)
{
    char* d = dest;
    const char* s = src;
    while (len--)
        *d++ = *s++;
    return dest;
}

// Basic memset
void* memset(void* dest, int byte, size_t len)
{
    char* d = dest;
    while (len--)
        *d++ = byte;
    return dest;
}

// Basic strlen
size_t strlen(const char *s)
{
    const char *p = s;
    while (*p)
        p++;
    return p - s;
}

size_t strnlen(const char *s, size_t n)
{
    const char *p = s;
    while (n-- && *p)
        p++;
    return p - s;
}

int strcmp(const char* s1, const char* s2)
{
    unsigned char c1, c2;
    do {
        c1 = *s1++;
        c2 = *s2++;
    } while (c1 != 0 && c1 == c2);
    return c1 - c2;
}

char* strcpy(char* dest, const char* src)
{
    char* d = dest;
    while ((*d++ = *src++))
        ;
    return dest;
}
