assume cs:code, ds:data
data segment
    dummy db 0Dh, 0Ah, '$'
    string db 100, 101 dup ('$')
    s db 100, 101 dup ('$')
    e db 100, 101 dup ('$')
    m db 100, 101 dup ('$')
data ends



code segment
print macro string
    xor ax, ax
	mov dx, offset string
	mov ah, 09h
	int 21h
endm

input macro string, s, e, m
	xor ax, ax
	mov ah, 0ah
	lea dx, string
	int 21h
endm

start:
    mov ax, data
    mov ds, ax

    input string s e m
    print dummy
    print string
    mov ah, 4Ch
    int 21h
code ends
end start