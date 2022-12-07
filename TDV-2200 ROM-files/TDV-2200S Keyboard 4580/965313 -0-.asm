;
;	Disassembled by:
;		DASMx object code disassembler
;		(c) Copyright 1996-2003   Conquest Consultants
;		Version 1.40 (Oct 18 2003)
;
;	File:		C:\Users\Frode\Desktop\Datasystemer\TDV22xx terminals\DASMx\aaa.BIN
;
;	Size:		2048 bytes
;	Checksum:	6542
;	CRC-32:		B0ADF1F4
;
;	Date:		Tue Jul 10 19:52:47 2018
;
;	CPU:		Intel 8048 (MCS-48 family)
;
;
;
	org	00000H
Beginning:
	sel	rb0
	jmp	Init

;///////////////////////////////////////////////////////

SignalInt:
	strt	t
	jmp	SignalIntHandler
	nop

;///////////////////////////////////////////////////////

TimerInt:
	sel	rb1
	mov	r7,a
	clr	f1

	mov	a,#0FBH
	mov	t,a

	djnz	r3,TransmitBit
	inc	r3
	mov	a,r2
	jnz	ReceiveBit
	jt0	TransmitBit
	mov	r2,#008H
	mov	r3,#006H
	jmp	TransmitBit
;
ReceiveBit:
	mov	r3,#004H
	mov	a,r4
	clr	c
	jnt0	ReceiveAny
	cpl	c
ReceiveAny:
	rrc	a
	mov	r4,a
	djnz	r2,TransmitBit
	mov	r3,#006H
	xrl	a,#020H
	jnz	TransmitBit
	mov	r1,#008H
	mov	@r1,a
	inc	r1
	mov	@r1,a
	inc	a
	mov	psw,a
	retr
;
TransmitBit:
	mov	a,r5
	jz	TimerInterruptEnd
	dec	a
	mov	r5,a
	jz	TransmitEnd
	xrl	a,#009H
	jz	TransmitLow
	mov	a,r6
	rrc	a
	mov	r6,a
	jc	TransmitHigh
TransmitLow:
	anl	p1,#0DFH
	orl	p1,#040H
	jmp	TimerInterruptEnd
TransmitEnd:
	anl	p1,#0BFH
TransmitHigh:
	orl	p1,#020H
TimerInterruptEnd:
	mov	a,r7
	retr

;////////////////////////////////////////////////////////////

Main:
	jf1	Main
	sel	rb0
	cpl	f1
	mov	a,r2
	jb4	DoLastKBColumn
	in	a,p1
	anl	a,#0E0H
	orl	a,r2
	outl	p1,a
	mov	a,r4
	jb7	KeyDoneNoChangeInKeyHold
	ins	a,bus
	jz	NoKeyDown
	xch	a,@r1
	jz	KeyDoneNoChangeInKeyHold
	anl	a,@r1
	jz	KeyDoneNoChangeInKeyHold
	mov	r7,a
	inc	r1
	mov	a,r5
	jz	L007D
	mov	a,r7
	cpl	a
	anl	a,@r1
	cpl	a
	anl	a,@r1
	mov	@r1,a
	cpl	a
	anl	a,r7
	mov	r7,a
	jz	KeyDone
	mov	a,r3
	jb6	KeyDone
	jb3	KeyDone
L007D:
	mov	a,r7
	jb7	GoProcRow7
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
	jmp	ProccessKey
;
GoProcRow7:
	mov	a,@r1
	orl	a,#080H
	mov	@r1,a
	clr	a
	jmp	ProccessKey
;
GoProcRow6:
	mov	a,@r1
	orl	a,#040H
	mov	@r1,a
	mov	a,#010H
	jmp	ProccessKey
;
GoProcRow5:
	mov	a,@r1
	orl	a,#020H
	mov	@r1,a
	mov	a,#020H
	jmp	ProccessKey
;
GoProcRow4:
	mov	a,@r1
	orl	a,#010H
	mov	@r1,a
	mov	a,#030H
	jmp	ProccessKey
;
GoProcRow3:
	mov	a,@r1
	orl	a,#008H
	mov	@r1,a
	mov	a,#040H
	jmp	ProccessKey
