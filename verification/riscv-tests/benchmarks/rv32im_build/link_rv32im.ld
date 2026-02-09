/* Linker script for RV32IM CPU (graduation project) */
/* Memory layout matches the CPU's memory map */

OUTPUT_ARCH( "riscv" )
ENTRY(_start)

MEMORY
{
  /* Instruction memory starts at 0x80000000 */
  /* Data memory is unified, total 64KB available */
  RAM (rwx) : ORIGIN = 0x80000000, LENGTH = 64K
}

SECTIONS
{
  /* Code section at base address */
  . = 0x80000000;
  .text.init : { *(.text.init) } > RAM

  /* Main code section - right after .text.init */
  .text : { *(.text .text.*) } > RAM

  /* Read-only data */
  .rodata : { *(.rodata .rodata.* .srodata*) } > RAM

  /* tohost section MUST be at 0x80001000 (for test result) */
  . = 0x80001000;
  .tohost : {
    *(.tohost)
  } > RAM

  /* Data section after tohost */
  . = ALIGN(0x100);
  .data : {
    *(.data .data.*)
    __global_pointer$ = . + 0x800;
    *(.sdata .sdata.*)
  } > RAM

  /* BSS section */
  .sbss : {
    *(.sbss .sbss.*)
    *(.scommon)
  } > RAM

  .bss : {
    *(.bss .bss.*)
    *(COMMON)
  } > RAM

  /* TLS sections (simplified) */
  .tdata : {
    _tdata_begin = .;
    *(.tdata .tdata.*)
    _tdata_end = .;
  } > RAM

  .tbss : {
    *(.tbss .tbss.*)
    _tbss_end = .;
  } > RAM

  /* End of data */
  _end = .;

  /* Stack starts at 64KB mark and grows downward */
  /* Leave space: code + data should be < 48KB to have 16KB stack */
}
