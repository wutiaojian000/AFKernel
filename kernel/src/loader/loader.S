%include "boot.inc"
section loader vstart=LOADER_BASE_ADDR
LOADER_STACK_TOP equ LOADER_BASE_ADDR
jmp loader_start
 
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
 
;gdt指针 前两字节是GDT界限，后四个字节是GDT基址 这里还是实模式下，dw是16位
gdt_ptr  dw  GDT_LIMIT
         dd  GDT_BASE
loadermsg  db  '2 loader in real'





loader_start:
  mov  sp,  LOADER_BASE_ADDR
  mov  bp,  loadermsg
  mov  cx,  17
  mov  ax,  0x1301
  mov  bx,  0x001f
  mov  dx,  0x1800
  int  0x10
 
;准备进入保护模式
;1.打开A20
;2.加载gdt
;3.cr0的pe为置1
  in  al, 0x92
  or  al, 0000_0010b
  out 0x92, al
 
  lgdt  [gdt_ptr]
 
  mov  eax, cr0
  or  eax, 0x00000001
  mov  cr0, eax
 
  jmp  dword  SELECTOR_CODE:p_mode_start  ;刷新流水线
 
[bits 32]
p_mode_start:
  mov  ax, SELECTOR_DATA
  mov  ds, ax
  mov  es, ax
  mov  ss, ax
  mov  esp, LOADER_STACK_TOP
  mov  ax, SELECTOR_VIDEO
  mov  gs, ax
 
  mov byte [gs:160], 'P'  ;第二行打印字符'P'，一行是80个字符





mov eax, KERNEL_START_SECTOR
mov ebx, KERNEL_BIN_BASE_ADDR

mov ecx, 200
;从硬盘中读取内核文件到缓冲区
call rd_disk_m_32
 




;创建页目录表并初始化页内存位图
call setup_page
 
;将描述符表地址及偏移量写入内存gdt_ptr
sgdt [gdt_ptr]
 
;将gdt描述符中的视频段描述符段基址+0xc0000000
mov ebx, [gdt_ptr + 2]
or dword [ebx + 0x18 + 4], 0xc0000000  ;0x18是第4条段描述符，4字节处是段基址高8位
;gdt基址加上0xc0000000，使其成为内核所在的高地址
add dword [gdt_ptr + 2], 0xc0000000
 
add esp, 0xc0000000;栈指针也映射到内核地址
 
;把页目录地址赋给cr3
mov eax, PAGE_DIR_TABLE_POS
mov cr3, eax
 
;打开cr3的pg位
mov eax, cr0
or eax, 0x80000000
mov cr0, eax
 
;开启分页后，用gdt新的地址重新加载
lgdt [gdt_ptr]
 
mov byte [gs:320], 'V'

jmp SELECTOR_CODE:enter_kernel
enter_kernel:
  call kernel_init
  mov esp, 0xc009f000
  jmp KERNEL_ENTRY_POINT 





rd_disk_m_32:
  mov esi, eax    ;备份eax
  mov di, cx      ;备份cx
;读写硬盘
;设置读取的扇区数
  mov dx, 0x1f2
  mov al, cl
  out dx, al      ;读取的扇区数
 
  mov eax, esi    ;恢复eax
 
;存入LBA地址
  ;写入端口0x1f3
  mov dx, 0x1f3
  out dx, al
 
  ;写入端口0x1f4
  mov cl, 8
  shr eax, cl
  mov dx, 0x1f4
  out dx, al
 
  ;写入端口0x1f5
  shr eax, cl
  mov dx, 0x1f5
  out dx, al
 
  ;写入端口0x1f6
  shr eax, cl
  and al, 0x0f
  or al, 0xe0    ;7-4位为1110
  mov dx, 0x1f6
  out dx, al
 
  ;写入端口0x1f7读命令
  mov dx, 0x1f7
  mov al, 0x20
  out dx, al
 
  ;检测硬盘状态
