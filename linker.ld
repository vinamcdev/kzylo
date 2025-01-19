ENTRY(start)

SECTIONS
{
  . = 1M;
  .text :
  {
    *(.text)
    *(.text.*)
  }
  .rodata :
  {
    *(.rodata)
    *(.rodata.*)
  }
  .data :
  {
    *(.data)
    *(.data.*)
  }
  .bss :
  {
    *(.bss)
    *(.bss.*)
    *(COMMON)
  }
  . = ALIGN(4096);
}