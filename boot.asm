; Simple Operating System Bootloader
; This is an MBR (Master Boot Record) bootloader

[org 0x7c00]
[bits 16]

start:
    ; Initialize segment registers
    mov ax, 0
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    
    ; Clear screen
    mov ax, 0x0003
    int 0x10
    
    ; Print startup message
    mov si, msg
    call print_string
    
    ; Load kernel from disk
    call load_kernel
    
    ; Jump to kernel
    jmp 0x1000

load_kernel:
    ; Load kernel.bin from sector 2 (and following) to memory at physical address 0x1000
    mov ah, 0x02        ; BIOS read sectors
    mov al, 8           ; Number of sectors to read (adjust if kernel larger)
    mov ch, 0           ; Cylinder
    mov cl, 2           ; Sector (1-based, sector 2)
    mov dh, 0           ; Head
    mov dl, 0           ; Drive (floppy 0)
    xor ax, ax
    mov es, ax          ; ES:BX = 0x0000:0x1000
    mov bx, 0x1000      ; Buffer offset
    int 0x13
    jc load_error       ; Jump if error
    ret

; Enable A20 using fast method (port 0x92)
enable_a20:
    in al, 0x92
    or al, 2
    out 0x92, al
    ret

; GDT for protected mode switch
gdt_start:
    dq 0
    ; Code segment descriptor: base=0, limit=4GB (granularity), exec/read
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10011010b
    db 11001111b
    db 0x00
    ; Data segment descriptor: base=0, limit=4GB, read/write
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00
gdt_end:

gdtr:
    dw gdt_end - gdt_start - 1
    dd gdt_start

; Switch to protected mode and jump to 32-bit kernel at 0x1000
switch_to_protected:
    call enable_a20
    cli
    lgdt [gdtr]
    ; Set PE bit in CR0
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    ; Far jump to protected mode entry at linear address 0x1000
    push word 0x1000
    push word 0x08
    retf

load_error:
    mov si, load_err_msg
    call print_string
    jmp $

; Message string
msg db 'cos build by GitHub Copilot', 13, 10, 0
load_err_msg db 'Kernel load error!', 13, 10, 0

; Print string function
print_string:
    lodsb
    or al, al
    jz done
    mov ah, 0x0e
    int 0x10
    jmp print_string
done:
    ret

kernel_start:
    ; Infinite loop - system is running
    jmp kernel_start


; Pad to 510 bytes, last two bytes are boot signature
times (510 - ($ - $$)) db 0
dw 0xaa55
