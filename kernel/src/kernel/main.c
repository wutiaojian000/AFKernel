#include "print.h"
#include "init.h"

void main(void) __attribute__((section(".text.start")));

void main(void)
{
    // put_str("kernel.\n");
    // put_int(0);
    // put_char('\n');
    // put_int(9);
    // put_char('\n');
    // put_int(0x00021a3f);
    // put_char('\n');
    //put_int(0x12345678);
    //put_char('\n');
    //put_int(0x00000000);
    init_all();
    asm volatile("sti");//打开中断
    while(1);
}