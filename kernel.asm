; Simple Operating System Kernel
; This file contains basic kernel functionalities

[bits 16]
[org 0x1000]

global _start

_start:
    ; This is the kernel entry point
    ; Boot code will jump here
    jmp kernel_main

; Kernel main function
kernel_main:
    cli                      ; disable interrupts while we setup stack
    
    ; Set up a safe stack (avoid overlapping boot sector area)
    xor ax, ax
    mov ss, ax
    mov sp, 0x8000

    mov ax, cs
    mov ds, ax
    mov es, ax

    ; Initialize Interrupt Descriptor Table
    call init_idt

    ; Initialize memory management
    call init_memory

    ; Enable interrupts
    sti
    
    ; Start command line interface
    call command_line

; Initialize IDT (Interrupt Descriptor Table)
init_idt:
    ; IDT setup should be here, but we skip it in simple version
    ret

; Initialize memory management
init_memory:
    ; Memory manager initialization should be here
    ret

; Command line interface
command_line:
    ; Display prompt
    mov si, prompt
    call print_string
    
    ; Read command
    call read_command
    
    ; Parse and execute command
    call parse_command
    
    jmp command_line

; Read command from keyboard
read_command:
    mov di, command_buffer
    xor cx, cx
.read_loop:
.read_wait:
    mov ah, 0x00         ; BIOS: Read keystroke (wait)
    int 0x16
    ; AL = ASCII, AH = scan code
    cmp al, 13           ; Enter key (CR)
    je .done
    cmp al, 8            ; Backspace
    je .backspace
    cmp al, 0            ; ignore null
    je .read_loop
    cmp cx, 50           ; Max length (reserve 1 for NUL)
    jae .read_loop
    mov [di], al
    inc di
    inc cx
    ; Echo character to screen
    mov ah, 0x0e
    int 0x10
    jmp .read_wait
.backspace:
    cmp cx, 0
    je .read_loop
    dec di
    dec cx
    mov ah, 0x0e
    mov al, 8
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 8
    int 0x10
    jmp .read_loop
.done:
    mov byte [di], 0
    mov ah, 0x0e
    mov al, 13
    int 0x10
    mov al, 10
    int 0x10
    ret

; Parse and execute command
parse_command:
    mov si, command_buffer
    cmp byte [si], 0
    je .done
    
    ; Check for 'help'
    mov di, cmd_help
    call strcmp
    jc .help
    
    ; Check for 'clear'
    mov di, cmd_clear
    call strcmp
    jc .clear
    
    ; Check for 'info'
    mov di, cmd_info
    call strcmp
    jc .info
    
    ; Check for 'exit'
    mov di, cmd_exit
    call strcmp
    jc .exit
    
    ; Unknown command
    mov si, unknown_cmd
    call print_string
    jmp .done
    
.help:
    mov si, help_msg
    call print_string
    jmp .done
    
.clear:
    mov ax, 0x0003
    int 0x10
    jmp .done
    
.info:
    mov si, info_msg
    call print_string
    jmp .done
    
.exit:
    mov si, exit_msg
    call print_string
    jmp kernel_loop
    
.done:
    ret

; String compare function
strcmp:
    push si
    push di
.loop:
    mov al, [si]
    mov bl, [di]
    cmp al, bl
    jne .not_equal
    cmp al, 0
    je .equal
    inc si
    inc di
    jmp .loop
.not_equal:
    pop di
    pop si
    clc
    ret
.equal:
    pop di
    pop si
    stc
    ret

; Print string function
print_string:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0e
    int 0x10
    jmp print_string
.done:
    ret

; Kernel main loop (fallback)
kernel_loop:
    ; Kernel runs continuously
    hlt
    jmp kernel_loop

; Simple exception handler
exception_handler:
    call print_exception
    jmp kernel_loop

; Print exception message
print_exception:
    ; Error handling code can be added here
    ret

; Setup GDT (Global Descriptor Table)
setup_gdt:
    ; GDT descriptor
    gdt_start:
        dq 0                    ; null描述符
        
        ; 代码段描述符
        dw 0xffff               ; limit
        dw 0                    ; base low
        db 0                    ; base mid
        db 0x9a                 ; 访问字节
        db 0xcf                 ; limit high + flag
        db 0                    ; base high
        
        ; 数据段描述符
        dw 0xffff               ; limit
        dw 0                    ; base low
        db 0                    ; base mid
        db 0x92                 ; 访问字节
        db 0xcf                 ; limit high + flag
        db 0                    ; base high
        
    gdt_end:
    
    gdt_descriptor:
        dw gdt_end - gdt_start - 1
        dd gdt_start
    
    ret

; Data section
prompt db '> ', 0
command_buffer times 51 db 0

cmd_help db 'help', 0
cmd_clear db 'clear', 0
cmd_info db 'info', 0
cmd_exit db 'exit', 0

help_msg db 'Available commands:', 13, 10
         db '  help  - Show this help', 13, 10
         db '  clear - Clear screen', 13, 10
         db '  info  - Show system info', 13, 10
         db '  exit  - Exit to kernel loop', 13, 10, 0

unknown_cmd db 'Unknown command. Type help for available commands.', 13, 10, 0

info_msg db 'Simple OS v1.0', 13, 10
         db 'Running in 16-bit real mode', 13, 10
         db 'Kernel loaded at 0x1000', 13, 10, 0

exit_msg db 'Exiting to kernel loop...', 13, 10, 0
