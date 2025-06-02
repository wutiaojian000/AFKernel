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
    pic_init(); //初始化PIC

    uint64_t idt_operand = (sizeof(idt) - 1) | ((uint64_t)(uint32_t)idt << 16);//基址+界限
    asm("lidt %0;"::"m"(idt_operand));
    put_str("idt_init done.\n");

}

