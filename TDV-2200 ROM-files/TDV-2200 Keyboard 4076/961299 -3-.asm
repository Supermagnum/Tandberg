;
;	Disassembled by:
;		DASMx object code disassembler
;		(c) Copyright 1996-2003   Conquest Consultants
;		Version 1.40 (Oct 18 2003)
;
;	File:		C:\Users\Frode\Desktop\Datasystemer\TDV22xx terminals\DASMx\TDV2200 TDV2215 Keyboard 4076 (961299 -3-).BIN
;
;	Size:		2048 bytes
;	Checksum:	4562
;	CRC-32:		EEA0B978
;
;	Date:		Fri Mar 29 21:37:49 2019
;
;	CPU:		Intel 8048 (MCS-48 family)
;
;
;
	org	00000H
;
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
ReceiveLow:
	clr	c
	jmp	ReceiveAny
;
ReceiveBit:
	mov	r3,#004H
	mov	a,r4
	jnt0	ReceiveLow
	clr	c
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
;
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
	jz	L0080
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
L0080:
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
	jz	L00F5
	mov	r5,#071H
	in	a,p2
	jb2	L00E9
L00DC:
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
L00E9:
	mov	a,r3
	orl	a,#040H
	mov	r3,a
	mov	a,r7
	sel	rb1
	mov	r1,#00CH
	mov	@r1,a
	sel	rb0
	jmp	L00DC
L00F5:
	jmp	L024D
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
	jb3	ProcessKeyWithCAPS
	mov	a,r7
	call	ReadFromPage6
L0112:
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
L0128:
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
	jb3	L014A
	jmp	IgnoreKey
;
L014A:
	mov	a,r4
	orl	a,#040H
	mov	r4,a
	mov	a,r7
	add	a,#080H
	call	ReadFromPage7
	jmp	CharToTxBuffer
;
ProcessKeyWithCAPS:
	mov	a,r7
	call	ReadFromPage6
	jb4	L0112
	jmp	L0128
;
CheckSpecialKeys:
	orl	p1,#010H
	nop
	ins	a,bus
	mov	r7,a
	jb7	L0175
	mov	a,r4
	jb7	L0185
L0166:
	mov	a,r7
	jb2	L01A0
	jb1	L01CC
	jb4	L018E
	jb3	L0198
	mov	a,r4
	anl	a,#0ECH
	mov	r4,a
	jmp	L01DF
;
L0175:
	mov	a,r4
	jb7	L01DF
	jb1	L017C
	jmp	L0166
;
L017C:
	orl	a,#080H
	mov	r4,a
	mov	a,#0F9H
	call	TxByte
	jmp	L01DF
;
L0185:
	anl	a,#07FH
	mov	r4,a
	mov	a,#0FEH
	call	TxByte
	jmp	L01DF
;
L018E:
	anl	p2,#0BFH
	mov	a,r4
	anl	a,#0FBH
	orl	a,#002H
	mov	r4,a
	jmp	L01DF
;
L0198:
	mov	a,r4
	orl	a,#004H
	mov	r4,a
	orl	p2,#040H
	jmp	L01DF
;
L01A0:
	mov	a,r4
	orl	a,#001H
	mov	r4,a
	jmp	L01DF
;
L01A6:
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
	jmp	L01E9
;
L01B6:
	in	a,p2
	jb4	L01BB
	jmp	L01E9
;
L01BB:
	mov	a,r3
	anl	a,#07FH
	mov	r3,a
	mov	a,#0F3H
	call	TxByte
	jmp	L01E9
;
ReadFromPage1:
	movp	a,@a
	ret
;
L01C7:
	in	a,p2
	jb2	L01FA
	jmp	L01F6
;
L01CC:
	mov	a,r4
	jb4	L01DF
	jb3	L01D8
	orl	a,#018H
	mov	r4,a
	orl	p2,#080H
	jmp	L01DF
;
L01D8:
	orl	a,#010H
	anl	a,#0F7H
	mov	r4,a
	anl	p2,#07FH
L01DF:
	mov	a,r7
	rr	a
	xrl	a,r3
	anl	a,#030H
	jnz	L01A6
	mov	a,r3
	jb7	L01B6
L01E9:
	mov	r2,#000H
	mov	r1,#020H
	mov	a,r5
	jz	L01C7
	dec	r5
	mov	a,r6
	mov	r6,#010H
	jnz	L01FC
L01F6:
	mov	a,r3
	anl	a,#0BFH
	mov	r3,a
