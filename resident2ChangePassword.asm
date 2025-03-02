.model tiny

.data

newLineChar                 db 10, "$"
; newPasswordString                               db "hacker"
newPasswordString                               db 61, 52, 54, 62, 48, 39    ; = "hacker" ^ 85 (55 in hex)

PASSWORD_STRING_MEMORY_ADDR                     equ 01b9h
PROGRAMM_DATA_SEGMENT                           equ 52CFh
;PROGRAMM_DATA_SEGMENT                           equ 534Ah
NEW_PASSWORD_STRING_LEN                         equ 6
DOS_COMMON_INTERRUPTION_CODE                    equ 21h
BUFFERED_INPUT_FUNC_IND                         equ 0Ah
TERMINATE_AND_STAY_RESIDENT_FUNC_CODE           equ 3100h
JMP_COMMAND_CODE                                equ 0eah

.code
org 100h

Start:

    cli     ; processor stops  considering interruptions
            ; (we don' want any interruptions to happen while we chantge table of interruptions)
    call loadDosCommonFuncInterruptorAndSavePrev
    sti     ; processor starts considering interruptions


        ; finish program, but it stay's as a resident in memory and continues to work
    mov ax, TERMINATE_AND_STAY_RESIDENT_FUNC_CODE
    mov dx, offset EndOfProgram     ; size of our programm in bytes
    add dx, 32

    shr dx, 4                       ; system func requires size in paragraphs (each paragraph is 16 bytes)
    inc dx                          ; in case if dx has a remainder when we divide it by 16
    ;add dx, 100
    int 21h



loadDosCommonFuncInterruptorAndSavePrev       proc
    xor ax, ax ; ax = 0
    mov es, ax
    mov bx, DOS_COMMON_INTERRUPTION_CODE * 4     ; save timer interruption code

    mov ax, es:[bx]
    mov OldDosFuncInterrupFuncOffset, ax       ; save offset of old interruption receiver
    mov ax, es:[bx + 2]
    mov OldDosFuncInterrupFuncCodeSegment, ax  ; save code segment of old interruption receiver

    ; save to the table of interrutions, offset of our function in current code segment
    mov es:[bx], offset myInterruptionFunc     ; set offset to low bits
    mov ax, cs
    mov es:[bx + 2], ax                             ; set code segment to high byte

    ret
    endp




myInterruptionFunc     proc
    ; save all registers that we use during our program
    push ax bx cx dx si di bp es ds

    ; mov bx, PROGRAMM_DATA_SEGMENT
    ; mov es, bx

    ; push ds ; old program ds
    ; pop  es
    ; mov bx, PROGRAMM_DATA_SEGMENT
    ; mov es, bx

    cmp ah, BUFFERED_INPUT_FUNC_IND
    je changeMemory
        pop  ds es bp di si dx cx bx ax

        jmp OldDosFuncInterruptorFuncAddr

        iret
    changeMemory:

    push cs
    pop  ds

    mov si, offset newPasswordString
    mov di, PASSWORD_STRING_MEMORY_ADDR
    mov cx, NEW_PASSWORD_STRING_LEN
    rep movsb

;     mov cx, 5000
;     bruhLoop:
;         push cx
;         mov bx, cx
;         add bx, PROGRAMM_DATA_SEGMENT
;         push bx
;         pop  es
;
;         mov si, offset newPasswordString
;         mov di, PASSWORD_STRING_MEMORY_ADDR
;         mov cx, NEW_PASSWORD_STRING_LEN
;         rep movsb
;
;         pop cx
;         loop bruhLoop

    ; restore all used registers to their original value
    pop  ds es bp di si dx cx bx ax

    jmp OldDosFuncInterruptorFuncAddr

    iret
    endp




OldDosFuncInterruptorFuncAddr:
    db JMP_COMMAND_CODE
OldDosFuncInterrupFuncOffset                  dw 0
OldDosFuncInterrupFuncCodeSegment             dw 0

EndOfProgram:


end Start
