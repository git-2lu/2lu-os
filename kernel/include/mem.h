#ifndef KERNEL_MEM_H
#define KERNEL_MEM_H

#include <common.h>

#define PAGE_SIZE 4096
#define PAGE_STATE_FREE 0
#define PAGE_STATE_ALLOCATED 1
#define BITMAP_SIZE 4

void init_page_allocator(void);
void *alloc_pages(uint32_t n);
void free_pages(void *p);

#endif