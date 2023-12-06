;
;	Disassembled by:
;		DASMx object code disassembler
;		(c) Copyright 1996-2003   Conquest Consultants
;		Version 1.40 (Oct 18 2003)
;
;	File:		tdv2215.bin
;
;	Size:		2048 bytes
;	Checksum:	9B0D
;	CRC-32:		2F500C10
;
;	Date:		Sun Mar 25 20:48:49 2018
;
;	CPU:		Intel 8048 (MCS-48 family)
;
;
;
	org	00000H
Beginning:
	sel	rb0
	jmp	Init

;////////////////////////////////////////////////////////////
; Int Int
;
; Expansion not supported
;
SignalInt:
	sel	rb0
	jmp	Reset
	nop

;////////////////////////////////////////////////////////////
; Timer Int
;
; Governs UART Tx/Rx
; 	9 bits per byte: low start bit + 8 data (lsb first)
; 	2400 baud Tx, 600 baud Rx
; 	RS-422 hardware-level
;
;	r2 = Bits remaining to be received
;	r3 = Divide-by-4 for receiving
;	r4 = Current byte being received
;	r5 = Number of bits left of current transmittion
;	r6 = Current byte being transmitted
;	r7 = Backup of A during routine
;
;
TimerInt:
	sel	rb1		; Use INT regs
	mov	r7,a		; Save A
	clr	f1		; Potential new things to do later
	
	mov	a,#0FBH
	mov	t,a		; Next Int in 5 clocks (freq: 5.76M*5/(15*32) = 60K)

	djnz	r3,TransmitBit
	inc	r3		; Make sure we falls through next round if r3 is 0
	mov	a,r2
	jnz	ReceiveBit
	jt0	TransmitBit	; Start bit spotted?
	mov	r2,#008H	; Receive 8 bits then
	mov	r3,#006H	; but wait till the 6th tick from now
	jmp	TransmitBit
;
ReceiveLow:
	clr	c
	jmp	ReceiveAny
ReceiveBit:
	mov	r3,#004H	; Receive each 4th tick
	mov	a,r4
	jnt0	ReceiveLow
	clr	c		; Receive High
	cpl	c
ReceiveAny:
	rrc	a
	mov	r4,a

	djnz	r2,TransmitBit	; 8 bits received?
	mov	r3,#006H	; Wait 6 ticks before checking for new start-bit
	xrl	a,#020H
	jnz	TransmitBit
	mov	r1,#008H
	mov	@r1,a		; Clear #008H and #009H if ' ' received
	inc	r1
	mov	@r1,a
	retr
;
TransmitBit:
	mov	a,r5		; Any more bits to transmit?
	jz	InterruptEnd
	dec	a		; Last bit being transmitted?
	mov	r5,a
	jz	TransmitEnd
	xrl	a,#009H		; First bit to be transmitted?
	jz	TransmitLow
	mov	a,r6
	rrc	a
	mov	r6,a
	jc	TransmitHigh
TransmitLow:
	anl	p1,#0DFH	; Clear Tx
	orl	p1,#040H	; Set signal to beeper
	jmp	InterruptEnd
TransmitEnd:
	anl	p1,#0BFH	; Clear signal to beeper
TransmitHigh:
	orl	p1,#020H	; Set Tx
InterruptEnd:
	mov	a,r7		; Restore A
	retr

;////////////////////////////////////////////////////////////
; Main Method
;
Main:
	jf1	Main		; Wait for things to do.
	sel	rb0
	cpl	f1		; Make sure we wait next time, in case we finish early
	mov	a,r2
	jb4	DoLastKBColumn
	in	a,p1		; Set given KB column
	anl	a,#0E0H
	orl	a,r2
	outl	p1,a
	mov	a,r4		; Check Break
	jb7	KeyDoneNoChangeInKeyHold
	ins	a,bus		; Read given KB column
	jz	NoKeyDown
	xch	a,@r1		; Debounce - Save new key state
	jz	KeyDoneNoChangeInKeyHold
	anl	a,@r1
	jz	KeyDoneNoChangeInKeyHold
	mov	r7,a
	inc	r1
	mov	a,r5
	jz	L007E
	mov	a,r7		; a = held keys
	cpl	a
	anl	a,@r1
	cpl	a
	anl	a,@r1		; !(!a AND @r1) AND @r1 = a AND @r1... why?
	mov	@r1,a		; a = keys who are still being held
	cpl	a
	anl	a,r7
	mov	r7,a		; a = newly held keys
	jz	KeyDone
	mov	a,r3
	jb6	KeyDone
	jb3	KeyDone
