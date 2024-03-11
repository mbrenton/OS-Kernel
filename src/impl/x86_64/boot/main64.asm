global long_mode_start
extern kernel_main

section .text
bits 64
long_mode_start:
    ; load null into all data segment registers
    mov ax, 0
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; print `OK`
    ; Write to video memory, cpu hooks text up to screen
    ; Move data into video memory
    ; halt, cpu will freeze and not run any further
	call kernel_main

    hlt