.not_ready:
  nop
  in al, dx
  and al, 0x88    ;第4位为1代表准备好传输
  cmp al, 0x08
  jnz .not_ready
 
  ;从0x1f0读取数据
  mov ax, di      ;待读取的扇区数
  mov dx, 256
  mul dx          ;mul的被乘数放ax里，结果也放ax里，这里因为是按字读的，16位，所以是读256次
  mov cx, ax
 
  mov dx, 0x1f0
.go_on_read:
  in ax, dx
  mov [ebx], ax
  add ebx, 2
  loop .go_on_read  ;用cx来计数
  ret               ;返回到函数调用处





setup_page:
;先把页目录占用空间清0
  mov ecx, 4096
  mov esi, 0
.clear_page_dir:
  mov byte [PAGE_DIR_TABLE_POS + esi], 0
  inc esi
  loop .clear_page_dir
 
;创建页目录表项
.create_pde:
  mov eax, PAGE_DIR_TABLE_POS
  add eax, 0x1000
  mov ebx, eax
 
;下面将目录项0和0xc00都存成第一个页表的地址
;对应0-0xc03fffff和0-0xc00fffff对应的地址都指向相同的页表
;为将地址映射为内核地址做准备
  or eax, PG_US_U | PG_RW_W | PG_P
  ;用户属性所有特权都可以访问 可读可写 在内存中存在
  mov [PAGE_DIR_TABLE_POS + 0x0], eax
  mov [PAGE_DIR_TABLE_POS + 0xc00], eax ;0xc00以上对应内核空间页表 0xc0000000-0xffffffff
 
  sub eax, 0x1000
  mov [PAGE_DIR_TABLE_POS + 4092], eax  ;页目录表项最后一项放页目录表自己的地址
 
  ;创建页表项
  mov ecx, 256  ;1MB低端内存，1MB/4KB=256
  mov esi, 0
  mov edx, PG_US_U | PG_RW_W | PG_P

.create_pte:
  mov [ebx + esi * 4], edx  ;  ebx是第一个页表的地址
  add edx, 4096
  inc esi
  loop .create_pte
 
  ;创建内核其他页表的PDE
  mov eax, PAGE_DIR_TABLE_POS
  add eax, 0x2000            ;第二个页表的位置
  or eax, PG_US_U | PG_RW_W | PG_P
  mov ebx, PAGE_DIR_TABLE_POS
  mov ecx, 254
  mov esi, 769    ;768目录项写过了
.create_kernel_pde:
  mov [ebx + esi * 4], eax
  inc esi
  add eax, 0x1000
  loop .create_kernel_pde
  ret





;将kernel中的段搬到对应位置
kernel_init:
  xor eax, eax
  xor ebx, ebx
  xor ecx, ecx
  xor edx, edx
 
  mov dx, [KERNEL_BIN_BASE_ADDR + 42];42偏移处是e_phentsize，program header大小
  mov ebx, [KERNEL_BIN_BASE_ADDR + 28];42偏移处是e_phoff，第一个program header在文件中的偏移
 
  add ebx, KERNEL_BIN_BASE_ADDR
  mov cx, [KERNEL_BIN_BASE_ADDR + 44];有几个program header

.each_segment:
  cmp byte [ebx + 0], PT_NULL
  je .PTNULL

  ;mov eax, [ebx + 24]
  ;and eax, 0x00000001
  ;cmp eax, 0x00000000
  ;je .PTNULL
  ;mov ecx, 0x00000001
 
  ;为函数mem_cpy压入参数 mem_cpy(dst, src, size)
  push dword [ebx + 16]  ;size
  mov eax, [ebx + 4]
  add eax, KERNEL_BIN_BASE_ADDR
  push eax  ;src
  push dword [ebx + 8]
 
  call mem_cpy
  add esp, 12  ;清理压入的三个参数

.PTNULL:
  add ebx, edx
  loop .each_segment
  ret
  




mem_cpy:
  cld
  push ebp
  mov ebp, esp
  push ecx
 
  mov edi, [ebp + 8]  ;dst
  mov esi, [ebp + 12]  ;src
  mov ecx, [ebp + 16]  ;size
  rep movsb  ;主字节拷贝
  
  ;恢复环境
  pop ecx  ;ecx对外层循环loop .each_segment有用
  pop ebp
  ret