L007E:
	mov	a,r7			; a = held keys or newly held keys
	jb7	GoProcRow7		; Proccess one every main loop
	jb6	GoProcRow6
	jb5	GoProcRow5
	jb4	GoProcRow4
	jb3	GoProcRow3
	jb2	GoProcRow2
	jb1	GoProcRow1
	mov	a,@r1
	orl	a,#001H
	mov	@r1,a
	mov	a,#070H
	add	a,r2
	jmp	ProccessKey
;
GoProcRow7:
	mov	a,@r1
	orl	a,#080H
	mov	@r1,a
	mov	a,r2
	jmp	ProccessKey
;
GoProcRow6:
	mov	a,@r1
	orl	a,#040H
	mov	@r1,a
	mov	a,#010H
	add	a,r2
	jmp	ProccessKey
;
GoProcRow5:
	mov	a,@r1
	orl	a,#020H
	mov	@r1,a
	mov	a,#020H
	add	a,r2
	jmp	ProccessKey
;
GoProcRow4:
	mov	a,@r1
	orl	a,#010H
	mov	@r1,a
	mov	a,#030H
	add	a,r2
	jmp	ProccessKey
;
GoProcRow3:
	mov	a,@r1
	orl	a,#008H
	mov	@r1,a
	mov	a,#040H
	add	a,r2
	jmp	ProccessKey
;
GoProcRow2:
	mov	a,@r1
	orl	a,#004H
	mov	@r1,a
	mov	a,#050H
	add	a,r2
	jmp	ProccessKey
;
NoKeyDown:
	xch	a,@r1
	jnz	KeyDoneNoChangeInKeyHold	; Wait a turn before changing this
	dec	r6
	inc	r1
	mov	@r1,#000H
	jmp	KeyDone
;
KeyDoneNoChangeInKeyHold:
	inc	r1
KeyDone:
	inc	r1
	inc	r2
	jmp	TryTx
;
CharToTxBuffer:
	mov	r7,a
	mov	a,r5
	jz	L00F1
	mov	r5,#071H
	mov	a,r7
	mov	@r0,a
	inc	r3
	inc	r0
	mov	a,r0
	xrl	a,#018H
	jnz	KeyDone
	mov	r0,#010H
	jmp	KeyDone
;
IgnoreKey:
	mov	a,r4
	orl	a,#040H
	mov	r4,a
	jmp	KeyDone
L00F1:
	jmp	L0251
DoLastKBColumn:
	jmp	CheckSpecialKeys
;////////////////////////////////////////////////////////////
ReadFromPage0:
	movp	a,@a
	ret
;////////////////////////////////////////////////////////////
GoProcRow1:
	mov	a,@r1
	orl	a,#002H
	mov	@r1,a
	mov	a,#060H
	add	a,r2
ProccessKey:
	mov	r7,a		; a = key nr
	mov	a,r4
	anl	a,#0BFH
	mov	r4,a
	jb0	ProcessKeyWithCTRL
	jb1	ProcessKeyWithSHIFT
	jb2	ProcessKeyWithSHIFT
	jb3	ProcessKeyWithCAPS
	mov	a,r7
	jf0	UseAlternateCharFlags
	call	ReadFromPage4		; Read key flags
L0110:
	jb0	L0114
	jmp	IgnoreKey
;
L0114:
	jb5	L0127
L0116:
	mov	a,r7
	add	a,#080H
	jf0	TxCharFromPage6
	call	ReadFromPage4
	jmp	CharToTxBuffer
;
UseAlternateCharFlags:
	call	ReadFromPage6
	jmp	L0110
;
TxCharFromPage6:
	call	ReadFromPage6
	jmp	CharToTxBuffer
;
L0127:
	mov	a,r4
	orl	a,#040H
	mov	r4,a
	jmp	L0116
