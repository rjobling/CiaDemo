
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
   4:	       move.l #9995,d3
   a:	       subi.l #9995,d3
  10:	       asr.l #2,d3
	for (i = 0; i < count; i++)
  12:	/----- beq.s 26 <_start+0x26>
  14:	|      lea 270b <__bss_start>,a2
  1a:	|      moveq #0,d2
		__preinit_array_start[i]();
  1c:	|  /-> movea.l (a2)+,a0
  1e:	|  |   jsr (a0)
	for (i = 0; i < count; i++)
  20:	|  |   addq.l #1,d2
  22:	|  |   cmp.l d3,d2
  24:	|  \-- bne.s 1c <_start+0x1c>

	count = __init_array_end - __init_array_start;
  26:	\----> move.l #9995,d3
  2c:	       subi.l #9995,d3
  32:	       asr.l #2,d3
	for (i = 0; i < count; i++)
  34:	/----- beq.s 48 <_start+0x48>
  36:	|      lea 270b <__bss_start>,a2
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
  4e:	       move.l #9995,d2
  54:	       subi.l #9995,d2
  5a:	       asr.l #2,d2
	for (i = count; i > 0; i--)
  5c:	/----- beq.s 6e <_start+0x6e>
  5e:	|      lea 270b <__bss_start>,a2
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
  7c:	                      clr.l 2714 <_ZL6sError>

	#if !defined(LDOS)

	SysBase = *((struct ExecBase**) 4);
  82:	                      movea.l 4 <_start+0x4>,a6
  86:	                      move.l a6,2722 <SysBase>

	sVBR = 0;
  8c:	                      clr.l 2742 <_ZL4sVBR>
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
  b8:	                  |   move.l d0,2742 <_ZL4sVBR>
	}

	DOSBase = (struct DosLibrary*) OpenLibrary((CONST_STRPTR) "dos.library", 0);
  be:	                  \-> movea.l 2722 <SysBase>,a6
  c4:	                      lea 6cc <strlen+0x14>,a1
  ca:	                      moveq #0,d0
  cc:	                      jsr -552(a6)
  d0:	                      move.l d0,2710 <DOSBase>
	if (DOSBase == nullptr)
  d6:	/-------------------- beq.w 5e4 <main+0x570>
	{
		return false;
	}

	GfxBase = (struct GfxBase*) OpenLibrary((CONST_STRPTR) "graphics.library", 0);
  da:	|                     movea.l 2722 <SysBase>,a6
  e0:	|                     lea 6d8 <strlen+0x20>,a1
  e6:	|                     moveq #0,d0
  e8:	|                     jsr -552(a6)
  ec:	|                     move.l d0,2732 <GfxBase>
	if (GfxBase == nullptr)
	{
		CloseLibrary((Library*) DOSBase);
  f2:	|                     movea.l 2722 <SysBase>,a6
	if (GfxBase == nullptr)
  f8:	|  /----------------- beq.w 5da <main+0x566>

		return false;
	}

	IntuitionBase = (struct IntuitionBase*) OpenLibrary((CONST_STRPTR) "intuition.library", 0);
  fc:	|  |                  lea 6e9 <strlen+0x31>,a1
 102:	|  |                  moveq #0,d0
 104:	|  |                  jsr -552(a6)
 108:	|  |                  move.l d0,2718 <IntuitionBase>
	if (IntuitionBase == nullptr)
	{
		CloseLibrary((Library*) GfxBase);
 10e:	|  |                  movea.l 2722 <SysBase>,a6
	if (IntuitionBase == nullptr)
 114:	|  |  /-------------- beq.w 5ca <main+0x556>
		CloseLibrary((Library*) DOSBase);

		return false;
	}

	MathBase = OpenLibrary("mathffp.library", 0);
 118:	|  |  |               lea 6fb <strlen+0x43>,a1
 11e:	|  |  |               moveq #0,d0
 120:	|  |  |               jsr -552(a6)
 124:	|  |  |               move.l d0,270c <MathBase>
	if (MathBase == nullptr)
 12a:	|  |  |  /----------- beq.w 5b4 <main+0x540>
		CloseLibrary((Library*) DOSBase);

		return false;
	}

	sSavedWorkbench = CloseWorkBench();
 12e:	|  |  |  |            movea.l 2718 <IntuitionBase>,a6
 134:	|  |  |  |            jsr -78(a6)
 138:	|  |  |  |            tst.l d0
 13a:	|  |  |  |            sne d0
 13c:	|  |  |  |            neg.b d0
 13e:	|  |  |  |            move.b d0,271c <_ZL15sSavedWorkbench>

	OwnBlitter();
 144:	|  |  |  |            movea.l 2732 <GfxBase>,a6
 14a:	|  |  |  |            jsr -456(a6)
	WaitBlit();
 14e:	|  |  |  |            movea.l 2732 <GfxBase>,a6
 154:	|  |  |  |            jsr -228(a6)

	Forbid();
 158:	|  |  |  |            movea.l 2722 <SysBase>,a6
 15e:	|  |  |  |            jsr -132(a6)

	sSavedActiView = GfxBase->ActiView;
 162:	|  |  |  |            movea.l 2732 <GfxBase>,a6
 168:	|  |  |  |            move.l 34(a6),271e <_ZL14sSavedActiView>

	LoadView(nullptr);
 170:	|  |  |  |            suba.l a1,a1
 172:	|  |  |  |            jsr -222(a6)
	WaitTOF();
 176:	|  |  |  |            movea.l 2732 <GfxBase>,a6
 17c:	|  |  |  |            jsr -270(a6)
	WaitTOF();
 180:	|  |  |  |            movea.l 2732 <GfxBase>,a6
 186:	|  |  |  |            jsr -270(a6)

	Disable();
 18a:	|  |  |  |            movea.l 2722 <SysBase>,a6
 190:	|  |  |  |            jsr -120(a6)

	// Save current interrupt and DMA settings.
	sSavedADKCON = custom.adkconr;
 194:	|  |  |  |            move.w dff010 <gcc8_c_support.c.ba290747+0xdf8670>,d4
 19a:	|  |  |  |            move.w d4,2730 <_ZL12sSavedADKCON>
	sSavedDMACON = custom.dmaconr;
 1a0:	|  |  |  |            move.w dff002 <gcc8_c_support.c.ba290747+0xdf8662>,d3
 1a6:	|  |  |  |            move.w d3,272e <_ZL12sSavedDMACON>
	sSavedINTENA = custom.intenar;
 1ac:	|  |  |  |            move.w dff01c <gcc8_c_support.c.ba290747+0xdf867c>,d2
 1b2:	|  |  |  |            move.w d2,272c <_ZL12sSavedINTENA>

	// Disable all interrupts.
	custom.intena = (u16) ~INTF_SETCLR;
 1b8:	|  |  |  |            move.w #32767,dff09a <gcc8_c_support.c.ba290747+0xdf86fa>

	// Clear all pending interrupts.
	custom.intreq = (u16) ~INTF_SETCLR;
 1c0:	|  |  |  |            move.w #32767,dff09c <gcc8_c_support.c.ba290747+0xdf86fc>

	// Clear all DMA channels.
	custom.dmacon = (u16) ~DMAF_SETCLR;
 1c8:	|  |  |  |            move.w #32767,dff096 <gcc8_c_support.c.ba290747+0xdf86f6>

	// Disable all CIA interrupts.
	ciaa.ciaicr = (u8) ~CIAICRF_SETCLR;
 1d0:	|  |  |  |            move.b #127,bfed01 <gcc8_c_support.c.ba290747+0xbf8361>
	ciab.ciaicr = (u8) ~CIAICRF_SETCLR;
 1d8:	|  |  |  |            move.b #127,bfdd00 <gcc8_c_support.c.ba290747+0xbf7360>

	// Save current CIA interrupts, which clears any pending.
	sSavedCIAAICR = ciaa.ciaicr;
 1e0:	|  |  |  |            move.b bfed01 <gcc8_c_support.c.ba290747+0xbf8361>,d6
 1e6:	|  |  |  |            move.b d6,2727 <_ZL13sSavedCIAAICR>
	sSavedCIABICR = ciab.ciaicr;
 1ec:	|  |  |  |            move.b bfdd00 <gcc8_c_support.c.ba290747+0xbf7360>,d5
 1f2:	|  |  |  |            move.b d5,2726 <_ZL13sSavedCIABICR>

	// Save current CIA controls.
	sSavedCIAACRA = ciaa.ciacra;
 1f8:	|  |  |  |            move.b bfee01 <gcc8_c_support.c.ba290747+0xbf8461>,51(sp)
 200:	|  |  |  |            move.b 51(sp),272b <_ZL13sSavedCIAACRA>
	sSavedCIAACRB = ciaa.ciacrb;
 208:	|  |  |  |            move.b bfef01 <gcc8_c_support.c.ba290747+0xbf8561>,52(sp)
 210:	|  |  |  |            move.b 52(sp),272a <_ZL13sSavedCIAACRB>
	sSavedCIABCRA = ciab.ciacra;
 218:	|  |  |  |            move.b bfde00 <gcc8_c_support.c.ba290747+0xbf7460>,53(sp)
 220:	|  |  |  |            move.b 53(sp),2729 <_ZL13sSavedCIABCRA>
	sSavedCIABCRB = ciab.ciacrb;
 228:	|  |  |  |            move.b bfdf00 <gcc8_c_support.c.ba290747+0xbf7560>,d7
 22e:	|  |  |  |            move.b d7,2728 <_ZL13sSavedCIABCRB>

	// Clear CIA Alarm count.
	ciab.ciacrb = CIACRBF_ALARM;
 234:	|  |  |  |            move.b #-128,bfdf00 <gcc8_c_support.c.ba290747+0xbf7560>
	ciab.ciatodhi = 0;
 23c:	|  |  |  |            move.b #0,bfda00 <gcc8_c_support.c.ba290747+0xbf7060>
	ciab.ciatodmid = 0;
 244:	|  |  |  |            move.b #0,bfd900 <gcc8_c_support.c.ba290747+0xbf6f60>
	ciab.ciatodlow = 0;
 24c:	|  |  |  |            move.b #0,bfd800 <gcc8_c_support.c.ba290747+0xbf6e60>

	// Clear all CIA controls.
	ciaa.ciacra = 0;
 254:	|  |  |  |            move.b #0,bfee01 <gcc8_c_support.c.ba290747+0xbf8461>
	ciaa.ciacrb = 0;
 25c:	|  |  |  |            move.b #0,bfef01 <gcc8_c_support.c.ba290747+0xbf8561>
	ciab.ciacra = 0;
 264:	|  |  |  |            move.b #0,bfde00 <gcc8_c_support.c.ba290747+0xbf7460>
	ciab.ciacrb = 0;
 26c:	|  |  |  |            move.b #0,bfdf00 <gcc8_c_support.c.ba290747+0xbf7560>

	// Clear CIA TOD count.
	ciab.ciatodhi = 0;
 274:	|  |  |  |            move.b #0,bfda00 <gcc8_c_support.c.ba290747+0xbf7060>
	ciab.ciatodmid = 0;
 27c:	|  |  |  |            move.b #0,bfd900 <gcc8_c_support.c.ba290747+0xbf6f60>
	ciab.ciatodlow = 0;
 284:	|  |  |  |            move.b #0,bfd800 <gcc8_c_support.c.ba290747+0xbf6e60>

	// Pause CIA TOD count.
	ciab.ciatodhi = 0;
 28c:	|  |  |  |            move.b #0,bfda00 <gcc8_c_support.c.ba290747+0xbf7060>

	// Set all colors to black.
	for (int i = 0; i < countof(custom.color); i++)
 294:	|  |  |  |            moveq #0,d1
	{
		custom.color[i] = 0x000;
 296:	|  |  |  |            movea.l #14675968,a0
 29c:	|  |  |  |        /-> move.l d1,d0
 29e:	|  |  |  |        |   addi.l #192,d0
 2a4:	|  |  |  |        |   add.l d0,d0
 2a6:	|  |  |  |        |   move.w #0,(0,a0,d0.l)
	for (int i = 0; i < countof(custom.color); i++)
 2ac:	|  |  |  |        |   addq.l #1,d1
 2ae:	|  |  |  |        |   moveq #32,d0
 2b0:	|  |  |  |        |   cmp.l d1,d0
 2b2:	|  |  |  |        \-- bne.s 29c <main+0x228>

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void System_WaitVbl(u32 vend, u32 mask)
{
	while ((custom.vpos32 & mask) == vend) {}
 2b4:	|  |  |  |        /-> move.l dff004 <gcc8_c_support.c.ba290747+0xdf8664>,d0
 2ba:	|  |  |  |        |   andi.l #130816,d0
 2c0:	|  |  |  |        \-- beq.s 2b4 <main+0x240>
	while ((custom.vpos32 & mask) != vend) {}
 2c2:	|  |  |  |        /-> move.l dff004 <gcc8_c_support.c.ba290747+0xdf8664>,d0
 2c8:	|  |  |  |        |   andi.l #130816,d0
 2ce:	|  |  |  |        \-- bne.s 2c2 <main+0x24e>
	while ((custom.vpos32 & mask) == vend) {}
 2d0:	|  |  |  |        /-> move.l dff004 <gcc8_c_support.c.ba290747+0xdf8664>,d0
 2d6:	|  |  |  |        |   andi.l #130816,d0
 2dc:	|  |  |  |        \-- beq.s 2d0 <main+0x25c>
	while ((custom.vpos32 & mask) != vend) {}
 2de:	|  |  |  |        /-> move.l dff004 <gcc8_c_support.c.ba290747+0xdf8664>,d0
 2e4:	|  |  |  |        |   andi.l #130816,d0
 2ea:	|  |  |  |        \-- bne.s 2de <main+0x26a>
	custom.vposw = 0x8000;
 2ec:	|  |  |  |            move.w #-32768,dff02a <gcc8_c_support.c.ba290747+0xdf868a>
	return *((System_IrqFunc**) (((u8*) sVBR) + 0x64));
 2f4:	|  |  |  |            movea.l 2742 <_ZL4sVBR>,a3
 2fa:	|  |  |  |            movea.l 100(a3),a6
	sSavedIrq1Handler = System_GetIrq1Handler();
 2fe:	|  |  |  |            move.l a6,2746 <_ZL17sSavedIrq1Handler>
	return *((System_IrqFunc**) (((u8*) sVBR) + 0x68));
 304:	|  |  |  |            move.l 104(a3),46(sp)
	sSavedIrq2Handler = System_GetIrq2Handler();
 30a:	|  |  |  |            move.l 46(sp),273e <_ZL17sSavedIrq2Handler>
	return *((System_IrqFunc**) (((u8*) sVBR) + 0x6c));
 312:	|  |  |  |            movea.l 108(a3),a5
	sSavedIrq3Handler = System_GetIrq3Handler();
 316:	|  |  |  |            move.l a5,273a <_ZL17sSavedIrq3Handler>
	return *((System_IrqFunc**) (((u8*) sVBR) + 0x78));
 31c:	|  |  |  |            movea.l 120(a3),a4
	sSavedIrq6Handler = System_GetIrq6Handler();
 320:	|  |  |  |            move.l a4,2736 <_ZL17sSavedIrq6Handler>
	while ((custom.vpos32 & mask) == vend) {}
 326:	|  |  |  |        /-> move.l dff004 <gcc8_c_support.c.ba290747+0xdf8664>,d0
 32c:	|  |  |  |        |   andi.l #130816,d0
 332:	|  |  |  |        \-- beq.s 326 <main+0x2b2>
	while ((custom.vpos32 & mask) != vend) {}
 334:	|  |  |  |        /-> move.l dff004 <gcc8_c_support.c.ba290747+0xdf8664>,d0
 33a:	|  |  |  |        |   andi.l #130816,d0
 340:	|  |  |  |        \-- bne.s 334 <main+0x2c0>
	System_WaitVbl();
 342:	|  |  |  |            lea 69a <_Z14System_WaitVbljj.constprop.0>,a2
 348:	|  |  |  |            jsr (a2)
	*((System_IrqFunc**) (((u8*) sVBR) + 0x78)) = func;
 34a:	|  |  |  |            move.l #1534,120(a3)
	ciab.ciacra = CIACRAF_RUNMODE;
 352:	|  |  |  |            move.b #8,bfde00 <gcc8_c_support.c.ba290747+0xbf7460>
	ciab.ciaicr = CIAICRF_SETCLR | CIAICRF_TA;
 35a:	|  |  |  |            move.b #-127,bfdd00 <gcc8_c_support.c.ba290747+0xbf7360>
	ciab.ciatalo = kATimerCount & 255;
 362:	|  |  |  |            move.b #-72,bfd400 <gcc8_c_support.c.ba290747+0xbf6a60>
	ciab.ciacrb = CIACRAF_RUNMODE;
 36a:	|  |  |  |            move.b #8,bfdf00 <gcc8_c_support.c.ba290747+0xbf7560>
	ciab.ciaicr = CIAICRF_SETCLR | CIAICRF_TB;
 372:	|  |  |  |            move.b #-126,bfdd00 <gcc8_c_support.c.ba290747+0xbf7360>
	ciab.ciatblo = kBTimerCount & 255;
 37a:	|  |  |  |            move.b #-84,bfd600 <gcc8_c_support.c.ba290747+0xbf6c60>
	ciab.ciaicr = CIAICRF_SETCLR | CIAICRF_ALRM;
 382:	|  |  |  |            move.b #-124,bfdd00 <gcc8_c_support.c.ba290747+0xbf7360>
	ciab.ciacrb |= CIACRBF_ALARM;
 38a:	|  |  |  |            move.b bfdf00 <gcc8_c_support.c.ba290747+0xbf7560>,d0
 390:	|  |  |  |            ori.b #-128,d0
 394:	|  |  |  |            move.b d0,bfdf00 <gcc8_c_support.c.ba290747+0xbf7560>
	ciab.ciatodhi  = kAlarmCount >> 16;
 39a:	|  |  |  |            move.b #0,bfda00 <gcc8_c_support.c.ba290747+0xbf7060>
	ciab.ciatodmid = kAlarmCount >> 8;
 3a2:	|  |  |  |            move.b #0,bfd900 <gcc8_c_support.c.ba290747+0xbf6f60>
	ciab.ciatodlow = kAlarmCount;
 3aa:	|  |  |  |            move.b #90,bfd800 <gcc8_c_support.c.ba290747+0xbf6e60>
	ciab.ciacrb &= ~CIACRBF_ALARM;
 3b2:	|  |  |  |            move.b bfdf00 <gcc8_c_support.c.ba290747+0xbf7560>,d0
 3b8:	|  |  |  |            andi.b #127,d0
 3bc:	|  |  |  |            move.b d0,bfdf00 <gcc8_c_support.c.ba290747+0xbf7560>
	System_WaitVbl();
 3c2:	|  |  |  |            jsr (a2)
	custom.intena = INTF_SETCLR | INTF_INTEN | INTF_EXTER;
 3c4:	|  |  |  |            move.w #-8192,dff09a <gcc8_c_support.c.ba290747+0xdf86fa>

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
bool System_TestLMB()
{
	return !(ciaa.ciapra & CIAF_GAMEPORT0);
 3cc:	|  |  |  |            move.b bfe001 <gcc8_c_support.c.ba290747+0xbf7661>,d0
	if (System_Init())
	{
		if (Init())
		{
			while (!System_TestLMB())
 3d2:	|  |  |  |            btst #6,d0
 3d6:	|  |  |  |  /-------- beq.s 428 <main+0x3b4>
	while ((custom.vpos32 & mask) == vend) {}
 3d8:	|  |  |  |  |  /----> move.l dff004 <gcc8_c_support.c.ba290747+0xdf8664>,d0
 3de:	|  |  |  |  |  |      andi.l #130816,d0
 3e4:	|  |  |  |  |  +----- beq.s 3d8 <main+0x364>
	while ((custom.vpos32 & mask) != vend) {}
 3e6:	|  |  |  |  |  |  /-> move.l dff004 <gcc8_c_support.c.ba290747+0xdf8664>,d0
 3ec:	|  |  |  |  |  |  |   andi.l #130816,d0
 3f2:	|  |  |  |  |  |  \-- bne.s 3e6 <main+0x372>
	ciab.ciatahi = kATimerCount >> 8;
 3f4:	|  |  |  |  |  |      move.b #11,bfd500 <gcc8_c_support.c.ba290747+0xbf6b60>
	ciab.ciatbhi = kBTimerCount >> 8;
 3fc:	|  |  |  |  |  |      move.b #13,bfd700 <gcc8_c_support.c.ba290747+0xbf6d60>
	ciab.ciatodhi  = 0;
 404:	|  |  |  |  |  |      move.b #0,bfda00 <gcc8_c_support.c.ba290747+0xbf7060>
	ciab.ciatodmid = 0;
 40c:	|  |  |  |  |  |      move.b #0,bfd900 <gcc8_c_support.c.ba290747+0xbf6f60>
	ciab.ciatodlow = 0;
 414:	|  |  |  |  |  |      move.b #0,bfd800 <gcc8_c_support.c.ba290747+0xbf6e60>
	return !(ciaa.ciapra & CIAF_GAMEPORT0);
 41c:	|  |  |  |  |  |      move.b bfe001 <gcc8_c_support.c.ba290747+0xbf7661>,d0
			while (!System_TestLMB())
 422:	|  |  |  |  |  |      btst #6,d0
 426:	|  |  |  |  |  \----- bne.s 3d8 <main+0x364>
	custom.intena = INTF_EXTER;
 428:	|  |  |  |  \-------> move.w #8192,dff09a <gcc8_c_support.c.ba290747+0xdf86fa>
	System_WaitVbl();
 430:	|  |  |  |            jsr (a2)
	*((System_IrqFunc**) (((u8*) sVBR) + 0x78)) = func;
 432:	|  |  |  |            clr.l 120(a3)
	while ((custom.vpos32 & mask) == vend) {}
 436:	|  |  |  |        /-> move.l dff004 <gcc8_c_support.c.ba290747+0xdf8664>,d0
 43c:	|  |  |  |        |   andi.l #130816,d0
 442:	|  |  |  |        \-- beq.s 436 <main+0x3c2>
	while ((custom.vpos32 & mask) != vend) {}
 444:	|  |  |  |        /-> move.l dff004 <gcc8_c_support.c.ba290747+0xdf8664>,d0
 44a:	|  |  |  |        |   andi.l #130816,d0
 450:	|  |  |  |        \-- bne.s 444 <main+0x3d0>
	u16 test = custom.dmaconr; // For compatiblity with A1000.
 452:	|  |  |  |            move.w dff002 <gcc8_c_support.c.ba290747+0xdf8662>,d0
	while (custom.dmaconr & DMAF_BLTDONE) {}
 458:	|  |  |  |        /-> move.w dff002 <gcc8_c_support.c.ba290747+0xdf8662>,d0
 45e:	|  |  |  |        |   btst #14,d0
 462:	|  |  |  |        \-- bne.s 458 <main+0x3e4>
	ciaa.ciaicr = (u8) ~CIAICRF_SETCLR;
 464:	|  |  |  |            move.b #127,bfed01 <gcc8_c_support.c.ba290747+0xbf8361>
	ciab.ciaicr = (u8) ~CIAICRF_SETCLR;
 46c:	|  |  |  |            move.b #127,bfdd00 <gcc8_c_support.c.ba290747+0xbf7360>
	pending = ciaa.ciaicr;
 474:	|  |  |  |            move.b bfed01 <gcc8_c_support.c.ba290747+0xbf8361>,d0
	pending = ciab.ciaicr;
 47a:	|  |  |  |            move.b bfdd00 <gcc8_c_support.c.ba290747+0xbf7360>,d0
	custom.intena = (u16) ~INTF_SETCLR;
 480:	|  |  |  |            move.w #32767,dff09a <gcc8_c_support.c.ba290747+0xdf86fa>
	custom.intreq = (u16) ~INTF_SETCLR;
 488:	|  |  |  |            move.w #32767,dff09c <gcc8_c_support.c.ba290747+0xdf86fc>
	custom.dmacon = (u16) ~DMAF_SETCLR;
 490:	|  |  |  |            move.w #32767,dff096 <gcc8_c_support.c.ba290747+0xdf86f6>
	*((System_IrqFunc**) (((u8*) sVBR) + 0x64)) = func;
 498:	|  |  |  |            move.l a6,100(a3)
	*((System_IrqFunc**) (((u8*) sVBR) + 0x68)) = func;
 49c:	|  |  |  |            move.l 46(sp),104(a3)
	*((System_IrqFunc**) (((u8*) sVBR) + 0x6c)) = func;
 4a2:	|  |  |  |            move.l a5,108(a3)
	*((System_IrqFunc**) (((u8*) sVBR) + 0x78)) = func;
 4a6:	|  |  |  |            move.l a4,120(a3)
	custom.cop1lc = (u32) GfxBase->copinit;
 4aa:	|  |  |  |            movea.l 2732 <GfxBase>,a0
 4b0:	|  |  |  |            move.l 38(a0),dff080 <gcc8_c_support.c.ba290747+0xdf86e0>
	custom.cop2lc = (u32) GfxBase->LOFlist;
 4b8:	|  |  |  |            move.l 50(a0),d0
 4bc:	|  |  |  |            move.l d0,dff084 <gcc8_c_support.c.ba290747+0xdf86e4>
	custom.copjmp1 = 0;
 4c2:	|  |  |  |            move.w #0,dff088 <gcc8_c_support.c.ba290747+0xdf86e8>
	custom.adkcon = ADKF_SETCLR | sSavedADKCON;
 4ca:	|  |  |  |            ori.w #-32768,d4
 4ce:	|  |  |  |            move.w d4,dff09e <gcc8_c_support.c.ba290747+0xdf86fe>
	custom.dmacon = DMAF_SETCLR | sSavedDMACON;
 4d4:	|  |  |  |            ori.w #-32768,d3
 4d8:	|  |  |  |            move.w d3,dff096 <gcc8_c_support.c.ba290747+0xdf86f6>
	custom.intena = INTF_SETCLR | sSavedINTENA;
 4de:	|  |  |  |            ori.w #-32768,d2
 4e2:	|  |  |  |            move.w d2,dff09a <gcc8_c_support.c.ba290747+0xdf86fa>
	ciaa.ciacra = sSavedCIAACRA;
 4e8:	|  |  |  |            move.b 51(sp),bfee01 <gcc8_c_support.c.ba290747+0xbf8461>
	ciaa.ciacrb = sSavedCIAACRB;
 4f0:	|  |  |  |            move.b 52(sp),bfef01 <gcc8_c_support.c.ba290747+0xbf8561>
	ciab.ciacra = sSavedCIABCRA;
 4f8:	|  |  |  |            move.b 53(sp),bfde00 <gcc8_c_support.c.ba290747+0xbf7460>
	ciab.ciacrb = sSavedCIABCRB;
 500:	|  |  |  |            move.b d7,bfdf00 <gcc8_c_support.c.ba290747+0xbf7560>
	ciaa.ciaicr = sSavedCIAAICR;
 506:	|  |  |  |            move.b d6,bfed01 <gcc8_c_support.c.ba290747+0xbf8361>
	ciab.ciaicr = sSavedCIABICR;
 50c:	|  |  |  |            move.b d5,bfdd00 <gcc8_c_support.c.ba290747+0xbf7360>
	ciaa.ciaicr = CIAICRF_SETCLR | CIAICRF_SP;
 512:	|  |  |  |            move.b #-120,bfed01 <gcc8_c_support.c.ba290747+0xbf8361>
	Enable();
 51a:	|  |  |  |            movea.l 2722 <SysBase>,a6
 520:	|  |  |  |            jsr -126(a6)
	LoadView(sSavedActiView);
 524:	|  |  |  |            movea.l 2732 <GfxBase>,a6
 52a:	|  |  |  |            movea.l 271e <_ZL14sSavedActiView>,a1
 530:	|  |  |  |            jsr -222(a6)
	WaitTOF();
 534:	|  |  |  |            movea.l 2732 <GfxBase>,a6
 53a:	|  |  |  |            jsr -270(a6)
	WaitTOF();
 53e:	|  |  |  |            movea.l 2732 <GfxBase>,a6
 544:	|  |  |  |            jsr -270(a6)
	Permit();
 548:	|  |  |  |            movea.l 2722 <SysBase>,a6
 54e:	|  |  |  |            jsr -138(a6)
	WaitBlit();
 552:	|  |  |  |            movea.l 2732 <GfxBase>,a6
 558:	|  |  |  |            jsr -228(a6)
	DisownBlitter();
 55c:	|  |  |  |            movea.l 2732 <GfxBase>,a6
 562:	|  |  |  |            jsr -462(a6)
	if (sSavedWorkbench)
 566:	|  |  |  |            tst.b 271c <_ZL15sSavedWorkbench>
 56c:	|  |  |  |     /----- bne.w 5f0 <main+0x57c>
	if (sError != nullptr)
 570:	|  |  |  |  /--|----> tst.l 2714 <_ZL6sError>
 576:	|  |  |  |  |  |  /-- beq.s 5a4 <main+0x530>
		Write(Output(), (APTR) sError, strlen(sError) + 1);
 578:	|  |  |  |  |  |  |   movea.l 2710 <DOSBase>,a6
 57e:	|  |  |  |  |  |  |   jsr -60(a6)
 582:	|  |  |  |  |  |  |   move.l d0,d4
 584:	|  |  |  |  |  |  |   move.l 2714 <_ZL6sError>,d2
 58a:	|  |  |  |  |  |  |   move.l d2,-(sp)
 58c:	|  |  |  |  |  |  |   jsr 6b8 <strlen>
 592:	|  |  |  |  |  |  |   addq.l #4,sp
 594:	|  |  |  |  |  |  |   movea.l 2710 <DOSBase>,a6
 59a:	|  |  |  |  |  |  |   move.l d4,d1
 59c:	|  |  |  |  |  |  |   move.l d0,d3
 59e:	|  |  |  |  |  |  |   addq.l #1,d3
 5a0:	|  |  |  |  |  |  |   jsr -48(a6)
	CloseLibrary((Library*) MathBase);
 5a4:	|  |  |  |  |  |  \-> movea.l 2722 <SysBase>,a6
 5aa:	|  |  |  |  |  |      movea.l 270c <MathBase>,a1
 5b0:	|  |  |  |  |  |      jsr -414(a6)
	CloseLibrary((Library*) IntuitionBase);
 5b4:	|  |  |  \--|--|----> movea.l 2722 <SysBase>,a6
 5ba:	|  |  |     |  |      movea.l 2718 <IntuitionBase>,a1
 5c0:	|  |  |     |  |      jsr -414(a6)
	CloseLibrary((Library*) GfxBase);
 5c4:	|  |  |     |  |      movea.l 2722 <SysBase>,a6
 5ca:	|  |  \-----|--|----> movea.l 2732 <GfxBase>,a1
 5d0:	|  |        |  |      jsr -414(a6)
	CloseLibrary((Library*) DOSBase);
 5d4:	|  |        |  |      movea.l 2722 <SysBase>,a6
 5da:	|  \--------|--|----> movea.l 2710 <DOSBase>,a1
 5e0:	|           |  |      jsr -414(a6)
			Deinit();
		}

		System_Deinit();
	}
}
 5e4:	\-----------|--|----> moveq #0,d0
 5e6:	            |  |      movem.l (sp)+,d2-d7/a2-a6
 5ea:	            |  |      lea 16(sp),sp
 5ee:	            |  |      rts
		OpenWorkBench();
 5f0:	            |  \----> movea.l 2718 <IntuitionBase>,a6
 5f6:	            |         jsr -210(a6)
 5fa:	            \-------- bra.w 570 <main+0x4fc>

000005fe <_ZL11Irq6Handlerv>:
{
 5fe:	       move.l d0,-(sp)
	u8 pending = ciab.ciaicr;
 600:	       move.b bfdd00 <gcc8_c_support.c.ba290747+0xbf7360>,d0
	custom.intreq = INTF_EXTER;
 606:	       move.w #8192,dff09c <gcc8_c_support.c.ba290747+0xdf86fc>
	if (pending & CIAICRF_TA)
 60e:	       btst #0,d0
 612:	   /-- beq.s 624 <_ZL11Irq6Handlerv+0x26>
		custom.color[0] = 0x0f0;
 614:	   |   move.w #240,dff180 <gcc8_c_support.c.ba290747+0xdf87e0>
		custom.color[0] = 0x000;
 61c:	   |   move.w #0,dff180 <gcc8_c_support.c.ba290747+0xdf87e0>
	if (pending & CIAICRF_TB)
 624:	   \-> btst #1,d0
 628:	   /-- beq.s 63a <_ZL11Irq6Handlerv+0x3c>
		custom.color[0] = 0x00f;
 62a:	   |   move.w #15,dff180 <gcc8_c_support.c.ba290747+0xdf87e0>
		custom.color[0] = 0x000;
 632:	   |   move.w #0,dff180 <gcc8_c_support.c.ba290747+0xdf87e0>
	if (pending & CIAICRF_ALRM)
 63a:	   \-> btst #2,d0
 63e:	/----- beq.s 67c <_ZL11Irq6Handlerv+0x7e>
		if (!sToggle)
 640:	|      tst.b 274a <_ZL7sToggle>
 646:	|  /-- bne.s 680 <_ZL11Irq6Handlerv+0x82>
			custom.color[0] = 0xff0;
 648:	|  |   move.w #4080,dff180 <gcc8_c_support.c.ba290747+0xdf87e0>
			custom.color[0] = 0x000;
 650:	|  |   move.w #0,dff180 <gcc8_c_support.c.ba290747+0xdf87e0>
			ciab.ciatodhi  = (kAlarmCount - 1) >> 16;
 658:	|  |   move.b #0,bfda00 <gcc8_c_support.c.ba290747+0xbf7060>
			ciab.ciatodmid = (kAlarmCount - 1) >> 8;
 660:	|  |   move.b #0,bfd900 <gcc8_c_support.c.ba290747+0xbf6f60>
			ciab.ciatodlow = (kAlarmCount - 1);
 668:	|  |   move.b #89,bfd800 <gcc8_c_support.c.ba290747+0xbf6e60>
			sToggle = true;
 670:	|  |   move.b #1,274a <_ZL7sToggle>
			asm("stop #0x2500\n");
 678:	|  |   stop #9472
}
 67c:	\--|-> move.l (sp)+,d0
 67e:	   |   rte
			custom.color[0] = 0xf00;
 680:	   \-> move.w #3840,dff180 <gcc8_c_support.c.ba290747+0xdf87e0>
			custom.color[0] = 0x000;
 688:	       move.w #0,dff180 <gcc8_c_support.c.ba290747+0xdf87e0>
			sToggle = false;
 690:	       clr.b 274a <_ZL7sToggle>
}
 696:	       move.l (sp)+,d0
 698:	       rte

0000069a <_Z14System_WaitVbljj.constprop.0>:
	while ((custom.vpos32 & mask) == vend) {}
 69a:	/-> move.l dff004 <gcc8_c_support.c.ba290747+0xdf8664>,d0
 6a0:	|   andi.l #130816,d0
 6a6:	\-- beq.s 69a <_Z14System_WaitVbljj.constprop.0>
	while ((custom.vpos32 & mask) != vend) {}
 6a8:	/-> move.l dff004 <gcc8_c_support.c.ba290747+0xdf8664>,d0
 6ae:	|   andi.l #130816,d0
 6b4:	\-- bne.s 6a8 <_Z14System_WaitVbljj.constprop.0+0xe>
}
 6b6:	    rts

000006b8 <strlen>:
unsigned long strlen(const char* s) {
 6b8:	       movea.l 4(sp),a0
	unsigned long t=0;
 6bc:	       moveq #0,d0
	while(*s++)
 6be:	       tst.b (a0)
 6c0:	/----- beq.s 6ca <strlen+0x12>
		t++;
 6c2:	|  /-> addq.l #1,d0
	while(*s++)
 6c4:	|  |   tst.b (0,a0,d0.l)
 6c8:	|  \-- bne.s 6c2 <strlen+0xa>
}
 6ca:	\----> rts
