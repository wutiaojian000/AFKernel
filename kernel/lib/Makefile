AS = nasm
SRC = $(wildcard *.S)
OBJ = $(SRC:.S=.o)
ASFLAGS = -f elf
OUTPUT_DIR = ../../out/lib/

lib: $(OBJ)
	mv *.o $(OUTPUT_DIR)

%.o: %.S
	@mkdir -p $(OUTPUT_DIR)
	$(AS) $(ASFLAGS) $< -o $@

.PHONY: lib clean
clean:
	rm -f ../../out/lib/$(OBJ)
