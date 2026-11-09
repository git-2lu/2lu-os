ENTRY(_start)

SECTIONS
{
    /* 1. FLASH: Direct Boot Magic Header */
    .header : AT(0)
    {
        LONG(0xaedb041d)
        LONG(0xaedb041d)
    } > irom

    /* 2. FLASH: Startup Assembly (Must be at byte 8) */
    .text.entry ORIGIN(irom) + 8 :
    {
        KEEP(*(.text.entry))
    } > irom

    /* 3. FLASH: C Code Instructions */
    .text :
    {
        *(.text .text.*)
    } > irom
    
    . = ALIGN(4);
    _flash_code_end = .; 
    _irom_size = _flash_code_end - ORIGIN(irom);

    /* 4. FLASH: Strings & Constants (Mapped via DROM) */
    .rodata ORIGIN(drom) + _irom_size : AT(_irom_size)
    {
        *(.rodata .rodata.*)
    } > drom
    
    . = ALIGN(4);
    /* Calculate exactly where the data section sits in the binary file */
    _data_lma_offset = . - ORIGIN(drom);
    _data_lma = ORIGIN(drom) + _data_lma_offset;

    /* 5. RAM: Initialized Data (Lives in Flash, executes in RAM) */
    .data ORIGIN(ram) : AT(_data_lma_offset)
    {
        _data_start = .;
        *(.data .data.*)
        . = ALIGN(4);
        _data_end = .;
    } > ram
    
    _data_size = _data_end - _data_start;

    /* 6. RAM: Uninitialized Data (Cleared to zero at boot) */
    .bss :
    {
        __bss_start = .;
        *(.bss .bss.*)
        *(COMMON)
        . = ALIGN(4);
        __BSS_END__ = .;
    } > ram

    . = ALIGN(4096);
    __heap_start = .;

    /* Required by RISC-V toolchains for global variable optimizations */
    __global_pointer$ = ORIGIN(ram) + 0x800;

    /* 7. RAM: System Stack configuration pointer */
    __stack_top = ORIGIN(ram) + LENGTH(ram);
}
