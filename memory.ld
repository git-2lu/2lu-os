/*
 * ESP32-C3 Memory Map
 * IROM = flash mapped to instruction cache (code execution)
 * DROM = flash mapped to data cache (read-only data)
 * RAM  = SRAM (stack, .data, .bss)
 */
MEMORY
{
    /* Flash regions (set up by ROM bootloader's Flash MMU) */
    irom (x): org = 0x42000000, len = 0x400000   /* 4MB flash for code */
    drom (r): org = 0x3C000000, len = 0x400000   /* 4MB flash for rodata */
    
    /* Internal SRAM — ESP32-C3 has 512KB total, 0x50000 usable */
    ram (rw): org = 0x3FC80000, len = 0x50000     /* 320KB SRAM */
}
