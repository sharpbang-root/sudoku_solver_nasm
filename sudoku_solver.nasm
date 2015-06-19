; COMMANDS TO COMPILE, LINK AND RUN:
;     nasm -o sudoku_solver.o -f elf64 sudoku_solver.nasm
;     gcc sudoku_solver.o -o sudoku_solver -nostdlib
;     ./sudoku_solver <input board>

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
    ; print current cell (value in [rsi])
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
    ; end print current cell (value in [rsi])
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
    ; end print vertical separator if not last miniboard
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
    ; end print line break
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
    ; end print horizontal separators if not last miniboard
    test rcx, rcx
    jne loop_print_board_x_board_start
    pop rcx
    ; end loop to print boardDimension x boardDimension cells
    pop rsi
    pop rbp
    ret
    ; end function to print board formatted

    ; function to check if value exists in other cells in the same row
    ;     rax = boardChars;
    ;     rdi = cellIndex;
    ;     rsi = cellValue;
    ; return rax = 0 if duplicate value found, or rax = 1 otherwise
    func_check_value_row:
    push rbp
    mov rbp, rsp
    push rbx
    ; get starting index of row and store in rbx
    push rdx
    push rax
    push rcx
    xor rdx, rdx
    mov rax, rdi
    mov rcx, boardDimension
    div rcx
    mul rcx
    mov rbx, rax
    pop rcx
    pop rax
    pop rdx
    ; end get starting index of row and store in rbx
    ; loop to check each cell in same row
    push rcx
    mov rcx, boardDimension
    dec rcx
    loop_check_value_row:
    push rbx
    add rbx, rcx
    ; check value only if cell is not cell whose value we are checking
    cmp rdi, rbx
    je skip_check_value_row
    add rbx, rax
    cmp sil, [rbx]
    je row_duplicate_value_found ; if duplicate value, return 0
    skip_check_value_row:
    ; end check value only if cell is not cell whose value we are checking
    pop rbx
    dec rcx
    test rcx, rcx
    jne loop_check_value_row
    pop rcx
    ; end loop to check each cell in same row
    pop rbx
    pop rbp
    mov rax, 1 ; no duplicate value found, return 1
    ret
    row_duplicate_value_found:
    pop rbx
    pop rcx
    pop rbx
    pop rbp
    xor rax, rax
    ret
    ; end function to check if value exists in other cells in the same row
