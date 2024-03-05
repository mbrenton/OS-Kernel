/* How to link operating system together */

ENTRY(start)

SECTIONS
{
    . = 1M; /*Set current address to 1MB, convention for kernels, all operating system data will start 1MB in*/

    /*Boot section with multiboot header*/
    .boot:
    {
        KEEP(*(.multiboot_header))
    }

    /*text section with cpu instructions*/
    .text:
    {
        *(.text)
    }
}