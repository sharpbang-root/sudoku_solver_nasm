; COMMANDS TO COMPILE, LINK AND RUN:
;     nasm -o sudoku.o -f elf64 sudoku.nasm
;     gcc sudoku.o -o sudoku -nostdlib
;     ./sudoku <input board>

global _start

miniBoardDimension equ 3
boardDimension equ miniBoardDimension * miniBoardDimension
boardSize equ boardDimension * boardDimension

section .data
    inputBoardStr db 'INPUT BOARD:', 0x0A
    verticalSeparator db '|'
    horizontalSeparators db '---+---+---', 0x0A
    lineBreak db 0x0A

section .bss
    inputBoardChars resb boardSize
    workingBoardChars resb boardSize

section .text
    _start:
    push rax
    push rdi
    push rdi
    push rdx
    ; read input board as chars
    xor rax, rax                    ; sys_read
    xor rdi, rdi                    ; STDIN
    mov rsi, inputBoardChars        ; read buffer
    mov rdx, boardSize              ; size bytes
    push rcx
    syscall
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    pop rax
    ; print input board label
    push rax
    push rdi
    push rsi
    push rdx
    mov rax, 0x01
    mov rdi, 0x01
    mov rsi, inputBoardStr
    mov rdx, 0x0D
    push rcx
    syscall
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    pop rax
    ; print input board
    push rax
    mov rax, inputBoardChars
    call func_print_board
    pop rax

    ; exit
    mov rax, 0x3C                   ; sys_exit
    xor rdi, rdi                    ; error code
    syscall

    ; function to print board formatted
    ;     rax = boardChars;
    func_print_board:
    push rbp
    mov rbp, rsp
    push rsi
    mov rsi, rax
    ; loop to print boardDimension x boardDimension cells
    push rcx
    mov rcx, miniBoardDimension
    loop_print_board_x_board_start:
    ; loop to print boardDimension x miniBoardDimension cells
    push rcx
    mov rcx, miniBoardDimension
    loop_print_board_x_mini_start:
    ; loop to print boardDimension x 1 cells
    push rcx
    mov rcx, miniBoardDimension
    loop_print_board_x_1_start:
    ; loop to print miniBoardDimension x 1 cells
    push rcx
    mov rcx, miniBoardDimension
    loop_print_mini_x_1_start:
    push rax
    push rdi
    push rdx
    mov rax, 0x01
    mov rdi, 0x01
    mov rdx, 0x01
    push rcx
    syscall
    pop rcx
    pop rdx
    pop rdi
    pop rax
    inc rsi
    dec rcx
    test rcx, rcx
    jne loop_print_mini_x_1_start
    pop rcx
    ; end loop to print miniBoardDimension x 1 cells
    dec rcx
    ; print vertical separator if not last miniboard
    test rcx, rcx
    je skip_print_vertical_separator
    push rax
    push rdi
    push rsi
    push rdx
    mov rax, 0x01
    mov rdi, 0x01
    mov rsi, verticalSeparator
    mov rdx, 0x01
    push rcx
    syscall
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    pop rax
    skip_print_vertical_separator:
    test rcx, rcx
    jne loop_print_board_x_1_start
    pop rcx
    ; end loop to print boardDimension x 1 cells
    dec rcx
    ; print line break
    push rax
    push rdi
    push rsi
    push rdx
    mov rax, 0x01
    mov rdi, 0x01
    mov rsi, lineBreak
    mov rdx, 0x01
    push rcx
    syscall
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    pop rax
    test rcx, rcx
    jne loop_print_board_x_mini_start
    pop rcx
    ; end loop to print boardDimension x miniBoardDimension cells
    dec rcx
    ; print horizontal separators if not last miniboard
    test rcx, rcx
    je skip_print_horizontal_separators
    push rax
    push rdi
    push rsi
    push rdx
    mov rax, 0x01
    mov rdi, 0x01
    mov rsi, horizontalSeparators
    mov rdx, 0x0C
    push rcx
    syscall
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    pop rax
    skip_print_horizontal_separators:
    test rcx, rcx
    jne loop_print_board_x_board_start
    pop rcx
    ; end loop to print boardDimension x boardDimension cells
    pop rsi
    pop rbp
    ret
