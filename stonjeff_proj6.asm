TITLE String Primitives and Macros   (stonjeff_proj6.asm)

; Author: Jeff "Gent" Stone
; Last Modified: 3/9/2022
; OSU email address: stonjeff@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6            Due Date: 3/13/2022
; Description: This file is provided as a template from which you may work
;              when developing assembly projects in CS271.

INCLUDE Irvine32.inc

; ------------------------------------------------------------------------------------
; Name: mDisplayString 
; Description: This macro displays string statements to the console
; Preconditions: Statement variables declared and passed by reference.
; Postconditions: Statement displayed to console
; Receives: stringAddr (input, reference)
; Returns:  N/A
; ------------------------------------------------------------------------------------
mDisplayString	MACRO	stringAddr:REQ
  push	edx
  mov	edx,	stringAddr
  call	WriteString
  pop	edx
ENDM

; ------------------------------------------------------------------------------------
; Name: mGetString
; Description:	This macro displays a message prompt to user by invoking mDisplayString
;				and then calls ReadString to receive keyboard input from user, which is 
;				passed to a buffer with restricted size.
; Preconditions:  Message prompt string & string buffer declared and addresses passed 
;				  by reference. Size of buffer passed by value.
; Postconditions: Prompt displayed and user-entered value returned in edx, size of user 
;				  entry (in bytes) moved from eax to byteCount
; Receives:	promptAddr, bufferAddr, BUFF_SIZE, where:
;			promptAddr	= address of prompt message (input, reference)
;			bufferAddr	= address of entered string/buffer (output, reference)
;			BUFF_SIZE	= max length (20 bytes) of string (input, value)
; Returns:	EDX = buffer address of user string
;			EAX = number of characters entered which is moved to byteCount
;			byteCount	= number of characters in bytes (output, reference)
; ------------------------------------------------------------------------------------
mGetString	MACRO	promptAddr:REQ, bufferAddr:REQ, byteCount:REQ
  push	eax
  push	ecx
  push	edx
  mDisplayString	promptAddr

  mov	edx,		bufferAddr	; point to the buffer
  mov	ecx,		BUFF_SIZE	; specify max character allowed in string
  call	ReadString
  mov	byteCount,	eax			; number of characters entered moved FROM EAX to byteCount
  pop	edx
  pop	ecx
  pop	eax
ENDM

.const								

; CONSTANTS
INT_COUNT	equ 10
BUFF_SIZE	equ	23	

.data

; STATEMENTS
  introMsg		BYTE	"Project 6: String Primitives and Macros.", 09, "By Gent Stone", 13, 10, 10, 0
  intInstruct	BYTE	"This program will ask you to enter 10 signed integers.", 13, 10
				BYTE	"Each of the integers and their sum must fit within a 32-bit register.", 13, 10
				BYTE	"You can only enter 0, + or - in front of the integers.", 13, 10
				BYTE	"The program will display the 10 integers, their sum and truncated average.", 13, 10
				BYTE	"**EC1: Each line of valid input will display the line number and current subtotal.", 13, 10
				BYTE	"**EC2: You will also be asked to enter 10 decimal (floating point) integers,", 13, 10
				BYTE	"which will be displayed, along with their sum and average.", 13, 10, 10
				BYTE	"You will now enter the first 10 integers!", 13, 10, 10, 0
  fltInstruct	BYTE	"You will now enter 10 decimal (floating point) integers.", 13, 10, 10, 0
				BYTE	"Each of the decimal integers and their sum fit within a 32-bit register.", 13, 10
				BYTE	"You can only enter 0, + or - in front of the integers and a decimal . as a radix.", 13, 10, 10, 0
  intPromptMsg	BYTE	"Enter an integer: ", 0
  decPromptMsg	BYTE	"Enter a decimal integer: ", 0
  errorMsg		BYTE	"ERROR: Invalid input. Please try again: ", 0
  subtotalMsg	BYTE	"The current subtotal is: ", 0
  enteredMsg	BYTE	"You entered the following integers:", 13, 10, 0
  sumMsg		BYTE	"The sum of these integers is: ", 0
  truncAvgMsg	BYTE	"The truncated average of these integers is: ", 0
  avgMsg		BYTE	"The average of these decimal integers is: ", 0
  byeMsg		BYTE	"Thanks for using this program. Goodbye!", 13, 10, 10, 0
  spacer		BYTE	", ", 0
  period		BYTE	". ", 0

; VARIABLES
  intArray		SDWORD	INT_COUNT	DUP(?)	; List to hold the user-entered integers
  decIntArray	REAL4	INT_COUNT	DUP(?)	; List to hold the user-entered decimal integers
  intCountArray	DWORD	INT_COUNT	DUP(?)	; List to hold the 
  intSum		SDWORD	?					; Sum of integers
  intAvg		SDWORD	?					; Average of integers
  lineNum		DWORD	?					; Tracks current line number
  decIntSum		REAL4	?					; Sum of decimal integers
  decIntAvg		REAL4	?					; Average of decimal integers
  intCount		DWORD	INT_COUNT			; Used with FILD to convert int to float
  stringBuffer	BYTE	BUFF_SIZE	DUP(?)	; Buffer array to hold user-entered string
  stringCount	DWORD	?					; Tracks number of user-entered characters after 
											; ReadString called to set counter in char loop

