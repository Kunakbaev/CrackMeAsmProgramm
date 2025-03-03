.model tiny

.data

TERMINATOR_SYMBOL                               equ '$'

newLineChar                 db 10, "$"
; newPasswordString                               db "hacker"
newPasswordString                               db 61, 52, 54, 62, 48, 39    ; = "hacker" ^ 85 (55 in hex)
isActive                                        db 0
siPosition                                      dw 0
;charsSequence                                   db "abcdefg", TERMINATOR_SYMBOL
charsSequence                                   db 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 0b4h, 0ah, 0bah, 38h, 01h,        0cdh, 21h, 0a0h, 39h, 01h, 03ch, 00h, 0ebh, 1ch, 0b4h, TERMINATOR_SYMBOL



DOS_COMMON_INTERRUPTION_CODE                    equ 21h
BUFFERED_INPUT_FUNC_IND                         equ 0Ah
TIMER_INT_CODE                                  equ 08h
TERMINATE_AND_STAY_RESIDENT_FUNC_CODE           equ 3100h
JMP_COMMAND_CODE                                equ 0eah

.code
org 100h

Start:

    cli     ; processor stops  considering interruptions
            ; (we don' want any interruptions to happen while we chantge table of interruptions)
    call loadDosCommonFuncInterruptorAndSavePrev
    call loadMyTimerInterruptorAndSavePrev
    sti     ; processor starts considering interruptions

    mov siPosition, offset charsSequence

        ; finish program, but it stay's as a resident in memory and continues to work
    mov ax, TERMINATE_AND_STAY_RESIDENT_FUNC_CODE
    mov dx, offset EndOfProgram     ; size of our programm in bytes
    add dx, 1200

    shr dx, 4                       ; system func requires size in paragraphs (each paragraph is 16 bytes)
    inc dx                          ; in case if dx has a remainder when we divide it by 16
    ;add dx, 100
    int 21h


; ---------------------------------         NEW INTERRUPTION FUNCS        ------------------------------------

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


loadMyTimerInterruptorAndSavePrev       proc
    xor ax, ax ; ax = 0
    mov es, ax
    mov bx, TIMER_INT_CODE * 4     ; save timer interruption code

    mov ax, es:[bx]
    mov OldTimerInterrupFuncOffset, ax       ; save offset of old interruption receiver
    mov ax, es:[bx + 2]
    mov OldTimerInterrupFuncCodeSegment, ax  ; save code segment of old interruption receiver

    ; save to the table of interrutions, offset of our function in current code segment
    mov es:[bx], offset myTimerInterruptionFunc     ; set offset to low bits
    mov ax, cs
    mov es:[bx + 2], ax                             ; set code segment to high byte

    ret
    endp









; Entry  : CL - char code to store
pressGivenChar      proc
    mov ah, 05h
    int 16h

    ret
    endp


myTimerInterruptionFunc     proc
    ; save all registers that we use during our program
    push ax bx cx dx si di bp es ds



    push cs
    pop  ds
    cmp isActive, 1
    je pressKeyFromSeq
        ; restore all used registers to their original value
        pop  ds es bp di si dx cx bx ax
        jmp OldTimerInterruptorFuncAddr
        iret
    pressKeyFromSeq:



    xor ax, ax ; AX = 0
    mov si, siPosition
    lodsb
    inc siPosition
    mov cl, al
    call pressGivenChar

    cmp cl, TERMINATOR_SYMBOL
    jne continueSpammingSymbols
        mov isActive, 0
    continueSpammingSymbols:



    ; restore all used registers to their original value
    pop  ds es bp di si dx cx bx ax

    jmp OldTimerInterruptorFuncAddr

    iret
    endp


myInterruptionFunc     proc
    ; save all registers that we use during our program
    push ax bx cx dx si di bp es ds

    cmp ah, BUFFERED_INPUT_FUNC_IND
    je changeState
        pop  ds es bp di si dx cx bx ax
        jmp OldDosFuncInterruptorFuncAddr
        iret
    changeState:

    mov cs:isActive, 1

    pop  ds es bp di si dx cx bx ax
    jmp OldDosFuncInterruptorFuncAddr
    iret

    endp


OldDosFuncInterruptorFuncAddr:
    db JMP_COMMAND_CODE
OldDosFuncInterrupFuncOffset                  dw 0
OldDosFuncInterrupFuncCodeSegment             dw 0


OldTimerInterruptorFuncAddr:
    db JMP_COMMAND_CODE
OldTimerInterrupFuncOffset                  dw 0
OldTimerInterrupFuncCodeSegment             dw 0

EndOfProgram:


end Start
