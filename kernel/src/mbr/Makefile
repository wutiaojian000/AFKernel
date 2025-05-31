SRC = mbr.S
OBJ = $(SRC:.S=.o)
TARGET = mbr.bin

mbr: $(TARGET)

# $(TARGET): $(OBJ)
# 	@mkdir -p ../../out/mbr
# 	ld $^ -o ../../out/mbr/mbr.elf
# 	# objcopy -O binary ../../out/mbr/mbr.elf ../../	out/$(TARGET)

%.bin: %.S
	@mkdir -p ../../../out/mbr
	nasm -I ../../include/ $< -o $@
	mv $@ ../../../out/mbr/
	dd if=../../../out/mbr/mbr.bin of=../../../../hd60M.img bs=512 count=1 conv=notrunc

.PHONY: mbr clean
clean:
	rm -f $(OBJ)
