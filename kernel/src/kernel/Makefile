CC = gcc
AS = nasm
LD = ld
ASFLAGS = -f elf
CFLAGS_GENER = -Wall -m32 -fno-stack-protector
# 需要关闭栈保护，glib或一些别的库里才有
CFLAGS_ARCH = -m elf_i386
CFLAGS_TEXT = -Ttext 0xc0001500 
CFLAGS_RODATA = --section-start .rodata=0xc0002000 
CFLAGS_ENTRY = -e main
CFLAGS_LD_TEXT = -T link.ld
SOURCE_DIR = ./
SOURCE_LIB = ../../lib/
INCLUDE_DIR = ../../include/
INCLUDE_PIC_DIR = ../../include/PIC/
OUTPUT_DIR = ../../../out/kernel/
OUTPUT_LIB = ../../../out/lib/

SOURCES = $(wildcard $(SOURCE_DIR)*.c)
INCLUDE = -I$(INCLUDE_DIR)
INCLUDE += -I$(INCLUDE_PIC_DIR)
INCLUDE += -I$(SOURCE_LIB)
OBJ = $(patsubst %.c, %.o, $(SOURCES))
TARGET = main

kernel: $(TARGET)

$(TARGET):KERNEL_S PIC $(OBJ)
	$(LD) $(CFLAGS_ARCH) $(CFLAGS_TEXT) $(CFLAGS_RODATA) $(CFLAGS_ENTRY) $(CFLAGS_LD_TEXT) $(OUTPUT_DIR)*.o $(OUTPUT_LIB)*.o -o $(OUTPUT_DIR)main.bin
	dd if=$(OUTPUT_DIR)main.bin of=../../../hd60M.img bs=512 count=200 seek=9 conv=notrunc


%.o:%.c 
	@mkdir -p $(OUTPUT_DIR)
	$(CC) $(INCLUDE) $(CFLAGS_GENER) -c $< -o $@
	@mv $@ $(OUTPUT_DIR)

PIC:
	$(MAKE) -C PIC/

KERNEL_S:
	@mkdir -p $(OUTPUT_DIR)
	$(AS) $(ASFLAGS) Kernel.S -o Kernel.o
	@mv Kernel.o $(OUTPUT_DIR)

.PHONY: kernel PIC KERNEL_S