;
ProcessKeyWithSHIFT:
	mov	a,r7
	jf0	UseAlternateCharSHIFT
	call	ReadFromPage4
L0132:
	jb1	L0138
	jb2	L0145
	jmp	IgnoreKey
;
L0138:
	jb5	L014D
L013A:
	mov	a,r7
	jf0	TxCharFromPage7
	call	ReadFromPage5
	jmp	CharToTxBuffer
;
UseAlternateCharSHIFT:
	call	ReadFromPage6
	jmp	L0132
;
L0145:
	mov	a,r4
	orl	a,#040H
	mov	r4,a
	jb1	L013A
	jmp	KeyDone
;
L014D:
	mov	a,r4
	orl	a,#040H
	mov	r4,a
	jmp	L013A
;
TxCharFromPage7:
	call	ReadFromPage7
	jmp	CharToTxBuffer
;
ProcessKeyWithCTRL:
	mov	a,r7
	jf0	L016D
	call	ReadFromPage4
L015C:
	jb3	L0160
	jmp	IgnoreKey
;
L0160:
	mov	a,r4
	orl	a,#040H
	mov	r4,a
	mov	a,r7
	add	a,#080H
	jf0	TxCharFromPage7b
	call	ReadFromPage5
	jmp	CharToTxBuffer
;
L016D:
	call	ReadFromPage6
	jmp	L015C
;
TxCharFromPage7b:
	call	ReadFromPage7
	jmp	CharToTxBuffer
;
ProcessKeyWithCAPS:
	mov	a,r7
	jf0	L017E
	call	ReadFromPage4
L017A:
	jb4	L0110
	jmp	L0132
;
L017E:
	call	ReadFromPage6
	jmp	L017A
;
CheckSpecialKeys:
	orl	p1,#010H
	nop
	ins	a,bus
	mov	r7,a		; Save special key switches in r7
	clr	f0
	jb0	UseAlternateLayout
L018A:
	jb7	ProccessBreak
	mov	a,r4
	jb7	EndBreak
L018F:
	mov	a,r7
	rr	a
	xrl	a,r3
	anl	a,#030H
	jnz	ProccessChangeInLocks
	mov	a,r7
	jb2	DoCTRL
	jb1	DoCAPS
	jb4	DoSHIFT
	jb3	DoLOCK
	mov	a,r4
	anl	a,#0ECH
	mov	r4,a
	jmp	NextThingAfterSpecialKeys
;
UseAlternateLayout:
	cpl	f0
	jmp	L018A
;
ProccessBreak:
	mov	a,r4
	jb7	NextThingAfterSpecialKeys
	jb1	StartBreak
	jmp	L018F
;
StartBreak:
	orl	a,#080H
	mov	r4,a
	mov	a,#0F9H
	call	TxByte
	jmp	NextThingAfterSpecialKeys
;
EndBreak:
	anl	a,#07FH
	mov	r4,a
	mov	a,#0FEH
	call	TxByte
	jmp	NextThingAfterSpecialKeys
;
ProccessChangeInLocks:
	mov	a,r7
	rr	a
	anl	a,#030H
	xch	a,r3
	anl	a,#0CFH
	orl	a,r3
	xch	a,r3
	swap	a
	xrl	a,#0DFH
	call	TxByte
	jmp	NextThingAfterSpecialKeys
;
DoSHIFT:
	anl	p2,#0BFH	; turn off lock
	mov	a,r4
	anl	a,#0FBH
	orl	a,#002H		; turn on shift
	mov	r4,a
	jmp	NextThingAfterSpecialKeys
;
DoLOCK:
	mov	a,r4
	orl	a,#004H
	mov	r4,a
	orl	p2,#040H
	jmp	NextThingAfterSpecialKeys
;
DoCTRL:
	mov	a,r4
	orl	a,#001H
	mov	r4,a
	jmp	NextThingAfterSpecialKeys
;////////////////////////////////////////////////////////////
ReadFromPage1:
	movp	a,@a
	ret
;////////////////////////////////////////////////////////////
DoCAPS:
	mov	a,r4
	jb4	NextThingAfterSpecialKeys
	jb3	SkipCAPSOnLOCK
	orl	a,#018H
	mov	r4,a
	orl	p2,#080H
	jmp	NextThingAfterSpecialKeys
