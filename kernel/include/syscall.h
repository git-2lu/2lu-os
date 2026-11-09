#ifndef SYSCALL_H
#define SYSCALL_H

#include <common.h>

#define SYS_PUTCHAR 1
#define SYS_PRINT 2

void sys_putchar(char c);
void sys_print(const char*);

#endif