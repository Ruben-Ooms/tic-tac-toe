	JMP	HERE		; Skip to printing section

; ----- Initilization Array ---------------------------------------------------

; Load array into ram
; D represents a new line
; 0 represents the end of the array

	DB	"123"
	DB	D
	DB	"456"
	DB	D
	DB	"789"
	DB	0

; ----- Initalizing Board -----------------------------------------------------

; AL is used to store the character in the array, or the offset from the leftmost character in VDU
; BL stores the address of the array
; CL stores the address of the video ram

HERE:
	CLO			; Close all peripheral windows
	MOV	CL,C0		; Video ram base address
	MOV	BL,02		; Offset of initalization array

LOOP1:				; Text output to vdu
	MOV	AL,[BL]		; Text pointer into AL
	CMP	AL,0		; At end yet
	JZ	INITIAL		; Jump out of loop
	CMP	AL,D		; At new line
	JZ	NEWLINE		; Jump to create new line
	MOV	[CL],AL		; AL into video memory
	INC	CL		; Next video location
	INC	BL		; Next element of the array
	JMP	LOOP1		; Restart initial printing loop

; ----- Playing the Board ----------------------------------------------------

; AL stores the user input square 1-9
; BL stores the current players symbol
; CL stores the VDU address
; DL stores the offset from the left for the VDU

INITIAL:
	MOV	BL,58		; Initalizes X as the first player
LOOP2:
	MOV	CL,C0		; Sets CL to the first element of the VDU
	IN	00		; Gets user input
	CMP	AL,D		; Checks for enter key to exit
	JZ	EXIT
	PUSH	AL		; Copies AL to DL
	POP	DL		; This technically is not necessary to do and could instead just use AL
	CMP	DL,31		; Verifies ascii code >31 ie past 0
	JS	LOOP2
	CMP	DL,3A		; Verifies ascii code <3A ie not past 9
	JNS	LOOP2
	SUB	DL,31		; Therefore DL will have numbers 0-8 corresponding with 1-9 on the board
ROW:
	SUB	DL,3		; Since columns are 3 elements wide if it is larger than 3 it needs to go to the next line
	JNS	ROWINC		; Sets CL to the next row when DL is larger than 2
	ADD	DL,3		; Add 3 back so it contains numbers 0-2
	ADD	CL,DL		; Offsets DL by CL
	MOV	[CL],BL		; Move the player symbol into the correct place in VDU
	CMP	BL,58		; Checks whether the current player is X
	JZ	SWAPO		; Swaps to O if it is
	JMP	SWAPX		; Swaps to X otherwise
EXIT:
	HALT

; ----- Functions ------------------------------------------------------------

	ORG 	60
NEWLINE:		; New line funciton
	PUSH	CL	; Get Video ram adress to AL
	POP 	AL	
	AND	AL,0F	; The VDU represents 16 characters in a line so this finds which character it is on
	ADD	CL,10	; Set Video address to next line
	SUB	CL,AL	; Set Video ram address back to the first character (left)
	INC	BL	; Next element of the array
	JMP 	LOOP1	; Restart printing loop

ROWINC:			; Row increment function
	ADD	CL,10	; Sets CL to the next row	
	JMP	ROW

SWAPO:
	MOV	BL,4F	; Sets BL to O
	JMP	LOOP2

SWAPX:
	MOV	BL,58	; Sets BL to X
	JMP	LOOP2

END