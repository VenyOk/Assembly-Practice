input macro string, s, e, m 
    xor ax, ax
    mov ah, 0ah
    lea dx, string
    int 21h
endm


print macro string
    xor ax, ax
    mov dx, offset string
    mov ah, 09h
    int 21h
endm
