#include "interrupt.h"
#include "stdint.h"
#include "global.h"
#include "io.h"
#include "pic_config.h"

#define IDT_DESC_CNT 0x21   //当前支持的中断数

struct gate_desc
{
    uint16_t    func_offset_low_word;
    uint16_t    selector;
    uint8_t     dcount;     //没用到
    uint8_t     attribute;
    uint16_t    func_offset_high_word;
};

static void make_idt_desc(struct gate_desc *p_gdesc, uint8_t attr, intr_handler function);
static struct gate_desc idt[IDT_DESC_CNT];

extern intr_handler intr_entry_table[IDT_DESC_CNT];//定义在kernel的intr_entry_table数组
char *intr_name[IDT_DESC_CNT];//记录异常的名字
intr_handler idt_table[IDT_DESC_CNT];

//通用的中断处理函数
static void general_inrt_handler(uint8_t vec_nr)
{
    if(vec_nr == 0x27 || vec_nr == 0x2f)
    {
        //IRQ7和IRQ15会产生伪中断，不用处理
        return;
    }
    put_str("int vector: 0x");
    put_int(vec_nr);
    put_char('\n');
}

static void exception_init(void)
{
    int i;
    for(i = 0; i < IDT_DESC_CNT; ++i)
    {
        idt_table[i] = general_inrt_handler;
        intr_name[i] = "unknown";
    }
    intr_name[0] = "#DE Devide error";
    intr_name[1] = "#DB Debug Exception";
    intr_name[2] = "#NMI Interrupt";
    intr_name[3] = "#BP Breakpoint Exception";
    intr_name[4] = "#OF Overflow Exception";
    intr_name[5] = "#BR Bound Range Exceeded Exception";
    intr_name[6] = "#UD Invalid Opcode Exception";
    intr_name[7] = "#NM Device Not Available Exception";
    intr_name[8] = "#DF Double Fault Exception";
    intr_name[9] = "#Coprocessor Segment Fault";
    intr_name[10] = "#TS Invaild TSS Exception";
    intr_name[11] = "#NP Segment Not Present";
    intr_name[12] = "#SS Stack Fault Exception";
    intr_name[13] = "#GP General Protection Exception";
    intr_name[14] = "#PF Page-Fault Exception";
    //intr_name[15] = "#DE Devide error";
    intr_name[16] = "#MF x87 FPU Floating-Point Error";
    intr_name[17] = "#AC Alignment Check Exception";
    intr_name[18] = "#MC Machine-Check Exception";
    intr_name[19] = "#XF SIMD Floating-Point Exception";
}

//创建中断门描述符
static void make_idt_desc(struct gate_desc *p_gdesc, uint8_t attr, intr_handler function)
{
    p_gdesc->func_offset_low_word = (uint32_t)function & 0x0000ffff;
    p_gdesc->selector = SELECTOR_K_CODE;
    p_gdesc->attribute = attr;
    p_gdesc->func_offset_high_word = ((uint32_t)function & 0xffff0000) >> 16;
}

//初始化中断描述符表
static void idt_desc_init(void)
{
    int i;
    for(i = 0; i < IDT_DESC_CNT; ++i)
    {
        make_idt_desc(&idt[i], IDT_DESC_ATTR_DPL0, intr_entry_table[i]);
    }
    put_str("idt_desc_init done.\n");
}

//完成中断初始化的相关工作
void idt_init()
{
    put_str("idt_init start.\n");
    idt_desc_init();
    exception_init();//初始化异常名并注册通用异常处理函数
    pic_init(); //初始化PIC

    uint64_t idt_operand = (sizeof(idt) - 1) | ((uint64_t)(uint32_t)idt << 16);//基址+界限
    asm("lidt %0;"::"m"(idt_operand));
    put_str("idt_init done.\n");

}