;
GoProcRow2:
	mov	a,@r1
	orl	a,#004H
	mov	@r1,a
	mov	a,#050H
	jmp	ProccessKey
;
NoKeyDown:
	xch	a,@r1
	jnz	KeyDoneNoChangeInKeyHold
	dec	r6
	inc	r1
	mov	@r1,#000H
	dec	r1
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
	jz	L00F2
	mov	r5,#071H
	in	a,p2
	jb2	L00E6
L00D9:
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
L00E6:
	mov	a,r3
	orl	a,#040H
	mov	r3,a
	mov	a,r7
	sel	rb1
	mov	r1,#00CH
	mov	@r1,a
	sel	rb0
	jmp	L00D9
L00F2:
	jmp	L025D
DoLastKBColumn:
	jmp	CheckSpecialKeys
;////////////////////////////////////////////////////////////
;
ReadFromPage0:
	movp	a,@a
	ret
;
GoProcRow1:
	mov	a,@r1
	orl	a,#002H
	mov	@r1,a
	mov	a,#060H
ProccessKey:
	add	a,r2
	mov	r7,a
	mov	a,r4
	anl	a,#0BFH
	mov	r4,a
	jb0	ProcessKeyWithCTRL
	jb1	ProcessKeyWithSHIFT
	jb2	ProcessKeyWithSHIFT
	mov	a,r7
	call	ReadFromPage6		; Read key flags
	jb0	ActuateNormalKey
	jmp	IgnoreKey
;
ActuateNormalKey:
	jb5	RepTxNormalKey
TxNormalKey:
	mov	a,r7
	add	a,#080H
	call	ReadFromPage6
	jmp	CharToTxBuffer
;
RepTxNormalKey:
	mov	a,r4
	orl	a,#040H
	mov	r4,a
	jmp	TxNormalKey
;
ProcessKeyWithSHIFT:
	mov	a,r7
	call	ReadFromPage6
	jb1	ActuateShiftKey
	jb2	ActuateCapsKey
	jmp	IgnoreKey
;
ActuateShiftKey:
	jb5	RepTxShiftKey
TxShiftKey:
	mov	a,r7
	call	ReadFromPage7
	jmp	CharToTxBuffer
;
ActuateCapsKey:
	mov	a,r4
	orl	a,#040H
	mov	r4,a
	jb1	TxShiftKey
	jmp	KeyDone
;
RepTxShiftKey:
	mov	a,r4
	orl	a,#040H
	mov	r4,a
	jmp	TxShiftKey
;
ProcessKeyWithCTRL:
	mov	a,r7
	call	ReadFromPage6
	jb3	L0145
L0143:
	jmp	IgnoreKey
;
L0145:
	jb4	L0152
ActuateCtrlKey:
	mov	a,r4
	orl	a,#040H
	mov	r4,a
	mov	a,r7
	add	a,#080H
	call	ReadFromPage7
	jmp	CharToTxBuffer
;
L0152:
	mov	a,r5
	jz	L0143
	mov	a,#0FFH
	call	TxByte
	jmp	ActuateCtrlKey
;
CheckSpecialKeys:
	orl	p1,#010H
	nop
	ins	a,bus
	mov	r7,a
	jb7	L0174
	mov	a,r4
	jb7	L0184
L0165:
	mov	a,r7
	jb2	L019F
	jb1	L01CD
	jb4	L018D
	jb3	L0197
	mov	a,r4
	anl	a,#0ECH
	mov	r4,a
	jmp	L01F0
;
L0174:
	mov	a,r4
	jb7	L01F0
	jb1	L017B
	jmp	L0165
;
L017B:
	orl	a,#080H
	mov	r4,a
	mov	a,#0F9H
	call	TxByte
	jmp	L01F0
;
L0184:
	anl	a,#07FH
	mov	r4,a
	mov	a,#0FEH
	call	TxByte
	jmp	L01F0
;
L018D:
	anl	p2,#0BFH
	mov	a,r4
	anl	a,#0FBH
	orl	a,#002H
	mov	r4,a
	jmp	L01F0
