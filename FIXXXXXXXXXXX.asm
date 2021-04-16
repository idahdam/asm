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
DELAY_EASY equ 10h ; membuat variabel untuk delay easy
DELAY_MED equ 6h ; membuat variabel untuk delay medium
DELAY_HARD equ 3h ; membuat variabel untuk delay hard
PATTERN equ 6h ;banyaknya pattern yang akan muncul yaitu 6x
SHIFT_AMOUNT equ 9h ;banyaknya shift yang akan dilakukan pada register A
rand16reg equ 021h ;two bytes

; main program calls
ORG 0h
	JMP START_GAME ;Jump ke Start game
	
COUNTUP: ;Count up untuk menambah skor
	MOV P2, A
	DJNZ R2, START_SHIFT
	RET
	
START_SHIFT: ;Shifting pada register A 
	JNB P2.0, SHIFTING
	INC R3
	MOV A, R3
	CPL A
	MOV P0, A
	CLR A
	JMP SHIFTING
	
SHIFTING: ;Proses Shifting
	RR A
	JMP COUNTUP
	
START_GAME: ;Memulai game
	MOV DPTR, #LUT ;Mengisi DPTR dengan alamat Look up table
	;MOV A,#11111111B ; Memasukkan A dengan 1 semua
	MOV P0,#00000000B ; P0 sebagai output
	MOV R3, #0FFh ;Mengisi R3 untuk skor dengan FF agar jika diincrement akan dimulai dari 0
	MOV R5, #0h
	JNB P2.7, EASY ;Jump jika difficulty = easy 
	JNB P2.3, MEDIUM ;Jump jika difficulty = medium 
	JNB P2.2, HARD ;Jump jika difficulty = hard 
	JMP START_GAME ;Looping kembali ke awal game jika satu round sudah selesai

EASY:
	SETB P2.7
	CALL SET_DIFFICULTY_E ;Memanggil 
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
	; set delay di sini untuk medium
	MOV R0, #DELAY_MED
	MOV R1, #PATTERN
	RET
	
SET_DIFFICULTY_H:
	; set delay di sini untuk hard
	MOV R0, #DELAY_HARD
	MOV R1, #PATTERN
	RET

DELAY:
	;Fungsi delay berdasarkan timer yang dipengaruhi difficulty
	MOV TMOD, #00000001B
	MOV TL1, #00H 
	MOV TH1, #00H
	SETB TR1

AGAIN:
	JNB TF1, AGAIN
	CLR TR1
	CLR TF1
	DJNZ R0, DELAY ;looping untuk banyaknya delay berdasarkan difficulty
	RET


MAIN_GAME:
	;Fungsi main game mulai disini
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
	DEC R1
	ANL A, #01010101b
	CJNE R1, #0, MAIN_GAME
	
	JMP START_GAME


EXIT_GAME: ;Fungsi untuk keluar dari game
	JMP END_GAME

; implementasi keypad
BACK:
	MOV P1,#11111111B ;Memasukkan P1 dengan 1 semua
     	CLR P1.0  ;membuat p1.0 atau baris pertama menjadi low
     	JB P1.4,NEXT1  ; memeriksa jika kolom 1 low dan jump ke NEXT1 jika tidak low
     	MOV A,#0D   ; Memasukkan A dengan nilai 0 jika kolom low yaitu saat switch ditekan
     	ACALL DISPLAY  ; Memanggil subroutine untuk display
     	
NEXT1:
	JB P1.5,NEXT2 ; Prosedur yang sama dengan pada BACK dilakukan pada semua subroutine next lainnya
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
       	
CHECK_DONE: ;Pemeriksaan jika selesai
	RET

DISPLAY:MOVC A,@A+DPTR ;Pengambilan data dari LUT berdasarkan skor
	CPL A
        ;MOV P0,A
        CPL A      
        RET

; randomizer untuk pattern

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
LUT: ;Lookuptable untuk pemeriksaan pattern dengan input
	DB 10000000B 
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