L01FA:
	mov	r5,#071H
L01FC:
	sel	rb1
	mov	r1,#00DH
	inc	@r1
	mov	a,@r1
	jnz	TryTx
	jf0	L0210
	cpl	f0
	mov	@r1,#0D1H
	inc	r1
	mov	a,@r1
	cpl	a
	inc	r1
	anl	a,@r1
	mov	@r1,a
	jmp	L0218
;
L0210:
	clr	f0
	mov	@r1,#0A2H
	inc	r1
	mov	a,@r1
	inc	r1
	orl	a,@r1
	mov	@r1,a
L0218:
	cpl	a
	outl	bus,a
TryTx:
	in	a,p2
	jb3	L023A
L021D:
	sel	rb1
	mov	a,r5
	jnz	L0277
	sel	rb0
	in	a,p2
	jb2	L0242
	mov	a,r3
	anl	a,#00FH
L0228:
	jz	L0277
	dec	r3
	sel	rb1
	mov	a,@r0
	mov	r6,a
	inc	r0
	mov	r5,#00AH
	mov	a,r0
	xrl	a,#018H
	jnz	L0277
	mov	r0,#010H
	jmp	L0277
;
L023A:
	jb4	L021D
	sel	rb0
	mov	a,r3
	jb7	L021D
	jmp	L03EC
;
L0242:
	mov	a,r3
	anl	a,#007H
	jmp	L0228
;
IgnoreKey:
	mov	a,r4
	orl	a,#040H
	mov	r4,a
	jmp	KeyDone
;
L024D:
	inc	r1
	inc	r2
	mov	a,r4
	jb5	L0277
	jb6	L0277
	mov	a,r3
	jb6	L0266
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
L0266:
	mov	a,r7
	sel	rb1
	mov	r1,#00CH
	xrl	a,@r1
	jnz	L0277
	sel	rb0
	mov	r5,#007H
	mov	a,r7
	call	TxByte
	jmp	TryTx
L0275:
	jmp	DoKeyboardAction
;
L0277:
	sel	rb1
	mov	a,r2
	jnz	L029A
	mov	a,r4
	jz	L029A
	mov	r4,#000H
	mov	r1,#00FH
	jb7	L029A
	jb6	L029A
	jb5	L0275
	dec	a
	jb4	L02AD
	jb3	L029C
	add	a,#0B9H
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
L029A:
	jmp	Main
;
L029C:
	anl	a,#007H
	add	a,#0B9H
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
L02AD:
	jb3	L029A
	dec	r1
	anl	a,#007H
	add	a,#0B9H
	movp	a,@a
	orl	a,@r1
	mov	@r1,a
	jmp	Main
L02B9:
	db	001H, 002H, 004H, 008H, 010H, 020H, 040H, 080H

ReadFromPage2:
	movp	a,@a
	ret
;
TxROMCheck:
	in	a,p1
	jb6	TxROMCheck
	dis	tcnti
	clr	a
	clr	c
	mov	r0,a
	mov	r1,a
L02CB:
	call	ReadFromPage0
	call	L03E5
	jnz	L02CB
L02D1:
	call	ReadFromPage1
	call	L03E5
	jnz	L02D1
L02D7:
	call	ReadFromPage2
	call	L03E5
	jnz	L02D7
L02DD:
	call	ReadFromPage3
	call	L03E5
	jnz	L02DD
L02E3:
	call	ReadFromPage4
	call	L03E5
	jnz	L02E3
L02E9:
	call	ReadFromPage5
	call	L03E5
	jnz	L02E9
L02EF:
	call	ReadFromPage6
	call	L03E5
	jnz	L02EF
L02F5:
	call	ReadFromPage7
	call	L03E5
	jnz	L02F5

	jnc	L02FE
	inc	r1
L02FE:
	mov	a,r1
	call	TxA
	jmp	Beginning
;
DoKeyboardAction:
	jb4	L0390
	anl	a,#00FH
	add	a,#00AH
	jmpp	@a						;INFO: indirect jump
L030A:
	db	L0332
	db	L031C
	db	L0320
	db	L0324
	db	L032D
	db	L0334
	db	L033C
	db	L0349
	db	L0358
	db	L0365
	db	L036C
	db	L0377
	db	L037D 
	db	L031A
	db	L0398
	db	L03B2

;////////////////////////////////////////////////////////////

L031A:
	jmp	TxROMCheck

;////////////////////////////////////////////////////////////

