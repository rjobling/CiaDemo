////////////////////////////////////////////////////////////////////////////////
// system.cpp
////////////////////////////////////////////////////////////////////////////////

#include "system.h"
#include <exec/execbase.h>
#include <graphics/gfxbase.h>
#include <hardware/adkbits.h>
#include <hardware/cia.h>
#include <hardware/custom.h>
#include <hardware/dmabits.h>
#include <hardware/intbits.h>
#include <proto/dos.h>
#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/mathffp.h>

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
volatile Custom& custom = *((Custom*) 0xdff000);
volatile CIA& ciaa = *((CIA*) 0xbfe001);
volatile CIA& ciab = *((CIA*) 0xbfd000);

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
#if !defined(LDOS)
struct ExecBase* SysBase;
struct DosLibrary* DOSBase;
struct GfxBase* GfxBase;
struct IntuitionBase* IntuitionBase;
struct Library* MathBase;
#endif

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
static const char* sError;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
#if !defined(LDOS)
static volatile void* sVBR;
#endif

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
#if !defined(LDOS)
static bool sSavedWorkbench;
static View* sSavedActiView;
static u16 sSavedADKCON;
static u16 sSavedDMACON;
static u16 sSavedINTENA;
static u8 sSavedCIAAICR;
static u8 sSavedCIAACRA;
static u8 sSavedCIAACRB;
static u8 sSavedCIABICR;
static u8 sSavedCIABCRA;
static u8 sSavedCIABCRB;
static System_IrqFunc* sSavedIrq1Handler;
static System_IrqFunc* sSavedIrq2Handler;
static System_IrqFunc* sSavedIrq3Handler;
static System_IrqFunc* sSavedIrq6Handler;
#endif

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
bool System_Init()
{
	sError = nullptr;

	#if !defined(LDOS)

	#pragma GCC diagnostic push
	#pragma GCC diagnostic ignored "-Warray-bounds"
	SysBase = *((struct ExecBase**) 4);
	#pragma GCC diagnostic pop

	sVBR = 0;
	if (SysBase->AttnFlags & AFF_68010)
	{
		u16 getvbr[] = {0x4e7a, 0x0801, 0x4e73}; // movec.l vbr,d0 rte
		sVBR = (volatile void*) Supervisor((ULONG (*)()) getvbr);
	}

	DOSBase = (struct DosLibrary*) OpenLibrary((CONST_STRPTR) "dos.library", 0);
	if (DOSBase == nullptr)
	{
		return false;
	}

	GfxBase = (struct GfxBase*) OpenLibrary((CONST_STRPTR) "graphics.library", 0);
	if (GfxBase == nullptr)
	{
		CloseLibrary((Library*) DOSBase);

		return false;
	}

	IntuitionBase = (struct IntuitionBase*) OpenLibrary((CONST_STRPTR) "intuition.library", 0);
	if (IntuitionBase == nullptr)
	{
		CloseLibrary((Library*) GfxBase);
		CloseLibrary((Library*) DOSBase);

		return false;
	}

	MathBase = OpenLibrary("mathffp.library", 0);
	if (MathBase == nullptr)
	{
		CloseLibrary((Library*) IntuitionBase);
		CloseLibrary((Library*) GfxBase);
		CloseLibrary((Library*) DOSBase);

		return false;
	}

	sSavedWorkbench = CloseWorkBench();

	OwnBlitter();
	WaitBlit();

	Forbid();

	sSavedActiView = GfxBase->ActiView;

	LoadView(nullptr);
	WaitTOF();
	WaitTOF();

	Disable();

	// Save current interrupt and DMA settings.
	sSavedADKCON = custom.adkconr;
	sSavedDMACON = custom.dmaconr;
	sSavedINTENA = custom.intenar;

	// Disable all interrupts.
	custom.intena = (u16) ~INTF_SETCLR;

	// Clear all pending interrupts.
	custom.intreq = (u16) ~INTF_SETCLR;

	// Clear all DMA channels.
	custom.dmacon = (u16) ~DMAF_SETCLR;

	// Disable all CIA interrupts.
	ciaa.ciaicr = (u8) ~CIAICRF_SETCLR;
	ciab.ciaicr = (u8) ~CIAICRF_SETCLR;

	// Save current CIA interrupts, which clears any pending.
	sSavedCIAAICR = ciaa.ciaicr;
	sSavedCIABICR = ciab.ciaicr;

	// Save current CIA controls.
	sSavedCIAACRA = ciaa.ciacra;
	sSavedCIAACRB = ciaa.ciacrb;
	sSavedCIABCRA = ciab.ciacra;
	sSavedCIABCRB = ciab.ciacrb;

	// Clear CIA Alarm count.
	ciab.ciacrb = CIACRBF_ALARM;
	ciab.ciatodhi = 0;
	ciab.ciatodmid = 0;
	ciab.ciatodlow = 0;

	// Clear all CIA controls.
	ciaa.ciacra = 0;
	ciaa.ciacrb = 0;
	ciab.ciacra = 0;
	ciab.ciacrb = 0;

	// Clear CIA TOD count.
	ciab.ciatodhi = 0;
	ciab.ciatodmid = 0;
	ciab.ciatodlow = 0;

	// Pause CIA TOD count.
	ciab.ciatodhi = 0;

	// Set all colors to black.
	for (int i = 0; i < countof(custom.color); i++)
	{
		custom.color[i] = 0x000;
	}

	System_WaitVbl();
	System_WaitVbl();

	// Make sure toggle is set to long frame.
	custom.vposw = 0x8000;

	// Save current interrupt handlers.
	sSavedIrq1Handler = System_GetIrq1Handler();
	sSavedIrq2Handler = System_GetIrq2Handler();
	sSavedIrq3Handler = System_GetIrq3Handler();
	sSavedIrq6Handler = System_GetIrq6Handler();

	System_WaitVbl();

	#endif

	return true;
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void System_Deinit()
{
	#if !defined(LDOS)

	System_WaitVbl();
	System_WaitBlt();

	// Disable all CIA interrupts.
	ciaa.ciaicr = (u8) ~CIAICRF_SETCLR;
	ciab.ciaicr = (u8) ~CIAICRF_SETCLR;

	// Clear all pending CIA interrupts.
	u8 pending;
	pending = ciaa.ciaicr;
	pending = ciab.ciaicr;
	unused(pending);

	// Disable all interrupts.
	custom.intena = (u16) ~INTF_SETCLR;

	// Clear all pending interrupts.
	custom.intreq = (u16) ~INTF_SETCLR;

	// Clear all DMA channels.
	custom.dmacon = (u16) ~DMAF_SETCLR;

	// Restore interrupt handlers.
	System_SetIrq1Handler(sSavedIrq1Handler);
	System_SetIrq2Handler(sSavedIrq2Handler);
	System_SetIrq3Handler(sSavedIrq3Handler);
	System_SetIrq6Handler(sSavedIrq6Handler);

	// Restore copper lists.
	custom.cop1lc = (u32) GfxBase->copinit;
	custom.cop2lc = (u32) GfxBase->LOFlist;
	custom.copjmp1 = 0;

	// Restore interrupts and DMA settings.
	custom.adkcon = ADKF_SETCLR | sSavedADKCON;
	custom.dmacon = DMAF_SETCLR | sSavedDMACON;
	custom.intena = INTF_SETCLR | sSavedINTENA;

	// Restore CIA timer settings.
	ciaa.ciacra = sSavedCIAACRA;
	ciaa.ciacrb = sSavedCIAACRB;
	ciab.ciacra = sSavedCIABCRA;
	ciab.ciacrb = sSavedCIABCRB;

	// Restore CIA interrupts.
	ciaa.ciaicr = sSavedCIAAICR;
	ciab.ciaicr = sSavedCIABICR;

	// Enable CIAA interrupts for keyboard inputs.
	ciaa.ciaicr = CIAICRF_SETCLR | CIAICRF_SP;

	Enable();

	LoadView(sSavedActiView);
	WaitTOF();
	WaitTOF();

	Permit();

	WaitBlit();
	DisownBlitter();

	if (sSavedWorkbench)
	{
		OpenWorkBench();
	}

	if (sError != nullptr)
	{
		Write(Output(), (APTR) sError, strlen(sError) + 1);
	}

	CloseLibrary((Library*) MathBase);
	CloseLibrary((Library*) IntuitionBase);
	CloseLibrary((Library*) GfxBase);
	CloseLibrary((Library*) DOSBase);

	#else

	if (sError != nullptr)
	{
		LDOS_Assert(sError);
	}

	#endif
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void System_SetError(const char* error)
{
	sError = error;
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
bool System_IsAGA()
{
	return (custom.vposr & 0x0100);
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
System_IrqFunc* System_GetIrq1Handler()
{
	#if !defined(LDOS)
	return *((System_IrqFunc**) (((u8*) sVBR) + 0x64));
	#else
	return *((System_IrqFunc**) 0x64);
	#endif
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
System_IrqFunc* System_GetIrq2Handler()
{
	#if !defined(LDOS)
	return *((System_IrqFunc**) (((u8*) sVBR) + 0x68));
	#else
	return *((System_IrqFunc**) 0x68);
	#endif
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
System_IrqFunc* System_GetIrq3Handler()
{
	#if !defined(LDOS)
	return *((System_IrqFunc**) (((u8*) sVBR) + 0x6c));
	#else
	return *((System_IrqFunc**) 0x6c);
	#endif
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
System_IrqFunc* System_GetIrq6Handler()
{
	#if !defined(LDOS)
	return *((System_IrqFunc**) (((u8*) sVBR) + 0x78));
	#else
	return *((System_IrqFunc**) 0x78);
	#endif
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void System_SetIrq1Handler(System_IrqFunc* func)
{
	#if !defined(LDOS)
	*((System_IrqFunc**) (((u8*) sVBR) + 0x64)) = func;
	#else
	*((System_IrqFunc**) 0x64) = func;
	#endif
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void System_SetIrq2Handler(System_IrqFunc* func)
{
	#if !defined(LDOS)
	*((System_IrqFunc**) (((u8*) sVBR) + 0x68)) = func;
	#else
	*((System_IrqFunc**) 0x68) = func;
	#endif
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void System_SetIrq3Handler(System_IrqFunc* func)
{
	#if !defined(LDOS)
	*((System_IrqFunc**) (((u8*) sVBR) + 0x6c)) = func;
	#else
	*((System_IrqFunc**) 0x6c) = func;
	#endif
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void System_SetIrq6Handler(System_IrqFunc* func)
{
	#if !defined(LDOS)
	*((System_IrqFunc**) (((u8*) sVBR) + 0x78)) = func;
	#else
	*((System_IrqFunc**) 0x78) = func;
	#endif
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void System_WaitVbl(u32 vend, u32 mask)
{
	while ((custom.vpos32 & mask) == vend) {}
	while ((custom.vpos32 & mask) != vend) {}
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void System_WaitBlt()
{
	u16 test = custom.dmaconr; // For compatiblity with A1000.
	unused(test);

	while (custom.dmaconr & DMAF_BLTDONE) {}
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
bool System_TestLMB()
{
	return !(ciaa.ciapra & CIAF_GAMEPORT0);
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
bool System_TestRMB()
{
	return !(custom.potinp & (1 << 10));
}