;
L0197:
	mov	a,r4
	orl	a,#004H
	mov	r4,a
	orl	p2,#040H
	jmp	L01F0
;
L019F:
	mov	a,r4
	orl	a,#001H
	mov	r4,a
	jmp	L01F0
;
L01A5:
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
	jmp	L01FA
;
L01B5:
	in	a,p2
	jb4	L01BA
	jmp	L01FA
;
L01BA:
	mov	a,r3
	anl	a,#07FH
	mov	r3,a
	mov	a,#0F3H
	call	TxByte
	jmp	L01FA
;
IgnoreKey:
	mov	a,r4
	orl	a,#040H
	mov	r4,a
	jmp	KeyDone
;
ReadFromPage1:
	movp	a,@a
	ret
;
	nop
L01CD:
	mov	a,r4
	jb4	L01F0
	jb3	L01E1
	orl	a,#018H
	mov	r4,a
	orl	p2,#080H
	mov	a,#0FFH
	call	TxByte
	mov	a,#0C1H
	call	TxByte
	jmp	L01F0
;
L01E1:
	orl	a,#010H
	anl	a,#0F7H
	mov	r4,a
	anl	p2,#07FH
	mov	a,#0FFH
	call	TxByte
	mov	a,#0C0H
	call	TxByte
L01F0:
	mov	a,r7
	rr	a
	xrl	a,r3
	anl	a,#030H
	jnz	L01A5
	mov	a,r3
	jb7	L01B5
L01FA:
	mov	r2,#000H
	mov	r1,#020H
	mov	a,r5
	jnz	L0206
	in	a,p2
	jb2	L0210
	jmp	L020C
;
L0206:
	dec	r5
	mov	a,r6
	mov	r6,#010H
	jnz	L0212
L020C:
	mov	a,r3
	anl	a,#0BFH
	mov	r3,a
L0210:
	mov	r5,#071H
L0212:
	sel	rb1
	mov	r1,#00DH
	inc	@r1
	mov	a,@r1
	jnz	TryTx
	jf0	L0226
	cpl	f0
	mov	@r1,#0D1H
	inc	r1
	mov	a,@r1
	cpl	a
	inc	r1
	anl	a,@r1
	mov	@r1,a
	jmp	L022E
;
L0226:
	clr	f0
	mov	@r1,#0A2H
	inc	r1
	mov	a,@r1
	inc	r1
	orl	a,@r1
	mov	@r1,a
L022E:
	cpl	a
	outl	bus,a
TryTx:
	in	a,p2
	jb3	L0250
L0233:
	sel	rb1
	mov	a,r5
	jnz	L0287
	sel	rb0
	in	a,p2
	jb2	L0258
	mov	a,r3
	anl	a,#00FH
L023E:
	jz	L0287
	dec	r3
	sel	rb1
	mov	a,@r0
	mov	r6,a
	inc	r0
	mov	r5,#00AH
	mov	a,r0
	xrl	a,#018H
	jnz	L0287
	mov	r0,#010H
	jmp	L0287
;
L0250:
	jb4	L0233
	sel	rb0
	mov	a,r3
	jb7	L0233
	jmp	L03F0
;
L0258:
	mov	a,r3
	anl	a,#007H
	jmp	L023E
;
L025D:
	inc	r1
	inc	r2
	mov	a,r4
	jb5	L0287
	jb6	L0287
	mov	a,r3
	jb6	L0276
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
L0276:
	mov	a,r7
	sel	rb1
	mov	r1,#00CH
	xrl	a,@r1
	jnz	L0287
	sel	rb0
	mov	r5,#007H
	mov	a,r7
	call	TxByte
	jmp	TryTx
L0285:
	jmp	DoKeyboardAction
;
L0287:
	sel	rb1
	mov	a,r2
	jnz	L02AA
	mov	a,r4
	jz	L02AA
	mov	r4,#000H
	mov	r1,#00FH
	jb7	L02AA
	jb6	L02AA
	jb5	L0285
	dec	a
	jb4	L02BD
	jb3	L02AC
	add	a,#0C9H
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
L02AA:
	jmp	Main