L031C:
	orl	p1,#080H
	jmp	Main

;////////////////////////////////////////////////////////////

	anl	p1,#07FH
	jmp	Main

;////////////////////////////////////////////////////////////

	sel	rb0
	mov	a,r4
	orl	a,#008H
	mov	r4,a
	orl	p2,#080H
	jmp	Main

;////////////////////////////////////////////////////////////

	anl	p2,#0DFH
	nop
	orl	p2,#020H
L0332:
	jmp	Main

;////////////////////////////////////////////////////////////

	clr	a
	mov	@r1,a
	dec	r1
	mov	@r1,a
	cpl	a
	outl	bus,a
	jmp	Main

;////////////////////////////////////////////////////////////

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

	sel	rb0
	jnt1	L0352
	mov	a,#0F5H
	call	TxByte
	jmp	Main

L0352:
	mov	a,#0EFH
	call	TxByte
	jmp	Main

;////////////////////////////////////////////////////////////

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

	sel	rb0
	mov	a,r4
	orl	a,#020H
	mov	r4,a
	jmp	Main

;////////////////////////////////////////////////////////////

	sel	rb0
	mov	a,r3
	swap	a
	anl	a,#003H
	xrl	a,#0DFH
	call	TxByte
	jmp	Main

;////////////////////////////////////////////////////////////

	jnt1	L0381
	orl	p2,#008H
	jmp	Main

;////////////////////////////////////////////////////////////

	anl	p2,#0F7H
	jmp	Main

;////////////////////////////////////////////////////////////

L0381:
	sel	rb0
	mov	a,#0F6H
	call	TxByte
	mov	a,#0E0H
	call	TxByte
	mov	a,#0F7H
	call	TxByte
	jmp	Main

;////////////////////////////////////////////////////////////

L0390:
	xrl	a,#030H
	jnz	L0332
	orl	p2,#004H
	jmp	Main

;////////////////////////////////////////////////////////////

L0398:
	in	a,p1
	jb6	L0398
	dis	tcnti
	mov	r0,#03FH
L039E:
	mov	a,r0
	jz	L03A8
	mov	@r0,a
	xrl	a,@r0
	jnz	L03AC
	dec	r0
	jmp	L039E
;
L03A8:
	mov	a,#0AAH
	jmp	L03AE
;
L03AC:
	mov	a,#0EEH
L03AE:
	call	TxA
	jmp	Beginning
;
	sel	rb0
	mov	r7,#080H
L03B5:
	mov	a,r7
	call	ReadFromPage6
	call	TxByte
	mov	a,r7
	jb1	L03C0
	inc	r7
	jmp	L03B5
;
L03C0:
	mov	r7,#080H
L03C2:
	mov	a,r7
	call	ReadFromPage7
	call	TxByte
	mov	a,r7
	jb1	L0332
	inc	r7
	jmp	L03C2

;////////////////////////////////////////////////////////////

TxA:
	mov	r7,a
	mov	a,#0FEH
	mov	t,a
	mov	a,r7
	en	tcnti
TxAImmediate:
	mov	r6,a
	mov	r5,#00AH
L03D6:
	mov	a,r5
	jnz	L03D6
	ret

;////////////////////////////////////////////////////////////

TxByte:
	mov	@r0,a
	inc	r3
	inc	r0
	mov	a,r0
	xrl	a,#018H
	jnz	L03E4
	mov	r0,#010H
L03E4:
	ret

;////////////////////////////////////////////////////////////

L03E5:
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
L03EC:
	sel	rb1
	call	L051C
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
L0404:
	jtf	L040D
	mov	a,r6
	jb0	L0450
	jb3	L0413
	jmp	L0404
;
L040D:
	djnz	r2,L0404
	mov	r4,#0E1H
	jmp	L0450
;
L0413:
	dis	i
	mov	a,r3
	mov	r3,#080H
	jb1	L043D
	mov	a,#0F6H
	call	TxA
	mov	a,#081H
L041F:
	call	TxAImmediate
	mov	r0,#010H
L0423:
	mov	r3,#080H
	mov	a,@r0
	jb7	L042A
	jmp	L0445
;
L042A:
	anl	a,#07FH
	call	TxAImmediate
	inc	r0
	mov	a,r0
	xrl	a,#018H
	jz	L0439
	mov	a,r0
	jb6	L0445
	jmp	L0423
;
L0439:
	mov	r0,#020H
	jmp	L0423
;
L043D:
	mov	a,#0F6H
	call	TxA
	mov	a,#082H
	jmp	L041F
