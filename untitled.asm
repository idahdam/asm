; ===============================================;
; whack a mole					 ;
; group x					 ;
; ===============================================;

; declaring delay per difficulties
DELAY_EASY equ 10h
DELAY_MED equ 9h
DELAY_HARD equ 8h

; main program calls
ORG 0h
	MOV DPTR, #100h ;moves starting address of LUT to DPTR
	MOV A,#11111111B ; loads A with all 1's
	MOV P0,#00000000B ; initializes P0 as output port
	JMP MAIN
	
MAIN:	
	MOV R1, #8h
	CLR A
	JNB P2.7, START_GAME
	JMP MAIN
	
	;MOV A, #11010000b ; randomizer -> lampu
	;MOV B, #00101000b ; input 
	;XRL A, B
	;SUBB A, #11010000b ; randomizer
	;CALL COUNTUP

;COUNTUP:
;	MOV P3, A
;	DJNZ R1, START_SHIFT
;	JMP MAIN
;	
;START_SHIFT:
;	JNB P3.0, SHITFIING
;	INC R0
;	JMP SHITFIING
;	
;SHITFIING:
;	RR A
;	JMP COUNTUP
;	JNB P0.0, START_GAME ; to start
;	JNB P0.1, EXIT_GAME; to exit
;	JMP MAIN
	
START_GAME:
	
	JNB P1.7, EASY
	JNB P2.6, MEDIUM
	JNB P3.5, HARD
	JMP START_GAME

EASY:
	SETB P1.0
	JMP SET_DIFFICULTY_E
MEDIUM:
	SETB P1.1
	JMP SET_DIFFICULTY_M
HARD:
	SETB P1.2
	JMP SET_DIFFICULTY_H
	
SET_DIFFICULTY_E:
	; set delay di sini untuk easy
	MOV R0, DELAY_EASY
	JMP MAIN_GAME
	
SET_DIFFICULTY_M:
	MOV R0, DELAY_MED
	JMP MAIN_GAME
	
SET_DIFFICULTY_H:
	MOV R0, DELAY_HARD
	JMP MAIN_GAME
	
DELAY_FILLER:
	MOV A, R0
	MOV R1, A
	RET

DELAY_COUNTER:
	DJNZ R1, DELAY_COUNTER
	RET

MAIN_GAME:
	CALL DELAY_FILLER
	CALL DELAY_COUNTER

EXIT_GAME:
	JMP END_GAME
END_GAME:
	END

; keypad implementation
BACK:
	MOV P1,#11111111B ;loads P1 with all 1's
	CLR P1.0  ;makes row 1 low
	JB P1.4,NEXT1  ; checks whether column 1 is low and jumps to NEXT1 if not low
	MOV A,#0D   ; loads a with 0D if column is low (that means key 1 is pressed)
	ACALL DISPLAY  ; calls DISPLAY subroutine
NEXT1:
	JB P1.5,NEXT2 ; checks whether column 2 is low and so on...
	MOV A,#1D
	ACALL DISPLAY
NEXT2:
	JB P1.6,NEXT3
      	MOV A,#2D
      	ACALL DISPLAY
   
NEXT3:
	SETB P1.0
      	CLR P1.1
      	JB P1.4,NEXT4
      	MOV A,#4D
      	ACALL DISPLAY
      	
NEXT4:
	JB P1.5,NEXT5
      	MOV A,#5D
      	ACALL DISPLAY

NEXT5:
	JB P1.6,NEXT6
      	MOV A,#6D
      	ACALL DISPLAY
      	
NEXT6:
	SETB P1.1
      	CLR P1.2
      	JB P1.4,NEXT7
      	MOV A,#8D
      	ACALL DISPLAY
      	
NEXT7:
	JB P1.5,NEXT8
      	MOV A,#9D
      	ACALL DISPLAY
NEXT8:
	JB P1.6,NEXT9
       	MOV A,#10D
       	ACALL DISPLAY

NEXT9:
	SETB P1.2
       	CLR P1.3
       	JB P1.4,NEXT10
       	MOV A,#12D
       	ACALL DISPLAY
       	
NEXT10:
	JB P1.5,NEXT11
       	MOV A,#13D
       	ACALL DISPLAY
       	
NEXT11:
	JB P1.6, BACK
       	MOV A,#14D
       	ACALL DISPLAY
       	LJMP BACK

DISPLAY:
	MOVC A,@A+DPTR ; gets digit drive pattern for the current key from LUT
        MOV P0,A      ; puts corresponding digit drive pattern into P0
        RET

ORG 100h
LUT: 
	DB 10000000B ; Look up table starts here
	DB 01000000B 
	DB 00100000B
	DB 00000000B
	DB 00010000B
	DB 00001000B
	DB 00000100B
	DB 00000000B
	DB 00000000B
	END
