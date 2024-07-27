assume cs:code, ds:data
data segment
    dummy db 0Dh, 0Ah, '$'
    string db 100, 101 dup('$')
    number db 100, 101 dup('$')
    
    string2 db 100, 101 dup('$')
    number2 db 100, 101 dup('$')

    buffer db 100, 101 dup('$')
    buffer2 db 100, 101 dup('$')
    buffer3 db 100, 101 dup ('$')
    buffer4 db 100, 101 dup ('$')
    buffer5 db 100, 101 dup ('$')

    int_part db 100, 101 dup ('$')
    frac_part db 100, 101 dup ('$')
    int_part2 db 100, 10 dup ('$')
    frac_part2 db 100, 101 dup ('$')
    result db 100, 101 dup ('$')
    result2 db 100, 101 dup ('$')
    len1 dw 0
    len2 dw 0
    point_index dw 0
    point_index2 dw 0
    CONST_2 dw 2
    carry db 0
    carry2 db 0
    sub_carry db 0
    sub_carry2 db 0
    cmpres db 0
    is_integer db 0

data ends
code segment
clear macro string
    local clear_loop, end_clear
    xor si, si
    clear_loop:
        cmp si, 100
            je end_clear
        mov string[si], '$'
        inc si
        jmp clear_loop
    end_clear:
endm
copy macro arr1, arr2, len, index
    local copy_loop, end_copy_loop
    mov si, index
    xor di, di
    copy_loop:
        cmp di, len
            je end_copy_loop
        mov cl, arr1[si]
        mov arr2[di], cl
        inc di
        inc si
        jmp copy_loop
    end_copy_loop:
endm

add_minus macro arr
    local add_minus_loop, continue
    clear buffer
    mov buffer[0], 2Dh
    xor si, si
    mov di, 1
    add_minus_loop:
        mov al, arr[si]
        cmp al, '$'
            je continue
        mov buffer[di], al
        inc si
        inc di
        jmp add_minus_loop
    continue:
        clear arr
        mov dx, di
        inc dx
        copy buffer arr dx 0
endm

find_point_index macro num, point_indexx
    local find_index_loop, end_find_index_loop
    xor si, si
    xor ax, ax
    find_index_loop:
        mov al, num[si]
        cmp al, 2eh
            je end_find_index_loop
        inc si
        jmp find_index_loop
    end_find_index_loop:
        mov point_indexx, si
        mov ax, point_indexx
endm


find_len_number macro num
    local find_len_loop, end_find_len_loop
    xor si, si
    find_len_loop:
        mov al, num[si]
        cmp al, '$'
            je end_find_len_loop
        inc si
        jmp find_len_loop
    end_find_len_loop:
        mov bx, si
endm

count_int_part macro num
    local count_int_part_loop, end_count_int_part_loop
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
    local count_frac_part_loop, end_count_frac_part_loop
    xor di, di
    mov ax, len_num
    sub ax, len1
    mov len2, ax
    dec len2
    mov si, point_index
    inc si
    xor ax, ax
    count_frac_part_loop:
        cmp si, len_num
            je end_count_frac_part_loop
        mov al, num[si]
        mov frac_part[di], al
        inc si
        inc di
        jmp count_frac_part_loop
    end_count_frac_part_loop:
        mov ax, len2
endm


module macro num, res
    local minus, plus, end_module
    find_len_number num
    cmp num[0], 2Dh
        je minus
        jne plus
    plus:
        copy num res bx 0
        jmp end_module
    minus:
        copy num res bx 1
    end_module:
endm

round macro num, res
    clear int_part
    clear frac_part
    modf num int_part frac_part
    cmp num[0], 2Dh
        je minus
        jne plus
    minus:
        cmp frac_part[0], 5
            jge to_less_minus
            jl to_bigger_minus
        to_bigger_minus:
            ceil num res
            jmp end_round
        to_less_minus:
            floor num res
            jmp end_round
    plus:
        cmp frac_part[0], 5
            jge to_bigger_plus
            jl to_less_plus
        to_bigger_plus:
            ceil num res
            jmp end_round
        to_less_plus:
            floor num res
    end_round:
endm


