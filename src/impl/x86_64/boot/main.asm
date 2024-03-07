; global to access when linking
global start

; code section
section .text ; 32 bit mode
bits 32
start:
    ; Store address of top of stack into register, currently no frames on the stack
    mov esp, stack_top

    ; Check if loadaed into multiboot 
    call check_multiboot
    ; CPU instruction, for cpu information
    call check_cpuid
    ; CPU ID to check for long mode support
    call check_long_mode

	; print `OK`
    ; Write to video memory, cpu hooks text up to screen
    ; Move data into video memory
    ; halt, cpu will freeze and not run any further
	mov dword [0xb8000], 0x2f4b2f4f
	hlt

;Check multiboot subroutine
check_multiboot:
    ; Check if eax register holds magic value
    cmp eax, 0x36d76289
    ; Jump not equal instruction to jump to no multiboot section if comparison fails
    jne .no_multiboot
    ; otherwise return from subroutine
    ret
.no_multiboot:
    ; If the case, jump and display error
    mov al, "M"
    jmp error

check_cpuid:
    ; pushing flag register on the stack
    pushfd
    ; popping off stack into eax register
    pop eax
    ; move into exc register to check later
    mov ecx, eax
    ; xor to flip a bit on eax register, flipping id bit (21)
    xor eax, 1 << 21
    ; Copy flag register by pushing itback to the stack
    push eax
    ; Pop it into flag register 
    popfd
    ; Copy it back into eax register
    pushfd
    pop eax
    ; Back into flag register
    push exc
    popfd
    ; Check if flipped bit
    cmp eax, ecx
    ; Jump to no cpu id label
    je .no_cupid
    ret
.no_cupid:
    mov al, "C"
    jmp error

check_long_mode:
    ; MAgic number
    mov eax, 0x80000000

error:
    ; print "ERR: X" where X is the error code
    mov dword [0xb8000], 0x4f524f45
    mov dword [0xb8004], 0x4f3a4f52
    mov dword [0xb8008], 0x4f204f20
    mov dword [0xb800a], al
    hlt

; bss section contains statically allocated variables. Memory reserved when bootloader loads kernel. CPU uses ESP register to determine address of current stack frame (stack pointer)
section .bss
stack_bottom:
    ;Reserve 16KB of memory for stack space
    resb 4096 * 4
stack_top:
