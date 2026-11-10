#include "syscall.h"

void sys_putchar(char c) {
    asm volatile (
        "li a7, %0 \n"    // Load Syscall ID into a7
        "mv a0, %1 \n"    // Load the character argument into a0
        "ecall     \n"    // Jump to the Exception Vector!
        :
        : "i"(SYS_PUTCHAR), "r"((uint32_t)c)
        : "a0", "a7", "memory"
    );
}

void sys_print(const char *str) {
    asm volatile (
        "li a7, %0 \n"    // Load Syscall ID into a7
        "mv a0, %1 \n"    // Load the string address pointer into a0
        "ecall     \n"    // Jump to the Exception Vector!
        :
        : "i"(SYS_PRINT), "r"((uint32_t)str)
        : "a0", "a7", "memory"
    );
}


void sys_exit(int code){
    asm volatile(
        "li a7, %0\n"
        "mv a0, %1\n"
        "ecall\n"
        :
        : "i"(SYS_EXIT), "r"(code)
        : "a0", "a7", "memory"
    );
}