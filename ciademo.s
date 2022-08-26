
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
   4:	       move.l #10023,d3
   a:	       subi.l #10023,d3
  10:	       asr.l #2,d3
	for (i = 0; i < count; i++)
  12:	       move.l #10023,d0
  18:	       cmpi.l #10023,d0
  1e:	/----- beq.s 32 <_start+0x32>
  20:	|      lea 2727 <__bss_start>,a2
  26:	|      moveq #0,d2
		__preinit_array_start[i]();
  28:	|  /-> movea.l (a2)+,a0
  2a:	|  |   jsr (a0)
	for (i = 0; i < count; i++)
  2c:	|  |   addq.l #1,d2
  2e:	|  |   cmp.l d3,d2
  30:	|  \-- bcs.s 28 <_start+0x28>

	count = __init_array_end - __init_array_start;
  32:	\----> move.l #10023,d3
  38:	       subi.l #10023,d3
  3e:	       asr.l #2,d3
	for (i = 0; i < count; i++)
  40:	       move.l #10023,d0
  46:	       cmpi.l #10023,d0
  4c:	/----- beq.s 60 <_start+0x60>
  4e:	|      lea 2727 <__bss_start>,a2
  54:	|      moveq #0,d2
		__init_array_start[i]();
  56:	|  /-> movea.l (a2)+,a0
  58:	|  |   jsr (a0)
	for (i = 0; i < count; i++)
  5a:	|  |   addq.l #1,d2
  5c:	|  |   cmp.l d3,d2
  5e:	|  \-- bcs.s 56 <_start+0x56>

	main();
  60:	\----> jsr 8c <main>

	// call dtors
	count = __fini_array_end - __fini_array_start;
  66:	       move.l #10023,d2
  6c:	       subi.l #10023,d2
  72:	       asr.l #2,d2
	for (i = count; i > 0; i--)
  74:	/----- beq.s 86 <_start+0x86>
  76:	|      lea 2727 <__bss_start>,a2
		__fini_array_start[i - 1]();
  7c:	|  /-> subq.l #1,d2
  7e:	|  |   movea.l -(a2),a0
  80:	|  |   jsr (a0)
	for (i = count; i > 0; i--)
  82:	|  |   tst.l d2
  84:	|  \-- bne.s 7c <_start+0x7c>
}
  86:	\----> movem.l (sp)+,d2-d3/a2
  8a:	       rts