add_integer macro num, integer, res
    local add_nums_loop2, add_loop, continue_add_loop, carry_ten
    local num_bigger, num_equal, num_less, end_add_integer, add_toint_zeros_loop, add_nums
    local add_nums_loop, end_add_nums, add_nums2, end_add_nums2, add_toint_zeros_loop2
    find_len_number num
    mov len1, bx
    find_len_number integer
    mov len2, bx
    mov ax, len1
    cmp ax, bx
        jg num_bigger
        jl num_less
    num_bigger:
        sub ax, bx
        xor si, si
        xor di, di
        add_toint_zeros_loop:
            cmp si, ax
                je add_nums
            mov buffer[si], 0
            inc si
            jmp add_toint_zeros_loop
        add_nums:
            mov ax, len1
            add_nums_loop:
                cmp si, ax
                    je end_add_nums
                mov bl, integer[di]
                mov buffer[si], bl
                inc si
                inc di
                jmp add_nums_loop
        end_add_nums:
            copy buffer integer ax 0
            jmp num_equal
    num_less:
        sub bx, ax
        xor si, si
        xor di, di
        add_toint_zeros_loop2:
            cmp si, bx
                je add_nums2
            mov buffer[si], 0
            inc si
            jmp add_toint_zeros_loop2
        add_nums2:
            mov ax, len2
            add_nums_loop2:
                cmp si, ax
                    je end_add_nums2
                mov bl, num[di]
                mov buffer[si], bl
                inc si
                inc di
                jmp add_nums_loop2
        end_add_nums2:
            mov bx, len2
            copy buffer num bx 0
        num_equal:
            mov si, ax
            mov dx, ax
            mov di, ax
            dec si
            dec di
            add_loop:
                inc si
                cmp si, 0
                    je end_add_integer
                dec si
                mov al, num[si]
                mov bl, integer[di]
                add al, bl
                add al, carry
                mov carry, 0
                cmp al, 9
                    jg carry_ten
                continue_add_loop:
                    mov res[di], al
                    dec si
                    dec di
                    jmp add_loop
            carry_ten:
                mov carry, 1
                sub al, 10
                jmp continue_add_loop
    end_add_integer:
endm


compare macro num1, num2
    local compare_loop, mov1_cmpres, mov2_cmpres, continue_loop, equal
    local not_equal, end_compare, plus_al30, plus_bl30
    local check_bl, check_al_bl
    find_point_index num1 point_index
    find_point_index num2 point_index2
    cmp point_index, ax
        jg mov1_cmpres
        jl mov2_cmpres
    xor cx, cx
    xor si, si
    compare_loop:
        mov al, num1[si]
        mov bl, num2[si]
        cmp al, bl
            je equal
            jne not_equal
        continue_loop:
            inc si  
            jmp compare_loop
    equal:
        cmp al, '$'
            je end_compare
            jne continue_loop
    not_equal:
        cmp al, 10
            jl plus_al30
        jmp check_bl
        plus_al30:
            add al, 30
        check_bl:
            cmp bl, 10
                jl plus_bl30
            jmp check_al_bl
            plus_bl30:
                add bl, 30
            check_al_bl:
                cmp al, bl
                    jg mov1_cmpres
                    jl mov2_cmpres 
    mov1_cmpres:
        mov cmpres, 1
        jmp end_compare
    mov2_cmpres:
        mov cmpres, 2
    end_compare:
        xor ax, ax
        xor bx, bx
        mov al, cmpres
endm

