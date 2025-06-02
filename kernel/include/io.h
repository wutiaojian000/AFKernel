#ifndef __LIB_IO_H
#define __LIB_IO_H
#include "stdint.h"

//向端口port写入一个字节data
static inline void outb(uint16_t port, uint8_t data)
{
    asm volatile("outb %b0, %w1"::"a"(data), "Nd"(port));//N表示0-255的立即数约束
}

//向端口port写入addr为起始地址word_cnt字节数据
static inline void outsw(uint16_t port, const void *addr, uint32_t word_cnt)
{
    //outsw是把ds:esi处16位写入port端口 +S的意思是把addr约束到esi中
    asm volatile("cld;rep outsw":"+S"(addr), "+c"(word_cnt):"d"(port));//N表示0-255的立即数约束
}

//从端口port读入1字节返回
static inline uint8_t inb(uint16_t port)
{
    uint8_t data;
    asm volatile("inb %w1, %b0":"=a"(data):"Nd"(port) );
    return data;
}

//向端口port读入addr为起始地址word_cnt字节数据
static inline void insw(uint16_t port, const void *addr, uint32_t word_cnt)
{
    //insw是把es:edi处16位写入内存 +D的意思是把addr约束到edi中
    //"memory"是因为es:edi指向的内存被修改
    asm volatile("cld;rep insw":"+D"(addr), "+c"(word_cnt):"d"(port):"memory");
}

#endif