.code
main PROC

;---------------------------------------------------------------
; Introduction - invoke mDisplayString and pass introMsg parameter
;---------------------------------------------------------------
  mDisplayString	OFFSET	introMsg
  mDisplayString	OFFSET	intInstruct

;---------------------------------------------------------------
; Build Integer Array - Displays line number and then sets up loop 
;	to call the ReadVal procedure which reads user character input 
;	as a string, checks that string input is valid & then casts to 
;	integer,then moves to integer array and returns to loop.
;	Current subtotal is displayed by invoking mDisplayString with
;	subtotal message and calling WriteVal to display subtotal.
;	Then line number is incremented and loop continues until ECX = 0.
;---------------------------------------------------------------
  mov	ecx,		INT_COUNT		
  mov	lineNum,	1
_BuildArray:
  push	lineNum								; Display line number by
  call	WriteVal							; calling WriteVal
  mDisplayString	OFFSET		period
											; Push statement parameters to
  push	OFFSET		errorMsg				; [ebp + 24]
  push	OFFSET		intPromptMsg			; [ebp + 20]
  push	OFFSET		intArray				; [ebp + 16]
  push	OFFSET		stringCount				; [ebp + 12]
  push	OFFSET		stringBuffer			; [ebp + 8]
  call	ReadVal								; and call ReadVal procedure

  mov	eax,		[edi]					; move entered value to eax
  add	intSum,		eax						; increment subtotal
  mDisplayString	OFFSET		subtotalMsg	; Display subtotal message
  push	intSum
  call	WriteVal							; Display subtotal

  call	CrLf
  add	edi,		TYPE		intArray	; iterate index of array (4 bytes)
  inc	lineNum
  LOOP	_BuildArray

;---------------------------------------------------------------
; Display integers - Invoke mDisplayString to display user-entered values message 
;	and then push the address integer array and stringBuffer to WriteVal
;	set a loop (size of intArray) to display all entered integers from the 
;	the array as strings in WriteVal, separated by a spacer (comma and space)
;	by invoking mDisplayString with the spacer string.
;---------------------------------------------------------------
  mDisplayString	OFFSET		enteredMsg	; Display integers entered message
  mov	ecx,		INT_COUNT				; Set counter
  mov	esi,		OFFSET		intArray	; move address of array to esi
_DisplayArray:
  push	OFFSET		stringBuffer			; [ebp + 12]
  push	[esi]								; [ebp + 8] push currently referenced value of esi
  call	WriteVal
  add	esi,		TYPE		intArray	; increment to next index address in array
  cmp	ecx,		1						; Check whether integer is last in array
  je	_NoSpacer
  mDisplayString	OFFSET		spacer		; Invoke mSisplayString to display spacer
_NoSpacer:
  LOOP	_DisplayArray
  call	CrLf

;---------------------------------------------------------------
; Display sum & average of the user-entered integers. 
;	Current subtotal is known, so invoke mDisplayString to display
;	sum message and then call WriteVal procedure to display sum.
;	Divide sum by number of integers (10) and invoke mDisplayString
;	to display the truncated average message and call WriteVal to 
;	display the rounded (down) value. 
;---------------------------------------------------------------
  mDisplayString	OFFSET		sumMsg
  push	intSum								; [ebp + 8]
  call	WriteVal
  call	CrLf

  mov	eax,		intSum
  cdq
  mov	ebx,		INT_COUNT
  idiv	ebx									; Divide sum by # of values (10)	
  mov	intAvg,		eax						; to obtain average
  mDisplayString	OFFSET		truncAvgMsg	; Invoke mDisplayString
  push	intAvg
  call	WriteVal							; Call WriteVal to display average
  call	CrLf
  call	CrLf


;---------------------------------------------------------------
; ReadFloatVal
;---------------------------------------------------------------
  mDisplayString	OFFSET	fltInstruct

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
; Description:	Invokes mGetString to read string from user keyboard input, checks if valid 
;				entry, casts from ASCII string to signed int, passes integer to main
; Preconditions: stringBuffer, stringCount, intArray, intPromptMsg & errorMsg declared and passed
; Postconditions: intArray with 10 valid (<= 32-bit) signed integers returned to loop in main
; Receives: stringBuffer (output, reference) = [ebp + 8] array to hold input string, 
;	stringCount (input, value) = [ebp + 12] holds value of characters entered in string, 
;	intArray (output, reference) = [ebp + 16] array to hold cast integers, 
;	intPromptMsg (input, reference) = [ebp + 20] message to prompt user for integers, 
;	errorMsg (input, reference) = [ebp + 24] message that user input is invalid
; Returns:  edi with array of user-entered integers
; ------------------------------------------------------------------------------------
ReadVal	PROC
  LOCAL accum:SDWORD, sign:SDWORD			; Declaring LOCAL variables pushes ebp and moves esp to ebp
  push	eax									; accum = temp variable for current accumulator value
  push	ebx									; sign  = variable which sets current integer + or - 
  push	ecx
  push	edx
  push	esi
  push	edi

