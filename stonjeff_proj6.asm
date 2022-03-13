TITLE String Primitives and Macros   (stonjeff_proj6.asm)

; Author: Jeff "Gent" Stone
; Last Modified: 3/12/2022
; OSU email address: stonjeff@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6        Due Date: 3/13/2022
; Description: This program implements two macros for string processing. The first macro
;	displays messages and characters to the console as strings, using the Irvine Library
;	WriteString procedure. The second macro uses ReadString to take user-input numeral 
;	characters as strings. The user is prompted to enter 10 integers that will fit into a 32-bit
;	register. Procedures (ReadVal and WriteVal) have been implemented to  cast the numeric
;	strings to integers. As the integers are cast, they are stored in an array, the sum of
;	the integers and the average (floor) are determined. 
;	Finally, the integers are cast back to strings and all ten integers are displayed to 
;	the console, along with the determined sum and average.
;	**EC1 - Line numbers and a running subtoral are displayed for all valid entries.

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
  mov	edx,	stringAddr		; Address of string to be displayed moved to edx
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
;			BUFF_SIZE	= max length (23 bytes) of string (input, value)
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
  mov	ecx,		BUFF_SIZE	; specify max characters allowed in string
  call	ReadString				
  mov	byteCount,	eax			; number of characters entered by user moved FROM EAX to byteCount
  pop	edx
  pop	ecx
  pop	eax
ENDM

.const								

; CONSTANTS
INT_COUNT	equ 10				; Length of integer array
BUFF_SIZE	equ	23				; Length of string buffer (1 (+/-) + 11 (32-bit size values) + 11 for padding)

.data

; STATEMENTS
  introMsg		BYTE	"Project 6: String Primitives and Macros.", 09, "By Gent Stone", 13, 10, 10, 0
  intInstruct	BYTE	"This program will ask you to enter 10 signed integers.", 13, 10
				BYTE	"Each of the integers and their sum must fit within a 32-bit register.", 13, 10
				BYTE	"You can only enter 0, + or - in front of the integers.", 13, 10
				BYTE	"The program will then display the 10 integers, their sum and truncated average.", 13, 10
				BYTE	"**EC1: Each line of valid input will display the line number and current subtotal.", 13, 10, 10, 0
  intPromptMsg	BYTE	"Enter an integer: ", 0
  errorMsg		BYTE	"ERROR: Invalid input. Please try again!", 13, 10, 0
  subtotalMsg	BYTE	"The current subtotal is: ", 0
  enteredMsg	BYTE	"You entered the following integers:", 13, 10, 0
  sumMsg		BYTE	"The sum of these integers is: ", 0
  truncAvgMsg	BYTE	"The truncated average of these integers is: ", 0
  byeMsg		BYTE	"Thanks for using this program. Goodbye!", 13, 10, 10, 0
  spacer		BYTE	", ", 0
  period		BYTE	". ", 0

; VARIABLES
  intArray		SDWORD	INT_COUNT	DUP(?)	; List to hold the user-entered integers
  intSum		SDWORD	?					; Sum of integers
  intAvg		SDWORD	?					; Average of integers
  lineNum		DWORD	?					; Tracks current line number
  index			DWORD	0					; Used to increment index in intArray
  blank			DWORD	0					; Used to NOT increment lineNum, intSum and intAvg
  stringCount	DWORD	?					; Tracks number of user-entered characters (string length)

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
  mov	ecx,		LENGTHOF	intArray
  mov	lineNum,	1
  mov	edi,		OFFSET		intArray

_BuildArray:								; Display line number by moving to ebx &
  push	blank								; [ebp + 12]
  push	OFFSET		lineNum					; [ebp + 8]
  call	WriteVal							; calling WriteVal
  mDisplayString	OFFSET		period
											; Push statement parameters to
  push	index								; [ebp + 24]												
  push	OFFSET		errorMsg				; [ebp + 20]
  push	OFFSET		intPromptMsg			; [ebp + 16]
  push	OFFSET		intArray				; [ebp + 12]
  push	OFFSET		stringCount				; [ebp + 8]
  call	ReadVal								; and call ReadVal procedure

  mov	eax,		[edi]					; move entered value to eax
  add	intSum,		eax						; increment subtotal
  mDisplayString	OFFSET		subtotalMsg	; Display subtotal message
  push	blank								; [ebp + 12]
  push	OFFSET		intSum					; [ebp + 8]
  call	WriteVal							; Display subtotal

  call	CrLf
  add	edi,		TYPE		intArray	; iterate index of array (4 bytes)
  inc	lineNum
  inc	index
  LOOP	_BuildArray

;---------------------------------------------------------------
; Display integers - Invoke mDisplayString to display user-entered values message 
;	and then push the address integer array and stringBuffer to WriteVal
;	set a loop (size of intArray) to display all entered integers from the 
;	the array as strings in WriteVal, separated by a spacer (comma and space)
;	by invoking mDisplayString with the spacer string.
;---------------------------------------------------------------
  call	CrLf 
  mDisplayString	OFFSET		enteredMsg	; Display integers entered message
  mov	ecx,		LENGTHOF	intArray	; Set counter
  mov	esi,		OFFSET		intArray
  mov	index,		0