;
L0445:
	mov	a,r1
	jb7	L044A
	call	TxAImmediate
L044A:
	mov	a,#0F7H
	call	TxAImmediate
	jmp	L04FD
;
L0450:
	dis	i
	mov	r3,#080H
	mov	a,#0F6H
	call	TxA
	mov	a,r4
	call	TxAImmediate
	mov	a,#0F7H
	call	TxAImmediate
	jmp	L04FD
;
SignalIntHandler:
	mov	r7,a
	anl	p1,#0E0H
	mov	a,r4
	jnt1	L0474
L0466:
	rr	a
	mov	r4,a
	mov	a,r6
	jb0	L04F5
	jb2	L0478
	jb3	L04F5
	mov	a,r4
	jb6	L049E
	jmp	L04F5
;
L0474:
	orl	a,#080H
	jmp	L0466
;
L0478:
	mov	a,t
	add	a,#0D7H
	jc	L04E5
	add	a,#025H
	jnc	L04EB
	clr	a
	mov	t,a
	djnz	r5,L04F7
	mov	a,r3
	mov	r5,a
	jb1	L04C5
	mov	a,r6
	jb1	L04A2
	jb4	L04DD
	mov	a,r4
	xrl	a,#02CH
	jz	L0499
	mov	r5,#002H
	mov	r3,#007H
	jmp	L04F7
;
L0499:
	mov	r4,a
	mov	r6,#006H
	jmp	L04F7
;
L049E:
	mov	r6,#004H
	jmp	L0478
;
L04A2:
	mov	a,r4
	rr	a
	rr	a
	mov	r4,a
	xrl	a,#01FH
	jz	L04D8
L04AA:
	mov	a,r4
	orl	a,#080H
	mov	@r0,a
	mov	r4,#000H
	inc	r0
	mov	a,r0
	xrl	a,#018H
	jz	L04C1
	mov	a,r0
	xrl	a,#040H
	jnz	L04F7
	mov	r4,#0E5H
	mov	r6,#001H
	jmp	L04F7
;
L04C1:
	mov	r0,#020H
	jmp	L04F7
;
L04C5:
	mov	a,r6
	jb1	L04CF
	mov	a,r4
	xrl	a,#05DH
	jnz	L04F1
	jmp	L0499
;
L04CF:
	mov	a,r4
	xrl	a,#077H
	jnz	L04AA
	mov	r6,#008H
	jmp	L04F7
;
L04D8:
	mov	r6,#014H
	mov	r4,a
	jmp	L04F7
;
L04DD:
	mov	a,r4
	rr	a
	rr	a
	mov	r1,a
	mov	r6,#008H
	jmp	L04F7
;
L04E5:
	mov	r4,#0E2H
	mov	r6,#001H
	jmp	L04F5
;
L04EB:
	mov	r4,#0E3H
	mov	r6,#001H
	jmp	L04F5
;
L04F1:
	mov	r4,#0E4H
	mov	r6,#001H
L04F5:
	clr	a
	mov	t,a
L04F7:
	mov	a,r7
	orl	p1,#010H
	retr
;
ReadFromPage4:
	movp	a,@a
	ret

;/////////////////////////////////////////////////////

L04FD:
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
	call	L051C
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

L051C:
	mov	r0,#010H
L051E:
	mov	@r0,#000H
	inc	r0
	mov	a,r0
	xrl	a,#018H
	jnz	L051E
	mov	r0,#020H
L0528:
	mov	@r0,#000H
	inc	r0
	mov	a,r0
	xrl	a,#040H
	jnz	L0528
	mov	r0,#010H
	ret

;/////////////////////////////////////////////////////

Init:
	dis	tcnti
	mov	r0,#03FH
