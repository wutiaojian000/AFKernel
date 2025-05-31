TI_GDT equ 0
RPL0 equ 0
SELECTOR_VIDEO equ (0x0003<<3) + TI_GDT + RPL0

put_int_buffer dq 0



[bits 32]
section .text
global put_int
put_int:
  pushad
  mov ebp, esp
  mov eax, [ebp + 4 * 9]  ;call的返回地址占4字节+pushad的8个4字节
  mov edx, eax
  mov edi, 7  ;put_int_buffer中初始的偏移量
  mov ecx, 8  ;32位数字中有8个16进制数
  mov ebx, put_int_buffer
.16based_4bits:
  and edx, 0x0000000f
 
  cmp edx, 9
  jg .is_A2F
  add edx, '0'
  jmp .store
.is_A2F:
  sub edx, 10
  add edx, 'A'
.store:
  mov [ebx + edi], dl
  dec edi
  shr eax, 4
  mov edx, eax
  loop .16based_4bits
 
;把高位的0给去掉
.ready_print:
  inc edi  ;edi变成0xffffffff了，加上1变成0
.skip_prefix_0:
  cmp edi, 8
  je .full0
.go_on_skip:
  mov cl, [put_int_buffer + edi]
  inc edi
  cmp  cl, '0'
  je .skip_prefix_0
  dec edi
  jmp .put_each_num
.full0:
  mov cl, '0'
.put_each_num:
  push ecx
  call put_char
  add esp, 4
  inc edi
  mov cl, [put_int_buffer + edi]
  cmp edi, 8
  jl .put_each_num
  popad
  ret

global put_str
put_str:
  push ebx
  push ecx
  xor ecx, ecx
  mov ebx, [esp + 12]
.goon:
  mov cl, [ebx]
  cmp cl, 0
  jz .str_over
  push ecx
  call put_char
  add esp, 4
  inc ebx
  jmp .goon
.str_over:
  pop ecx
  pop ebx
  ret
 
global put_char
put_char:
  pushad  ;将通用寄存器压栈
  mov ax, SELECTOR_VIDEO
  mov gs, ax  ;不能直接为段寄存器赋值
 
  ;获取光标当前位置
  mov dx, 0x03d4  ;索引寄存器
  mov al, 0x0e  ;用于提供光标位置的高8位
  out dx, al
  mov dx, 0x03d5  ;通过读写数据端口0x3d5来获得或设置光标的位置
  in al, dx  ;得到光标位置的高8位
  mov ah, al
 
  ;获取低8位
  mov dx, 0x03d4  ;索引寄存器
  mov al, 0x0f  ;用于提供光标位置的低8位
  out dx, al
  mov dx, 0x03d5  ;通过读写数据端口0x3d5来获得或设置光标的位置
  in al, dx  ;得到光标位置的低8位
  
  ;将光标存入bx
  mov bx, ax
  ;在栈中获取待打印的字符
  mov ecx, [esp + 36]  ;前面压入了8个通用寄存器和返回地址
  cmp cl, 0xd
  jz .is_carriage_return
  cmp cl, 0xa
  jz .is_line_feed
  
  cmp cl, 0x8  ;回车的ascii码
  jz .is_backspace
  jmp .put_other

.is_backspace:
  dec bx
  shl bx, 1  ;光标实际位置是下标*2
 
  mov byte [gs:bx], 0x20  ;将删除的字节补为空格
  inc bx
  mov byte [gs:bx], 0x07
  shr bx, 1
  jmp .set_cursor

.put_other:
  shl bx, 1
  mov [gs:bx], cl  ;ascii码本身
  inc bx
  mov byte [gs:bx], 0x07
  shr bx, 1
  inc bx
  cmp bx, 4000
  jl .set_cursor  ;如果光标值小于2000，表示没有写到显存的最后，则设置新的光标值；若超出则换行处理

.is_line_feed:
.is_carriage_return:
  ;如果是CR（\r），只要把光标移到行首即可
  xor dx, dx  ;dx是被除数的高16位
  mov ax, bx  ;ax是被除数的低16位
  mov si, 0x80
  
  div si  
 
  sub bx, dx  ;光标值减去除80的余数就是取整

.is_carriage_return_end:
  add bx, 80
  cmp bx, 80
.is_line_feed_end:
  jl .set_cursor
  
.roll_screen:
  cld
  mov ecx, 960
  
  mov esi, 0xc00b80a0  ;第1行
  mov edi, 0xc00b8000  ;第0行
  rep movsd
 
;将最后一行填充为空白
  mov ebx, 3840
  mov ecx, 80

.cls:
  mov word [gs:ebx], 0x0720  ;空格键
  add ebx, 2
  loop .cls
  mov bx, 1920  ;重设置为最后一行的首字符

.set_cursor:
;将光标设置为ebx 设置高8位
  mov dx, 0x03d4
  mov al, 0x0e
  out dx, al
  mov dx, 0x03d5
  mov al, bh
  out dx, al
 
;在设置低8位
  mov dx, 0x03d4
  mov al, 0x0f
  out dx, al
  mov dx, 0x03d5
  mov al, bl
  out dx, al

.put_char_done:
  popad
  ret
  
