LOADER_BASE_ADDR equ 0x900
LOADER_START_SECTOR equ 0x2

KERNEL_ENTRY_POINT equ 0xc0001500
KERNEL_BIN_BASE_ADDR equ 0x70000
KERNEL_START_SECTOR equ 0x9

;gdt描述符属性
DESC_G_4K  equ          1_00000000000000000000000b  ;下划线没有特别意义
DESC_D_32  equ          1_0000000000000000000000b
DESC_L  equ             0_000000000000000000000b
DESC_AVL  equ           0_00000000000000000000b
DESC_LIMIT_CODE2  equ   1111_0000000000000000b
DESC_LIMIT_DATA2  equ   DESC_LIMIT_CODE2
DESC_LIMIT_VIDEO2 equ   0000_0000000000000000b
DESC_P equ              1_000000000000000b
DESC_DPL_0  equ         00_0000000000000b
DESC_DPL_1  equ         01_0000000000000b
DESC_DPL_2  equ         10_0000000000000b
DESC_DPL_3  equ         11_0000000000000b
DESC_S_CODE equ         1_000000000000b
DESC_S_DATA equ         DESC_S_CODE
DESC_S_sys  equ         0_000000000000b
DESC_TYPE_CODE  equ     1000_00000000b;x=1 c=0 r=0 a=0 可执行非一致不可读，已访问位a清0
DESC_TYPE_DATA  equ     0010_00000000b;x=0 e=0 w=1 a=0 不可执行向上扩展可写，已访问位a清0

DESC_CODE_HIGH4 equ     (0x00 << 24) + DESC_G_4K + DESC_D_32 + \
DESC_L + DESC_AVL + DESC_LIMIT_CODE2 + \
DESC_P + DESC_DPL_0 + DESC_S_CODE + \
DESC_TYPE_CODE + 0x00
 
DESC_DATA_HIGH4 equ     (0x00 << 24) + DESC_G_4K + DESC_D_32 + \
DESC_L + DESC_AVL + DESC_LIMIT_DATA2 + \
DESC_P + DESC_DPL_0 + DESC_S_DATA + \
DESC_TYPE_DATA + 0x00
 
DESC_VIDEO_HIGH4 equ     (0x00 << 24) + DESC_G_4K + DESC_D_32 + \
DESC_L + DESC_AVL + DESC_LIMIT_VIDEO2 + \
DESC_P + DESC_DPL_0 + DESC_S_DATA + \
DESC_TYPE_DATA + 0x0b
 
;选择子属性
RPL0  equ  00b
RPL1  equ  01b
RPL2  equ  10b
RPL3  equ  11b
TI_GDT  equ  000b
TI_LDT  equ  100b

;分页属性
PAGE_DIR_TABLE_POS equ 0x100000

PG_P equ 1b
PG_RW_R equ 00b
PG_RW_W equ 10b
PG_US_S equ 000b
PG_US_U equ 100b

;elf属性
PT_NULL equ 00b
