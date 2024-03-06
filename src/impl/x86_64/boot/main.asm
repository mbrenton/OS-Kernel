; global to access when linking
global start

; code section
section .text
; 32 bit mode
bits 32
start:
	; print `OK`
    ; Write to video memory, cpu hooks text up to screen
    ; Move data into video memory
    ; halt, cpu will freeze and not run any further
	mov dword [0xb8000], 0x2f4b2f4f
	hlt
