	.cfi_sections .debug_frame

	.text
	.type KPutCharX, function
	.globl	KPutCharX

KPutCharX:
	.cfi_startproc
	move.l	a6, -(sp)
	.cfi_adjust_cfa_offset 4
	move.l	4.w, a6
	jsr		-0x204(a6)
	move.l	(sp)+, a6
	.cfi_adjust_cfa_offset -4
	rts
	.cfi_endproc
	.size KPutCharX, .-KPutCharX

	.text
	.type PutChar, function
	.globl	PutChar

PutChar:
	.cfi_startproc
	move.b	d0, (a3)+
	rts
	.cfi_endproc
	.size PutChar, .-PutChar
