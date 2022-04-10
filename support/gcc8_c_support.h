#pragma once

#ifdef __cplusplus
	extern "C" {
#endif

#define offsetof(st, m) __builtin_offsetof(st, m)

// VSCode's IntelliSense doesn't know about 68000 registers, so suppress warnings
#ifndef __INTELLISENSE__
	#define ASM __asm
	#define REGS(...) __VA_ARGS__
#else
	#define ASM(...)
	#define REGS(...) "cc"
#endif

void *memcpy (void *, const void *, unsigned long);
void *memset (void *, int, unsigned long);
void *memmove (void *, const void *, unsigned long);
unsigned long strlen (const char *);

#define INCBIN(name, file) INCBIN_SECTION(name, file, ".rodata", "")
#define INCBIN_CHIP(name, file) INCBIN_SECTION(name, file, ".INCBIN.MEMF_CHIP", "aw")
#define INCBIN_SECTION(name, file, section, flags) \
	__asm__(".pushsection " #section ", " #flags "\n" \
			".global incbin_" #name "_start\n" \
			".type incbin_" #name "_start, @object\n" \
			".balign 2\n" \
			"incbin_" #name "_start:\n" \
			".incbin \"" file "\"\n" \
			\
			".global incbin_" #name "_end\n" \
			".type incbin_" #name "_end, @object\n" \
			".size incbin_" #name "_start, incbin_" #name "_end - incbin_" #name "_start\n" \
			".balign 1\n" \
			"incbin_" #name "_end:\n" \
			".byte 0\n" \
			".popsection\n" \
	); \
	extern const __attribute__((aligned(2))) char incbin_ ## name ## _start[1024*1024]; \
	extern const void* incbin_ ## name ## _end;\
	const void* name = &incbin_ ## name ## _start;

inline unsigned int muluw32(unsigned short a, unsigned short b) {
	unsigned int r = a;
	asm("muluw %1,%0":"+d"(r): "mid"(b): "cc");
	return r;
}
inline int mulsw32(short a, short b) {
	int r = a;
	asm("mulsw %1,%0":"+d"(r): "mid"(b): "cc");
	return r;
}
inline unsigned short muluw16(unsigned short a, unsigned short b) {
	asm("muluw %1,%0":"+d"(a): "mid"(b): "cc");
	return a;
}
inline short mulsw16(short a, short b) {
	asm("mulsw %1,%0":"+d"(a): "mid"(b): "cc");
	return a;
}
inline unsigned short divuw(unsigned int a, unsigned short b) {
	asm("divuw %1,%0":"+d"(a): "mid"(b): "cc");
	return a;
}
inline short divsw(int a, short b) {
	asm("divsw %1,%0":"+d"(a): "mid"(b): "cc");
	return a;
}
inline unsigned short divuwr(unsigned short* r, unsigned int a, unsigned short b) {
	asm("divuw %1,%0\n move.l %0,%2\n swap %2":"+d"(a): "mid"(b), "mid"(*r): "cc");
	return a;
}
inline short divswr(unsigned short* r, unsigned int a, unsigned short b) {
	asm("divsw %1,%0\n move.l %0,%2\n swap %2":"+d"(a): "mid"(b), "mid"(*r): "cc");
	return a;
}
inline unsigned short moduw(unsigned int a, unsigned short b) {
	asm("divuw %1,%0\n swap %0":"+d"(a): "mid"(b): "cc");
	return a;
}
inline short modsw(int a, short b) {
	asm("divsw %1,%0\n swap %0":"+d"(a): "mid"(b): "cc");
	return a;
}

#if defined(DEBUG)

void warpmode(int on); // bool on/off
void KPrintF(const char* fmt, ...); // output to debugger

// WinUAE debug overlay, coordinates are PAL-based (0,0)-(768,576)
void debug_clear();
void debug_rect(short left, short top, short right, short bottom, unsigned int color);
void debug_filled_rect(short left, short top, short right, short bottom, unsigned int color);
void debug_text(short left, short top, unsigned int color, const char* fmt, ...);

// profiler
void debug_start_idle();
void debug_stop_idle();

// Graphics debugger
enum debug_resource_flags {
	debug_resource_bitmap_interleaved = 1 << 0,
	debug_resource_bitmap_masked = 1 << 1,
	debug_resource_bitmap_ham = 1 << 2,
};

void debug_register_bitmap(const void* addr, const char* name, short width, short height, short numPlanes, unsigned short flags);
void debug_register_palette(const void* addr, const char* name, short numEntries, unsigned short flags);
void debug_register_copperlist(const void* addr, const char* name, unsigned int size, unsigned short flags);
void debug_unregister(const void* addr);

#else

#define warpmode(on)
#define KPrintF(fmt, ...)

#define debug_clear()
#define debug_rect(left, top, right, bottom, color)
#define debug_filled_rect(left, top, right, bottom, color)
#define debug_text(left, top, color, fmt, ...)

#define debug_start_idle()
#define debug_stop_idle()

#define debug_register_bitmap(addr, name, width, height, numPlanes, flags)
#define debug_register_palette(addr, name, numEntries, flags)
#define debug_register_copperlist(addr, name, size, flags)
#define debug_unregister(addr)

#endif

#ifdef __cplusplus
	} // extern "C"
#endif