_DisplayArray:
  push	index
  push	OFFSET		intArray				; [ebp + 8] push reference to address of intArray
  call	WriteVal

  add	esi,		TYPE		intArray	; increment to next index address in array
  cmp	ecx,		1						; Check whether integer is last in array
  je	_NoSpacer
  mDisplayString	OFFSET		spacer		; Invoke mDisplayString to display spacer

_NoSpacer:
  inc	index
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
  push	blank								; [ebp + 12]
  push	OFFSET		intSum					; [ebp + 8]
  call	WriteVal
  call	CrLf

  mov	eax,		intSum
  cdq
  mov	ebx,		INT_COUNT
  idiv	ebx									; Divide sum by # of values (10)	
  mov	intAvg,		eax						; to obtain average
  mDisplayString	OFFSET		truncAvgMsg	; Invoke mDisplayString
  push	blank								; [ebp + 12]
  push	OFFSET		intAvg					; [ebp + 8]
  call	WriteVal							; Call WriteVal to display average
  call	CrLf
  call	CrLf

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
; Receives: stringCount (input, value) = [ebp + 8] holds value of # of characters entered in string, 
;	intArray (output, reference) = [ebp + 12] array to hold cast integers, 
;	intPromptMsg (input, reference) = [ebp + 16] message to prompt user for integers, 
;	errorMsg (input, reference) = [ebp + 20] message that user input is invalid
;	index (input, value) = [ebp + 24] current index of edi in outer loop in main
; Returns:  edi with array of user-entered integers
; ------------------------------------------------------------------------------------
ReadVal	PROC
  LOCAL accum:SDWORD, sign:SDWORD, stringBuffer[23]:BYTE			
											; Declaring LOCAL variables pushes ebp and moves esp to ebp
											; accum = temp variable for current accumulator value
  											; sign  = variable which sets current integer + or - 
											; stringBuffer = array for holding user-entered string
  push  eax
  push	ebx
  push	ecx
  push	edx
  push	esi
  push	edi

_GetString:
  lea	esi,	stringBuffer
  mGetString	[ebp + 16], esi, [ebp + 8]	; invoke macro to prompt user & get string
  mov	ecx,	[ebp + 8]					; Set counter to length of string
  lea	esi,	stringBuffer
  mov	edi,	[ebp + 12]					; Move address of intArray to edi
  mov	eax,	[ebp + 24]					; Move value in index to eax
  mov	ebx,	4
  mul	ebx
  add	edi,	eax							; increment array to next index
  mov	sign,	1							; Set depending on input of user (1 - pos or -1 - neg)
  CLD										; Set direction flag to terate forward through array

  LODSB										; mov al, [esi] & inc esi
  cmp	al,		43							; & check whether first character is
  je	_PlusChar							; + or
  cmp	al,		45
  je	_MinusChar							; - symbol and then
  sub	esi,	TYPE		stringBuffer	; If no +/- symbol then dec esi to check digit
  mov	eax,	0							; empty the upper range of the accumulator
  jmp	_CharCheck

_MinusChar:									; set sign accordingly to
  mov	sign,	-1							; negative signed integer
_PlusChar:									; is positive signed integer
  dec	ecx
  mov	eax,	0							; empty the upper range of the accumulator

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
  mdisplayString [ebp + 20]					; Display error message and
  jmp	_GetString							; return to prompt and get new string entry

_End:
  
  pop	edi
  pop	esi
  pop	edx
  pop	ecx
  pop	ebx
  pop	eax
  ret 20									; return to main
ReadVal	ENDP

; ------------------------------------------------------------------------------------
; Name: WriteVal procedure
; Description: Casts integers within the array to ASCII strings and invokes mDisplayString 
;	to display values to the console.
; Preconditions:	Array filled with 10 SDWORD integers
; Postconditions:	Integer is displayed to console
; Receives: address of intArray (input, reference) =  [ebp + 8] or
;	lineNum/intSum/intAvg values (input, indirect operand) = [ebp+ 8]
; Returns:  N/A
; ------------------------------------------------------------------------------------
WriteVal	PROC
  LOCAL	num:SDWORD,	sign:SDWORD, stringBuffer[23]:BYTE			
											; num  = variable to hold current integer
											; sign = variable to set current integer as + or -
											; stringBuffer = array for holding string to be displayed
  push  eax
  push	ebx
  push	ecx
  push	edx
  push	esi
  push	edi

  mov	esi,	[ebp + 8]					; Move address of lineNum, intArray, intSum or intAvg to esi
  mov	eax,	[ebp + 12]					; Move value in index (or blank for non-array values) to eax
  mov	ebx,	4
  mul	ebx
  add	esi,	eax							; increment index of array 
  mov	eax,	[esi]						; Move the value at current index of intArray (or value of lineNum, intSum or intAvg) to eax
  mov	num,	eax
  mov	sign,	1							; Initialize sign to 1 (+)
  lea	edi,	stringBuffer				; Move address of stringBuffer array to edi
  mov	ecx,	LENGTHOF	stringBuffer	; Set ecx to SIZEOF stringBuffer 
  add	edi,	ecx							; Move through length of stringBuffer - 1 to
  sub	edi,	TYPE		stringBuffer	; Point to last index of array
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
  add	edi,	TYPE		stringBuffer
  mDisplayString	edi

  pop	edi
  pop	esi
  pop	edx
  pop	ecx
  pop	ebx
  pop	eax
  ret 8
WriteVal	ENDP

END main
