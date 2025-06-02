[bits 32]
%define ERROR_CODE nop  ;相关异常中CPU压入了异常码，这里不做操作
%define ZERO push 0     ;相关异常中CPU没有压入异常码，为了同一栈中格式需要压入0

extern  put_str;

section .data
intr_str db "interrupt occur!\n", 0xa, 0
global intr_entry_table
intr_entry_table:   ;中断服务例程入口地址数组，注意一下数据段和代码段交替定义的方式

%macro VECTOR 2
section .text
intr%1entry:
    %2
    push intr_str
    call put_str
    add esp, 4

    ;如果是从片上发的中断，除了向从片上发EOI，还要向主片上发EOI
    mov al, 0x20
    out 0xa0, al
    out 0x20, al

    add esp, 4  ;跨过error code
    iret        ;从中断返回，32位下等同于iretd

section .data
    dd intr%1entry  ;存放各个中断服务程序的地址

%endmacro

VECTOR 0x00, ZERO
VECTOR 0x01, ZERO
VECTOR 0x02, ZERO
VECTOR 0x03, ZERO
VECTOR 0x04, ZERO
VECTOR 0x05, ZERO
VECTOR 0x06, ZERO
VECTOR 0x07, ZERO
VECTOR 0x08, ZERO
VECTOR 0x09, ZERO
VECTOR 0x0a, ZERO
VECTOR 0x0b, ZERO
VECTOR 0x0c, ZERO
VECTOR 0x0d, ZERO
VECTOR 0x0e, ZERO
VECTOR 0x0f, ZERO
VECTOR 0x10, ZERO
VECTOR 0x11, ZERO
VECTOR 0x12, ZERO
VECTOR 0x13, ZERO
VECTOR 0x14, ZERO
VECTOR 0x15, ZERO
VECTOR 0x16, ZERO
VECTOR 0x17, ZERO
VECTOR 0x18, ZERO
VECTOR 0x19, ZERO
VECTOR 0x1a, ZERO
VECTOR 0x1b, ZERO
VECTOR 0x1c, ZERO
VECTOR 0x1d, ZERO
VECTOR 0x1e, ZERO
VECTOR 0x1f, ZERO
VECTOR 0x20, ZERO