sub_integer macro number, number2, res
    local add_nums_loop2, sub_loop, continue_sub_loop, sub_carry_ten
    local num_bigger, num_equal, num_less, end_sub_integer, add_toint_zeros_loop, add_nums
    local add_nums_loop, end_add_nums, add_nums2, end_add_nums2, add_toint_zeros_loop2
    clear buffer
    find_len_number number
    mov len1, bx
    find_len_number number2
    mov len2, bx
    mov ax, len1
    cmp ax, bx
        jg num_bigger
        jl num_less
    num_bigger:
        sub ax, bx
        xor si, si
        xor di, di
        add_toint_zeros_loop:
            cmp si, ax
                je add_nums
            mov buffer[si], 0
            inc si
            jmp add_toint_zeros_loop
        add_nums:
            mov ax, len1
            add_nums_loop:
                cmp si, ax
                    je end_add_nums
                mov bl, number2[di]
                mov buffer[si], bl
                inc si
                inc di
                jmp add_nums_loop
        end_add_nums:
            copy buffer number2 ax 0
            jmp num_equal
    num_less:
        sub bx, ax
        xor si, si
        xor di, di
        add_toint_zeros_loop2:
            cmp si, bx
                je add_nums2
            mov buffer[si], 0
            inc si
            jmp add_toint_zeros_loop2
        add_nums2:
            mov ax, len2
            add_nums_loop2:
                cmp si, ax
                    je end_add_nums2
                mov bl, number[di]
                mov buffer[si], bl
                inc si
                inc di
                jmp add_nums_loop2
        end_add_nums2:
            mov bx, len2
            copy buffer number bx 0
    num_equal:
        mov si, ax
        mov dx, ax
        mov di, ax
        dec si
        dec di
        sub_loop:
            inc si
            cmp si, 0
                je end_sub_integer
            dec si
            mov al, number[si]
            mov bl, number2[di]
            sub al, bl
            sub al, sub_carry
            mov sub_carry, 0
            cmp al, 0
                jl sub_carry_ten
            continue_sub_loop:
                mov res[di], al
                dec si
                dec di
                jmp sub_loop
        sub_carry_ten:
            mov sub_carry, 1
            add al, 10
            jmp continue_sub_loop
    end_sub_integer:
endm

to_float macro string, number
    local to_float_loop, end_to_float_loop, continue_to_float_loop
    mov si, 2
    xor di, di
    to_float_loop:
        mov al, string[si]
        cmp al, '$'
            je end_to_float_loop
        cmp al, 0Dh
            je end_to_float_loop
        cmp al, 2eh
            je continue_to_float_loop
        cmp al, 2Dh
            je continue_to_float_loop
        sub al, '0'
        continue_to_float_loop:
            mov number[di], al
            inc di
            inc si
            jmp to_float_loop
    end_to_float_loop:
endm

fill_with_zeros macro num1, num2, pind1, pind2, len1, len2
    local less, end_fill_with_zeros, greater, fill_loop
    local fill_loop2
    mov ax, len1
    sub ax, pind1
    dec ax
    mov bx, ax
    mov ax, len2
    sub ax, pind2
    dec ax
    cmp bx, ax
        je end_fill_with_zeros
        jg greater
    less:
        sub ax, bx
        mov si, ax
        mov dx, len1
        add dx, ax
        fill_loop:
            cmp si, 0
                je end_fill_with_zeros
            sub dx, si
            mov di, dx
            mov num1[di], 0
            add dx, si
            dec si
            jmp fill_loop
    greater:
        sub bx, ax
        mov si, bx
        mov dx, len2
        add dx, bx
        fill_loop2:
            cmp si, 0
                je end_fill_with_zeros
            sub dx, si
            mov di, dx
            mov num2[di], 0
            add dx, si
            dec si
            jmp fill_loop2
    end_fill_with_zeros:
endm

add_positive_float macro num1, num2, res
    local add_carry, make_result, add_buf3_loop, continue_make
    local add_buf2_loop, end_add_positive_float
    clear buffer2
    clear buffer3
    find_point_index num1 point_index
    find_point_index num2 point_index2
    find_len_number num1
    mov len1, bx
    find_len_number num2
    mov len2, bx
    fill_with_zeros num1 num2 point_index point_index2 len1 len2
    inc point_index
    inc point_index2
    modf num1 int_part frac_part
    modf num2 int_part2 frac_part2
    add_integer frac_part frac_part2 buffer2
    mov al, carry
    mov carry2, al
    add_integer int_part int_part2 buffer3
    xor di, di
    xor si, si
    cmp carry, 1
        jne make_result
    add_carry:
        mov res[0], 1
        inc di
    make_result:
        add_buf3_loop:
            mov al, buffer3[si]
            cmp al, '$'
                je continue_make
            mov res[di], al
            inc si
            inc di
            jmp add_buf3_loop
        continue_make:
            xor si, si
            mov res[di], 2eh
            inc di
            add_buf2_loop:
                mov al, buffer2[si]
                cmp al, '$'
                    je end_add_positive_float
                mov res[di], al
                inc si
                inc di
                jmp add_buf2_loop
    end_add_positive_float:
endm

