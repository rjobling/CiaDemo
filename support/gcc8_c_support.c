#include "gcc8_c_support.h"
#include <proto/exec.h>
extern struct ExecBase* SysBase;

unsigned long strlen(const char* s) {
	unsigned long t=0;
	while(*s++)
		t++;
	return t;
}

__attribute__((optimize("no-tree-loop-distribute-patterns")))
	void* memset(void *dest, int val, unsigned long len) {
	unsigned char *ptr = (unsigned char *)dest;
	while(len-- > 0)
		*ptr++ = val;
	return dest;
}

__attribute__((optimize("no-tree-loop-distribute-patterns")))
void* memcpy(void *dest, const void *src, unsigned long len) {
	char *d = (char *)dest;
	const char *s = (const char *)src;
	while(len--)
		*d++ = *s++;
	return dest;
}

__attribute__((optimize("no-tree-loop-distribute-patterns")))
void* memmove(void *dest, const void *src, unsigned long len) {
	char *d = dest;
	const char *s = src;
	if (d < s) {
		while (len--)
			*d++ = *s++;
	} else {
		const char *lasts = s + (len - 1);
		char *lastd = d + (len - 1);
		while (len--)
			*lastd-- = *lasts--;
	}
	return dest;
}

int main();

extern void (*__preinit_array_start[])() __attribute__((weak));
extern void (*__preinit_array_end[])() __attribute__((weak));
extern void (*__init_array_start[])() __attribute__((weak));
extern void (*__init_array_end[])() __attribute__((weak));
extern void (*__fini_array_start[])() __attribute__((weak));
extern void (*__fini_array_end[])() __attribute__((weak));

__attribute__((used)) __attribute__((section(".text.unlikely")))
void _start() {
	// initialize globals, ctors etc.
	unsigned long count;
	unsigned long i;

	count = __preinit_array_end - __preinit_array_start;
	for (i = 0; i < count; i++)
		__preinit_array_start[i]();

	count = __init_array_end - __init_array_start;
	for (i = 0; i < count; i++)
		__init_array_start[i]();

	main();

	// call dtors
	count = __fini_array_end - __fini_array_start;
	for (i = count; i > 0; i--)
		__fini_array_start[i - 1]();
}

#if defined(DEBUG)

// vbcc
typedef unsigned char *va_list;
#define va_start(ap, lastarg) ((ap)=(va_list)(&lastarg+1))

void KPutCharX();
void PutChar();

__attribute__((noipa))
void KPrintF(const char* fmt, ...) {
	va_list vl;
	va_start(vl, fmt);
	union { long(*func)(long mode, const char* string); ULONG ulong; UWORD* puword; } UaeDbgLog;
	UaeDbgLog.ulong = 0xf0ff60;
	if(*UaeDbgLog.puword == 0x4eb9 || *UaeDbgLog.puword == 0xa00e) {
		char temp[128];
		RawDoFmt((CONST_STRPTR)fmt, vl, PutChar, temp);
		UaeDbgLog.func(86, temp);
	} else {
		RawDoFmt((CONST_STRPTR)fmt, vl, KPutCharX, 0);
	}
}

void warpmode(int on) { // bool
	union { long(*func)(long mode, int index, const char* param, int param_len, char* outbuf, int outbuf_len); ULONG ulong; UWORD* puword; } UaeConf;
	UaeConf.ulong = 0xf0ff60;
	if(*UaeConf.puword == 0x4eb9 || *UaeConf.puword == 0xa00e) {
		char outbuf;
		UaeConf.func(82, -1, on ? "warp true" : "warp false", 0, &outbuf, 1);
		UaeConf.func(82, -1, on ? "cpu_speed max" : "cpu_speed real", 0, &outbuf, 1);
		UaeConf.func(82, -1, on ? "cpu_cycle_exact false" : "cpu_cycle_exact true", 0, &outbuf, 1);
		UaeConf.func(82, -1, on ? "cpu_memory_cycle_exact false" : "cpu_memory_cycle_exact true", 0, &outbuf, 1);
		UaeConf.func(82, -1, on ? "blitter_cycle_exact false" : "blitter_cycle_exact true", 0, &outbuf, 1);
	}
}

