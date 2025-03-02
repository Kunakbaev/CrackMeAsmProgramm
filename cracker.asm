.model tiny


.data

BASE_TEN                    equ 10
MAX_NUMBER_STRING_LEN       equ 8
MAX_INPUT_PASSWORD_LEN      equ 11
HASH_BASE                   equ 857
HASH_MODULE                 equ 0fa91h
; HASH_MODULE                 equ 1820
; password = 913267
correctPasswordHash         equ 56637

introMessage                db "Hello, i am simple cracker, crack me please."
                            db " You need to somehow print such a string, that you will be granted access."
                            db " Note, that you're not allowed to change executable program.", 10, "$"

hintMessage                 db "Hint: password len is <= 7, password contains only decimal digits"
newLineChar                 db 10, "$"
youveEnteredMessage         db "You've entered: $"
pleasePrintMessage          db "Print password: $"

accessDenied                db "Access denied$"
accessGranted               db "Access granted$"

bufferForNum2StringFunc     db MAX_NUMBER_STRING_LEN dup(?)

; put buffer memory to the end of local variables just in case
usersPasswordLen            db 0                                ; WARNING: this byte is same as usersPasswordBuffer[1],
                                                                ; but just for convenience I will add this variable
usersPasswordBuffer         db MAX_INPUT_PASSWORD_LEN           ;
                            db 0                                ; number of bytes, that actually have been read
                            db MAX_INPUT_PASSWORD_LEN dup(?)          ; actual string

.code
org 100h

; write 123456789012345678 in order to hack program

Start:
    call printNewLine
    call printNewLine
    call printEntryMessages     ; show user, what he has to do
    call readUsersPassword      ; read users password
    call echoUsersPassword      ; echo read password

    mov  si, offset usersPasswordBuffer
    call countStringHash
    ; push ax
    ; call printAxNumber
    ; pop  ax

    ; call echoUsersPasswordHash  ; echo hash of users password string

    call comparePasswords



    mov ax, 4c00h               ; end program with exit code 0
    int 21h




printNewLine        proc
    mov ah, 9h
    mov dx, offset newLineChar
    int 21h

    ret
    endp

; Entry  : AX - number to transform
; Exit   : puts string to buffer
;          SI - string start
; Destr  : BX, DX
numberToString      proc
    add si, MAX_NUMBER_STRING_LEN - 2
    mov byte ptr [si + 1], '$'

    digitsLoop:
        ; AX /= 10, remainder is stored to DX
        mov dx, 0
        mov bx, BASE_TEN
        div bx

        add dl, '0'
        mov byte ptr [si], dl
        dec si

        ; if number is zero than it has no more digits to be stored
        cmp ax, 0
        jne digitsLoop
    ; mov byte ptr [si + MAX_NUMBER_STRING_LEN - 1], '$'
    inc si

    ret
    endp

printAxNumber       proc
    push bx
    mov bx, ax

    ; store string representation of AX to buffer
    mov si, offset bufferForNum2StringFunc
    call numberToString

    ; output that buffer
    mov ah, 9h
    mov dx, si
    int 21h

    call printNewLine

    pop  bx
    ret
    endp

readUsersPassword       proc
    mov ah, 0ah                              ; code of DOS function that reads to buffer
    mov dx, offset usersPasswordBuffer
    int 21h

    xor al, al                        ; AL = 0
    mov al, [usersPasswordBuffer + 1] ; put num of bytes that have been read to AL
    mov usersPasswordLen, al          ; save users password len
    call printNewLine

    ret
    endp

echoUsersPassword       proc
    ; WARNING: string len can be eq to MAX_LEN
    mov si, offset usersPasswordBuffer
    xor ax, ax                  ; set AX = 0
    mov al, usersPasswordLen    ; get num of chars read
    add si, ax
    add si, 2
    ; si now points to char after last read symbol
    ; we set this char to '$', so DOS printer function will work fine
    mov al, '$'
    mov byte [si], al
    mov ah, 9h

    mov ah, 09h                 ; print message for user
    mov dx, offset youveEnteredMessage
    int 21h

    mov dx, offset usersPasswordBuffer
    add dx, 2
    int 21h
    call printNewLine

    ret
    endp


; counts polynomial hash of string
; Entry : SI - memory address of string buffer
; Exit  : AX - hash of string
; Destr : CX
countStringHash         proc
    xor ax, ax      ; AX = 0

    inc si
    xor cx, cx      ; CX = 0
    mov cl, [si]    ; CX = number of bytes in users password string

    cmp cx, 0
    jne notEmptyString
        ; string len is 0, string is empty, so hash is 0
        mov ax, 0
        ret
    notEmptyString:

    inc si          ; move to actual string
    charsCycle:
        ; AX *= HASH_BASE
        mov bx, HASH_BASE
        mul bx

        ; AX %= HASH_MODULE
        mov bx, HASH_MODULE
        div bx
        mov ax, dx

        xor bx, bx      ; BX = 0
        mov bl, [si]
        add ax, bx
        inc ax  ; if all characters are equal to char 0, than no matter what len string has, hash will be always eq to 0
        inc si

        ; AX %= HASH_MODULE
        xor dx, dx          ; DX = 0
        mov bx, HASH_MODULE
        div bx
        mov ax, dx

        loop charsCycle

    ret
    endp

; Checks if users password is correct, if so, gives access
; Entry : AX - users password hash
; Exit  : None
; Destr : AX, DX
comparePasswords        proc
    ; I am super trivial smily vulnerability
    cmp ax, 2
    jne notTrivialVulnerability
        jmp grantAccess
    notTrivialVulnerability:


    sub ax, correctPasswordHash
    cmp ax, 0
    je grantAccess
        mov dx, offset accessDenied
        jmp grantAccessIfEnd
    grantAccess:
        mov dx, offset accessGranted
    grantAccessIfEnd:

    ; output message to screen
    mov ah, 09h
    int 21h

    ret
    endp




; Prints entry messages, shows user, what his goal is
; Entry  : None
; Exit   : None
; Destr  : ah, di
printEntryMessages      proc
    mov ah, 9h
    mov dx, offset introMessage
    int 21h

    mov ah, 9h
    mov dx, offset pleasePrintMessage
    int 21h

    ret
    endp

end Start