0000008c <main>:
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
int main()
{
  8c:	                      lea -16(sp),sp
  90:	                      movem.l d2-d7/a2-a6,-(sp)

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
bool System_Init()
{
	sError = nullptr;
  94:	                      clr.l 2730 <_ZL6sError>

	#if !defined(LDOS)

	#pragma GCC diagnostic push
	#pragma GCC diagnostic ignored "-Warray-bounds"
	SysBase = *((struct ExecBase**) 4);
  9a:	                      movea.l 4 <_start+0x4>,a6
  9e:	                      move.l a6,273e <SysBase>
	#pragma GCC diagnostic pop

	sVBR = 0;
  a4:	                      clr.l 275e <_ZL4sVBR>
	if (SysBase->AttnFlags & AFF_68010)
  aa:	                      btst #0,297(a6)
  b0:	                  /-- beq.s d6 <main+0x4a>
	{
		u16 getvbr[] = {0x4e7a, 0x0801, 0x4e73}; // movec.l vbr,d0 rte
  b2:	                  |   move.w #20090,54(sp)
  b8:	                  |   move.w #2049,56(sp)
  be:	                  |   move.w #20083,58(sp)
		sVBR = (volatile void*) Supervisor((ULONG (*)()) getvbr);
  c4:	                  |   moveq #54,d7
  c6:	                  |   add.l sp,d7
  c8:	                  |   exg d7,a5
  ca:	                  |   jsr -30(a6)
  ce:	                  |   exg d7,a5
  d0:	                  |   move.l d0,275e <_ZL4sVBR>
	}

	DOSBase = (struct DosLibrary*) OpenLibrary((CONST_STRPTR) "dos.library", 0);
  d6:	                  \-> movea.l 273e <SysBase>,a6
  dc:	                      lea 6e8 <strlen+0x18>,a1
  e2:	                      moveq #0,d0
  e4:	                      jsr -552(a6)
  e8:	                      move.l d0,272c <DOSBase>
	if (DOSBase == nullptr)
  ee:	/-------------------- beq.w 5fc <main+0x570>
	{
		return false;
	}

	GfxBase = (struct GfxBase*) OpenLibrary((CONST_STRPTR) "graphics.library", 0);
  f2:	|                     movea.l 273e <SysBase>,a6
  f8:	|                     lea 6f4 <strlen+0x24>,a1
  fe:	|                     moveq #0,d0
 100:	|                     jsr -552(a6)
 104:	|                     move.l d0,274e <GfxBase>
	if (GfxBase == nullptr)
	{
		CloseLibrary((Library*) DOSBase);
 10a:	|                     movea.l 273e <SysBase>,a6
	if (GfxBase == nullptr)
 110:	|  /----------------- beq.w 5f2 <main+0x566>

		return false;
	}

	IntuitionBase = (struct IntuitionBase*) OpenLibrary((CONST_STRPTR) "intuition.library", 0);
 114:	|  |                  lea 705 <strlen+0x35>,a1
 11a:	|  |                  moveq #0,d0
 11c:	|  |                  jsr -552(a6)
 120:	|  |                  move.l d0,2734 <IntuitionBase>
	if (IntuitionBase == nullptr)
	{
		CloseLibrary((Library*) GfxBase);
 126:	|  |                  movea.l 273e <SysBase>,a6
	if (IntuitionBase == nullptr)
 12c:	|  |  /-------------- beq.w 5e2 <main+0x556>
		CloseLibrary((Library*) DOSBase);

		return false;
	}

	MathBase = OpenLibrary("mathffp.library", 0);
 130:	|  |  |               lea 717 <strlen+0x47>,a1
 136:	|  |  |               moveq #0,d0
 138:	|  |  |               jsr -552(a6)
 13c:	|  |  |               move.l d0,2728 <MathBase>
	if (MathBase == nullptr)
 142:	|  |  |  /----------- beq.w 5cc <main+0x540>
		CloseLibrary((Library*) DOSBase);

		return false;
	}

	sSavedWorkbench = CloseWorkBench();
 146:	|  |  |  |            movea.l 2734 <IntuitionBase>,a6
 14c:	|  |  |  |            jsr -78(a6)
 150:	|  |  |  |            tst.l d0
 152:	|  |  |  |            sne d0
 154:	|  |  |  |            neg.b d0
 156:	|  |  |  |            move.b d0,2738 <_ZL15sSavedWorkbench>

	OwnBlitter();
 15c:	|  |  |  |            movea.l 274e <GfxBase>,a6
 162:	|  |  |  |            jsr -456(a6)
	WaitBlit();
 166:	|  |  |  |            movea.l 274e <GfxBase>,a6
 16c:	|  |  |  |            jsr -228(a6)

	Forbid();
 170:	|  |  |  |            movea.l 273e <SysBase>,a6
 176:	|  |  |  |            jsr -132(a6)

	sSavedActiView = GfxBase->ActiView;
 17a:	|  |  |  |            movea.l 274e <GfxBase>,a6
 180:	|  |  |  |            move.l 34(a6),273a <_ZL14sSavedActiView>

	LoadView(nullptr);
 188:	|  |  |  |            suba.l a1,a1
 18a:	|  |  |  |            jsr -222(a6)
	WaitTOF();
 18e:	|  |  |  |            movea.l 274e <GfxBase>,a6
 194:	|  |  |  |            jsr -270(a6)
	WaitTOF();
 198:	|  |  |  |            movea.l 274e <GfxBase>,a6
 19e:	|  |  |  |            jsr -270(a6)

	Disable();
 1a2:	|  |  |  |            movea.l 273e <SysBase>,a6
 1a8:	|  |  |  |            jsr -120(a6)

	// Save current interrupt and DMA settings.
	sSavedADKCON = custom.adkconr;
 1ac:	|  |  |  |            move.w dff010 <gcc8_c_support.c.50501803+0xdf864d>,d4
 1b2:	|  |  |  |            move.w d4,274c <_ZL12sSavedADKCON>
	sSavedDMACON = custom.dmaconr;
 1b8:	|  |  |  |            move.w dff002 <gcc8_c_support.c.50501803+0xdf863f>,d3
 1be:	|  |  |  |            move.w d3,274a <_ZL12sSavedDMACON>
	sSavedINTENA = custom.intenar;
 1c4:	|  |  |  |            move.w dff01c <gcc8_c_support.c.50501803+0xdf8659>,d2
 1ca:	|  |  |  |            move.w d2,2748 <_ZL12sSavedINTENA>

	// Disable all interrupts.
	custom.intena = (u16) ~INTF_SETCLR;
 1d0:	|  |  |  |            move.w #32767,dff09a <gcc8_c_support.c.50501803+0xdf86d7>

	// Clear all pending interrupts.
	custom.intreq = (u16) ~INTF_SETCLR;
 1d8:	|  |  |  |            move.w #32767,dff09c <gcc8_c_support.c.50501803+0xdf86d9>

	// Clear all DMA channels.
	custom.dmacon = (u16) ~DMAF_SETCLR;
 1e0:	|  |  |  |            move.w #32767,dff096 <gcc8_c_support.c.50501803+0xdf86d3>

	// Disable all CIA interrupts.
	ciaa.ciaicr = (u8) ~CIAICRF_SETCLR;
 1e8:	|  |  |  |            move.b #127,bfed01 <gcc8_c_support.c.50501803+0xbf833e>
	ciab.ciaicr = (u8) ~CIAICRF_SETCLR;
 1f0:	|  |  |  |            move.b #127,bfdd00 <gcc8_c_support.c.50501803+0xbf733d>

	// Save current CIA interrupts, which clears any pending.
	sSavedCIAAICR = ciaa.ciaicr;
 1f8:	|  |  |  |            move.b bfed01 <gcc8_c_support.c.50501803+0xbf833e>,d6
 1fe:	|  |  |  |            move.b d6,2743 <_ZL13sSavedCIAAICR>
	sSavedCIABICR = ciab.ciaicr;
 204:	|  |  |  |            move.b bfdd00 <gcc8_c_support.c.50501803+0xbf733d>,d5
 20a:	|  |  |  |            move.b d5,2742 <_ZL13sSavedCIABICR>

	// Save current CIA controls.
	sSavedCIAACRA = ciaa.ciacra;
 210:	|  |  |  |            move.b bfee01 <gcc8_c_support.c.50501803+0xbf843e>,51(sp)
 218:	|  |  |  |            move.b 51(sp),2747 <_ZL13sSavedCIAACRA>
	sSavedCIAACRB = ciaa.ciacrb;
 220:	|  |  |  |            move.b bfef01 <gcc8_c_support.c.50501803+0xbf853e>,52(sp)
 228:	|  |  |  |            move.b 52(sp),2746 <_ZL13sSavedCIAACRB>
	sSavedCIABCRA = ciab.ciacra;
 230:	|  |  |  |            move.b bfde00 <gcc8_c_support.c.50501803+0xbf743d>,53(sp)
 238:	|  |  |  |            move.b 53(sp),2745 <_ZL13sSavedCIABCRA>
	sSavedCIABCRB = ciab.ciacrb;
 240:	|  |  |  |            move.b bfdf00 <gcc8_c_support.c.50501803+0xbf753d>,d7
 246:	|  |  |  |            move.b d7,2744 <_ZL13sSavedCIABCRB>

	// Clear CIA Alarm count.
	ciab.ciacrb = CIACRBF_ALARM;
 24c:	|  |  |  |            move.b #-128,bfdf00 <gcc8_c_support.c.50501803+0xbf753d>
	ciab.ciatodhi = 0;
 254:	|  |  |  |            move.b #0,bfda00 <gcc8_c_support.c.50501803+0xbf703d>
	ciab.ciatodmid = 0;
 25c:	|  |  |  |            move.b #0,bfd900 <gcc8_c_support.c.50501803+0xbf6f3d>
	ciab.ciatodlow = 0;
 264:	|  |  |  |            move.b #0,bfd800 <gcc8_c_support.c.50501803+0xbf6e3d>

	// Clear all CIA controls.
	ciaa.ciacra = 0;
 26c:	|  |  |  |            move.b #0,bfee01 <gcc8_c_support.c.50501803+0xbf843e>
	ciaa.ciacrb = 0;
 274:	|  |  |  |            move.b #0,bfef01 <gcc8_c_support.c.50501803+0xbf853e>
	ciab.ciacra = 0;
 27c:	|  |  |  |            move.b #0,bfde00 <gcc8_c_support.c.50501803+0xbf743d>
	ciab.ciacrb = 0;
 284:	|  |  |  |            move.b #0,bfdf00 <gcc8_c_support.c.50501803+0xbf753d>

	// Clear CIA TOD count.
	ciab.ciatodhi = 0;
 28c:	|  |  |  |            move.b #0,bfda00 <gcc8_c_support.c.50501803+0xbf703d>
	ciab.ciatodmid = 0;
 294:	|  |  |  |            move.b #0,bfd900 <gcc8_c_support.c.50501803+0xbf6f3d>
	ciab.ciatodlow = 0;
 29c:	|  |  |  |            move.b #0,bfd800 <gcc8_c_support.c.50501803+0xbf6e3d>

	// Pause CIA TOD count.
	ciab.ciatodhi = 0;
 2a4:	|  |  |  |            move.b #0,bfda00 <gcc8_c_support.c.50501803+0xbf703d>

	// Set all colors to black.
	for (int i = 0; i < countof(custom.color); i++)
 2ac:	|  |  |  |            moveq #0,d1
	{
		custom.color[i] = 0x000;
 2ae:	|  |  |  |            movea.l #14675968,a0
 2b4:	|  |  |  |        /-> move.l d1,d0
 2b6:	|  |  |  |        |   addi.l #192,d0
 2bc:	|  |  |  |        |   add.l d0,d0
 2be:	|  |  |  |        |   move.w #0,(0,a0,d0.l)
	for (int i = 0; i < countof(custom.color); i++)
 2c4:	|  |  |  |        |   addq.l #1,d1
 2c6:	|  |  |  |        |   moveq #32,d0
 2c8:	|  |  |  |        |   cmp.l d1,d0
 2ca:	|  |  |  |        \-- bne.s 2b4 <main+0x228>

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void System_WaitVbl(u32 vend, u32 mask)
{
	while ((custom.vpos32 & mask) == vend) {}
 2cc:	|  |  |  |        /-> move.l dff004 <gcc8_c_support.c.50501803+0xdf8641>,d0
 2d2:	|  |  |  |        |   andi.l #130816,d0
 2d8:	|  |  |  |        \-- beq.s 2cc <main+0x240>
	while ((custom.vpos32 & mask) != vend) {}
 2da:	|  |  |  |        /-> move.l dff004 <gcc8_c_support.c.50501803+0xdf8641>,d0
 2e0:	|  |  |  |        |   andi.l #130816,d0
 2e6:	|  |  |  |        \-- bne.s 2da <main+0x24e>
	while ((custom.vpos32 & mask) == vend) {}
 2e8:	|  |  |  |        /-> move.l dff004 <gcc8_c_support.c.50501803+0xdf8641>,d0
 2ee:	|  |  |  |        |   andi.l #130816,d0
 2f4:	|  |  |  |        \-- beq.s 2e8 <main+0x25c>
	while ((custom.vpos32 & mask) != vend) {}
 2f6:	|  |  |  |        /-> move.l dff004 <gcc8_c_support.c.50501803+0xdf8641>,d0
 2fc:	|  |  |  |        |   andi.l #130816,d0
 302:	|  |  |  |        \-- bne.s 2f6 <main+0x26a>
	custom.vposw = 0x8000;
 304:	|  |  |  |            move.w #-32768,dff02a <gcc8_c_support.c.50501803+0xdf8667>
	return *((System_IrqFunc**) (((u8*) sVBR) + 0x64));
 30c:	|  |  |  |            movea.l 275e <_ZL4sVBR>,a3
 312:	|  |  |  |            movea.l 100(a3),a6
	sSavedIrq1Handler = System_GetIrq1Handler();
 316:	|  |  |  |            move.l a6,2762 <_ZL17sSavedIrq1Handler>
	return *((System_IrqFunc**) (((u8*) sVBR) + 0x68));
 31c:	|  |  |  |            move.l 104(a3),46(sp)
	sSavedIrq2Handler = System_GetIrq2Handler();
 322:	|  |  |  |            move.l 46(sp),275a <_ZL17sSavedIrq2Handler>
	return *((System_IrqFunc**) (((u8*) sVBR) + 0x6c));
 32a:	|  |  |  |            movea.l 108(a3),a5
	sSavedIrq3Handler = System_GetIrq3Handler();
 32e:	|  |  |  |            move.l a5,2756 <_ZL17sSavedIrq3Handler>
	return *((System_IrqFunc**) (((u8*) sVBR) + 0x78));
 334:	|  |  |  |            movea.l 120(a3),a4
	sSavedIrq6Handler = System_GetIrq6Handler();
 338:	|  |  |  |            move.l a4,2752 <_ZL17sSavedIrq6Handler>
	while ((custom.vpos32 & mask) == vend) {}
 33e:	|  |  |  |        /-> move.l dff004 <gcc8_c_support.c.50501803+0xdf8641>,d0
 344:	|  |  |  |        |   andi.l #130816,d0
 34a:	|  |  |  |        \-- beq.s 33e <main+0x2b2>
	while ((custom.vpos32 & mask) != vend) {}
 34c:	|  |  |  |        /-> move.l dff004 <gcc8_c_support.c.50501803+0xdf8641>,d0
 352:	|  |  |  |        |   andi.l #130816,d0
 358:	|  |  |  |        \-- bne.s 34c <main+0x2c0>
	System_WaitVbl();
 35a:	|  |  |  |            lea 6b2 <_Z14System_WaitVbljj.constprop.0>,a2
 360:	|  |  |  |            jsr (a2)
	*((System_IrqFunc**) (((u8*) sVBR) + 0x78)) = func;
 362:	|  |  |  |            move.l #1558,120(a3)
	ciab.ciacra = CIACRAF_RUNMODE;
 36a:	|  |  |  |            move.b #8,bfde00 <gcc8_c_support.c.50501803+0xbf743d>
	ciab.ciaicr = CIAICRF_SETCLR | CIAICRF_TA;
 372:	|  |  |  |            move.b #-127,bfdd00 <gcc8_c_support.c.50501803+0xbf733d>
	ciab.ciatalo = kATimerCount & 255;
 37a:	|  |  |  |            move.b #-72,bfd400 <gcc8_c_support.c.50501803+0xbf6a3d>
	ciab.ciacrb = CIACRAF_RUNMODE;
 382:	|  |  |  |            move.b #8,bfdf00 <gcc8_c_support.c.50501803+0xbf753d>
	ciab.ciaicr = CIAICRF_SETCLR | CIAICRF_TB;
 38a:	|  |  |  |            move.b #-126,bfdd00 <gcc8_c_support.c.50501803+0xbf733d>
	ciab.ciatblo = kBTimerCount & 255;
 392:	|  |  |  |            move.b #-84,bfd600 <gcc8_c_support.c.50501803+0xbf6c3d>
	ciab.ciaicr = CIAICRF_SETCLR | CIAICRF_ALRM;
 39a:	|  |  |  |            move.b #-124,bfdd00 <gcc8_c_support.c.50501803+0xbf733d>
	ciab.ciacrb |= CIACRBF_ALARM;
 3a2:	|  |  |  |            move.b bfdf00 <gcc8_c_support.c.50501803+0xbf753d>,d0
 3a8:	|  |  |  |            ori.b #-128,d0
 3ac:	|  |  |  |            move.b d0,bfdf00 <gcc8_c_support.c.50501803+0xbf753d>
	ciab.ciatodhi  = kAlarmCount >> 16;
 3b2:	|  |  |  |            move.b #0,bfda00 <gcc8_c_support.c.50501803+0xbf703d>
	ciab.ciatodmid = kAlarmCount >> 8;
 3ba:	|  |  |  |            move.b #0,bfd900 <gcc8_c_support.c.50501803+0xbf6f3d>
	ciab.ciatodlow = kAlarmCount;
 3c2:	|  |  |  |            move.b #90,bfd800 <gcc8_c_support.c.50501803+0xbf6e3d>
	ciab.ciacrb &= ~CIACRBF_ALARM;
 3ca:	|  |  |  |            move.b bfdf00 <gcc8_c_support.c.50501803+0xbf753d>,d0
 3d0:	|  |  |  |            andi.b #127,d0
 3d4:	|  |  |  |            move.b d0,bfdf00 <gcc8_c_support.c.50501803+0xbf753d>
	System_WaitVbl();
 3da:	|  |  |  |            jsr (a2)
	custom.intena = INTF_SETCLR | INTF_INTEN | INTF_EXTER;
 3dc:	|  |  |  |            move.w #-8192,dff09a <gcc8_c_support.c.50501803+0xdf86d7>

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
bool System_TestLMB()
{
	return !(ciaa.ciapra & CIAF_GAMEPORT0);
 3e4:	|  |  |  |            move.b bfe001 <gcc8_c_support.c.50501803+0xbf763e>,d0
	if (System_Init())
	{
		if (Init())
		{
			while (!System_TestLMB())
 3ea:	|  |  |  |            btst #6,d0
 3ee:	|  |  |  |  /-------- beq.s 440 <main+0x3b4>
	while ((custom.vpos32 & mask) == vend) {}
 3f0:	|  |  |  |  |  /----> move.l dff004 <gcc8_c_support.c.50501803+0xdf8641>,d0
 3f6:	|  |  |  |  |  |      andi.l #130816,d0
 3fc:	|  |  |  |  |  +----- beq.s 3f0 <main+0x364>
	while ((custom.vpos32 & mask) != vend) {}
 3fe:	|  |  |  |  |  |  /-> move.l dff004 <gcc8_c_support.c.50501803+0xdf8641>,d0
 404:	|  |  |  |  |  |  |   andi.l #130816,d0
 40a:	|  |  |  |  |  |  \-- bne.s 3fe <main+0x372>
	ciab.ciatahi = kATimerCount >> 8;
 40c:	|  |  |  |  |  |      move.b #11,bfd500 <gcc8_c_support.c.50501803+0xbf6b3d>
	ciab.ciatbhi = kBTimerCount >> 8;
 414:	|  |  |  |  |  |      move.b #13,bfd700 <gcc8_c_support.c.50501803+0xbf6d3d>
	ciab.ciatodhi  = 0;
 41c:	|  |  |  |  |  |      move.b #0,bfda00 <gcc8_c_support.c.50501803+0xbf703d>
	ciab.ciatodmid = 0;
 424:	|  |  |  |  |  |      move.b #0,bfd900 <gcc8_c_support.c.50501803+0xbf6f3d>
	ciab.ciatodlow = 0;
 42c:	|  |  |  |  |  |      move.b #0,bfd800 <gcc8_c_support.c.50501803+0xbf6e3d>
	return !(ciaa.ciapra & CIAF_GAMEPORT0);
 434:	|  |  |  |  |  |      move.b bfe001 <gcc8_c_support.c.50501803+0xbf763e>,d0
			while (!System_TestLMB())
 43a:	|  |  |  |  |  |      btst #6,d0
 43e:	|  |  |  |  |  \----- bne.s 3f0 <main+0x364>
	custom.intena = INTF_EXTER;
 440:	|  |  |  |  \-------> move.w #8192,dff09a <gcc8_c_support.c.50501803+0xdf86d7>
	System_WaitVbl();
 448:	|  |  |  |            jsr (a2)
	*((System_IrqFunc**) (((u8*) sVBR) + 0x78)) = func;
 44a:	|  |  |  |            clr.l 120(a3)
	while ((custom.vpos32 & mask) == vend) {}
 44e:	|  |  |  |        /-> move.l dff004 <gcc8_c_support.c.50501803+0xdf8641>,d0
 454:	|  |  |  |        |   andi.l #130816,d0
 45a:	|  |  |  |        \-- beq.s 44e <main+0x3c2>
	while ((custom.vpos32 & mask) != vend) {}
 45c:	|  |  |  |        /-> move.l dff004 <gcc8_c_support.c.50501803+0xdf8641>,d0
 462:	|  |  |  |        |   andi.l #130816,d0
 468:	|  |  |  |        \-- bne.s 45c <main+0x3d0>
	u16 test = custom.dmaconr; // For compatiblity with A1000.
 46a:	|  |  |  |            move.w dff002 <gcc8_c_support.c.50501803+0xdf863f>,d0
	while (custom.dmaconr & DMAF_BLTDONE) {}
 470:	|  |  |  |        /-> move.w dff002 <gcc8_c_support.c.50501803+0xdf863f>,d0
 476:	|  |  |  |        |   btst #14,d0
 47a:	|  |  |  |        \-- bne.s 470 <main+0x3e4>
	ciaa.ciaicr = (u8) ~CIAICRF_SETCLR;
 47c:	|  |  |  |            move.b #127,bfed01 <gcc8_c_support.c.50501803+0xbf833e>
	ciab.ciaicr = (u8) ~CIAICRF_SETCLR;
 484:	|  |  |  |            move.b #127,bfdd00 <gcc8_c_support.c.50501803+0xbf733d>
	pending = ciaa.ciaicr;
 48c:	|  |  |  |            move.b bfed01 <gcc8_c_support.c.50501803+0xbf833e>,d0
	pending = ciab.ciaicr;
 492:	|  |  |  |            move.b bfdd00 <gcc8_c_support.c.50501803+0xbf733d>,d0
	custom.intena = (u16) ~INTF_SETCLR;
 498:	|  |  |  |            move.w #32767,dff09a <gcc8_c_support.c.50501803+0xdf86d7>
	custom.intreq = (u16) ~INTF_SETCLR;
 4a0:	|  |  |  |            move.w #32767,dff09c <gcc8_c_support.c.50501803+0xdf86d9>
	custom.dmacon = (u16) ~DMAF_SETCLR;
 4a8:	|  |  |  |            move.w #32767,dff096 <gcc8_c_support.c.50501803+0xdf86d3>
	*((System_IrqFunc**) (((u8*) sVBR) + 0x64)) = func;
 4b0:	|  |  |  |            move.l a6,100(a3)
	*((System_IrqFunc**) (((u8*) sVBR) + 0x68)) = func;
 4b4:	|  |  |  |            move.l 46(sp),104(a3)
	*((System_IrqFunc**) (((u8*) sVBR) + 0x6c)) = func;
 4ba:	|  |  |  |            move.l a5,108(a3)
	*((System_IrqFunc**) (((u8*) sVBR) + 0x78)) = func;
 4be:	|  |  |  |            move.l a4,120(a3)
	custom.cop1lc = (u32) GfxBase->copinit;
 4c2:	|  |  |  |            movea.l 274e <GfxBase>,a0
 4c8:	|  |  |  |            move.l 38(a0),dff080 <gcc8_c_support.c.50501803+0xdf86bd>
	custom.cop2lc = (u32) GfxBase->LOFlist;
 4d0:	|  |  |  |            move.l 50(a0),d0
 4d4:	|  |  |  |            move.l d0,dff084 <gcc8_c_support.c.50501803+0xdf86c1>
	custom.copjmp1 = 0;
 4da:	|  |  |  |            move.w #0,dff088 <gcc8_c_support.c.50501803+0xdf86c5>
	custom.adkcon = ADKF_SETCLR | sSavedADKCON;
 4e2:	|  |  |  |            ori.w #-32768,d4
 4e6:	|  |  |  |            move.w d4,dff09e <gcc8_c_support.c.50501803+0xdf86db>
	custom.dmacon = DMAF_SETCLR | sSavedDMACON;
 4ec:	|  |  |  |            ori.w #-32768,d3
 4f0:	|  |  |  |            move.w d3,dff096 <gcc8_c_support.c.50501803+0xdf86d3>
	custom.intena = INTF_SETCLR | sSavedINTENA;
 4f6:	|  |  |  |            ori.w #-32768,d2
 4fa:	|  |  |  |            move.w d2,dff09a <gcc8_c_support.c.50501803+0xdf86d7>
	ciaa.ciacra = sSavedCIAACRA;
 500:	|  |  |  |            move.b 51(sp),bfee01 <gcc8_c_support.c.50501803+0xbf843e>
	ciaa.ciacrb = sSavedCIAACRB;
 508:	|  |  |  |            move.b 52(sp),bfef01 <gcc8_c_support.c.50501803+0xbf853e>
	ciab.ciacra = sSavedCIABCRA;
 510:	|  |  |  |            move.b 53(sp),bfde00 <gcc8_c_support.c.50501803+0xbf743d>
	ciab.ciacrb = sSavedCIABCRB;
 518:	|  |  |  |            move.b d7,bfdf00 <gcc8_c_support.c.50501803+0xbf753d>
	ciaa.ciaicr = sSavedCIAAICR;
 51e:	|  |  |  |            move.b d6,bfed01 <gcc8_c_support.c.50501803+0xbf833e>
	ciab.ciaicr = sSavedCIABICR;
 524:	|  |  |  |            move.b d5,bfdd00 <gcc8_c_support.c.50501803+0xbf733d>
	ciaa.ciaicr = CIAICRF_SETCLR | CIAICRF_SP;
 52a:	|  |  |  |            move.b #-120,bfed01 <gcc8_c_support.c.50501803+0xbf833e>
	Enable();
 532:	|  |  |  |            movea.l 273e <SysBase>,a6
 538:	|  |  |  |            jsr -126(a6)
	LoadView(sSavedActiView);
 53c:	|  |  |  |            movea.l 274e <GfxBase>,a6
 542:	|  |  |  |            movea.l 273a <_ZL14sSavedActiView>,a1
 548:	|  |  |  |            jsr -222(a6)
	WaitTOF();
 54c:	|  |  |  |            movea.l 274e <GfxBase>,a6
 552:	|  |  |  |            jsr -270(a6)
	WaitTOF();
 556:	|  |  |  |            movea.l 274e <GfxBase>,a6
 55c:	|  |  |  |            jsr -270(a6)
	Permit();
 560:	|  |  |  |            movea.l 273e <SysBase>,a6
 566:	|  |  |  |            jsr -138(a6)
	WaitBlit();
 56a:	|  |  |  |            movea.l 274e <GfxBase>,a6
 570:	|  |  |  |            jsr -228(a6)
	DisownBlitter();
 574:	|  |  |  |            movea.l 274e <GfxBase>,a6
 57a:	|  |  |  |            jsr -462(a6)
	if (sSavedWorkbench)
 57e:	|  |  |  |            tst.b 2738 <_ZL15sSavedWorkbench>
 584:	|  |  |  |     /----- bne.w 608 <main+0x57c>
	if (sError != nullptr)
 588:	|  |  |  |  /--|----> tst.l 2730 <_ZL6sError>
 58e:	|  |  |  |  |  |  /-- beq.s 5bc <main+0x530>
		Write(Output(), (APTR) sError, strlen(sError) + 1);
 590:	|  |  |  |  |  |  |   movea.l 272c <DOSBase>,a6
 596:	|  |  |  |  |  |  |   jsr -60(a6)
 59a:	|  |  |  |  |  |  |   move.l d0,d4
 59c:	|  |  |  |  |  |  |   move.l 2730 <_ZL6sError>,d2
 5a2:	|  |  |  |  |  |  |   move.l d2,-(sp)
 5a4:	|  |  |  |  |  |  |   jsr 6d0 <strlen>
 5aa:	|  |  |  |  |  |  |   addq.l #4,sp
 5ac:	|  |  |  |  |  |  |   movea.l 272c <DOSBase>,a6
 5b2:	|  |  |  |  |  |  |   move.l d4,d1
 5b4:	|  |  |  |  |  |  |   move.l d0,d3
 5b6:	|  |  |  |  |  |  |   addq.l #1,d3
 5b8:	|  |  |  |  |  |  |   jsr -48(a6)
	CloseLibrary((Library*) MathBase);
 5bc:	|  |  |  |  |  |  \-> movea.l 273e <SysBase>,a6
 5c2:	|  |  |  |  |  |      movea.l 2728 <MathBase>,a1
 5c8:	|  |  |  |  |  |      jsr -414(a6)
	CloseLibrary((Library*) IntuitionBase);
 5cc:	|  |  |  \--|--|----> movea.l 273e <SysBase>,a6
 5d2:	|  |  |     |  |      movea.l 2734 <IntuitionBase>,a1
 5d8:	|  |  |     |  |      jsr -414(a6)
	CloseLibrary((Library*) GfxBase);
 5dc:	|  |  |     |  |      movea.l 273e <SysBase>,a6
 5e2:	|  |  \-----|--|----> movea.l 274e <GfxBase>,a1
 5e8:	|  |        |  |      jsr -414(a6)
	CloseLibrary((Library*) DOSBase);
 5ec:	|  |        |  |      movea.l 273e <SysBase>,a6
 5f2:	|  \--------|--|----> movea.l 272c <DOSBase>,a1
 5f8:	|           |  |      jsr -414(a6)
			Deinit();
		}

		System_Deinit();
	}
}
 5fc:	\-----------|--|----> moveq #0,d0
 5fe:	            |  |      movem.l (sp)+,d2-d7/a2-a6
 602:	            |  |      lea 16(sp),sp
 606:	            |  |      rts
		OpenWorkBench();
 608:	            |  \----> movea.l 2734 <IntuitionBase>,a6
 60e:	            |         jsr -210(a6)
 612:	            \-------- bra.w 588 <main+0x4fc>

00000616 <_ZL11Irq6Handlerv>:
{
 616:	       move.l d0,-(sp)
	u8 pending = ciab.ciaicr;
 618:	       move.b bfdd00 <gcc8_c_support.c.50501803+0xbf733d>,d0
	custom.intreq = INTF_EXTER;
 61e:	       move.w #8192,dff09c <gcc8_c_support.c.50501803+0xdf86d9>
	if (pending & CIAICRF_TA)
 626:	       btst #0,d0
 62a:	   /-- beq.s 63c <_ZL11Irq6Handlerv+0x26>
		custom.color[0] = 0x0f0;
 62c:	   |   move.w #240,dff180 <gcc8_c_support.c.50501803+0xdf87bd>
		custom.color[0] = 0x000;
 634:	   |   move.w #0,dff180 <gcc8_c_support.c.50501803+0xdf87bd>
	if (pending & CIAICRF_TB)
 63c:	   \-> btst #1,d0
 640:	   /-- beq.s 652 <_ZL11Irq6Handlerv+0x3c>
		custom.color[0] = 0x00f;
 642:	   |   move.w #15,dff180 <gcc8_c_support.c.50501803+0xdf87bd>
		custom.color[0] = 0x000;
 64a:	   |   move.w #0,dff180 <gcc8_c_support.c.50501803+0xdf87bd>
	if (pending & CIAICRF_ALRM)
 652:	   \-> btst #2,d0
 656:	/----- beq.s 694 <_ZL11Irq6Handlerv+0x7e>
		if (!sToggle)
 658:	|      tst.b 2766 <_ZL7sToggle>
 65e:	|  /-- bne.s 698 <_ZL11Irq6Handlerv+0x82>
			custom.color[0] = 0xff0;
 660:	|  |   move.w #4080,dff180 <gcc8_c_support.c.50501803+0xdf87bd>
			custom.color[0] = 0x000;
 668:	|  |   move.w #0,dff180 <gcc8_c_support.c.50501803+0xdf87bd>
			ciab.ciatodhi  = (kAlarmCount - 10) >> 16;
 670:	|  |   move.b #0,bfda00 <gcc8_c_support.c.50501803+0xbf703d>
			ciab.ciatodmid = (kAlarmCount - 10) >> 8;
 678:	|  |   move.b #0,bfd900 <gcc8_c_support.c.50501803+0xbf6f3d>
			ciab.ciatodlow = (kAlarmCount - 10);
 680:	|  |   move.b #80,bfd800 <gcc8_c_support.c.50501803+0xbf6e3d>
			sToggle = true;
 688:	|  |   move.b #1,2766 <_ZL7sToggle>
			asm("stop #0x2500\n");
 690:	|  |   stop #9472
}
 694:	\--|-> move.l (sp)+,d0
 696:	   |   rte
			custom.color[0] = 0xf00;
 698:	   \-> move.w #3840,dff180 <gcc8_c_support.c.50501803+0xdf87bd>
			custom.color[0] = 0x000;
 6a0:	       move.w #0,dff180 <gcc8_c_support.c.50501803+0xdf87bd>
			sToggle = false;
 6a8:	       clr.b 2766 <_ZL7sToggle>
}
 6ae:	       move.l (sp)+,d0
 6b0:	       rte

000006b2 <_Z14System_WaitVbljj.constprop.0>:
	while ((custom.vpos32 & mask) == vend) {}
 6b2:	/-> move.l dff004 <gcc8_c_support.c.50501803+0xdf8641>,d0
 6b8:	|   andi.l #130816,d0
 6be:	\-- beq.s 6b2 <_Z14System_WaitVbljj.constprop.0>
	while ((custom.vpos32 & mask) != vend) {}
 6c0:	/-> move.l dff004 <gcc8_c_support.c.50501803+0xdf8641>,d0
 6c6:	|   andi.l #130816,d0
 6cc:	\-- bne.s 6c0 <_Z14System_WaitVbljj.constprop.0+0xe>
}
 6ce:	    rts

000006d0 <strlen>:
	while(*s++)
 6d0:	   /-> movea.l 4(sp),a0
 6d4:	   |   tst.b (a0)+
 6d6:	/--|-- beq.s 6e4 <strlen+0x14>
 6d8:	|  |   move.l a0,-(sp)
 6da:	|  \-- jsr 6d0 <strlen>(pc)
 6de:	|      addq.l #4,sp
 6e0:	|      addq.l #1,d0
}
 6e2:	|      rts
	unsigned long t=0;
 6e4:	\----> moveq #0,d0
}
 6e6:	       rts
