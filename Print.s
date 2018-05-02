; Print.s
; Student names: Sid Singh & Josh Kall
; Last modification date: 5/2/18
; Runs on LM4F120 or TM4C123
; EE319K lab 7 device driver for any LCD
;
; As part of Lab 7, students need to implement these LCD_OutDec and LCD_OutFix
; This driver assumes two low-level LCD functions
; ST7735_OutChar   outputs a single 8-bit ASCII character
; ST7735_OutString outputs a null-terminated string 

    IMPORT   ST7735_OutChar
    IMPORT   ST7735_OutString
    EXPORT   LCD_OutDec
    EXPORT   LCD_OutFix

    AREA    |.text|, CODE, READONLY, ALIGN=2
    THUMB
	PRESERVE8

  

;-----------------------LCD_OutDec-----------------------
; Output a 32-bit number in unsigned decimal format
; Input: R0 (call by value) 32-bit unsigned number
; Output: none
; Invariables: This function must not permanently modify registers R4 to R11
cnt EQU 0	;binding
fp RN 11

LCD_OutDec
	PUSH 	{R4-R7, R11, LR}
	SUB		SP, #4		;allocation
	MOV		fp, SP
	SUB		fp, #400	;make room for branch to other subroutines
	MOV		R4, #0
	STRB	R4, [SP, #cnt]	;access
	MOV		R4, #10
	MOV		R5, #10
	
remainder
	UDIV 	R1, R0, R4
	MUL 	R2, R1, R4		;separate the digits by finding remainder
	SUB 	R2, R0, R2
	SUB		fp, #4
	STRB	R2, [fp]		;store least significant digit on stack
	LDRB	R6, [SP, #cnt]
	ADD		R6, #1				;access
	STRB	R6, [SP, #cnt]
	MOV		R0, R1
	;MUL		R4, R4, R5
	CMP		R0, #0
	BNE remainder
	
readStack
	LDRB	R0, [fp]		;read next most significant digit from stack
	ADD		fp, #4
	ADD		R0, #0x30		;convert to ascii form
	BL		ST7735_OutChar
	LDRB	R6, [SP, #cnt]
	SUB		R6, #1				;access
	STRB	R6, [SP, #cnt]
	CMP		R6, #0
	BEQ 	ret
	B		readStack
	
ret
	ADD SP, #4		;deallocation
	POP {R4-R7, R11, LR}
	BX   LR
;* * * * * * * * End of LCD_OutDec * * * * * * * *

; -----------------------LCD _OutFix----------------------
; Output characters to LCD display in fixed-point format
; unsigned decimal, resolution 0.001, range 0.000 to 9.999
; Inputs:  R0 is an unsigned 32-bit number
; Outputs: none
; E.g., R0=0,    then output "0.000 "
;       R0=3,    then output "0.003 "
;       R0=89,   then output "0.089 "
;       R0=123,  then output "0.123 "
;       R0=9999, then output "9.999 "
;       R0>9999, then output "*.*** "
; Invariables: This function must not permanently modify registers R4 to R11
LCD_OutFix
	PUSH 	{R4-R8, LR}
	SUB 	SP, #4	;allocation
	MOV 	R4, #9999
	CMP 	R0, R4 ; check if number is 10,000 or greater
	BHI 	stars
	MOV 	fp, SP	; move stackpointer into FP
	MOV 	R4, #10
	STRB 	R4, [SP, #cnt]	;store 10 onto stack
	LDRB 	R5, [SP, #cnt] ;load number into R4 using fp

remainderloop ; find the remainder 
	SUB 	R4, #1
	UDIV 	R6, R0, R5 ;divide by 10
	MUL 	R7, R6, R5
	SUB 	R7, R0, R7	;find remainder
	STRB 	R7, [SP, #-4]	;store remainder one address higher
	SUB 	SP, #4	;move stackpointer to where remainder is
	MOV 	R0, R6	;R0 has rest of the number
	CMP 	R4, #0
	BNE 	remainderloop	;loop to run 10 times
	
fdigit ; scan first digit
	LDRB 	R0, [SP]
	LDRB 	R6, [SP, #4*4]
	CMP 	R6, #10 ;look for 0 in the first digit place
	BEQ 	print0
	ADD 	SP, #4
	CMP 	R0, #0
	BEQ 	fdigit
	SUB 	SP, #4
		
ploopfix
	LDRB 	R0, [SP] 
	CMP 	R0, #10 ;check for end of number
	BEQ 	retfix
	
printfix
	ADD 	R0, #0x30 ;convert to ASCII
	BL		ST7735_OutChar ;print number
	ADD 	SP, #4
	B		ploopfix
	
print0
	ADD 	R0, #0x30
	BL		ST7735_OutChar ;print 0
	MOV 	R0, #0x2E
	BL		ST7735_OutChar ;print .
	ADD 	SP, #4
	B 		ploopfix
	
stars 						;prints *.***
	MOV 	R0,#0x2A ;*
	BL		ST7735_OutChar
	MOV 	R0,#0x2E ;.
	BL		ST7735_OutChar
	MOV 	R0,#0x2A
	BL		ST7735_OutChar
	MOV 	R0,#0x2A
	BL		ST7735_OutChar
	MOV 	R0,#0x2A
	BL		ST7735_OutChar
	
retfix
	ADD 	SP, #4 ;deallocate
	POP 	{R4-R8, LR} ; AAPCS
    BX   LR
 
     ALIGN
;* * * * * * * * End of LCD_OutFix * * * * * * * *

     ALIGN                           ; make sure the end of this section is aligned
     END                             ; end of file
