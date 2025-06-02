#include "8259A_ctrl.h"
#include "io.h"
#include "print.h"

#define PIC_M_CTRL 0x20 //主片控制端口
#define PIC_M_DATA 0x21 //主片数据端口
#define PIC_S_CTRL 0xA0 //从片控制端口
#define PIC_S_DATA 0xA1 //从片控制端口

//中断控制器初始化
void pic_init(void)
{
    //初始化主片
    outb(PIC_M_CTRL, 0x11);//边沿触发 级联 需要ICW4
    outb(PIC_M_DATA, 0x20);//起始向量号为0x20 可屏蔽中断的向量号是32往上的部分
    outb(PIC_M_DATA, 0x04);//IRQ2接从片
    outb(PIC_M_DATA, 0x01);//正常EOI

    //初始化从片
    outb(PIC_S_CTRL, 0x11);//边沿触发 级联 需要ICW4
    outb(PIC_S_DATA, 0x28);//主片的向量号是0x20-0x27 则从片起始向量号为0x28 
    outb(PIC_S_DATA, 0x02);//注意这里只有低三位有效，表示主片IRQ2接从片
    outb(PIC_S_DATA, 0x01);//正常EOI

    //打开时钟中断
    outb(PIC_M_DATA, 0xfe);//表示主片的IRQ0不被屏蔽
    outb(PIC_S_DATA, 0xff);//表示从片所有的IRQ0被屏蔽

    put_str("pic_init done.\n");
}
