.model small
.data
 secret_number Db 0
 user_guess Db 0      

 MSG_PROMPT_INPUT DB 'Enter your guess (0-99): $'
 MSG_ERROR_OUT_OF_RANGE DB 'Error: Out of range. Please enter a number between 0 and 99.', 13, 10, '$'
MSG_RESULT_LOWER DB 'Your guess is lower than the secret number.', 13, 10, '$'
MSG_RESULT_HIGHER DB 'Your guess is higher than the secret number.', 13, 10, '$'
MSG_RESULT_CORRECT DB 'Congratulations! You guessed the secret number correctly.', 13, 10, '$'
retry  db  'Retry [y/n] ? ' ,13, 10,'$'

.stack
.code
    main proc far
   
        .STARTUP

        ; Generate random number between 0 and 99 from geeting time interrupt
       MOV AH, 00h  ; Get system time
    INT 1Ah
    MOV AH, 00h  ; Get system time again (for more randomness)
    INT 1Ah
    ADD DX, CX   ; Combine low and high bytes of system time
    MOV AH, 0
    MOV AL, DL
    MOV CL, 64   ; Divide by 64 to get a number between 0 and 99
    DIV CL
    MOV secret_number, AH  ; Store the secret number
    mov dl,secret_number
    
    
user_input:
    ;  user for input
    MOV AH, 09H
    LEA DX, MSG_PROMPT_INPUT
    INT 21H

    ; Read user input
    MOV AH, 01H
    INT 21H

    ; Check if input is within range (0-99)
    CMP Al, '0'
    JL input_out_of_range
    CMP Al, '9'
    JG input_out_of_range

    ; Read the second digit
    MOV AH, 01H
    INT 21H

    ; Check if the second digit is within range (0-9)
    CMP AL, '0'
    JL input_out_of_range
    CMP AL, '9'
    JG input_out_of_range

    ; Convert input to number
    SUB AL, '0'
    MOV AH, 0
    MOV user_guess, Al

    ; Compare user guess with secret number
    CMP Al,dl
    JL user_guess_lower
    JG user_guess_higher
    JMP user_guess_correct

input_out_of_range:
    ; Print error message
    MOV AH, 09H
    LEA DX, MSG_ERROR_OUT_OF_RANGE
    INT 21H
    JMP user_input

user_guess_lower:
    ; Print result message
    MOV AH, 09H
    LEA DX, MSG_RESULT_LOWER
    INT 21H
    JMP user_input

user_guess_higher:
    ; Print result message
    MOV AH, 09H
    LEA DX, MSG_RESULT_HIGHER
    INT 21H
    JMP user_input

user_guess_correct:
    ; Print result message
    MOV AH, 09H
    LEA DX, MSG_RESULT_CORRECT
    INT 21H

    retry_while:
 
    MOV dx, offset retry    ; load address of 'prompt' message to DX
 
    MOV ah, 9h            
    INT 21h                 
 
    MOV ah, 1h              
    INT 21h  
    
    CMP al, 6Eh             ; check if input is 'n'
    JE exit_program        ; call 'return_to_DOS' label is input is 'n'
 
    CMP al, 79h             ; check if input is 'y'
    JE restart              ; call 'restart' label is input is 'y' ..
                            ;   "JE start" is not used because it is translated as NOP by emu8086
 
    JMP restart        ; if input is neither 'y' nor 'n' re-ask the same question
 

 
restart:
    JMP MAIN              ; JUMP to begining of program
    
exit_program:
    ; Terminate program
    .exit
    
    main endp
    
    end main