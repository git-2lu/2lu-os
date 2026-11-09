#include "mem.h"

extern uint8_t __heap_start[];
extern uint8_t __stack_top[];


static uint32_t page_bitmap[BITMAP_SIZE];
static uint32_t chain_bitmap[BITMAP_SIZE];


#define BIT_SET(arr, bit) (arr[bit/32] |= (1U << (bit%32)))
#define BIT_RESET(arr, bit)(arr[bit/32] &= ~(1U << (bit%32)))
#define BIT_TEST(arr, bit)(arr[bit/32] & (1U << (bit%32)))

static uint32_t total_pages = 0;
static uint8_t *heap_base = NULL;


void init_page_allocator(void){
    heap_base = (uint8_t *)(((uint32_t)__heap_start + PAGE_SIZE - 1) & ~(PAGE_SIZE -1));

    uint8_t *heap_end = (uint8_t *)__stack_top - (16*1024); // 16 KB headroom for stack but may need to change that don't like the fixed size

    if(heap_end <=heap_base){
        PANIC("Memory allocation error: Heap size calculation is invalid!");
    }

    total_pages = (heap_end - heap_base)/PAGE_SIZE;

    if(total_pages > (BITMAP_SIZE * 32)){
        total_pages = BITMAP_SIZE * 32;
    }

    for(uint8_t i =0;i<BITMAP_SIZE;i++){
        page_bitmap[i] = 0;
        chain_bitmap[i] = 0;
    }

    printf("Bitmap Memory Manager: Initialised. Total free 4KB pages: %d\r\n", total_pages);
}

void *alloc_pages(uint32_t n){
    if(!n) return NULL;

    for(uint8_t i=0;i<total_pages-1;i++){
        int found = 1;
        for(uint8_t j=0;j<n;j++){
            if(BIT_TEST(page_bitmap, i+j)){
                found = 0;
                break;
            }
        }

        if(found){
            for(uint8_t j=0;j<n;j++){
                BIT_SET(page_bitmap, i+j);
                if(j<n-1) BIT_SET(chain_bitmap, 1);
            }

            void *ptr = (void *)(heap_base + (i*PAGE_SIZE));
            memset(ptr, 0, n*PAGE_SIZE);
            return ptr;
        }
    }

    printf("Bitmap Warning: Out of Memory! Failed to allocate %d pages.\r\n", n);
    return NULL;
}

void free_pages(void *ptr){
    if(!ptr) return;

    uint8_t *addr = (uint8_t*)ptr;
    if(addr < heap_base || addr >=(heap_base + (total_pages * PAGE_SIZE))){
        PANIC("Bitmap Manager: Attempted to free an out-of-bounds address pointer!");
    }

    uint8_t i = (addr - heap_base)/PAGE_SIZE;

    while(i<total_pages){
        int is_chained = BIT_TEST(chain_bitmap, i);

        BIT_RESET(page_bitmap, i);
        BIT_RESET(chain_bitmap, i);

        if(is_chained) break;
        i++;
    }
}