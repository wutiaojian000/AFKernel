SRC = loader.S
OBJ = $(SRC:.S=.o)
TARGET = loader.bin

mbr: $(TARGET)

# $(TARGET): $(OBJ)
# 	@mkdir -p ../../out/mbr
# 	ld $^ -o ../../out/mbr/mbr.elf
# 	# objcopy -O binary ../../out/mbr/mbr.elf ../../	out/$(TARGET)

%.bin: %.S
	@mkdir -p ../../../out/loader
	nasm -I ../../include/ $< -o $@
	@mv $@ ../../../out/loader/
	dd if=../../../out/loader/loader.bin of=../../../../hd60M.img bs=512 count=1 seek=2 conv=notrunc

.PHONY: loader clean
clean:
	rm -f ../../../out/loader/$(OBJ)
