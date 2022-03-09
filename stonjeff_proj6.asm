TITLE String Primitives and Macros   (stonjeff_proj6.asm)

; Author: Jeff "Gent" Stone
; Last Modified: 3/8/2022
; OSU email address: stonjeff@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6            Due Date: 3/13/2022
; Description: This file is provided as a template from which you may work
;              when developing assembly projects in CS271.

INCLUDE Irvine32.inc

; ------------------------------------------------------------------------------------
; Name: mGetString
; Description: This macro displays a message to user and then takes keyboard input
; Preconditions: 
; Postconditions: 
; Receives:	promptAddr, bufferAddr, maxStrLen, strLenAddr where:
;			promptAddr	= address of prompt message (input, reference)
;			bufferAddr  = address of entered string/buffer (output, reference)
;			maxStrLen   = max length (bytes) of string (input, value)
;			strLenAddr  = address of string length (bytes) value (output, reference)
; Returns:  string value to referenced address and 
; ------------------------------------------------------------------------------------
mGetString MACRO promptAddr:REQ, bufferAddr:REQ, maxStrLen:REQ, strLenAddr:REQ
  push		eax
  push		ecx
  push		edx
  mov		edx,	promptAddr
  call		WriteString
  mov		edx,	bufferAddr		; Address of buffer
  mov		ecx,	maxStrLen		; buffer size
  call		ReadString
  mov		edi,	strLenAddr		; move address of user string to edi
  mov		[edi],	eax				; 
  pop		edx
  pop		ecx
  pop		eax
ENDM

; ------------------------------------------------------------------------------------
; Name: mDisplayString
; Description: 
; Preconditions: 
; Postconditions: 
; Receives: 
; Returns:  
; ------------------------------------------------------------------------------------
mDisplayString MACRO stringAddr:REQ
  push		edx
  mov		edx,	stringAddr
  call		WriteString
  pop		edx
ENDM

.const								

; CONSTANTS
LOOP_COUNT equ 10

.data

; STATEMENTS
  introMsg		BYTE	"Project 6: String Primitives and Macros.", 09, "By Gent Stone", 13, 10, 10
				BYTE	"This program will ask you to enter 10 signed integers.", 13, 10
				BYTE	"The integers must be between -2147483648 and +2147483647.", 13, 10
				BYTE	"The program will display the 10 integers, their sum and truncated average.", 13, 10
				BYTE	"**EC1: Each line of valid input will display the line number and current subtotal.", 13, 10
				BYTE	"**EC2: You will also be asked to enter 10 decimal (floating point) integers,", 13, 10
				BYTE	"which will be displayed, along with their sum and average.", 13, 10, 10, 0
  intPromptMsg	BYTE	"Enter an integer: ", 0
  decPromptMsg	BYTE	"Enter a decimal integer: ", 0
  invalidMsg	BYTE	"ERROR: Invalid input. Please try again: ", 0
  enteredMsg	BYTE	"You entered the following integers:", 13, 10, 0
  sumMsg		BYTE	"The sum of these integers is: ", 0
  truncAvgMsg	BYTE	"The truncated average of these integers is: ", 0
  avgMsg		BYTE	"The average of these decimal integers is: ", 0
  byeMsg		BYTE	"Thanks for using this program. Goodbye!", 13, 10, 10, 0
  spacer		BYTE	", ", 0
  period		BYTE	". ", 0

; VARIABLES
  intArray		SDWORD	LOOP_COUNT	DUP(?)	; List to hold the user-entered integers
  decIntArray	REAL10	LOOP_COUNT	DUP(?)	; List to hold the user-entered decimal integers
  intCountArray	DWORD	LOOP_COUNT	DUP(?)	; List to hold the 
  intSum		SDWORD	?
  intAvg		SDWORD	?
  lineNum		DWORD	?					; Tracks current line number
  decIntSum		REAL10	?
  decIntAvg		REAL10	?
  loopCount		DWORD	LOOP_COUNT			; Tracks the loop count
  sign			SDWORD	?					; set depending on input of user (1 - pos or -1 - neg)
  maxBytes		DWORD	?					;
.code
main PROC

;---------------------------------------------------------------
; Introduction - invoke mDisplayString and pass introMsg parameter
;---------------------------------------------------------------
  mDisplayString	OFFSET	introMsg

;---------------------------------------------------------------
; ReadVal
;---------------------------------------------------------------

;---------------------------------------------------------------
; WriteVal
;---------------------------------------------------------------

;---------------------------------------------------------------
; Entered integers sum & average
;---------------------------------------------------------------


;---------------------------------------------------------------
; ReadFloatVal
;---------------------------------------------------------------


;---------------------------------------------------------------
; WriteFloatVal
;---------------------------------------------------------------


;---------------------------------------------------------------
; Entered decimal integers sum & average
;---------------------------------------------------------------


;---------------------------------------------------------------
; Goodbye - invoke mDisplayString and pass byeMsg parameter
;---------------------------------------------------------------
  mDisplayString	OFFSET	 byeMsg

	Invoke ExitProcess,0	; exit to operating system

main ENDP


; ------------------------------------------------------------------------------------
; Name: ReadVal procedure
; Description: 
; Preconditions: 
; Postconditions: 
; Receives: 
; Returns:  
; ------------------------------------------------------------------------------------


; ------------------------------------------------------------------------------------
; Name: WriteVal procedure
; Description: 
; Preconditions: 
; Postconditions: 
; Receives: 
; Returns:  
; ------------------------------------------------------------------------------------

; ------------------------------------------------------------------------------------
; Name: ReadFloatFal procedure
; Description: 
; Preconditions: 
; Postconditions: 
; Receives: 
; Returns:  
; ------------------------------------------------------------------------------------

; ------------------------------------------------------------------------------------
; Name: WriteFloatVal procedure
; Description: 
; Preconditions: 
; Postconditions: 
; Receives: 
; Returns:  
; ------------------------------------------------------------------------------------

END main
