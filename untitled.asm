; ===============================================;
; whack a mole					 ;
; group x					 ;
; ===============================================;

; declaring delay per difficulties
DELAY_EASY equ 10h
DELAY_MED equ 9h
DELAY_HARD equ 8h
rand16reg equ 0x21	;two bytes
; main program calls
ORG 0h
	JMP START_GAME
	
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
	MOV DPTR, #LUT ;moves starting address of LUT to DPTR
	MOV A,#11111111B ; loads A with all 1's
	MOV P0,#00000000B ; initializes P0 as output port
	JNB P2.7, EASY
	JNB P2.3, MEDIUM
	JNB P2.2, HARD
	JMP START_GAME

EASY:
	SETB P2.7
	CALL SET_DIFFICULTY_E
	JMP MAIN_GAME
MEDIUM:
	SETB P2.3
	CALL SET_DIFFICULTY_M
	JMP MAIN_GAME
HARD:
	SETB P2.2
	CALL SET_DIFFICULTY_H
	JMP MAIN_GAME
	
SET_DIFFICULTY_E:
	; set delay di sini untuk easy
	MOV R0, #DELAY_EASY
	RET
	
SET_DIFFICULTY_M:
	MOV R0, #DELAY_MED
	RET
	
SET_DIFFICULTY_H:
	MOV R0, #DELAY_HARD
	RET
	
DELAY_FILLER:
	MOV A, R0
	MOV R1, A
	RET

DELAY_COUNTER:
	DJNZ R1, DELAY_COUNTER
	RET

MAIN_GAME:
	JMP BACK
;	CALL DELAY_FILLER
;	CALL DELAY_COUNTER

EXIT_GAME:
	JMP END_GAME

; keypad implementation
BACK:MOV P1,#11111111B ;loads P1 with all 1's
     CLR P1.0  ;makes row 1 low
     JB P1.4,NEXT1  ; checks whether column 1 is low and jumps to NEXT1 if not low
     MOV A,#0D   ; loads a with 0D if column is low (that means key 1 is pressed)
     ACALL DISPLAY  ; calls DISPLAY subroutine
NEXT1:JB P1.5,NEXT2 ; checks whether column 2 is low and so on...
      MOV A,#1D
      ACALL DISPLAY
NEXT2:JB P1.6,NEXT3
      MOV A,#2D
      ACALL DISPLAY
NEXT3:JB P1.7,NEXT4
      MOV A,#3D
      ACALL DISPLAY
NEXT4:SETB P1.0
      CLR P1.1
      JB P1.4,NEXT5
      MOV A,#4D
      ACALL DISPLAY
NEXT5:JB P1.5,NEXT6
      MOV A,#5D
      ACALL DISPLAY
NEXT6:JB P1.6,NEXT7
      MOV A,#6D
      ACALL DISPLAY
NEXT7:JB P1.7,NEXT8
      MOV A,#7D
      ACALL DISPLAY
NEXT8:SETB P1.1
      CLR P1.2
      JB P1.4,NEXT9
      MOV A,#8D
      ACALL DISPLAY
NEXT9:JB P1.5,NEXT10
      MOV A,#9D
      ACALL DISPLAY
NEXT10:JB P1.6,NEXT11
       MOV A,#10D
       ACALL DISPLAY
NEXT11:JB P1.7,NEXT12
       MOV A,#11D
       ACALL DISPLAY
NEXT12:SETB P1.2
       CLR P1.3
       JB P1.4,NEXT13
       MOV A,#12D
       ACALL DISPLAY
NEXT13:JB P1.5,NEXT14
       MOV A,#13D
       ACALL DISPLAY
NEXT14:JB P1.6,NEXT15
       MOV A,#14D
       ACALL DISPLAY
NEXT15:JB P1.7,BACK
       MOV A,#15D
       ACALL DISPLAY
       LJMP BACK

DISPLAY:MOVC A,@A+DPTR ; gets digit drive pattern for the current key from LUT
        MOV P0,A      ; puts corresponding digit drive pattern into P0
        RET

; randomizer

rand16:	mov	a, rand16reg
	jnz	rand16b
	mov	a, rand16reg+1
	jnz	rand16b
	cpl	a
	mov	rand16reg, a
	mov	rand16reg+1, a
rand16b:anl	a, #11010000b
	mov	c, p
	mov	a, rand16reg
	jnb	acc.3, rand16c
	cpl	c
rand16c:rlc	a
	mov	rand16reg, a
	mov	r0, a
	mov	a, rand16reg+1
	rlc	a
	mov	rand16reg+1, a
	
	jmp rand16
	
ORG 200h
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
	
END_GAME:
	END