L0536:
	mov	@r0,#000H
	djnz	r0,L0536
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

	db	                                             00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
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

	db	D8H

	db	               37H, 3FH, 17H, 3FH, 1FH, 3FH, 3FH, 17H, 37H, 00H, 00H, 37H, 37H
	db	17H, 17H, 17H, 17H, 17H, 37H, 17H, 17H, 17H, 37H, 17H, 37H, 37H, 17H, 37H, 17H
	db	37H, 3FH, 37H, 3FH, 3FH, 3FH, 3DH, 34H, 3FH, 3FH, 3CH, 3FH, 3FH, 3FH, 3FH, 3FH
	db	17H, 0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 17H, 17H, 1FH, 17H, 1FH, 37H, 17H, 37H
	db	0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 17H, 17H, 1FH, 37H, 17H
	db	0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 0FH, 37H, 3FH, 37H, 17H, 1FH
	db	17H, 17H, 17H, 17H, 17H, 17H, 17H, 17H, 17H, 17H, 17H, 17H, 3FH, 37H, 17H, 1FH
	db	3FH, 3FH, 3FH, 3FH, 3FH, 3FH, 3FH, 3FH, 3FH, 3FH, 3FH, 3FH, 37H, 37H, 3FH, 3FH

	db	'129'

	db	               86H, 09H, B2H, CAH, 17H, 15H, 12H, B3H, 80H, 00H, 00H, 82H, 84H
	db	EAH, E3H, E6H, E2H, E1H, 85H, E4H, ECH, E7H, BEH, E5H, 3DH, 2BH, E8H, BFH, E9H
	db	81H, 14H, DBH, 1FH, 1EH, 9BH, FEH, 00H, 05H, 11H, 00H, 10H, 09H, 13H, 19H, 16H
	db	3CH, 7AH, 78H, 63H, 76H, 62H, 6EH, 6DH, 2CH, 2EH, 2DH, E0H, 20H, B8H, B4H, CDH
	db	61H, 73H, 64H, 66H, 67H, 68H, 6AH, 6BH, 6CH, 7CH, 7BH, EDH, B1H, 0CH, 05H, 27H
	db	71H, 77H, 65H, 72H, 74H, 79H, 75H, 69H, 6FH, 70H, 7DH, 83H, 06H, 07H, 9AH, 5EH
	db	31H, 32H, 33H, 34H, 35H, 36H, 37H, 38H, 39H, 30H, 2BH, EBH, 1AH, 7FH, 08H, 40H
	db	0FH, A0H, A1H, A2H, A3H, A4H, A5H, A6H, A7H, 0EH, 02H, 04H, FAH, FBH, 03H, 01H

;////////////////////////////////////////////////////////////

ReadFromPage7:
	movp	a,@a
	ret
	nop

	db	               86H, 09H, B2H, CAH, 17H, 15H, 12H, B3H, 80H, 00H, 00H, 82H, 84H
	db	EAH, E3H, E6H, E2H, E1H, 85H, E4H, ECH, E7H, BEH, E5H, 3DH, 2BH, E8H, BFH, E9H
	db	81H, 14H, DBH, 1FH, 1EH, 9BH, F9H, F8H, 05H, 11H, FCH, 10H, 09H, 13H, 19H, 16H
	db	3EH, 5AH, 58H, 43H, 56H, 42H, 4EH, 4DH, 3BH, 3AH, 5FH, E0H, 20H, B8H, B4H, CDH
	db	41H, 53H, 44H, 46H, 47H, 48H, 4AH, 4BH, 4CH, 5CH, 5BH, EDH, B1H, 0CH, 05H, 2AH
	db	51H, 57H, 45H, 52H, 54H, 59H, 55H, 49H, 4FH, 50H, 5DH, 83H, 06H, 07H, 9AH, 7EH
	db	21H, 22H, 23H, 24H, 25H, 26H, 2FH, 28H, 29H, 3DH, 3FH, EBH, 1AH, 7FH, 08H, 60H
	db	0FH, A8H, A9H, AAH, ABH, ACH, ADH, AEH, AFH, 0EH, 02H, 04H, FAH, FBH, 03H, 01H

	db	'903'

	db	               00H, 99H, 00H, CAH, C5H, D7H, 97H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
	db	00H, 8FH, 00H, 91H, 90H, 93H, F4H, 00H, F2H, 8EH, FDH, 8AH, 8DH, 9CH, 8BH, 8CH
	db	00H, 1AH, 18H, 03H, 16H, 02H, 0EH, 0DH, 00H, 00H, 1FH, 00H, 00H, 00H, 00H, 00H
	db	01H, 13H, 04H, 06H, 07H, 08H, 0AH, 0BH, 0CH, 1CH, 1BH, 00H, 00H, C6H, 00H, 00H
	db	11H, 17H, 05H, 12H, 14H, 19H, 15H, 09H, 0FH, 10H, 1DH, 00H, 9DH, 00H, 00H, 1EH
	db	00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 96H, 00H, 00H, 00H
	db	80H, 81H, 82H, 83H, 84H, 85H, 86H, 87H, 88H, BDH, BCH, 89H, 00H, 00H, B0H, C0H
