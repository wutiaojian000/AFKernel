PROJECT_ROOT_PATH = /home/zcm/AFVM/
VERSION = 1.0.0

all: mbr loader lib kernel

mbr:
	$(MAKE) -C kernel/src/mbr

loader:
	$(MAKE) -C kernel/src/loader

lib:
	$(MAKE) -C kernel/lib

kernel:
	$(MAKE) -C kernel/src/kernel

#include kernel/src/loader/Makefile loader kernel
#include kernel/src/kernel/Makefile

.PHONY: mbr loader lib kernel clean
clean:
	@echo "clean..."
	rm -rf $(OBJ) $(TARGET) out

# # mbr
# SOURCE_DIR = ./kernel/src/mbr
# INCLUDE_DIR = ./kernel/include/

# AS = nasm
# CC = gcc
# LD = ld
# SOURCES = $(wildcard $(SOURCE_DIR)/*.S)
# INCLUDE = -I $(INCLUDE_DIR)
# OBJ = $(patsubst %.S, %.o, $(SOURCES))
# TARGET = mbr.bin

# $(TARGET):$(OBJ)
# 	@mkdir -p output
# 	$(LD) $(OBJ) -o out/mbr/$(TARGET).$(VERSION)
# 	@rm -rf $(OBJ)

# %.o:%.S
# 	$(AS) $(INCLUDE) $< -o $@

# # loader
# SOURCE_DIR = ./kernel/src/loader
# INCLUDE_DIR = ./kernel/include/

# AS = nasm
# CC = gcc
# SOURCES = $(wildcard $(SOURCE_DIR)/*.S)
# INCLUDE = -I $(INCLUDE_DIR)
# OBJ = $(patsubst %.S, %.o, $(SOURCES))
# TARGET = loader.bin

# $(TARGET):$(OBJ)
# 	@mkdir -p output
# 	$(CC) $(OBJ) -o output/loader/$(TARGET).$(VERSION)
# 	@rm -rf $(OBJ)

# %.o:%.S
# 	$(AS) $(INCLUDE) $< -o $@

# # kernel
# SOURCE_DIR = ./kernel/src/kernel/
# INCLUDE_DIR = ./kernel/include/

# CC = gcc
# CFLAGS_GENER = -Wall -m32
# CFLAGS_ARCH = -m elf_i386
# CFLAGS_TEXT = -Ttext 0xc0001500 
# CFLAGS_RODATA = --section-start .rodata=0xc0002000 
# CFLAGS_ENTRY = -e main
# SOURCES = $(wildcard $(SOURCE_DIR)/*.c)
# INCLUDE = -I$(INCLUDE_DIR)
# OBJ = $(patsubst %.c, %.o, $(SOURCES))
# TARGET = main

# $(TARGET):$(OBJ)
# 	@mkdir -p out
# 	$(CC) $(CFLAGS_GENER) $(CFLAGS_ARCH) $(CFLAGS_TEXT) $(CFLAGS_RODATA) $(CFLAGS_ENTRY) $(OBJ) -o output/$(TARGET).$(VERSION)
# 	@rm -rf $(OBJ)

# %.o:%.c
# 	$(CC) $(INCLUDE) -c $(CFLAGS) $< -o $@

# .PHONY: clean
# clean:
# 	@echo "clean..."
# 	rm -rf $(OBJ) $(TARGET) output

