////////////////////////////////////////////////////////////////////////////////
// system.h
////////////////////////////////////////////////////////////////////////////////

#pragma once

#include "core.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
struct Custom;
struct CIA;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
typedef void (System_IrqFunc)();

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
extern volatile Custom& custom;
extern volatile CIA& ciaa;
extern volatile CIA& ciab;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
bool System_Init();
void System_Deinit();

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void System_SetError(const char* error);

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
bool System_IsAGA();

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
System_IrqFunc* System_GetIrq1Handler();
System_IrqFunc* System_GetIrq2Handler();
System_IrqFunc* System_GetIrq3Handler();
System_IrqFunc* System_GetIrq6Handler();
void System_SetIrq1Handler(System_IrqFunc* func);
void System_SetIrq2Handler(System_IrqFunc* func);
void System_SetIrq3Handler(System_IrqFunc* func);
void System_SetIrq6Handler(System_IrqFunc* func);

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void System_WaitVbl(u32 vend = 0x00000, u32 mask = 0x1ff00);
void System_WaitBlt();

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
bool System_TestLMB();
bool System_TestRMB();