;
L02AC:
	anl	a,#007H
	add	a,#0C9H
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
L02BD:
	jb3	L02AA
	dec	r1
	anl	a,#007H
	add	a,#0C9H
	movp	a,@a
	orl	a,@r1
	mov	@r1,a
	jmp	Main
L02C9:
	db	001H, 002H, 004H, 008H, 010H, 020H, 040H, 080H

ReadFromPage2:
	movp	a,@a
	ret
;
	nop
TxROMCheck:
	in	a,p1
	jb6	TxROMCheck
	dis	tcnti
	clr	a
	clr	c
	mov	r0,a
	mov	r1,a
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

	jnc	L030F
	inc	r1
L030F:
	mov	a,r1
	call	TxA
	jmp	Beginning
;
DoKeyboardAction:
	jb4	L03A1
	anl	a,#00FH
	add	a,#01BH
	jmpp	@a						;INFO: indirect jump
L031B:
	db	BackToMain
	db	EnableClicks
	db	DisableClicks
	db	TurnOnCaps
	db	TriggerBeep
	db	TurnOffAllLEDs
	db	TurnOffHalfTheLEDs
	db	CheckExpDataline
	db	EnableKeyRepeat
	db	DisableKeyRepeat
	db	ReadLocks
	db	DisableExpReady
	db	EnableExpReady
	db	_TxROMCheck
	db	TxRAMCheck
	db	L03C3

;////////////////////////////////////////////////////////////

_TxROMCheck:
	jmp	TxROMCheck

;////////////////////////////////////////////////////////////

EnableClicks:
	orl	p1,#080H
	jmp	Main

;////////////////////////////////////////////////////////////

DisableClicks:
	anl	p1,#07FH
	jmp	Main

;////////////////////////////////////////////////////////////

TurnOnCaps:
	sel	rb0
	mov	a,r4
	orl	a,#008H
	mov	r4,a
	orl	p2,#080H
	jmp	Main

;////////////////////////////////////////////////////////////

TriggerBeep:
	anl	p2,#0DFH
	nop
	orl	p2,#020H
BackToMain:
	jmp	Main

;////////////////////////////////////////////////////////////

TurnOffAllLEDs:
	clr	a
	mov	@r1,a
	dec	r1
	mov	@r1,a
	cpl	a
	outl	bus,a
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

CheckExpDataline:
	sel	rb0
	jnt1	L0363
	mov	a,#0F5H
	call	TxByte
	jmp	Main

L0363:
	mov	a,#0EFH
	call	TxByte
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
	jmp	Main

;////////////////////////////////////////////////////////////

DisableExpReady:
	jnt1	L0392
	orl	p2,#008H
	jmp	Main

;////////////////////////////////////////////////////////////

EnableExpReady:
	anl	p2,#0F7H
	jmp	Main

;////////////////////////////////////////////////////////////

L0392:
	sel	rb0
	mov	a,#0F6H
	call	TxByte
	mov	a,#0E0H
	call	TxByte
	mov	a,#0F7H
	call	TxByte
	jmp	Main

;////////////////////////////////////////////////////////////

L03A1:
	xrl	a,#030H
	jnz	BackToMain
	orl	p2,#004H
	jmp	Main

;////////////////////////////////////////////////////////////

TxRAMCheck:
	in	a,p1
	jb6	TxRAMCheck
	dis	tcnti
	mov	r0,#03FH
L03AF:
	mov	a,r0
	jz	L03B9
	mov	@r0,a
	xrl	a,@r0
	jnz	L03BD
	dec	r0
	jmp	L03AF
L03B9:
	mov	a,#0AAH
	jmp	L03BF
L03BD:
	mov	a,#0EEH
L03BF:
	call	TxA
	jmp	Beginning
L03C3:
	sel	rb0
	mov	r7,#080H
L03C6:
	mov	a,r7
	call	ReadFromPage6
	call	TxByte
	mov	a,r7
	jb1	L03D1
	inc	r7
	jmp	L03C6
;
L03D1:
	mov	r7,#080H
L03D3:
	mov	a,r7
	call	ReadFromPage7
	call	TxByte
	mov	a,r7
	jb1	BackToMain
	inc	r7
	jmp	L03D3

