; global to access when linking
global start
extern long_mode_start

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

    ; To set up long mode, have to set up paging (map virtual addresses to physical addresses)
    call setup_page_tables
    call enable_paging

    ;Can load gloabl descripter table
    lgdt [gdt64.pointer]
    jmp gdt64.code_segment:long_mode_start

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
    push ecx
    popfd
    ; Check if flipped bit
    cmp eax, ecx
    ; Jump to no cpu id label
    je .no_cpuid
    ret
.no_cpuid:
    mov al, "C"
    jmp error

check_long_mode:
    ; Magic number
    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000001
    jb .no_long_mode

    mov eax, 0x80000001
    cpuid
    test edx, 1 << 29
    jz .no_long_mode

    ret
.no_long_mode:
    mov al, "L"
    jmp error

setup_page_tables:
    ; Identitiy mapping, map a physical address to the exact same virtual one. Paging done automatically when long mode is enabled.
    mov eax, page_table_l3
    or eax, 0b11 ; present, writable
    mov [page_table_l4], eax

    mov eax, page_table_l2
    or eax, 0b11 ; present, writable
    mov [page_table_l3], eax

    mov ecx, 0 ; counter

.loop:

    mov eax, 0x200000 ; 2MiB
    mul ecx
    or eax, 0b10000011 ; present, writable, huge page
    mov [page_table_l2 + ecx * 8], eax

    inc ecx ; increment counter
    cmp ecx, 512 ; checks if the whole table is mapped
    jne .loop ; if not, continue

    ret

enable_paging:
    ; pass page table location to cpu
    mov eax, page_table_l4
    mov cr3, eax

    ; enable PAE
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ; enable long mode
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1  << 8
    wrmsr

    ; enable paging
    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax
    
    ret

error:
    ; print "ERR: X" where X is the error code
    mov dword [0xb8000], 0x4f524f45
    mov dword [0xb8004], 0x4f3a4f52
    mov dword [0xb8008], 0x4f204f20
    mov byte  [0xb800a], al
    hlt

; bss section contains statically allocated variables. Memory reserved when bootloader loads kernel. CPU uses ESP register to determine address of current stack frame (stack pointer)
section .bss
; align 4KB for page table
align 4096
; Root page table, level 4, dont need a level 1 page table
page_table_l4:
    resb 4096
page_table_l3:
    resb 4096
page_table_l2:
    resb 4096
stack_bottom:
    ;Reserve 16KB of memory for stack space
    resb 4096 * 4
stack_top:

section .rodata
gdt64:
    dq 0 ; zero entry
.code_segment: equ $ - gdt64
    dq (1 << 43) | (1 << 44) | (1 << 47) | (1 << 53) ; code segment
.pointer:
    dw $ - gdt64 - 1
    dq gdt64