static void debug_cmd(unsigned int arg1, unsigned int arg2, unsigned int arg3, unsigned int arg4) {
	union { long(*func)(unsigned int arg0, unsigned int arg1, unsigned int arg2, unsigned int arg3, unsigned int arg4); ULONG ulong; UWORD* puword; } UaeLib;
	UaeLib.ulong = 0xf0ff60;
	if(*UaeLib.puword == 0x4eb9 || *UaeLib.puword == 0xa00e) {
		UaeLib.func(88, arg1, arg2, arg3, arg4);
	}
}

enum barto_cmd {
	barto_cmd_clear,
	barto_cmd_rect,
	barto_cmd_filled_rect,
	barto_cmd_text,
	barto_cmd_register_resource,
	barto_cmd_set_idle,
	barto_cmd_unregister_resource,
};

enum debug_resource_type {
	debug_resource_type_bitmap,
	debug_resource_type_palette,
	debug_resource_type_copperlist,
};

struct debug_resource {
	unsigned int address; // can't use void* because WinUAE is 64-bit
	unsigned int size;
	char name[32];
	unsigned short /*enum debug_resource_type*/ type;
	unsigned short /*enum debug_resource_flags*/ flags;

	union {
		struct bitmap {
			short width;
			short height;
			short numPlanes;
		} bitmap;
		struct palette {
			short numEntries;
		} palette;
	};
};

// debug overlay
void debug_clear() {
	debug_cmd(barto_cmd_clear, 0, 0, 0);
}

void debug_rect(short left, short top, short right, short bottom, unsigned int color) {
	debug_cmd(barto_cmd_rect, (((unsigned int)left) << 16) | ((unsigned int)top), (((unsigned int)right) << 16) | ((unsigned int)bottom), color);
}

void debug_filled_rect(short left, short top, short right, short bottom, unsigned int color) {
	debug_cmd(barto_cmd_filled_rect, (((unsigned int)left) << 16) | ((unsigned int)top), (((unsigned int)right) << 16) | ((unsigned int)bottom), color);
}

__attribute__((noipa))
void debug_text(short left, short top, unsigned int color, const char* fmt, ...) {
	va_list vl;
	va_start(vl, fmt);
	char temp[128];
	RawDoFmt((CONST_STRPTR)fmt, vl, PutChar, temp);
	debug_cmd(barto_cmd_text, (((unsigned int)left) << 16) | ((unsigned int)top), (unsigned int)temp, color);
}

// profiler
void debug_start_idle() {
	debug_cmd(barto_cmd_set_idle, 1, 0, 0);
}

void debug_stop_idle() {
	debug_cmd(barto_cmd_set_idle, 0, 0, 0);
}

// gfx debugger
static void my_strncpy(char* destination, const char* source, unsigned long num) {
	while(*source && --num > 0)
		*destination++ = *source++;
	*destination = '\0';
}

void debug_register_bitmap(const void* addr, const char* name, short width, short height, short numPlanes, unsigned short flags) {
	struct debug_resource resource = {
		.address = (unsigned int)addr,
		.size = mulsw32(width >> 3, mulsw16(height, numPlanes)),
		.type = debug_resource_type_bitmap,
		.flags = flags,
		.bitmap = { width, height, numPlanes }
	};

	if (flags & debug_resource_bitmap_masked)
		resource.size <<= 1;

	my_strncpy(resource.name, name, sizeof(resource.name));
	debug_cmd(barto_cmd_register_resource, (unsigned int)&resource, 0, 0);
}

void debug_register_palette(const void* addr, const char* name, short numEntries, unsigned short flags) {
	struct debug_resource resource = {
		.address = (unsigned int)addr,
		.size = numEntries << 1,
		.type = debug_resource_type_palette,
		.flags = flags,
		.palette = { numEntries }
	};
	my_strncpy(resource.name, name, sizeof(resource.name));
	debug_cmd(barto_cmd_register_resource, (unsigned int)&resource, 0, 0);
}

void debug_register_copperlist(const void* addr, const char* name, unsigned int size, unsigned short flags) {
	struct debug_resource resource = {
		.address = (unsigned int)addr,
		.size = size,
		.type = debug_resource_type_copperlist,
		.flags = flags,
	};
	my_strncpy(resource.name, name, sizeof(resource.name));
	debug_cmd(barto_cmd_register_resource, (unsigned int)&resource, 0, 0);
}

void debug_unregister(const void* addr) {
	debug_cmd(barto_cmd_unregister_resource, (unsigned int)addr, 0, 0);
}

#endif