;////////////////////////////////////////////////////////////

TxByte:
	mov	@r0,a
	inc	r3
	inc	r0
	mov	a,r0
	xrl	a,#018H
	jnz	L03E8
	mov	r0,#010H
L03E8:
	ret

;////////////////////////////////////////////////////////////

AddAToR1IncR0:
	addc	a,r1
	mov	r1,a
	inc	r0
	mov	a,r0
	ret

;////////////////////////////////////////////////////////////

ReadFromPage3:
	movp	a,@a
	ret
;
L03F0:
	sel	rb1
	call	L052D
	dis	tcnti
	anl	p1,#0BFH
	orl	p1,#020H
	clr	a
	mov	r1,#080H
	mov	r2,#02FH
	mov	r3,#005H
	mov	r4,a
	mov	r5,#005H
	mov	r6,a
	anl	p1,#0E0H
	orl	p1,#010H
	en	i
L0408:
	jtf	L0411
	mov	a,r6
	jb0	ExpTxR4
	jb3	L0417
	jmp	L0408
;
L0411:
	djnz	r2,L0408
	mov	r4,#0E1H
	jmp	ExpTxR4
;
L0417:
	dis	i
	mov	a,r3
	mov	r3,#080H
	jb1	L0441
	mov	a,#0F6H
	call	TxA
	mov	a,#081H
L0423:
	call	TxAImmediate
	mov	r0,#010H
L0427:
	mov	r3,#080H
	mov	a,@r0
	jb7	L042E
	jmp	L0449
;
L042E:
	anl	a,#07FH
	call	TxAImmediate
	inc	r0
	mov	a,r0
	xrl	a,#018H
	jz	L043D
	mov	a,r0
	jb6	L0449
	jmp	L0427
;
L043D:
	mov	r0,#020H
	jmp	L0427
;
L0441:
	mov	a,#0F6H
	call	TxA
	mov	a,#082H
	jmp	L0423
;
L0449:
	mov	a,r1
	jb7	L044E
	call	TxAImmediate
L044E:
	mov	a,#0F7H
	call	TxAImmediate
	jmp	ResetFromExp
;
ExpTxR4:
	dis	i
	mov	r3,#080H
	mov	a,#0F6H
	call	TxA
	mov	a,r4
	call	TxAImmediate
	mov	a,#0F7H
	call	TxAImmediate
	jmp	ResetFromExp

;///////////////////////////////////////////////////////

SignalIntHandler:
	mov	r7,a
	anl	p1,#0E0H
	mov	a,r4
	jnt1	L0478
L046A:
	rr	a
	mov	r4,a
	mov	a,r6
	jb0	L04FB
	jb2	L047C
	jb3	L04FB
	mov	a,r4
	jb6	L04A2
	jmp	L04FB
;
L0478:
	orl	a,#080H
	jmp	L046A
;
L047C:
	mov	a,t
	add	a,#0D7H
	jc	L04E9
	add	a,#025H
	jnc	L04EF
	clr	a
	mov	t,a
	djnz	r5,L04FD
	mov	a,r3
	mov	r5,a
	jb1	L04C9
	mov	a,r6
	jb1	L04A6
	jb4	L04E1
	mov	a,r4
	xrl	a,#02CH
	jz	L049D
	mov	r5,#002H
	mov	r3,#007H
	jmp	L04FD
;
L049D:
	mov	r4,a
	mov	r6,#006H
	jmp	L04FD
;
L04A2:
	mov	r6,#004H
	jmp	L047C
;
L04A6:
	mov	a,r4
	rr	a
	rr	a
	mov	r4,a
	xrl	a,#01FH
	jz	L04DC
L04AE:
	mov	a,r4
	orl	a,#080H
	mov	@r0,a
	mov	r4,#000H
	inc	r0
	mov	a,r0
	xrl	a,#018H
	jz	L04C5
	mov	a,r0
	xrl	a,#040H
	jnz	L04FD
	mov	r4,#0E5H
	mov	r6,#001H
	jmp	L04FD
