CC = gcc
LD = ld
CFLAGS_GENER = -Wall -m32
SOURCE_DIR = ./
SOURCE_LIB = ../../../lib/
INCLUDE_DIR = ../../../include/
INCLUDE_PIC_DIR = ../../../include/PIC
OUTPUT_DIR = ../../../../out/kernel/

SOURCES = $(wildcard $(SOURCE_DIR)*.c)
INCLUDE = -I$(INCLUDE_DIR)
INCLUDE += -I$(INCLUDE_PIC_DIR)
INCLUDE += -I$(SOURCE_LIB)
OBJ = $(patsubst %.c, %.o, $(SOURCES))
TARGET = 8259A_ctrl.o

PIC: $(TARGET)

# $(TARGET):$(OBJ)
# 	$(LD) $(CFLAGS_ARCH) $(CFLAGS_TEXT) $(CFLAGS_RODATA) $(CFLAGS_ENTRY) $(OUTPUT_DIR)*.o $(OUTPUT_LIB)*.o -o $(OUTPUT_DIR)kernel.bin
# 	dd if=$(OUTPUT_DIR)kernel.bin of=../../../hd60M.img bs=512 count=200 seek=9 conv=notrunc


%.o:%.c
	@mkdir -p $(OUTPUT_DIR)
	$(CC) $(INCLUDE) $(CFLAGS_GENER) -c $< -o $@
	@mv $@ $(OUTPUT_DIR)

.PHONY: PIC