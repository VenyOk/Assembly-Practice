assume cs:code, ds:data
data segment
    dummy db 0Dh, 0Ah, '$'
    string db 100, 101 dup('$')
    number db 100, 101 dup('$')
    int_part db 100, 101 dup ('$')
    frac_part db 100, 101 dup ('$')
    result db 100, 101 dup ('$')
    len_num dw 0
    len1 dw 0
    len2 dw 0
    point_index dw 0
    CONST_2 dw 2

data ends


code segment

to_number macro string, number
    local to_number_loop, end_to_number_loop
    mov si, 2
    xor di, di
    to_number_loop:
        mov al, string[si]
        cmp al, 0Dh
            je end_to_number_loop
        mov number[di], al
        inc di
        inc si
        jmp to_number_loop
    end_to_number_loop:
endm

find_point_index macro num
    local find_loop, end_find_loop
    xor si, si
    find_loop:
        mov al, num[si]
        cmp al, 2eh
            je end_find_loop
        inc si
        jmp find_loop
    end_find_loop:
        mov point_index, si
        mov ax, point_index
endm


find_len_number macro num
    xor si, si
    find_len_loop:
        mov al, num[si]
        cmp al, '$'
            je end_find_len_loop
        inc si
        jmp find_len_loop
    end_find_len_loop:
        mov len_num, si
        mov ax, len_num
endm


count_int_part macro num
    mov ax, point_index
    mov len1, ax
    xor si, si
    xor di, di
    count_int_part_loop:
        cmp si, len1
            je end_count_int_part_loop
        mov al, num[si]
        mov int_part[di], al
        inc di
        inc si
        jmp count_int_part_loop
    end_count_int_part_loop:
        mov ax, len1
endm

count_frac_part macro num
    xor di, di
    mov ax, len_num
    sub ax, len1
    mov len2, ax
    dec len2
    mov si, point_index
    inc si
    xor ax, ax
    counting_loop:
        cmp si, len_num
            je end_loop
        mov al, num[si]
        mov frac_part[di], al
        inc si
        inc di
        jmp counting_loop
    end_loop:
        mov ax, len2
endm


round macro num

    cmp num[0], 2Dh
        je minus
        jne plus
    minus:
    plus:
        cmp frac_part[0], 5
            jg to_bigger
            jle to_less
        to_bigger:
            
    end_round:
endm



print macro string
    xor ax, ax
	lea dx, string
	mov ah, 09h
	int 21h
endm

input macro string
	xor ax, ax
    mov dx, offset string
	mov ah, 0ah
	int 21h
endm

start:
    mov ax, data
    mov ds, ax
    input string
    print dummy
    
    to_number string number
    print number
    print dummy

    find_point_index number
    find_len_number number
    count_int_part number
    count_frac_part number
    print int_part
    print dummy
    print frac_part
    mov ah, 4ch
    int 21h
code ends
end start