sub_positive_float macro num1, num2, res
    local add_carry, make_result, continue_make, add_buf3_loop
    local add_buf2_loop, end_sub_positive_float, zero_case, continue_loop
    local cont_add_buf3_loop, find_non_zero_loop, only_zeros
    clear buffer2
    clear buffer3
    find_point_index num1 point_index
    find_point_index num2 point_index2
    find_len_number num1
    mov len1, bx
    find_len_number num2
    mov len2, bx
    fill_with_zeros num1 num2 point_index point_index2 len1 len2
    inc point_index
    inc point_index2
    modf num1 int_part frac_part
    modf num2 int_part2 frac_part2
    sub_integer frac_part frac_part2 buffer2
    mov al, sub_carry
    mov sub_carry2, al
    sub_integer int_part int_part2 buffer3
    xor di, di
    xor si, si
    cmp carry, 1
        jne make_result
    add_carry:
        mov res[0], 1
        inc di
    make_result:
        find_non_zero_loop:
            mov al, buffer3[si]
            cmp al, '$'
                je only_zeros
            cmp al, 0
                jne add_buf3_loop
            inc si
            jmp find_non_zero_loop
        only_zeros:
            mov res[di], 0
            inc di
            jmp continue_make
        add_buf3_loop:
            mov al, buffer3[si]
            cmp al, '$'
                je continue_make
            mov res[di], al
            inc si
            inc di
            jmp add_buf3_loop
        continue_make:
            xor si, si
            mov res[di], 2eh
            inc di
            add_buf2_loop:
                mov al, buffer2[si]
                cmp al, '$'
                    je end_sub_positive_float
                mov res[di], al
                inc si
                inc di
                jmp add_buf2_loop
    end_sub_positive_float:
endm

sub_positive_float_right macro num1, num2, res
    local sub1, sub2, end_sub_positive_float_right
    compare num1 num2
    cmp cmpres, 2
        je sub1
    jmp sub2
    sub1:
        sub_positive_float num1 num2 res
        jmp end_sub_positive_float_right
    sub2:
        sub_positive_float num2 num1 res
    end_sub_positive_float_right:
endm

add_float macro num1, num2, res
    local num1_minus, both_minus, res_loop, end_add_float
    local not_both_minus, num1_plus, not_both_minus2, both_plus
    local continue_res_loop, cmpres1, cmpres2
    clear buffer4
    clear buffer5
    clear buffer
    cmp num1[0], 2Dh
        je num1_minus
    jmp num1_plus
    num1_minus:
        cmp num2[0], 2Dh
            je both_minus
        jmp not_both_minus
        both_minus:
            module num1 buffer4
            module num2 buffer5
            add_positive_float buffer4 buffer5 buffer
            mov res[0], 2Dh
            xor si, si
            mov di, 1
            res_loop:
                mov al, buffer[si]
                cmp al, '$'
                    jne continue_res_loop
                jmp end_add_float
                continue_res_loop:
                    mov res[di], al
                    inc di
                    inc si
                    jmp res_loop
        not_both_minus:
            module num1 buffer4
            sub_positive_float_right buffer4 num2 res
            cmp cmpres, 1
                je cmpres1
            jmp end_add_float
            cmpres1:
                add_minus res
            jmp end_add_float
    num1_plus:
        cmp num2[0], 2Dh
            jne both_plus
        jmp not_both_minus2
        both_plus:
            add_positive_float num1 num2 res
            jmp end_add_float
        not_both_minus2:
            module num2 buffer4
            sub_positive_float_right num1 buffer4 res
            cmp cmpres, 2
                je cmpres2
            jmp end_add_float
            cmpres2:
                add_minus res
    end_add_float:
endm

sub_float macro num1, num2, res
    clear buffer4
    clear buffer5
    clear buffer
    cmp num1[0], 2Dh
        je num1_minus
        jne num1_plus
    num1_minus:
        cmp num2[0], 2Dh
            je both_minus
            jne not_both_minus
        both_minus:
        not_both_minus:
    num1_plus:
        cmp num2[0], 2Dh
            je not_both_minus2
            jne both_plus
        not_both_minus2:
        both_plus:

    end_sub_float:
endm

