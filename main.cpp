////////////////////////////////////////////////////////////////////////////////
// main.cpp
////////////////////////////////////////////////////////////////////////////////

#include <hardware/cia.h>
#include <hardware/custom.h>
#include <hardware/intbits.h>
#include "core.h"
#include "system.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
#define TEST_A_TIMER
#define TEST_B_TIMER
#define TEST_ALARM

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
static const u16 kATimerCount = 3000;
static const u16 kBTimerCount = 3500;
static const u32 kAlarmCount = 90;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
static const int kColorCount = 70;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
static bool sToggle = false;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
__attribute__((interrupt))
static void Irq6Handler()
{
	u8 pending = ciab.ciaicr;

	custom.intreq = INTF_EXTER;

	#if defined(TEST_A_TIMER)
	if (pending & CIAICRF_TA)
	{
		custom.color[0] = 0x0f0;
		custom.color[0] = 0x000;
	}
	#endif

	#if defined(TEST_B_TIMER)
	if (pending & CIAICRF_TB)
	{
		custom.color[0] = 0x00f;
		custom.color[0] = 0x000;
	}
	#endif

	#if defined(TEST_ALARM)
	if (pending & CIAICRF_ALRM)
	{
		if (!sToggle)
		{
			custom.color[0] = 0xff0;
			custom.color[0] = 0x000;
			ciab.ciatodhi  = (kAlarmCount - 1) >> 16;
			ciab.ciatodmid = (kAlarmCount - 1) >> 8;
			ciab.ciatodlow = (kAlarmCount - 1);

			sToggle = true;

			asm("stop #0x2500\n");
		}
		else
		{
			custom.color[0] = 0xf00;
			custom.color[0] = 0x000;

			sToggle = false;
		}
	}
	#endif
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
static bool Init()
{
	System_WaitVbl();

	System_SetIrq6Handler(Irq6Handler);

	#if defined(TEST_A_TIMER)
	ciab.ciacra = CIACRAF_RUNMODE;
	ciab.ciaicr = CIAICRF_SETCLR | CIAICRF_TA;
	ciab.ciatalo = kATimerCount & 255;
	#endif

	#if defined(TEST_B_TIMER)
	ciab.ciacrb = CIACRAF_RUNMODE;
	ciab.ciaicr = CIAICRF_SETCLR | CIAICRF_TB;
	ciab.ciatblo = kBTimerCount & 255;
	#endif

	#if defined(TEST_ALARM)
	ciab.ciaicr = CIAICRF_SETCLR | CIAICRF_ALRM;
	ciab.ciacrb |= CIACRBF_ALARM;
	ciab.ciatodhi  = kAlarmCount >> 16;
	ciab.ciatodmid = kAlarmCount >> 8;
	ciab.ciatodlow = kAlarmCount;
	ciab.ciacrb &= ~CIACRBF_ALARM;
	#endif

	// Wait for the top of the frame before starting.
	System_WaitVbl();

	// Enable the exter interrupts when still nearly at the top of the frame.
	custom.intena = INTF_SETCLR | INTF_INTEN | INTF_EXTER;

	return true;
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
static void Deinit()
{
	custom.intena = INTF_EXTER;

	System_WaitVbl();

	System_SetIrq6Handler(nullptr);
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
static void Update()
{
	System_WaitVbl();

	#if defined(TEST_A_TIMER)
	ciab.ciatahi = kATimerCount >> 8;
	#endif

	#if defined(TEST_B_TIMER)
	ciab.ciatbhi = kBTimerCount >> 8;
	#endif

	#if defined(TEST_ALARM)
	ciab.ciatodhi  = 0;
	ciab.ciatodmid = 0;
	ciab.ciatodlow = 0;
	#endif
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
int main()
{
	if (System_Init())
	{
		if (Init())
		{
			while (!System_TestLMB())
			{
				Update();
			}

			Deinit();
		}

		System_Deinit();
	}
}
