.MODEL SMALL
.STACK 100h
.DATA
    t1 DW ?
    x DW ?
    y DW ?
    z DW ?

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    MOV x, 10
    MOV y, 10
    MOV AX, x
    MOV BX, y
    ADD AX, BX
    MOV t1, AX
    MOV AX, t1
    MOV z, AX

    ; Exit the program
    MOV AH, 4Ch
    INT 21h
MAIN ENDP
END MAIN
