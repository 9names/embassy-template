MEMORY
{
{% if chip contains "rp2040" -%}
BOOT2 : ORIGIN = 0x10000000, LENGTH = 0x100
{% endif -%}
FLASH : ORIGIN = {{ flash_start }}, LENGTH = {{ flash_size }}
RAM   : ORIGIN = {{ ram_start }}, LENGTH = {{ ram_size }}
{% if chip contains "nrf91" -%}
IPC   : ORIGIN = 0x20000000, LENGTH = 64K
{% endif -%}
{% if chip contains "rp235" -%}
SRAM8 : ORIGIN = 0x20080000, LENGTH = 4K
SRAM9 : ORIGIN = 0x20081000, LENGTH = 4K
{% endif -%}
}

{% if chip contains "nrf91" -%}
PROVIDE(__start_ipc = ORIGIN(IPC));
PROVIDE(__end_ipc   = ORIGIN(IPC) + LENGTH(IPC));
{% endif -%}

{% if chip contains "rp235" -%}
SECTIONS {
    /* ### Boot ROM info
     *
     * Goes after .vector_table, to keep it in the first 4K of flash
     * where the Boot ROM (and picotool) can find it
     */
    .start_block : ALIGN(4)
    {
        __start_block_addr = .;
        KEEP(*(.start_block));
        KEEP(*(.boot_info));
    } > FLASH

} INSERT AFTER .vector_table;

/* move .text to start /after/ the boot info */
_stext = ADDR(.start_block) + SIZEOF(.start_block);

SECTIONS {
    /* ### Picotool 'Binary Info' Entries
     *
     * Picotool looks through this block (as we have pointers to it in our
     * header) to find interesting information.
     */
    .bi_entries : ALIGN(4)
    {
        /* We put this in the header */
        __bi_entries_start = .;
        /* Here are the entries */
        KEEP(*(.bi_entries));
        /* Keep this block a nice round size */
        . = ALIGN(4);
        /* We put this in the header */
        __bi_entries_end = .;
    } > FLASH
} INSERT AFTER .text;

SECTIONS {
    /* ### Boot ROM extra info
     *
     * Goes after everything in our program, so it can contain a signature.
     */
    .end_block : ALIGN(4)
    {
        __end_block_addr = .;
        KEEP(*(.end_block));
    } > FLASH

} INSERT AFTER .uninit;

PROVIDE(start_to_end = __end_block_addr - __start_block_addr);
PROVIDE(end_to_start = __start_block_addr - __end_block_addr);
{% endif -%}
