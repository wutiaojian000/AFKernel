#ifndef __KERNEL_PIC_CONFIG_H
#define __KERNEL_PIC_CONFIG_H

#define USE_8259A

#ifdef USE_8259A
    #include "8259A_ctrl.h"
#else
    #error "No PIC selected!"
#endif

#endif