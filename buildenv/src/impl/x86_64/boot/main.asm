; global to access when linking
global start

; code section
section .text
; 32 bit mode
bits 32
start:
; print 'OK'
; Write to video memory, cpu hooks text up to screen
    mv dword [0xb8000], 0x2f4b2f4f ; Move data into video memory
    hlt ; halt, cpu will freeze and not run any further