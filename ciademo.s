
ciademo.elf:     file format elf32-m68k


Disassembly of section .text:

00000000 <_start>:
extern void (*__init_array_end[])() __attribute__((weak));
extern void (*__fini_array_start[])() __attribute__((weak));
extern void (*__fini_array_end[])() __attribute__((weak));

__attribute__((used)) __attribute__((section(".text.unlikely")))
void _start() {
   0:	       movem.l d2-d3/a2,-(sp)
	// initialize globals, ctors etc.
	unsigned long count;
	unsigned long i;

	count = __preinit_array_end - __preinit_array_start;
   4:	       move.l #9691,d3
   a:	       subi.l #9691,d3
  10:	       asr.l #2,d3
	for (i = 0; i < count; i++)
  12:	/----- beq.s 26 <_start+0x26>
  14:	|      lea 25db <__bss_start>,a2
  1a:	|      moveq #0,d2
		__preinit_array_start[i]();
  1c:	|  /-> movea.l (a2)+,a0
  1e:	|  |   jsr (a0)
	for (i = 0; i < count; i++)
  20:	|  |   addq.l #1,d2
  22:	|  |   cmp.l d3,d2
  24:	|  \-- bne.s 1c <_start+0x1c>

	count = __init_array_end - __init_array_start;
  26:	\----> move.l #9691,d3
  2c:	       subi.l #9691,d3
  32:	       asr.l #2,d3
	for (i = 0; i < count; i++)
  34:	/----- beq.s 48 <_start+0x48>
  36:	|      lea 25db <__bss_start>,a2
  3c:	|      moveq #0,d2
		__init_array_start[i]();
  3e:	|  /-> movea.l (a2)+,a0
  40:	|  |   jsr (a0)
	for (i = 0; i < count; i++)
  42:	|  |   addq.l #1,d2
  44:	|  |   cmp.l d3,d2
  46:	|  \-- bne.s 3e <_start+0x3e>

	main();
  48:	\----> jsr 74 <main>

	// call dtors
	count = __fini_array_end - __fini_array_start;
  4e:	       move.l #9691,d2
  54:	       subi.l #9691,d2
  5a:	       asr.l #2,d2
	for (i = count; i > 0; i--)
  5c:	/----- beq.s 6e <_start+0x6e>
  5e:	|      lea 25db <__bss_start>,a2
		__fini_array_start[i - 1]();
  64:	|  /-> subq.l #1,d2
  66:	|  |   movea.l -(a2),a0
  68:	|  |   jsr (a0)
	for (i = count; i > 0; i--)
  6a:	|  |   tst.l d2
  6c:	|  \-- bne.s 64 <_start+0x64>
}
  6e:	\----> movem.l (sp)+,d2-d3/a2
  72:	       rts

