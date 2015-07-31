; COMMANDS TO COMPILE, LINK AND RUN:
;     nasm -o sudoku_solver.o -f elf64 sudoku_solver.nasm
;     gcc sudoku_solver.o -o sudoku_solver -nostdlib
;     echo <input_board> | ./sudoku_solver
;
;     E.g.
;     echo '005003040007009120020000000050816003400307006100492050000000030034500800080200900' | ./sudoku_solver
;
;     INPUT BOARD:
;     005|003|040
;     007|009|120
;     020|000|000
;     ---+---+---
;     050|816|003
;     400|307|006
;     100|492|050
;     ---+---+---
;     000|000|030
;     034|500|800
;     080|200|900
;     
;     SOLUTION:
;     815|723|649
;     347|689|125
;     629|145|387
;     ---+---+---
;     752|816|493
;     498|357|216
;     163|492|758
;     ---+---+---
;     271|968|534
;     934|571|862
;     586|234|971

global _start

miniBoardDimension equ 3
boardDimension equ miniBoardDimension * miniBoardDimension
boardSize equ boardDimension * boardDimension
asciiZero equ 48

section .data
    inputBoardStr db 'INPUT BOARD:', 0x0A
    verticalSeparator db '|'
    horizontalSeparators db '---+---+---', 0x0A
    errorInputStr db 'INPUT BOARD IS INVALID', 0x0A
    noSolutionStr db 'NO POSSIBLE SOLUTION', 0x0A
    solutionStr db 'SOLUTION:', 0x0A
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
    xor rax, rax ; sys_read
    xor rdi, rdi ; STDIN
    mov rsi, inputBoardChars ; read buffer
    mov rdx, boardSize ; size bytes
    push rcx
    syscall
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    pop rax
    ; end read input board as chars
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
    ; end print input board label
    ; print input board
    push rax
    mov rax, inputBoardChars
    call func_print_board
    pop rax
    ; end print input board
    ; copy inputBoardChars to workingBoardChars
    push rcx
    push rbx
    push rdi
    push rdx
    mov rcx, boardSize
    loop_copy_input_to_working:
    dec rcx
    mov rbx, inputBoardChars
    add rbx, rcx
    xor rdi, rdi
    mov dil, [rbx]
    mov rdx, workingBoardChars
    add rdx, rcx
    mov [rdx], dil
    test rcx, rcx
    jne loop_copy_input_to_working
    pop rdx
    pop rdi
    pop rbx
    pop rcx
    ; end copy inputBoardChars to workingBoardChars
    ; naive search and backtrack
    push rbx
    push rax
    push rdi
    mov rbx, inputBoardChars
    mov rax, workingBoardChars
    xor rdi, rdi
    loop_solver:
    ; check if cell has starting value
    push rbx
    add rbx, rdi
    xor rsi, rsi
    mov sil, [rbx]
    pop rbx
    cmp rsi, asciiZero
    je solve_for_cell ; if cell does not have starting value, proceed to solve for cell
    ; end check if cell has starting value
    ; check if starting value for cell is valid
    push rax
    mov rax, inputBoardChars
    call func_check_cell_value
    test rax, rax
    pop rax
    je invalid_input ; if starting value for cell is not valid, print error and exit
    ; end check if starting value for cell is valid
    ; go to next cell
    inc rdi
    cmp rdi, boardSize
    je solved ; if already at last cell, print solution and exit
    jmp loop_solver ; solve for next cell
    solve_for_cell:
    ; find and set valid value for current cell
    push rax
    add rax, rdi
    xor rsi, rsi
    mov sil, [rax]
    pop rax
    push rcx
    push rax
    call func_get_next_valid_value
    mov rcx, rax
    test rax, rax
    pop rax
    je no_valid_value_for_cell ; if no valid value found for cell, set to ascii 0 and backtrack
    ; set cell value and go to next cell
    push rax
    add rax, rdi
    mov [rax], cl
    pop rax
    pop rcx
    inc rdi
    ; end set cell value and go to next cell
    ; end find and set valid value for current cell
    cmp rdi, boardSize
    je solved ; if already at last cell, print solution and exit
    jmp loop_solver ; solve for next cell
    no_valid_value_for_cell:
    pop rcx
    ; set current cell to ascii 0
    push rax
    push rdx
    add rax, rdi
    mov rdx, asciiZero
    mov [rax], dl
    ; end set current cell to ascii 0
    pop rdx
    pop rax
    test rdi, rdi
    je no_solution ; if already at first cell, print error and exit
    ; backtrack to previous cell that has no starting value
    loop_backtrack_to_empty_cell:
    dec rdi
    ; check if cell has starting value
    push rbx
    add rbx, rdi
    xor rsi, rsi
    mov sil, [rbx]
    pop rbx
    cmp rsi, asciiZero
    je loop_solver ; if cell does not have starting value, proceed to solve for cell
    ; end check if cell has starting value
    test rdi, rdi
    je no_solution ; else if already at first cell, print error and exit
    jmp loop_backtrack_to_empty_cell ; backtrack further
    ; end backtrack to previous cell that has no starting value
    invalid_input:
    ; print invalid input error message
    push rax
    push rdi
    push rsi
    push rdx
    mov rax, 0x01
    mov rdi, 0x01
    mov rsi, errorInputStr
    mov rdx, 0x17
    push rcx
    syscall
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    pop rax
    ; end print invalid input error message
    jmp end
    no_solution:
    ; print no solution error message
    push rax
    push rdi
    push rsi
    push rdx
    mov rax, 0x01
    mov rdi, 0x01
    mov rsi, noSolutionStr
    mov rdx, 0x15
    push rcx
    syscall
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    pop rax
    ; end print no solution error message
    jmp end
    solved:
    ; print solution label
    push rax
    push rdi
    push rsi
    push rdx
    mov rax, 0x01
    mov rdi, 0x01
    mov rsi, solutionStr
    mov rdx, 0x0A
    push rcx
    syscall
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    pop rax
    ; end print solution label
    ; print solution
    call func_print_board
    ; end print solution
    end:
    pop rdi
    pop rax
    pop rbx
    ; end naive search and backtrack
    ; exit
    mov rax, 0x3C ; sys_exit
    xor rdi, rdi ; error code 0
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
    pop rsi
    pop rbp
    ret
    ; end function to print board formatted

    ; function to get next valid value of given cell
    ;     rax = boardChars;
    ;     rdi = cellIndex;
    ;     rsi = currentCellValue;
    ; return rax = next valid cell value, or rax = 0 if no other valid cell value
    func_get_next_valid_value:
    push rbp
    mov rbp, rsp
    push rcx
    push rdx
    mov rcx, boardDimension
    push rsi
    ; loop to find next valid value
    loop_get_next_valid_value:
    inc rsi
    mov rdx, rsi
    sub rdx, asciiZero
    cmp rdx, rcx
    jg no_valid_value ; if no more values to test, return 0
    push rax
    call func_check_cell_value
    test rax, rax
    pop rax
    je loop_get_next_valid_value ; if value is not valid, test next value
    mov rax, rsi ; return next valid value found
    pop rsi
    pop rdx
    pop rcx
    pop rbp
    ret
    ; end loop to find next valid value
    no_valid_value:
    pop rsi
    pop rdx
    pop rcx
    pop rbp
    xor rax, rax ; no valid value found; return 0
    ret
    ; end function to get next valid value of given cell

    ; function to check if value in given cell is valid (by checking for duplicates)
    ;     rax = boardChars;
    ;     rdi = cellIndex;
    ;     rsi = cellValue;
    ; return rax = 1 if value is valid, or rax = 0 otherwise
    func_check_cell_value:
    push rbp
    mov rbp, rsp
    push rax
    call func_check_value_row
    test rax, rax
    je value_not_valid ; if value is not valid, return 0
    pop rax
    push rax
    call func_check_value_column
    test rax, rax
    je value_not_valid ; if value is not valid, return 0
    pop rax
    push rax
    call func_check_value_miniboard
    test rax, rax
    je value_not_valid ; if value is not valid, return 0
    pop rax
    pop rbp
    mov rax, 1 ; value valid, return 1
    ret
    value_not_valid:
    pop rax
    pop rbp
    xor rax, rax ; value not valid, return 0
    ret
    ; end function to check if value in given cell is valid (by checking for duplicates)

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
    loop_check_value_row:
    dec rcx
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
    xor rax, rax ; duplicate value found, return 0
    ret
    ; end function to check if value exists in other cells in the same row

    ; function to check if value exists in other cells in the same column
    ;     rax = boardChars;
    ;     rdi = cellIndex;
    ;     rsi = cellValue;
    ; return rax = 0 if duplicate value found, or rax = 1 otherwise
    func_check_value_column:
    push rbp
    mov rbp, rsp
    push rbx
    ; get starting index of column and store in rbx
    push rdx
    push rax
    push rcx
    xor rdx, rdx
    mov rax, rdi
    mov rcx, boardDimension
    div rcx
    mul rcx
    mov rbx, rdi
    sub rbx, rax
    pop rcx
    pop rax
    pop rdx
    ; end get starting index of column and store in rbx
    ; loop to check each cell in same column
    push rcx
    ; get ending index of column and store in rcx
    push rax
    push rbx
    push rdx
    mov rax, boardDimension
    dec rax
    mov rbx, boardDimension
    mul rbx
    pop rdx
    pop rbx
    mov rcx, rbx
    add rcx, rax
    pop rax
    ; end get ending index of column and store in rcx
    loop_check_value_column:
    ; check value only if cell is not cell whose value we are checking
    cmp rdi, rcx
    je skip_check_value_column
    push rcx
    add rcx, rax
    cmp sil, [rcx]
    pop rcx
    je column_duplicate_value_found ; if duplicate value, return 0
    skip_check_value_column:
    ; end check value only if cell is not cell whose value we are checking
    sub rcx, boardDimension
    cmp rcx, rbx
    jge loop_check_value_column
    pop rcx
    ; end loop to check each cell in same column
    pop rbx
    pop rbp
    mov rax, 1 ; no duplicate value found, return 1
    ret
    column_duplicate_value_found:
    pop rcx
    pop rbx
    pop rbp
    xor rax, rax ; duplicate value found, return 0
    ret
    ; end function to check if value exists in other cells in the same column

    ; function to check if value exists in other cells in the same miniboard
    ;     rax = boardChars;
    ;     rdi = cellIndex;
    ;     rsi = cellValue;
    ; return rax = 0 if duplicate value found, or rax = 1 otherwise
    func_check_value_miniboard:
    push rbp
    mov rbp, rsp
    push rbx
    ; get index of top-left cell of miniboard containing cell and store in rbx
    ; get index of top-left cell of left-most miniboard in the row of miniboards containing cell and store in rbx
    push rax
    push rcx
    mov rax, boardDimension
    mov rbx, miniBoardDimension
    mul rbx
    mov rbx, 0
    mov rcx, 0
    get_topleft_cell_of_next_miniboard_row:
    add rcx, rax
    cmp rdi, rcx
    jl found_topleft_cell_of_miniboard_row
    mov rbx, rcx
    jmp get_topleft_cell_of_next_miniboard_row
    found_topleft_cell_of_miniboard_row:
    pop rcx
    pop rax
    ; end get index of top-left cell of left-most miniboard in the row of miniboards containing cell and store in rbx
    push rdx
    ; get index of top-left cell of top-most miniboard in the column of miniboards containing cell and store in rdx
    push rax
    push rbx
    push rcx
    mov rax, rdi
    mov rbx, boardDimension
    div rbx
    mov rax, rdx
    mov rdx, 0
    mov rcx, 0
    get_topleft_cell_of_next_miniboard_column:
    add rcx, miniBoardDimension
    cmp rax, rcx
    jl found_topleft_cell_of_miniboard_column
    mov rdx, rcx
    jmp get_topleft_cell_of_next_miniboard_column
    found_topleft_cell_of_miniboard_column:
    pop rcx
    pop rbx
    pop rax
    ; end get index of top-left cell of top-most miniboard in the column of miniboards containing cell and store in rdx
    add rbx, rdx
    pop rdx
    ; end get index of top-left cell of miniboard containing cell and store in rbx
    ; loop to check each cell in same miniboard
    push rcx
    mov rcx, miniBoardDimension
    loop_check_value_miniboard_each_row:
    ; loop to check each cell in miniboard row
    push rbx
    push rcx
    mov rcx, miniBoardDimension
    loop_check_value_miniboard_each_cell:
    ; check value only if cell is not cell whose value we are checking
    cmp rbx, rdi
    je skip_check_value_miniboard
    push rbx
    add rbx, rax
    cmp sil, [rbx]
    pop rbx
    je miniboard_duplicate_value_found ; if duplicate value, return 0
    skip_check_value_miniboard:
    ; end check value only if cell is not cell whose value we are checking
    inc rbx
    dec rcx
    test rcx, rcx
    jne loop_check_value_miniboard_each_cell
    pop rcx
    pop rbx
    ; end loop to check each cell in miniboard row
    add rbx, boardDimension
    dec rcx
    test rcx, rcx
    jne loop_check_value_miniboard_each_row
    pop rcx
    ; end loop to check each cell in same miniboard
    pop rbx
    pop rbp
    mov rax, 1 ; no duplicate value found, return 1
    ret
    miniboard_duplicate_value_found:
    pop rcx
    pop rbx
    pop rcx
    pop rbx
    pop rbp
    xor rax, rax ; duplicate value found, return 0
    ret
    ; end function to check if value exists in other cells in the same miniboard
