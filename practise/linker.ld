/* 定义内存区域 */
MEMORY {
    RAM (rwx) : ORIGIN = 0x80000000, LENGTH = 128M
    ROM (rx)  : ORIGIN = 0x00000000, LENGTH = 64K   /* 可选的ROM区域 */
}

/* 设置入口点 */
ENTRY(_start)

SECTIONS {
    /* .text 段放在 RAM 开头 */
    .text : {
        *(.text)           /* 所有代码 */
        *(.text.*)         /* 编译器生成的代码 */
        *(.rodata)         /* 只读数据 */
        *(.rodata.*)
    } > RAM
    
    /* .data 段 */
    .data : {
        _data_start = .;
        *(.data)
        *(.data.*)
        _data_end = .;
    } > RAM
    
    /* .bss 段 */
    .bss : {
        _bss_start = .;
        *(.bss)
        *(.bss.*)
        *(COMMON)          /* 公共符号 */
        _bss_end = .;
    } > RAM

    /* 栈区域 */
    .stack : {
        _stack_start = .;
        . += 0x1000;       /* 4KB 栈空间 */
        _stack_end = .;
    } > RAM
    
    /* 堆区域 */
    .heap : {
        _heap_start = .;
        . += 0x2000;       /* 8KB 堆空间 */
        _heap_end = .;
    } > RAM
    
    /* 设置全局符号 */
    _end = .;

    /* Spike tohost/fromhost for exit detection */
    .tohost : ALIGN(0x1000) {
        tohost = .;
        . += 8;
        fromhost = .;
        . += 8;
    } > RAM
}