;
SkipCAPSOnLOCK:
	orl	a,#010H
	anl	a,#0F7H
	mov	r4,a
	anl	p2,#07FH
NextThingAfterSpecialKeys:
	mov	r2,#000H	; Reset keyboard scanning variables
	mov	r1,#020H
	mov	a,r5
	jz	L020B
	dec	r5
	mov	a,r6
	mov	r6,#010H
	jnz	KeysBeingHeld
L020B:
	mov	r5,#071H
	mov	a,r3
	anl	a,#0BFH		; reset b0r3 bit 5
	mov	r3,a
KeysBeingHeld:
	sel	rb1
	mov	r1,#00DH
	inc	@r1
	mov	a,@r1
	jnz	TryTx
	sel	rb0
	mov	a,r3
	jb7	L022A
	orl	a,#080H
	mov	r3,a
	sel	rb1
	mov	@r1,#0D1H
	inc	r1
	mov	a,@r1
	cpl	a
	inc	r1
	anl	a,@r1
	mov	@r1,a
	jmp	L0235
;
L022A:
	anl	a,#07FH
	mov	r3,a
	sel	rb1
	mov	@r1,#0A2H
	inc	r1
	mov	a,@r1
	inc	r1
	orl	a,@r1
	mov	@r1,a
L0235:
	cpl	a
	outl	bus,a
TryTx:				; b1r0 -> byte to be Tx
	sel	rb1		; Check if a byte is being transmitted at the moment
	mov	a,r5
	jnz	CheckRx
	sel	rb0		; Bytes waiting for Tx?
	mov	a,r3
	anl	a,#00FH
	jz	CheckRx
	dec	r3
	sel	rb1		; Initiate transfer
	mov	a,@r0
	mov	r6,a
	inc	r0
	mov	r5,#00AH
	mov	a,r0		; Update pointer
	xrl	a,#018H
	jnz	CheckRx
	mov	r0,#010H
	jmp	CheckRx
;
L0251:
	inc	r1
	inc	r2
	mov	a,r4
	jb5	CheckRx
	jb6	CheckRx
	mov	a,r3
	jb6	L026A
	orl	a,#040H
	mov	r3,a
	mov	r5,#007H
	mov	a,r7
	call	TxByte
	mov	a,r7
	sel	rb1
	mov	r1,#00CH
	mov	@r1,a
	jmp	TryTx
;
L026A:
	mov	a,r7
	sel	rb1
	mov	r1,#00CH
	xrl	a,@r1
	jnz	CheckRx
	sel	rb0
	mov	r5,#007H
	mov	a,r7
	call	TxByte
	jmp	TryTx


;////////////////////////////////////////////////////////////
;
; 01 - 08: Turn LED 1-8 on
; 09 - 10: Turn LED 1-8 off
; 11 - 18: Turn LED 1-8 on in shadow bitmap
; 19 - 1F: Do nothing
; 20 - 3F: Excecute command
; 40 - FF: Do nothing
;
CheckRx:				; Check for byte received
	sel	rb1
	mov	a,r2
	jnz	BackToMain
	mov	a,r4		; Get byte
	jz	BackToMain
	mov	r4,#000H	; Clear Rx reg
	mov	r1,#00FH	; 00F = LED bitmap (actual LED values), 00E = LED Shadow 
	jb7	BackToMain
	jb6	BackToMain
	jb5	DoKeyboardAction
	dec	a
	jb4	L02AF
	jb3	TurnLEDOff
TurnLEDOn:
	add	a,#0BBH		; Turn LED a on
	movp	a,@a
	mov	r7,a
	orl	a,@r1
	mov	@r1,a
	cpl	a
	outl	bus,a
	dec	r1
	mov	a,r7
	cpl	a
	anl	a,@r1
	mov	@r1,a
BackToMain:
	jmp	Main
;
TurnLEDOff:
	anl	a,#007H
	add	a,#0BBH		; Turn LED a off
	movp	a,@a
	cpl	a
	mov	r7,a
	anl	a,@r1
	mov	@r1,a
	cpl	a
	outl	bus,a
	dec	r1
	mov	a,r7
	anl	a,@r1
	mov	@r1,a
	jmp	Main