;
L04C5:
	mov	r0,#020H
	jmp	L04FD
;
L04C9:
	mov	a,r6
	jb1	L04D3
	mov	a,r4
	xrl	a,#05DH
	jnz	L04F7
	jmp	L049D
;
L04D3:
	mov	a,r4
	xrl	a,#077H
	jnz	L04AE
	mov	r6,#008H
	jmp	L04FD
;
L04DC:
	mov	r6,#014H
	mov	r4,a
	jmp	L04FD
;
L04E1:
	mov	a,r4
	rr	a
	rr	a
	mov	r1,a
	mov	r6,#008H
	jmp	L04FD
;
L04E9:
	mov	r4,#0E2H
	mov	r6,#001H
	jmp	L04FB
;
L04EF:
	mov	r4,#0E3H
	mov	r6,#001H
	jmp	L04FB
;
ReadFromPage4:
	movp	a,@a
	ret
;
L04F7:
	mov	r4,#0E4H
	mov	r6,#001H
L04FB:
	clr	a
	mov	t,a
L04FD:
	mov	a,r7
	orl	p1,#010H
	retr

;///////////////////////////////////////////////////////

ResetFromExp:
	dis	tcnti
	sel	rb0
	mov	r0,#010H
	mov	r1,#020H
	mov	r2,#000H
	mov	a,r3
	anl	a,#0B0H
	orl	a,#080H
	mov	r3,a
	mov	r5,#0FFH
	sel	rb1
	call	L052D
	mov	r2,a
	mov	r3,#001H
	mov	r4,a
	mov	r5,a
	mov	r6,a
	mov	a,#0FFH
	mov	t,a
	en	tcnti
	jmp	Main

;/////////////////////////////////////////////////////

TxA:
	mov	r7,a
	mov	a,#0FEH
	mov	t,a
	mov	a,r7
	en	tcnti
TxAImmediate:
	mov	r6,a
	mov	r5,#00AH
L0529:
	mov	a,r5
	jnz	L0529
	ret

;/////////////////////////////////////////////////////

L052D:
	mov	r0,#010H
L052F:
	mov	@r0,#000H
	inc	r0
	mov	a,r0
	xrl	a,#018H
	jnz	L052F
	mov	r0,#020H
L0539:
	mov	@r0,#000H
	inc	r0
	mov	a,r0
	xrl	a,#040H
	jnz	L0539
	mov	r0,#010H
	ret

;/////////////////////////////////////////////////////

Init:
	dis	tcnti
	mov	r0,#03FH
L0547:
	mov	@r0,#000H
	djnz	r0,L0547
	mov	r0,#010H
	mov	r1,#020H
	mov	r5,#0FFH
	mov	a,#030H
	outl	p1,a
	outl	p2,a
	ins	a,bus
	rr	a
	anl	a,#030H
	mov	r3,a
	anl	p1,#020H
	sel	rb1
	mov	r0,#010H
	inc	r3
	mov	a,#0FFH
	outl	bus,a
	mov	t,a
	strt	t
	en	tcnti
	jmp	Main
;
ReadFromPage5:
	movp	a,@a
	ret

	db	                                                  00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H