00000074 <main>:
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
int main()
{
  74:	                      lea -16(sp),sp
  78:	                      movem.l d2-d7/a2-a6,-(sp)

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
bool System_Init()
{
	sError = nullptr;
  7c:	                      clr.l 25e4 <_ZL6sError>

	#if !defined(LDOS)

	SysBase = *((struct ExecBase**) 4);
  82:	                      movea.l 4 <_start+0x4>,a6
  86:	                      move.l a6,25f2 <SysBase>

	sVBR = 0;
  8c:	                      clr.l 2612 <_ZL4sVBR>
	if (SysBase->AttnFlags & AFF_68010)
  92:	                      btst #0,297(a6)
  98:	                  /-- beq.s be <main+0x4a>
	{
		u16 getvbr[] = {0x4e7a, 0x0801, 0x4e73}; // movec.l vbr,d0 rte
  9a:	                  |   move.w #20090,54(sp)
  a0:	                  |   move.w #2049,56(sp)
  a6:	                  |   move.w #20083,58(sp)
		sVBR = (volatile void*) Supervisor((ULONG (*)()) getvbr);
  ac:	                  |   moveq #54,d7
  ae:	                  |   add.l sp,d7
  b0:	                  |   exg d7,a5
  b2:	                  |   jsr -30(a6)
  b6:	                  |   exg d7,a5
  b8:	                  |   move.l d0,2612 <_ZL4sVBR>
	}

	DOSBase = (struct DosLibrary*) OpenLibrary((CONST_STRPTR) "dos.library", 0);
  be:	                  \-> movea.l 25f2 <SysBase>,a6
  c4:	                      lea 59c <strlen+0x14>,a1
  ca:	                      moveq #0,d0
  cc:	                      jsr -552(a6)
  d0:	                      move.l d0,25e0 <DOSBase>
	if (DOSBase == nullptr)
  d6:	/-------------------- beq.w 512 <main+0x49e>
	{
		return false;
	}

	GfxBase = (struct GfxBase*) OpenLibrary((CONST_STRPTR) "graphics.library", 0);
  da:	|                     movea.l 25f2 <SysBase>,a6
  e0:	|                     lea 5a8 <strlen+0x20>,a1
  e6:	|                     moveq #0,d0
  e8:	|                     jsr -552(a6)
  ec:	|                     move.l d0,2602 <GfxBase>
	if (GfxBase == nullptr)
	{
		CloseLibrary((Library*) DOSBase);
  f2:	|                     movea.l 25f2 <SysBase>,a6
	if (GfxBase == nullptr)
  f8:	|  /----------------- beq.w 508 <main+0x494>

		return false;
	}

	IntuitionBase = (struct IntuitionBase*) OpenLibrary((CONST_STRPTR) "intuition.library", 0);
  fc:	|  |                  lea 5b9 <strlen+0x31>,a1
 102:	|  |                  moveq #0,d0
 104:	|  |                  jsr -552(a6)
 108:	|  |                  move.l d0,25e8 <IntuitionBase>
	if (IntuitionBase == nullptr)
	{
		CloseLibrary((Library*) GfxBase);
 10e:	|  |                  movea.l 25f2 <SysBase>,a6
	if (IntuitionBase == nullptr)
 114:	|  |  /-------------- beq.w 4f8 <main+0x484>
		CloseLibrary((Library*) DOSBase);

		return false;
	}

	MathBase = OpenLibrary("mathffp.library", 0);
 118:	|  |  |               lea 5cb <strlen+0x43>,a1
 11e:	|  |  |               moveq #0,d0
 120:	|  |  |               jsr -552(a6)
 124:	|  |  |               move.l d0,25dc <MathBase>
	if (MathBase == nullptr)
 12a:	|  |  |  /----------- beq.w 4e2 <main+0x46e>
		CloseLibrary((Library*) DOSBase);

		return false;
	}

	sSavedWorkbench = CloseWorkBench();
 12e:	|  |  |  |            movea.l 25e8 <IntuitionBase>,a6
 134:	|  |  |  |            jsr -78(a6)
 138:	|  |  |  |            tst.l d0
 13a:	|  |  |  |            sne d0
 13c:	|  |  |  |            neg.b d0
 13e:	|  |  |  |            move.b d0,25ec <_ZL15sSavedWorkbench>

	OwnBlitter();
 144:	|  |  |  |            movea.l 2602 <GfxBase>,a6
 14a:	|  |  |  |            jsr -456(a6)
	WaitBlit();
 14e:	|  |  |  |            movea.l 2602 <GfxBase>,a6
 154:	|  |  |  |            jsr -228(a6)

	Forbid();
 158:	|  |  |  |            movea.l 25f2 <SysBase>,a6
 15e:	|  |  |  |            jsr -132(a6)

	sSavedActiView = GfxBase->ActiView;
 162:	|  |  |  |            movea.l 2602 <GfxBase>,a6
 168:	|  |  |  |            move.l 34(a6),25ee <_ZL14sSavedActiView>

	LoadView(nullptr);
 170:	|  |  |  |            suba.l a1,a1
 172:	|  |  |  |            jsr -222(a6)
	WaitTOF();
 176:	|  |  |  |            movea.l 2602 <GfxBase>,a6
 17c:	|  |  |  |            jsr -270(a6)
	WaitTOF();
 180:	|  |  |  |            movea.l 2602 <GfxBase>,a6
 186:	|  |  |  |            jsr -270(a6)

	Disable();
 18a:	|  |  |  |            movea.l 25f2 <SysBase>,a6
 190:	|  |  |  |            jsr -120(a6)

	// Save current interrupt and DMA settings.
	sSavedADKCON = custom.adkconr;
 194:	|  |  |  |            move.w dff010 <gcc8_c_support.c.ba290747+0xdf86fd>,d4
 19a:	|  |  |  |            move.w d4,2600 <_ZL12sSavedADKCON>
	sSavedDMACON = custom.dmaconr;
 1a0:	|  |  |  |            move.w dff002 <gcc8_c_support.c.ba290747+0xdf86ef>,d3
 1a6:	|  |  |  |            move.w d3,25fe <_ZL12sSavedDMACON>
	sSavedINTENA = custom.intenar;
 1ac:	|  |  |  |            move.w dff01c <gcc8_c_support.c.ba290747+0xdf8709>,d2
 1b2:	|  |  |  |            move.w d2,25fc <_ZL12sSavedINTENA>

	// Disable all interrupts.
	custom.intena = (u16) ~INTF_SETCLR;
 1b8:	|  |  |  |            move.w #32767,dff09a <gcc8_c_support.c.ba290747+0xdf8787>

	// Clear all pending interrupts.
	custom.intreq = (u16) ~INTF_SETCLR;
 1c0:	|  |  |  |            move.w #32767,dff09c <gcc8_c_support.c.ba290747+0xdf8789>

	// Clear all DMA channels.
	custom.dmacon = (u16) ~DMAF_SETCLR;
 1c8:	|  |  |  |            move.w #32767,dff096 <gcc8_c_support.c.ba290747+0xdf8783>

	// Disable all CIA interrupts.
	ciaa.ciaicr = (u8) ~CIAICRF_SETCLR;
 1d0:	|  |  |  |            move.b #127,bfed01 <gcc8_c_support.c.ba290747+0xbf83ee>
	ciab.ciaicr = (u8) ~CIAICRF_SETCLR;
 1d8:	|  |  |  |            move.b #127,bfdd00 <gcc8_c_support.c.ba290747+0xbf73ed>

	// Save current CIA interrupts, which clears any pending.
	sSavedCIAAICR = ciaa.ciaicr;
 1e0:	|  |  |  |            move.b bfed01 <gcc8_c_support.c.ba290747+0xbf83ee>,d6
 1e6:	|  |  |  |            move.b d6,25f7 <_ZL13sSavedCIAAICR>
	sSavedCIABICR = ciab.ciaicr;
 1ec:	|  |  |  |            move.b bfdd00 <gcc8_c_support.c.ba290747+0xbf73ed>,d5
 1f2:	|  |  |  |            move.b d5,25f6 <_ZL13sSavedCIABICR>

	// Save current CIA controls.
	sSavedCIAACRA = ciaa.ciacra;
 1f8:	|  |  |  |            move.b bfee01 <gcc8_c_support.c.ba290747+0xbf84ee>,51(sp)
 200:	|  |  |  |            move.b 51(sp),25fb <_ZL13sSavedCIAACRA>
	sSavedCIAACRB = ciaa.ciacrb;
 208:	|  |  |  |            move.b bfef01 <gcc8_c_support.c.ba290747+0xbf85ee>,52(sp)
 210:	|  |  |  |            move.b 52(sp),25fa <_ZL13sSavedCIAACRB>
	sSavedCIABCRA = ciab.ciacra;
 218:	|  |  |  |            move.b bfde00 <gcc8_c_support.c.ba290747+0xbf74ed>,53(sp)
 220:	|  |  |  |            move.b 53(sp),25f9 <_ZL13sSavedCIABCRA>
	sSavedCIABCRB = ciab.ciacrb;
 228:	|  |  |  |            move.b bfdf00 <gcc8_c_support.c.ba290747+0xbf75ed>,d7
 22e:	|  |  |  |            move.b d7,25f8 <_ZL13sSavedCIABCRB>

	// Clear all CIA controls.
	ciaa.ciacra = 0;
 234:	|  |  |  |            move.b #0,bfee01 <gcc8_c_support.c.ba290747+0xbf84ee>
	ciaa.ciacrb = 0;
 23c:	|  |  |  |            move.b #0,bfef01 <gcc8_c_support.c.ba290747+0xbf85ee>
	ciab.ciacra = 0;
 244:	|  |  |  |            move.b #0,bfde00 <gcc8_c_support.c.ba290747+0xbf74ed>
	ciab.ciacrb = 0;
 24c:	|  |  |  |            move.b #0,bfdf00 <gcc8_c_support.c.ba290747+0xbf75ed>

	// Set all colors to black.
	for (int i = 0; i < countof(custom.color); i++)
 254:	|  |  |  |            moveq #0,d1
	{
		custom.color[i] = 0x000;
 256:	|  |  |  |            movea.l #14675968,a0
 25c:	|  |  |  |        /-> move.l d1,d0
 25e:	|  |  |  |        |   addi.l #192,d0
 264:	|  |  |  |        |   add.l d0,d0
 266:	|  |  |  |        |   move.w #0,(0,a0,d0.l)
	for (int i = 0; i < countof(custom.color); i++)
 26c:	|  |  |  |        |   addq.l #1,d1
 26e:	|  |  |  |        |   moveq #32,d0
 270:	|  |  |  |        |   cmp.l d1,d0
 272:	|  |  |  |        \-- bne.s 25c <main+0x1e8>

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void System_WaitVbl(u32 vend, u32 mask)
{
	while ((custom.vpos32 & mask) == vend) {}
 274:	|  |  |  |        /-> move.l dff004 <gcc8_c_support.c.ba290747+0xdf86f1>,d0
 27a:	|  |  |  |        |   andi.l #130816,d0
 280:	|  |  |  |        \-- beq.s 274 <main+0x200>
	while ((custom.vpos32 & mask) != vend) {}
 282:	|  |  |  |        /-> move.l dff004 <gcc8_c_support.c.ba290747+0xdf86f1>,d0
 288:	|  |  |  |        |   andi.l #130816,d0
 28e:	|  |  |  |        \-- bne.s 282 <main+0x20e>
	while ((custom.vpos32 & mask) == vend) {}
 290:	|  |  |  |        /-> move.l dff004 <gcc8_c_support.c.ba290747+0xdf86f1>,d0
 296:	|  |  |  |        |   andi.l #130816,d0
 29c:	|  |  |  |        \-- beq.s 290 <main+0x21c>
	while ((custom.vpos32 & mask) != vend) {}
 29e:	|  |  |  |        /-> move.l dff004 <gcc8_c_support.c.ba290747+0xdf86f1>,d0
 2a4:	|  |  |  |        |   andi.l #130816,d0
 2aa:	|  |  |  |        \-- bne.s 29e <main+0x22a>
	custom.vposw = 0x8000;
 2ac:	|  |  |  |            move.w #-32768,dff02a <gcc8_c_support.c.ba290747+0xdf8717>
	return *((System_IrqFunc**) (((u8*) sVBR) + 0x64));
 2b4:	|  |  |  |            movea.l 2612 <_ZL4sVBR>,a2
 2ba:	|  |  |  |            move.l 100(a2),46(sp)
	sSavedIrq1Handler = System_GetIrq1Handler();
 2c0:	|  |  |  |            move.l 46(sp),2616 <_ZL17sSavedIrq1Handler>
	return *((System_IrqFunc**) (((u8*) sVBR) + 0x68));
 2c8:	|  |  |  |            movea.l 104(a2),a6
	sSavedIrq2Handler = System_GetIrq2Handler();
 2cc:	|  |  |  |            move.l a6,260e <_ZL17sSavedIrq2Handler>
	return *((System_IrqFunc**) (((u8*) sVBR) + 0x6c));
 2d2:	|  |  |  |            movea.l 108(a2),a5
	sSavedIrq3Handler = System_GetIrq3Handler();
 2d6:	|  |  |  |            move.l a5,260a <_ZL17sSavedIrq3Handler>
	return *((System_IrqFunc**) (((u8*) sVBR) + 0x78));
 2dc:	|  |  |  |            movea.l 120(a2),a4
	sSavedIrq6Handler = System_GetIrq6Handler();
 2e0:	|  |  |  |            move.l a4,2606 <_ZL17sSavedIrq6Handler>
	while ((custom.vpos32 & mask) == vend) {}
 2e6:	|  |  |  |        /-> move.l dff004 <gcc8_c_support.c.ba290747+0xdf86f1>,d0
 2ec:	|  |  |  |        |   andi.l #130816,d0
 2f2:	|  |  |  |        \-- beq.s 2e6 <main+0x272>
	while ((custom.vpos32 & mask) != vend) {}
 2f4:	|  |  |  |        /-> move.l dff004 <gcc8_c_support.c.ba290747+0xdf86f1>,d0
 2fa:	|  |  |  |        |   andi.l #130816,d0
 300:	|  |  |  |        \-- bne.s 2f4 <main+0x280>
	System_WaitVbl();
 302:	|  |  |  |            lea 56a <_Z14System_WaitVbljj.constprop.0>,a3
 308:	|  |  |  |            jsr (a3)
	*((System_IrqFunc**) (((u8*) sVBR) + 0x78)) = func;
 30a:	|  |  |  |            move.l #1324,120(a2)
	ciab.ciacra = CIACRAF_RUNMODE;
 312:	|  |  |  |            move.b #8,bfde00 <gcc8_c_support.c.ba290747+0xbf74ed>
	ciab.ciaicr = CIAICRF_SETCLR | CIAICRF_TA;
 31a:	|  |  |  |            move.b #-127,bfdd00 <gcc8_c_support.c.ba290747+0xbf73ed>
	ciab.ciatalo = 7000 & 255;
 322:	|  |  |  |            move.b #88,bfd400 <gcc8_c_support.c.ba290747+0xbf6aed>
	System_WaitVbl();
 32a:	|  |  |  |            jsr (a3)
	custom.intena = INTF_SETCLR | INTF_INTEN | INTF_EXTER;
 32c:	|  |  |  |            move.w #-8192,dff09a <gcc8_c_support.c.ba290747+0xdf8787>

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
bool System_TestLMB()
{
	return !(ciaa.ciapra & CIAF_GAMEPORT0);
 334:	|  |  |  |            move.b bfe001 <gcc8_c_support.c.ba290747+0xbf76ee>,d0
	if (System_Init())
	{
		if (Init())
		{
			while (!System_TestLMB())
 33a:	|  |  |  |            btst #6,d0
 33e:	|  |  |  |     /----- beq.s 356 <main+0x2e2>
	System_WaitVbl();
 340:	|  |  |  |     |  /-> jsr (a3)
	ciab.ciatahi = 7000 >> 8;
 342:	|  |  |  |     |  |   move.b #27,bfd500 <gcc8_c_support.c.ba290747+0xbf6bed>
 34a:	|  |  |  |     |  |   move.b bfe001 <gcc8_c_support.c.ba290747+0xbf76ee>,d0
			while (!System_TestLMB())
 350:	|  |  |  |     |  |   btst #6,d0
 354:	|  |  |  |     |  \-- bne.s 340 <main+0x2cc>
	custom.intena = INTF_EXTER | INTF_VERTB;
 356:	|  |  |  |     \----> move.w #8224,dff09a <gcc8_c_support.c.ba290747+0xdf8787>
	System_WaitVbl();
 35e:	|  |  |  |            jsr (a3)
	*((System_IrqFunc**) (((u8*) sVBR) + 0x78)) = func;
 360:	|  |  |  |            clr.l 120(a2)
	while ((custom.vpos32 & mask) == vend) {}
 364:	|  |  |  |        /-> move.l dff004 <gcc8_c_support.c.ba290747+0xdf86f1>,d0
 36a:	|  |  |  |        |   andi.l #130816,d0
 370:	|  |  |  |        \-- beq.s 364 <main+0x2f0>
	while ((custom.vpos32 & mask) != vend) {}
 372:	|  |  |  |        /-> move.l dff004 <gcc8_c_support.c.ba290747+0xdf86f1>,d0
 378:	|  |  |  |        |   andi.l #130816,d0
 37e:	|  |  |  |        \-- bne.s 372 <main+0x2fe>
	u16 test = custom.dmaconr; // For compatiblity with A1000.
 380:	|  |  |  |            move.w dff002 <gcc8_c_support.c.ba290747+0xdf86ef>,d0
	while (custom.dmaconr & DMAF_BLTDONE) {}
 386:	|  |  |  |        /-> move.w dff002 <gcc8_c_support.c.ba290747+0xdf86ef>,d0
 38c:	|  |  |  |        |   btst #14,d0
 390:	|  |  |  |        \-- bne.s 386 <main+0x312>
	ciaa.ciaicr = (u8) ~CIAICRF_SETCLR;
 392:	|  |  |  |            move.b #127,bfed01 <gcc8_c_support.c.ba290747+0xbf83ee>
	ciab.ciaicr = (u8) ~CIAICRF_SETCLR;
 39a:	|  |  |  |            move.b #127,bfdd00 <gcc8_c_support.c.ba290747+0xbf73ed>
	pending = ciaa.ciaicr;
 3a2:	|  |  |  |            move.b bfed01 <gcc8_c_support.c.ba290747+0xbf83ee>,d0
	pending = ciab.ciaicr;
 3a8:	|  |  |  |            move.b bfdd00 <gcc8_c_support.c.ba290747+0xbf73ed>,d0
	custom.intena = (u16) ~INTF_SETCLR;
 3ae:	|  |  |  |            move.w #32767,dff09a <gcc8_c_support.c.ba290747+0xdf8787>
	custom.intreq = (u16) ~INTF_SETCLR;
 3b6:	|  |  |  |            move.w #32767,dff09c <gcc8_c_support.c.ba290747+0xdf8789>
	custom.dmacon = (u16) ~DMAF_SETCLR;
 3be:	|  |  |  |            move.w #32767,dff096 <gcc8_c_support.c.ba290747+0xdf8783>
	*((System_IrqFunc**) (((u8*) sVBR) + 0x64)) = func;
 3c6:	|  |  |  |            move.l 46(sp),100(a2)
	*((System_IrqFunc**) (((u8*) sVBR) + 0x68)) = func;
 3cc:	|  |  |  |            move.l a6,104(a2)
	*((System_IrqFunc**) (((u8*) sVBR) + 0x6c)) = func;
 3d0:	|  |  |  |            move.l a5,108(a2)
	*((System_IrqFunc**) (((u8*) sVBR) + 0x78)) = func;
 3d4:	|  |  |  |            move.l a4,120(a2)
	custom.cop1lc = (u32) GfxBase->copinit;
 3d8:	|  |  |  |            movea.l 2602 <GfxBase>,a0
 3de:	|  |  |  |            move.l 38(a0),dff080 <gcc8_c_support.c.ba290747+0xdf876d>
	custom.cop2lc = (u32) GfxBase->LOFlist;
 3e6:	|  |  |  |            move.l 50(a0),d0
 3ea:	|  |  |  |            move.l d0,dff084 <gcc8_c_support.c.ba290747+0xdf8771>
	custom.copjmp1 = 0;
 3f0:	|  |  |  |            move.w #0,dff088 <gcc8_c_support.c.ba290747+0xdf8775>
	custom.adkcon = ADKF_SETCLR | sSavedADKCON;
 3f8:	|  |  |  |            ori.w #-32768,d4
 3fc:	|  |  |  |            move.w d4,dff09e <gcc8_c_support.c.ba290747+0xdf878b>
	custom.dmacon = DMAF_SETCLR | sSavedDMACON;
 402:	|  |  |  |            ori.w #-32768,d3
 406:	|  |  |  |            move.w d3,dff096 <gcc8_c_support.c.ba290747+0xdf8783>
	custom.intena = INTF_SETCLR | sSavedINTENA;
 40c:	|  |  |  |            ori.w #-32768,d2
 410:	|  |  |  |            move.w d2,dff09a <gcc8_c_support.c.ba290747+0xdf8787>
	ciaa.ciacra = sSavedCIAACRA;
 416:	|  |  |  |            move.b 51(sp),bfee01 <gcc8_c_support.c.ba290747+0xbf84ee>
	ciaa.ciacrb = sSavedCIAACRB;
 41e:	|  |  |  |            move.b 52(sp),bfef01 <gcc8_c_support.c.ba290747+0xbf85ee>
	ciab.ciacra = sSavedCIABCRA;
 426:	|  |  |  |            move.b 53(sp),bfde00 <gcc8_c_support.c.ba290747+0xbf74ed>
	ciab.ciacrb = sSavedCIABCRB;
 42e:	|  |  |  |            move.b d7,bfdf00 <gcc8_c_support.c.ba290747+0xbf75ed>
	ciaa.ciaicr = sSavedCIAAICR;
 434:	|  |  |  |            move.b d6,bfed01 <gcc8_c_support.c.ba290747+0xbf83ee>
	ciab.ciaicr = sSavedCIABICR;
 43a:	|  |  |  |            move.b d5,bfdd00 <gcc8_c_support.c.ba290747+0xbf73ed>
	ciaa.ciaicr = CIAICRF_SETCLR | CIAICRF_SP;
 440:	|  |  |  |            move.b #-120,bfed01 <gcc8_c_support.c.ba290747+0xbf83ee>
	Enable();
 448:	|  |  |  |            movea.l 25f2 <SysBase>,a6
 44e:	|  |  |  |            jsr -126(a6)
	LoadView(sSavedActiView);
 452:	|  |  |  |            movea.l 2602 <GfxBase>,a6
 458:	|  |  |  |            movea.l 25ee <_ZL14sSavedActiView>,a1
 45e:	|  |  |  |            jsr -222(a6)
	WaitTOF();
 462:	|  |  |  |            movea.l 2602 <GfxBase>,a6
 468:	|  |  |  |            jsr -270(a6)
	WaitTOF();
 46c:	|  |  |  |            movea.l 2602 <GfxBase>,a6
 472:	|  |  |  |            jsr -270(a6)
	Permit();
 476:	|  |  |  |            movea.l 25f2 <SysBase>,a6
 47c:	|  |  |  |            jsr -138(a6)
	WaitBlit();
 480:	|  |  |  |            movea.l 2602 <GfxBase>,a6
 486:	|  |  |  |            jsr -228(a6)
	DisownBlitter();
 48a:	|  |  |  |            movea.l 2602 <GfxBase>,a6
 490:	|  |  |  |            jsr -462(a6)
	if (sSavedWorkbench)
 494:	|  |  |  |            tst.b 25ec <_ZL15sSavedWorkbench>
 49a:	|  |  |  |     /----- bne.w 51e <main+0x4aa>
	if (sError != nullptr)
 49e:	|  |  |  |  /--|----> tst.l 25e4 <_ZL6sError>
 4a4:	|  |  |  |  |  |  /-- beq.s 4d2 <main+0x45e>
		Write(Output(), (APTR) sError, strlen(sError) + 1);
 4a6:	|  |  |  |  |  |  |   movea.l 25e0 <DOSBase>,a6
 4ac:	|  |  |  |  |  |  |   jsr -60(a6)
 4b0:	|  |  |  |  |  |  |   move.l d0,d4
 4b2:	|  |  |  |  |  |  |   move.l 25e4 <_ZL6sError>,d2
 4b8:	|  |  |  |  |  |  |   move.l d2,-(sp)
 4ba:	|  |  |  |  |  |  |   jsr 588 <strlen>
 4c0:	|  |  |  |  |  |  |   addq.l #4,sp
 4c2:	|  |  |  |  |  |  |   movea.l 25e0 <DOSBase>,a6
 4c8:	|  |  |  |  |  |  |   move.l d4,d1
 4ca:	|  |  |  |  |  |  |   move.l d0,d3
 4cc:	|  |  |  |  |  |  |   addq.l #1,d3
 4ce:	|  |  |  |  |  |  |   jsr -48(a6)
	CloseLibrary((Library*) MathBase);
 4d2:	|  |  |  |  |  |  \-> movea.l 25f2 <SysBase>,a6
 4d8:	|  |  |  |  |  |      movea.l 25dc <MathBase>,a1
 4de:	|  |  |  |  |  |      jsr -414(a6)
	CloseLibrary((Library*) IntuitionBase);
 4e2:	|  |  |  \--|--|----> movea.l 25f2 <SysBase>,a6
 4e8:	|  |  |     |  |      movea.l 25e8 <IntuitionBase>,a1
 4ee:	|  |  |     |  |      jsr -414(a6)
	CloseLibrary((Library*) GfxBase);
 4f2:	|  |  |     |  |      movea.l 25f2 <SysBase>,a6
 4f8:	|  |  \-----|--|----> movea.l 2602 <GfxBase>,a1
 4fe:	|  |        |  |      jsr -414(a6)
	CloseLibrary((Library*) DOSBase);
 502:	|  |        |  |      movea.l 25f2 <SysBase>,a6
 508:	|  \--------|--|----> movea.l 25e0 <DOSBase>,a1
 50e:	|           |  |      jsr -414(a6)
			Deinit();
		}

		System_Deinit();
	}
}
 512:	\-----------|--|----> moveq #0,d0
 514:	            |  |      movem.l (sp)+,d2-d7/a2-a6
 518:	            |  |      lea 16(sp),sp
 51c:	            |  |      rts
		OpenWorkBench();
 51e:	            |  \----> movea.l 25e8 <IntuitionBase>,a6
 524:	            |         jsr -210(a6)
 528:	            \-------- bra.w 49e <main+0x42a>

0000052c <_ZL11Irq6Handlerv>:
{
 52c:	    move.l d0,-(sp)
	custom.intreq = INTF_EXTER;
 52e:	    move.w #8192,dff09c <gcc8_c_support.c.ba290747+0xdf8789>
	u8 pending = ciab.ciaicr;
 536:	    move.b bfdd00 <gcc8_c_support.c.ba290747+0xbf73ed>,d0
	if (pending & CIAICRF_TA)
 53c:	    btst #0,d0
 540:	/-- beq.s 556 <_ZL11Irq6Handlerv+0x2a>
		custom.color[0] = 0x0f0;
 542:	|   move.w #240,dff180 <gcc8_c_support.c.ba290747+0xdf886d>
		custom.color[0] = 0x000;
 54a:	|   move.w #0,dff180 <gcc8_c_support.c.ba290747+0xdf886d>
}
 552:	|   move.l (sp)+,d0
 554:	|   rte
		custom.color[0] = 0xf00;
 556:	\-> move.w #3840,dff180 <gcc8_c_support.c.ba290747+0xdf886d>
		custom.color[0] = 0x000;
 55e:	    move.w #0,dff180 <gcc8_c_support.c.ba290747+0xdf886d>
}
 566:	    move.l (sp)+,d0
 568:	    rte

0000056a <_Z14System_WaitVbljj.constprop.0>:
	while ((custom.vpos32 & mask) == vend) {}
 56a:	/-> move.l dff004 <gcc8_c_support.c.ba290747+0xdf86f1>,d0
 570:	|   andi.l #130816,d0
 576:	\-- beq.s 56a <_Z14System_WaitVbljj.constprop.0>
	while ((custom.vpos32 & mask) != vend) {}
 578:	/-> move.l dff004 <gcc8_c_support.c.ba290747+0xdf86f1>,d0
 57e:	|   andi.l #130816,d0
 584:	\-- bne.s 578 <_Z14System_WaitVbljj.constprop.0+0xe>
}
 586:	    rts

00000588 <strlen>:
unsigned long strlen(const char* s) {
 588:	       movea.l 4(sp),a0
	unsigned long t=0;
 58c:	       moveq #0,d0
	while(*s++)
 58e:	       tst.b (a0)
 590:	/----- beq.s 59a <strlen+0x12>
		t++;
 592:	|  /-> addq.l #1,d0
	while(*s++)
 594:	|  |   tst.b (0,a0,d0.l)
 598:	|  \-- bne.s 592 <strlen+0xa>
}
 59a:	\----> rts