;
L02AF:
	jb3	BackToMain
	dec	r1
	anl	a,#007H
	add	a,#0BBH
	movp	a,@a
	orl	a,@r1
	mov	@r1,a
	jmp	Main
L02BB:
	db	001H, 002H, 004H, 008H, 010H, 020H, 040H, 080H

ReadSelectedLayout:
	mov	r7,#080H
	jf0	L02DF
L02C7:
	mov	a,r7
	call	ReadFromPage4
	call	TxByte
	mov	a,r7
	jb1	L02D2
	inc	r7
	jmp	L02C7
;
L02D2:
	mov	r7,#080H
L02D4:
	mov	a,r7
	call	ReadFromPage5
	call	TxByte
	mov	a,r7
	jb1	BackToMain
	inc	r7
	jmp	L02D4
;
L02DF:
	mov	a,r7
	call	ReadFromPage6
	call	TxByte
	mov	a,r7
	jb1	L02EA
	inc	r7
	jmp	L02DF
;
L02EA:
	mov	r7,#080H
L02EC:
	mov	a,r7
	call	ReadFromPage7
	call	TxByte
	mov	a,r7
	jb1	BackToMain
	inc	r7
	jmp	L02EC
;
AddAToR1IncR0:
	addc	a,r1
	mov	r1,a	; r1 = a+r1+c
	inc	r0
	mov	a,r0	; a = r0++
	ret

;////////////////////////////////////////////////////////////

ReadFromPage2:
	movp	a,@a
	ret

;////////////////////////////////////////////////////////////
;
DoKeyboardAction:
	jb4	BackToMain
	anl	a,#00FH
	add	a,#005H
	jmpp	@a						;INFO: indirect jump
L0305:
	db	BackToMain2
	db	EnableClicks
	db	DisableClicks
	db	BackToMain2
	db	TriggerBeep
	db	TurnOffAllLEDs
	db	TurnOffHalfTheLEDs
	db	BackToMain2
	db	EnableKeyRepeat
	db	DisableKeyRepeat
	db	ReadLocks
	db	DisableExpReady
	db	EnableExpReady
	db	TxROMCheck
	db	TxRAMCheck
	db	L03AD

;////////////////////////////////////////////////////////////

EnableClicks:
	orl	p1,#080H
	jmp	Main

;////////////////////////////////////////////////////////////

DisableClicks:
	anl	p1,#07FH
	jmp	Main

;////////////////////////////////////////////////////////////

TriggerBeep:
	anl	p2,#0DFH
	nop
	orl	p2,#020H
	jmp	Main

;////////////////////////////////////////////////////////////

TurnOffAllLEDs:
	clr	a
	mov	@r1,a	; (r1) = 0
	dec	r1
	mov	@r1,a	; (r1-1) = 0
	cpl	a
	outl	bus,a	; LEDs = off
	jmp	Main

;////////////////////////////////////////////////////////////

TurnOffHalfTheLEDs:
	mov	a,@r1
	anl	a,#0F0H
	mov	@r1,a
	cpl	a
	outl	bus,a
	dec	r1
	mov	a,@r1
	anl	a,#0F0H
	mov	@r1,a
	jmp	Main

;////////////////////////////////////////////////////////////

EnableKeyRepeat:
	sel	rb0
	mov	a,r4
	anl	a,#0DFH
	mov	r4,a
	mov	a,r3
	orl	a,#040H
	mov	r3,a
	mov	r5,#001H
	jmp	Main

;////////////////////////////////////////////////////////////

DisableKeyRepeat:
	sel	rb0
	mov	a,r4
	orl	a,#020H
	mov	r4,a
	jmp	Main

;////////////////////////////////////////////////////////////

ReadLocks:
	sel	rb0
	mov	a,r3
	swap	a
	anl	a,#003H
	xrl	a,#0DFH
	call	TxByte
BackToMain2:
	jmp	Main

;/////////////////////////////////////////////////////
;
; AA on OK
;
; Checksum is 029B0D... 02 + 9B + 0D = AA
;

TxROMCheck:
	in	a,p1
	jb6	TxROMCheck		; Wait for Transfer flag to go low
	dis	tcnti
	clr	a
	clr	c
	mov	r0,a
	mov	r1,a		; Reset registers
