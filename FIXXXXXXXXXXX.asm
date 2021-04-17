	; ================================================================;
; Kelompok B5 - Praktikum Siber Fisik		 		  ;
; 
; Whack A Mole					 		  ;
; 
; Anggota:
; 1. Muhammad Hadi - 1906355623
; 2. Ahmad Fakhri Mirfananda - 190630065
; 3. Ananda Luqman Mahendra - 190630067
; 4. Seno Aji Wicaksono - 1906300851
;                                         ;
; Description:					 		  ;
; Permainan Whack A Mole ini merupakan permainan yang sering 	  ;
; ditemukan pada arcade dengan memukul mole yang muncul. 	  ;
; Di sini kami mencoba melakukan pengaplikasian dengan MCU 8051	  ;
; ================================================================;

; declaring delay per difficulties
DELAY_EASY equ 10h
DELAY_MED equ 6h
DELAY_HARD equ 3h ;R0
PATTERN equ 6h ;R1
SHIFT_AMOUNT equ 9h ;R2
rand16reg equ 021h ;two bytes

; main program calls
ORG 0h
	JMP START_GAME
	
COUNTUP:
	MOV P2, A
	CJNE A, #0ffh, LETSGO
	CLR A
	RET
LETSGO:
	DJNZ R2, START_SHIFT
	RET
	

; to start shifting subroutine
START_SHIFT:
	JNB P2.0, SHIFTING
	INC R3
	INC R4
	MOV A, R3
	CPL A
	MOV P0, A
	CLR A
	CJNE R4, #3h, CHECK1
	MOV A, R3
	SUBB A, #3h
	MOV R3, A
	MOV A, R4
	SUBB A, #3h
	MOV R4, A
CHECK1:
	CJNE R4, #2h, CHECK2
	MOV A, R3
	SUBB A, #2h
	MOV R3, A
	MOV A, R4
	SUBB A, #2h
	MOV R4, A
CHECK2:
	CJNE R4, #1h, SHIFTING
	MOV A, R3
	SUBB A, #1h
	MOV R3, A
	MOV A, R4
	SUBB A, #1h
	MOV R4, A
	JMP SHIFTING
	
SHIFTING:
	RR A
	JMP COUNTUP
	
START_GAME:
	MOV DPTR, #LUT ;moves starting address of LUT to DPTR
	;MOV A,#11111111B ; loads A with all 1's
	MOV P0,#0ffh ; initializes P0 as output port
	MOV R3, #0FFh
	MOV R5, #0h
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
	MOV R1, #PATTERN
	RET
	
SET_DIFFICULTY_M:
	MOV R0, #DELAY_MED
	MOV R1, #PATTERN
	RET
	
SET_DIFFICULTY_H:
	MOV R0, #DELAY_HARD
	MOV R1, #PATTERN
	RET

DELAY:
	
	MOV TMOD, #00000001B
	MOV TL1, #00H 
	MOV TH1, #00H
	SETB TR1

AGAIN:
	JNB TF1, AGAIN
	CLR TR1
	CLR TF1
	DJNZ R0, DELAY
	RET


MAIN_GAME:
	 
	MOV R2, #SHIFT_AMOUNT
	CALL RAND16
	MOV A, B
	CPL A
	MOV P3, A
	MOV B, A
	MOV R5, B
	;CLR A ; take pattern
	CALL DELAY
	CALL BACK
	XRL A, B
	SUBB A, R5
	ADD A, R5
	CALL COUNTUP
	MOV R4, #0h
	DEC R1
	ANL A, #01010101b
	CJNE R1, #0, MAIN_GAME
	
	JMP START_GAME


EXIT_GAME:
	JMP END_GAME

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
	JB P1.6, CHECK_DONE
       	MOV A,#14D
       	ACALL DISPLAY
       	
CHECK_DONE:
	RET

DISPLAY:MOVC A,@A+DPTR ; gets digit drive pattern for the current key from LUT
	CPL A
        ;MOV P0,A
        CPL A      ; puts corresponding digit drive pattern into P0
        RET

; randomizer

rand16:	
	;ADDC A, #01010101b
	mov	a, rand16reg
	jnz	rand16b
	mov	a, rand16reg+1
	mov 	b, a
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
	mov	r6, a
	mov	b, a
	mov	a, rand16reg+1
	rlc	a
	mov	rand16reg+1, a
	ret
	
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