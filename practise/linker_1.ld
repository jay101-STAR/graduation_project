OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY {
    RAM (rwx) : ORIGIN = 0x80000000, LENGTH = 128K
}

SECTIONS {
    .text : {
        *(.text.startup)
        *(.text)
        *(.text.*)
    } > RAM
    
    .data : {
        *(.data)
        *(.data.*)
        *(.sdata)
        *(.sdata.*)
    } > RAM
    
    .bss : {
        *(.bss)
        *(.bss.*)
        *(.sbss)
        *(.sbss.*)
    } > RAM
    
    /* QEMU specific */
    .tohost : {
        *(.tohost)
    } > RAM
    
    /DISCARD/ : {
        *(.comment)
        *(.note*)
    }
}
