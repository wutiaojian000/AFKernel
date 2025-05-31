%include "boot.inc"
section loader vstart=LOADER_BASE_ADDR
LOADER_STACK_TOP equ LOADER_BASE_ADDR
;jmp .loader_start
 
;构建gdt
GDT_BASE:  dd  0x00000000
           dd  0x00000000
CODE_DESC: dd  0x0000FFFF
           dd  DESC_CODE_HIGH4
DATA_STACK_DESC: dd  0x0000FFFF
           dd  DESC_DATA_HIGH4
VIDEO_DESC: dd  0x80000007  ;limit=(0xbffff-0xb8000)/4k=0x7
           dd  DESC_VIDEO_HIGH4
 
GDT_SIZE  equ  $ - GDT_BASE
GDT_LIMIT  equ  GDT_SIZE - 1
times  60  dq  0  ;预留60个描述符的空位
SELECTOR_CODE equ  (0x0001<<3) + TI_GDT + RPL0  ;相当于((CODE_DESC - GDT_BASE) / 8 << 3) + TI_GDT + RPL0 原文这里的注释感觉不对，没有左移
SELECTOR_DATA equ  (0x0002<<3) + TI_GDT + RPL0
SELECTOR_VIDEO equ  (0x0003<<3) + TI_GDT + RPL0
 
total_mem_bytes dd 0  ;记录内存容量 位置为0xb00
 
;gdt指针 前两字节是GDT界限，后四个字节是GDT基址 这里还是实模式下，dw是16位
gdt_ptr  dw  GDT_LIMIT
         dd  GDT_BASE
 
ards_buf times 244 db 0
ards_nr dw 0

loader_start:  ;0xc00
;先是0xe820
  xor ebx, ebx  ;第一次ebx赋值为0
  mov edx, 0x534d4150  ;edx只赋值一次，后面不用动
  mov di, ards_buf  ;缓冲区
.e820_mem_get_loop:
  mov eax, 0x0000e820  ;执行0x15后，eax的值变成0x534d4150
  mov ecx, 20  ;地址范围描述符结构是20字节
  int 0x15
  jc .e820_failed_so_try_e801  ;cf位为1则有错误发生，跳转下一个方法
  add di, cx
  inc word [ards_nr]  ;自增指令
  cmp ebx, 0  ;cf为0且ebx为0则全部返回
  jnz .e820_mem_get_loop
  
 ;找出内存最大的结构，原文这里应该写错了，这里只是简单找出最大值，不是冒泡排序
  mov cx, [ards_nr]
  ;遍历每一个结构
  mov ebx, ards_buf
  xor edx, edx
.find_max_mem_area:
  mov eax, [ebx]
  add eax, [ebx + 8]  ;获取最大内存块，这里好怪，书中这里上一行还加上了基址，但感觉只取length_low就行了
  add ebx, 20
  cmp edx, eax
  jge .next_ards
  mov edx, eax
.next_ards:
  loop .find_max_mem_area  ;ecx为循环次数
  jmp .mem_get_ok
  
;功能号0xe801
.e820_failed_so_try_e801:
  mov ax, 0xe801
  int 0x15
  jc .e801_failed_so_try_88
  
;先算出低15MB内存
  mov cx, 0x400  ;ax现在是内存容量，1KB为单位
  mul cx
  shl edx, 16    ;16MB以上以64KB为单位
  and  eax, 0x0000ffff  ;之前记成mul16位乘法结果存eax，然后这里给我看懵了。mul16位结果存dx:ax。
  or edx, eax
  add edx, 0x100000  ;
  mov esi, edx
;再将16MB以上的内存算出来
  mov ecx, 0x10000
  xor eax, eax
  mov ax, bx
  mul ecx
  add esi, eax  ;只能算出4g的内存
  mov edx, esi
  jmp .mem_get_ok

.e801_failed_so_try_88:
  mov ah, 0x88
  int 0x15
  jc .error_hlt
  and eax, 0x0000ffff
 
  mov cx, 0x400
  mul cx
  shl edx, 16
  or edx, eax
  add edx, 0x100000

.mem_get_ok:
  mov [total_mem_bytes], edx

.error_hlt:
  jmp $ 
