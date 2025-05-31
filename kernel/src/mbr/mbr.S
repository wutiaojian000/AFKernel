%include "boot.inc"
SECTION MBR vstart=0x7c00
  mov ax, cs
  mov ds, ax
  mov es, ax
  mov ss, ax
  mov fs, ax
  mov sp, 0x7c00
  mov ax, 0xb800
  mov gs, ax
 
  mov ax, 0x0600
  mov bx, 0x0700
  mov cx, 0
  mov dx, 0x184f
 
  int 0x10
 
  mov byte [gs:0x00], '1'
  mov byte [gs:0x01], 0xa4
 
  mov byte [gs:0x02], ' '
  mov byte [gs:0x03], 0xa4
 
  mov byte [gs:0x04], 'M'
  mov byte [gs:0x05], 0xa4
 
  mov byte [gs:0x06], 'B'
  mov byte [gs:0x07], 0xa4
 
  mov byte [gs:0x08], 'R'
  mov byte [gs:0x09], 0xa4
 
  mov eax, LOADER_START_SECTOR  ;起始扇区1ba地址
  mov bx, LOADER_BASE_ADDR      ;写入的地址
  mov cx, 4                     ;待读入的扇区数
  call rd_disk__m_16            ;读取程序的起始部分
  
  mov ax, LOADER_BASE_ADDR
  ;add ax, 0x300

  jmp ax
 
;功能读取硬盘的n个扇区
rd_disk__m_16:
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
  mov [bx], ax
  add bx, 2
  loop .go_on_read  ;用cx来计数
  ret               ;返回到函数调用处
  
  times 510-($-$$) db 0
  db 0x55, 0xaa