;////////////////////////////////////////////////////////////
ReadFromPage6:
	movp	a,@a
	ret

	db	19H	; Checksum ajustement

	db	               06H, 05H, 0FH, 05H, 05H, 05H, 05H, 0FH, 07H, 00H, 00H, 07H, 07H
	db	07H, 07H, 07H, 07H, 07H, 07H, 07H, 07H, 07H, 05H, 07H, 05H, 05H, 07H, 05H, 07H
	db	05H, 05H, 0DH, 0DH, 05H, 0DH, 0DH, 0DH, 05H, 05H, 0DH, 05H, 05H, 05H, 05H, 0DH
	db	0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 1FH, 1FH, 1FH, 07H, 0FH, 0FH, 0FH, 0FH
	db	0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 1FH, 1FH, 07H, 0FH, 05H, 05H, 0FH
	db	0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 1FH, 07H, 05H, 05H, 0FH, 0FH
	db	1FH, 1FH, 1FH, 1FH, 1FH, 1FH, 1FH, 1FH, 1FH, 0FH, 1FH, 07H, 05H, 0FH, 05H, 0FH
	db	07H, 05H, 05H, 05H, 05H, 05H, 05H, 05H, 05H, 05H, 05H, 05H, 27H, 05H, 05H, 05H

	db	'531'

	db	               86H, 99H, B2H, CAH, C4H, 8FH, 88H, B3H, 80H, 00H, 00H, 82H, 84H
	db	EAH, E3H, E6H, E2H, E1H, 85H, E4H, ECH, E7H, 8CH, E5H, 8DH, 8EH, E8H, 8BH, E9H
	db	9DH, 8AH, 9EH, 9CH, 9DH, 9BH, CCH, CBH, C6H, 89H, C2H, F2H, 87H, 97H, F0H, C1H
	db	5CH, 7AH, 78H, 63H, 76H, 62H, 6EH, 6DH, 2CH, 2EH, 2FH, E0H, 20H, B8H, B4H, CDH
	db	61H, 73H, 64H, 66H, 67H, 68H, 6AH, 6BH, 6CH, 3BH, 3AH, EDH, B1H, C3H, 91H, 7DH
	db	71H, 77H, 65H, 72H, 74H, 79H, 75H, 69H, 6FH, 70H, 60H, 83H, C5H, 90H, 9AH, 7BH
	db	31H, 32H, 33H, 34H, 35H, 36H, 37H, 38H, 39H, 30H, 2DH, EBH, 96H, 7FH, EEH, 5EH
	db	DBH, A0H, A1H, A2H, A3H, A4H, A5H, A6H, A7H, BDH, BCH, F1H, FAH, F4H, B0H, C0H

;////////////////////////////////////////////////////////////
ReadFromPage7:
	movp	a,@a
	ret
	nop

	db	               86H, 86H, B2H, 85H, DAH, C9H, D7H, B3H, 80H, 00H, 00H, 82H, 84H
	db	EAH, E3H, E6H, E2H, E1H, 85H, E4H, ECH, E7H, 95H, E5H, 98H, 9FH, E8H, 92H, E9H
	db	BAH, D5H, BEH, BBH, BAH, BFH, B9H, B7H, C7H, D4H, B6H, D1H, D3H, D8H, D2H, B5H
	db	7CH, 5AH, 58H, 43H, 56H, 42H, 4EH, 4DH, 3CH, 3EH, 3FH, E0H, 20H, B8H, B4H, CDH
	db	41H, 53H, 44H, 46H, 47H, 48H, 4AH, 4BH, 4CH, 2BH, 2AH, EDH, B1H, D9H, 94H, 5DH
	db	51H, 57H, 45H, 52H, 54H, 59H, 55H, 49H, 4FH, 50H, 40H, 83H, C8H, 93H, 9AH, 5BH
	db	21H, 22H, 23H, 24H, 25H, 26H, 27H, 28H, 29H, 5FH, 3DH, EBH, D6H, 7FH, FEH, 7EH
	db	DBH, A8H, A9H, AAH, ABH, ACH, ADH, AEH, AFH, 80H, 81H, D0H, FAH, 84H, 83H, 82H

	db	'300'

	db	               00H, 00H, B2H, 00H, 00H, 00H, 00H, B3H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, CEH, CFH, 00H, FBH, F9H, F8H, 00H, 00H, FCH, 00H, 00H, 00H, 00H, FDH
	db	1CH, 1AH, 18H, 03H, 16H, 02H, 0EH, 0DH, 80H, 81H, 82H, 00H, 20H, B8H, B4H, CDH
	db	01H, 13H, 04H, 06H, 07H, 08H, 0AH, 0BH, 0CH, 83H, 84H, 00H, B1H, 00H, 00H, 1DH
	db	11H, 17H, 05H, 12H, 14H, 19H, 15H, 09H, 0FH, 10H, 85H, 00H, 00H, 00H, 9AH, 1BH
	db	86H, 87H, 88H, 89H, 8AH, 8BH, 8CH, 8DH, 8EH, 1FH, 8FH, 00H, 00H, 7FH, 00H, 1EH
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H