Page0ChkSumLoop:
	call	ReadFromPage0
	call	AddAToR1IncR0
	jnz	Page0ChkSumLoop
Page1ChkSumLoop:
	call	ReadFromPage1
	call	AddAToR1IncR0
	jnz	Page1ChkSumLoop
Page2ChkSumLoop:
	call	ReadFromPage2
	call	AddAToR1IncR0
	jnz	Page2ChkSumLoop
Page3ChkSumLoop:
	call	ReadFromPage3
	call	AddAToR1IncR0
	jnz	Page3ChkSumLoop
Page4ChkSumLoop:
	call	ReadFromPage4
	call	AddAToR1IncR0
	jnz	Page4ChkSumLoop
Page5ChkSumLoop:
	call	ReadFromPage5
	call	AddAToR1IncR0
	jnz	Page5ChkSumLoop
Page6ChkSumLoop:
	call	ReadFromPage6
	call	AddAToR1IncR0
	jnz	Page6ChkSumLoop
Page7ChkSumLoop:
	call	ReadFromPage7
	call	AddAToR1IncR0
	jnz	Page7ChkSumLoop

	jnc	TxR1andReset
	inc	r1		; Addc r1,0
	jmp	TxR1andReset

;/////////////////////////////////////////////////////
;
; EE on failure
; AA on OK
;

TxRAMCheck:
	in	a,p1
	jb6	TxRAMCheck	; Wait for Tx to be done
	dis	tcnti
	mov	r0,#03FH	; Test all of RAM
L039B:
	mov	a,r0
	jz	OutsideRAM
	mov	@r0,a
	xrl	a,@r0
	jnz	MemoryBad
	dec	r0
	jmp	L039B
OutsideRAM:
	mov	r1,#0AAH
	jmp	TxR1andReset
MemoryBad:
	mov	r1,#0EEH
	jmp	TxR1andReset

;/////////////////////////////////////////////////////

L03AD:
	sel	rb0
	jmp	ReadSelectedLayout

;/////////////////////////////////////////////////////

TxByte:
	mov	@r0,a
	inc	r3
	inc	r0
	mov	a,r0
	xrl	a,#018H
	jnz	L03BA
	mov	r0,#010H
L03BA:
	ret

;/////////////////////////////////////////////////////

TxR1andReset:
	mov	a,#0FEH
	mov	t,a
	en	tcnti		; Start timer again
	mov	a,r1
	mov	r6,a
	mov	r5,#00AH	; Setup transfer
L03C3:
	mov	a,r5
	jnz	L03C3		; Wait til it is complete
	jmp	Beginning	; Reset

;//////////////////////////////////////////////////////

DisableExpReady:
	sel	rb0
	orl	p2,#008H
	mov	a,#0EFH
	call	TxByte
	jmp	Main

;///////////////////////////////////////////////////////

EnableExpReady:
	anl	p2,#0F7H
	jmp	Main

;///////////////////////////////////////////////////////

Reset:
	nop
Init:
	dis	tcnti
	mov	r0,#03FH	; Clear data-memory (3F) to (00)
L03D9:
	mov	@r0,#000H
	djnz	r0,L03D9

	mov	r0,#010H
	mov	r1,#020H
	mov	r5,#070H

	mov	a,#030H		; Set output ports
	outl	p1,a
	outl	p2,a
	ins	a,bus		; Read special keyboard column
	rr	a
	anl	a,#030H
	mov	r3,a		; Get AL1 and AL2 in r3
	anl	p1,#020H	; Turn off special keyboard column

	sel	rb1
	mov	r0,#010H
	inc	r3		; Prepare divide-by-4 counter
	mov	a,#0FFH
	outl	bus,a		; Turn off all LEDs

	mov	t,a
	strt	t
	en	tcnti		; Enable Timer interrupts
	jmp	Main

;////////////////////////////////////////////////////////////

ReadFromPage3:
	movp	a,@a
	ret
	db	4 dup(000H)

;////////////////////////////////////////////////////////////

