.model tiny


.data

MAX_INPUT_PASSWORD_LEN      equ 255

introMessage                db "Hello, i am simple cracker, crack me please."
                            db "You need to somehow print such a string, that you will be granted access"
                            db "Note, that you're not allowed to change executable program.", 10, "$"

newLineChar                 db 10, "$"
youveEnteredMessage         db "You've entered: $"
pleasePrintMessage          db "Print password: $"
usersPasswordBuffer         db MAX_INPUT_PASSWORD_LEN           ;
                            db 0                                ; number of bytes, that actually have been read
                            db MAX_INPUT_PASSWORD_LEN dup(?)    ; actual string
usersPasswordLen            db 0                                ; WARNING: this byte is same as usersPasswordBuffer[1],
                                                                ; but just for convenience I will add this variable



.code
org 100h

Start:
    call printNewLine
    call printNewLine
    call printEntryMessages     ; show user, what he has to do
    call readUsersPassword      ; read users password
    call echoUsersPassword      ; echo read password

    mov ax, 4c00h               ; end program with exit code 0
    int 21h




printNewLine        proc
    mov ah, 9h
    mov dx, offset newLineChar
    int 21h

    ret
    endp

readUsersPassword       proc
    mov ah, 0ah                              ; code of DOS function that reads to buffer
    mov dx, offset usersPasswordBuffer
    int 21h

    xor al, al                        ; AL = 0
    mov al, [usersPasswordBuffer + 1] ; put num of bytes that have been read to AL
    mov usersPasswordLen, 0                          ; set usersPasswordLen to 0
    mov usersPasswordLen, al              ; save users password len
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


