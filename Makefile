#Variable to hold all x86_64 source files.
x86_64_asm_source_files := $(shell find src/impl/x86_64 -name *.asm)

#When compiling, each asm source file to object file, list of all object files.
x86_64_asm_object_files := $(patsubst src/impl/x86_64/%.asm, build/x86_64/%.o, $(x86_64_asm_source_files))

#Define what commands need to run to build one of obj files from src files
#Only recompile when src file changes
$(x86_64_asm_object_files): build/x86_64/%.o : src/impl/x86_64/%.asm
#Make sure there is a directory to hold compiled file
#Nasm to compile assembly code
	mkdir -p $(dir $@) && \
	nasm -f elf64 $(patsubst build/x86_64/%.o, src/impl/x86_64/%.asm, $@) -o $@

.PHONY: build-x86_64 #Only run if object files have changed.
build-x86_64: $(x86_64_asm_object_files)
#Final iso file in dist/x86_64
#Use linker command to link object files
	mkdir -p dist/x86_64 && \
	x86_64-elf-ld -n -o dist/x86_64/kernel.bin -T targets/x86_64/linker.ld $(x86_64_asm_object_files) && \
	cp dist/x86_64/kernel.bin targets/x86_64/iso/boot/kernel.bin && \
	grub-mkrescue /usr/lib/grub/i386-pc -o dist/x86_64/kernel.iso targets/x86_64/iso
#Copy kernel.bin from dist folder into boot folder
#Generate iso file using grub