ReadFromPage4:
	movp	a,@a
	ret

	db	72H	; Checksum ajustement?

	db	               37H, 37H, 17H, 37H, 17H, 37H, 37H, 17H, 37H, 00H, 00H, 37H, 37H
	db	17H, 17H, 17H, 17H, 17H, 37H, 17H, 17H, 17H, 37H, 17H, 37H, 37H, 17H, 37H, 17H
	db	37H, 37H, 37H, 37H, 37H, 37H, 3DH, 34H, 37H, 37H, 3CH, 37H, 37H, 37H, 37H, 34H
	db	00H, 0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 17H, 17H, 17H, 17H, 1FH, 37H, 17H, 37H
	db	0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 17H, 17H, 17H, 37H, 17H
	db	0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 37H, 37H, 37H, 17H, 17H
	db	17H, 17H, 17H, 17H, 17H, 17H, 17H, 17H, 17H, 1FH, 17H, 17H, 37H, 37H, 1FH, 1FH
	db	37H, 37H, 37H, 37H, 37H, 37H, 37H, 37H, 37H, 37H, 37H, 37H, 37H, 37H, 37H, 37H

	db	'129'

	db	               86H, 99H, B2H, CAH, C4H, CEH, 88H, B3H, 80H, 00H, 00H, 82H, 84H
	db	EAH, E3H, E6H, E2H, E1H, 85H, E4H, ECH, E7H, 8CH, E5H, 8DH, 8EH, E8H, 8BH, E9H
	db	81H, 8AH, DBH, 9CH, 9DH, 9BH, FEH, 00H, C6H, 89H, 00H, F2H, 87H, 97H, F0H, 00H
	db	00H, 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', E0H, ' ', B8H, B4H, CDH
	db	'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', '|', '{', EDH, B1H, C3H, 91H, ':'		; | = ø, { = æ
	db	'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '}', 83H, C5H, 90H, 9AH, ';'		; } = å
	db	'1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', EBH, 96H, 8FH, '@', '^'
	db	7FH, A0H, A1H, A2H, A3H, A4H, A5H, A6H, A7H, BDH, BCH, F1H, FAH, FBH, B0H, C0H

;////////////////////////////////////////////////////////////

ReadFromPage5:
	movp	a,@a
	ret
	nop

	db	               86H, 99H, B2H, CAH, C4H, CFH, D7H, B3H, 80H, 00H, 00H, 82H, 84H
	db	EAH, E3H, E6H, E2H, E1H, 85H, E4H, ECH, E7H, 8CH, E5H, 8DH, 8EH, E8H, 8BH, E9H
	db	81H, 8AH, DBH, 9CH, 9DH, 9BH, F9H, F8H, C6H, 89H, FCH, F2H, 87H, 97H, F0H, 93H
	db	00H, 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '<', '>', '?', E0H, ' ', B8H, B4H, CDH
	db	'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', '\', '[', EDH, B1H, C3H, 91H, '*'		; \ = Ø, [ = Æ
	db	'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', ']', 83H, C5H, 90H, 9AH, '+'		; ] = Å
	db	'!', '"', '#', '$', '%', '&', "'", '(', ')', '_', '=', EBH, 96H, 8FH, '`', '~'
	db	7FH, A8H, A9H, AAH, ABH, ACH, ADH, AEH, AFH, BDH, BCH, F1H, FAH, FBH, B0H, C0H

	db	'221'

	db	               00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, F4H, 00H, 00H, 00H, FDH, 00H, 00H, 00H, 00H, 00H
	db	00H, 1AH, 18H, 03H, 16H, 02H, 0EH, 0DH, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	01H, 13H, 04H, 06H, 07H, 08H, 0AH, 0BH, 0CH, 1CH, 1BH, 00H, 00H, 00H, 00H, 00H
	db	11H, 17H, 05H, 12H, 14H, 19H, 15H, 09H, 0FH, 10H, 1DH, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 1FH, 00H, 00H, 00H, 00H, 00H, 1EH
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H

;////////////////////////////////////////////////////////////

ReadFromPage6:
	movp	a,@a
	ret
	nop

	db	               00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H

	db	'XXX'

	db	               00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H

;////////////////////////////////////////////////////////////

ReadFromPage7:
	movp	a,@a
	ret
	nop

	db	               00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H

	db	'X02'

	db	               00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H