_GetString:
  mov	esi,	[ebp + 8]
  mGetString	[ebp + 20], esi, [ebp + 12]	; invoke macro to prompt user & get string
  mov	ecx,	[ebp + 12]					; Set counter to length of string
  mov	edi,	[ebp + 16]					; Move address of intArray to edi
  mov	sign,	1							; Set depending on input of user (1 - pos or -1 - neg)
  CLD										; Set direction flag to terate forward through array

  LODSB										; mov al, [esi] & inc esi
  cmp	al,		43							; & check whether first character is
  je	_PlusChar							; + or
  cmp	al,		45
  je	_MinusChar							; - symbol and then
  dec	esi									; If no +/- symbol then dec esi to check digit
  xor	eax,	eax							; empty the upper range of the accumulator
  jmp	_CharCheck

_MinusChar:									; set sign accordingly to
  mov	sign,	-1							; negative signed integer
_PlusChar:									; is positive signed integer
  dec	ecx
  xor	eax,	eax							; empty the upper range of the accumulator

_CharCheck:
  mov	ebx,	10
  imul	ebx									; multiply accumulator by 10 & if overflow flag
  jo	_Error								; set then invalid entry (exceeds register)
  mov	accum,	eax							; Save current accumulator
  xor	eax,	eax
  LODSB										; Increment ESI
  cmp	al,		48							; if less than 0 or
  jb	_Error
  cmp	al,		57							; greater than 9 then invalid entry
  ja	_Error
  sub	al,		48							; subtract 48 to cast ASCII to int
  cmp	sign,	1
  je	_Positive
  neg	eax									; * -1 if sign is negative

_Positive:
  add	eax,	accum						; Return accumulator
  jo	_Error								; If overflow then invalid, otherwise
  LOOP	_CharCheck

  mov	[edi],	eax							; move current integer to intArray
  jmp	_End

_Error:
  mdisplayString [ebp + 24]					; Display error message and
  jmp	_GetString							; return to prompt and get new string entry

_End:
  pop	edi
  pop	esi
  pop	edx
  pop	ecx
  pop	ebx
  pop	eax
  ret 24									; return to main
ReadVal	ENDP

; ------------------------------------------------------------------------------------
; Name: WriteVal procedure
; Description: Casts integers within the array to ASCII strings and invokes mDisplayString 
;	to display values to the console.
; Preconditions:	Array filled with 10 SDWORD integers
; Postconditions:	Integer is displayed to console
; Receives: value at current index of intArray (input, indirect operand) =  [ebp + 8]
;	stringBuffer (output, reference) = [ebp + 12] array to hold ASCII strings
; Returns:  N/A
; ------------------------------------------------------------------------------------
WriteVal	PROC
  LOCAL	num:SDWORD,	sign:SDWORD				; num  = variable to hold current integer
  push	eax									; sign = variable to set current integer as + or -
  push	ebx
  push	ecx
  push	edx
  push	esi
  push	edi

  mov	esi,	[ebp + 8]					; Move indirect operand to esi
  mov	num,	esi							; Move the value to a temp variable
  mov	sign,	1							; Initialize sign to 1 (+)
  mov	edi,	[ebp + 12]					; Move address of stringBuffer array to edi
  mov	ecx,	BUFF_SIZE					; Set ecx to SIZEOF stringBuffer 
  add	edi,	ecx							; Move through length of stringBuffer - 1 to
  dec	edi									; Point to last index of array
  STD										; Set direction flag to decrement backward thru array

  mov	al,		0							; Add a null-terminator at end of string
  STOSB										; mov [edi], al & dec edi

  cmp	num,	0							; If value is negative then
  jge	_WriteString
  mov	sign,	-1							; set sign to negative and
  neg	num									; make value positive

_WriteString:
  mov	eax,	num							; Move value to accumulator
  xor	edx,	edx
  mov	ebx,	10
  div	ebx									; Divide by 10
  mov	num,	eax							; Store quotient
  mov	eax,	edx
  add	al,		48							; Cast to ASCII string
  STOSB										; mov [edi], al & dec edi

  cmp	num,	0							; Check to see if last value
  jne	_WriteString						; otherwise iterate

  cmp	sign,	-1							; Check to see if value is negative
  jne	_DisplayString						; If not, move to display string
  mov	al,		"-"							; otherwise add negative symbol
  STOSB										; mov [edi], al & dec edi

_DisplayString:
  inc	edi
  mDisplayString	edi

  pop	edi
  pop	esi
  pop	edx
  pop	ecx
  pop	ebx
  pop	eax
  ret 8
WriteVal	ENDP
; ------------------------------------------------------------------------------------
; Name: ReadFloatVal procedure
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
