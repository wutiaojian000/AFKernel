CC = gcc
LD = ld
CFLAGS_GENER = -Wall -m32
CFLAGS_ARCH = -m elf_i386
CFLAGS_TEXT = -Ttext 0xc0001500 
CFLAGS_RODATA = --section-start .rodata=0xc0002000 
CFLAGS_ENTRY = -e main
SOURCE_DIR = ./
SOURCE_LIB = ../../lib/
INCLUDE_DIR = ../../include/
OUTPUT_DIR = ../../../out/kernel/
OUTPUT_LIB = ../../../out/lib/

SOURCES = $(wildcard $(SOURCE_DIR)*.c)
INCLUDE = -I$(INCLUDE_DIR)
INCLUDE += -I$(SOURCE_LIB)
OBJ = $(patsubst %.c, %.o, $(SOURCES))
TARGET = main

kernel: $(TARGET)

$(TARGET):$(OBJ)
	$(LD) $(CFLAGS_ARCH) $(CFLAGS_TEXT) $(CFLAGS_RODATA) $(CFLAGS_ENTRY) $(OUTPUT_DIR)*.o $(OUTPUT_LIB)*.o -o $(OUTPUT_DIR)kernel.bin
	dd if=$(OUTPUT_DIR)kernel.bin of=../../../hd60M.img bs=512 count=200 seek=9 conv=notrunc


%.o:%.c
	@mkdir -p $(OUTPUT_DIR)
	$(CC) $(INCLUDE) $(CFLAGS_GENER) -c $< -o $@
	@mv $@ $(OUTPUT_DIR)

.PHONY: kernel clean
clean:
	@echo "clean..."
	rm -f $(OUTPUT_DIR)