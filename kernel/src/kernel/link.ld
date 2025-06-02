ENTRY(main)

SECTIONS {
    /* 内核加载到 0xC0000000 起始的虚拟地址空间 */

    . = 0xC0001500;

    .text : {
        *(.text.start)   /* 可选：放第一个函数 _start */
        *(.text)
    }

    . = 0xC0002000;     /* 设置 .rodata 的起始地址 */

    .rodata : {
        *(.rodata)
    }

    .data : {
        *(.data)
    }

    .bss : {
        *(.bss COMMON)
    }

    /DISCARD/ : {
        *(.comment)
        *(.note.*)
    }
}