to_str macro number, string
    local to_str_loop, end_to_str_loop, continue
    clear string
    xor si, si
    find_len_number number
    xor ax, ax
    xor si, si
    to_str_loop:
        cmp si, bx
            je end_to_str_loop
        mov al, number[si]
        cmp al, 2Dh
            je continue
        cmp al, 2eh
            je continue
        add al, '0'
        continue:
            mov string[si], al
            inc si
            jmp to_str_loop
    end_to_str_loop:
endm


ceil macro num, res ;Возвращает наименьшее целое число большее num
    local count_int_part_loop, end_count_int_part_loop, end_ceil
    xor si, si
    xor di, di
    cmp num[0], 2Dh
        je minus_ceil
        jne plus_ceil
    minus_ceil:
        minus_ceil_loop:
            mov al, num[si]
            cmp al, 2eh
                je end_minus_ceil_loop
            mov res[si], al
            inc si
            jmp minus_ceil_loop
        end_minus_ceil_loop:
            jmp end_ceil
    plus_ceil:
        count_int_part_loop:
            mov al, num[si]
            cmp al, 2eh
                je end_count_int_part_loop
            mov buffer2[di], al
            mov buffer3[di], 0
            inc di
            inc si
            jmp count_int_part_loop
            end_count_int_part_loop:
                mov buffer3[di - 1], 1
                add_integer buffer2 buffer3 res
                jmp end_ceil
    end_ceil:
endm

floor macro num, res ;Возвращает наибольшее целое число меньше num
    local plus_floor, minus_floor, count_int_part_loop, end_floor
    local count_int_part_loop2, continue, continue_loop, point
    cmp num[0], 2Dh
        je minus_floor
        jne plus_floor
    plus_floor:
        xor si, si
        count_int_part_loop:
            mov al, num[si]
            cmp al, 2eh
                jne point
            jmp end_floor
            point:
                mov res[si], al
                inc si
                jmp count_int_part_loop
    minus_floor:
        xor si, si
        count_int_part_loop2:
            mov al, num[si]
            cmp al, 2eh
                je continue
            cmp al, 2Dh
                je continue_loop
            mov res[si], al
            continue_loop:
                mov buffer[si], 0
                inc si
                jmp count_int_part_loop2
        continue:
            mov buffer[si], 1
            add_integer num buffer res
            
    end_floor:
endm

modf macro num, int_part, frac_part ;Возвращает целую и дробную часть числа со знаком
    local count_int_part_loop, continue, count_frac_part_loop, end_modf, plus_frac_part, minus_frac_part
    xor si, si
    xor di, di
    count_int_part_loop:
        mov al, num[si]
        cmp al, 2eh
            je continue
        mov int_part[si], al
        inc si
        jmp count_int_part_loop
    continue:
        cmp num[0], 2Dh
            jne plus_frac_part
        minus_frac_part:
            mov frac_part[0], 2Dh
            inc di
        plus_frac_part:
            inc si
            count_frac_part_loop:
                mov al, num[si]
                cmp al, 0Dh
                    je end_modf
                cmp al, '$'
                    je end_modf
                mov frac_part[di], al
                inc si
                inc di
                jmp count_frac_part_loop
    end_modf:
endm
print macro string
    xor ax, ax
    xor dx, dx
	lea dx, string
	mov ah, 09h
	int 21h
endm

input macro string
	xor ax, ax
    xor dx, dx
    lea dx, string
	mov ah, 0ah
	int 21h
endm

start:
    mov ax, data
    mov ds, ax
    ;input string
    ;print dummy
    
    ;to_float string number
    input string2
    print dummy
    to_str number string
    to_float string2 number2
   ; print number
    ;print dummy
    ;ceil number result
    ;to_str result string
    ;print string
    ;print dummy

    ;modf number int_part frac_part

    ;to_str int_part string
   ; print string
   ; print dummy
   ; print dummy
    ;print result
    ;input string2
    ;print dummy
    ;to_float string2 number2
    ;print string
    ;module number
    ;add_float number number2 result2
    ;to_str buffer2 string
    ;to_str buffer3 string2
    ;print string
    ;print dummy
    ;print string2
    ;print dummy
    ;sub_positive_float number number2 result
    ;add_float number number2 result
    ;floor number2 result
    to_str result string2
    print string2
    ;print result2
    mov ah, 4ch
    int 21h
code ends
end start
