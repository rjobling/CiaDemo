# to generate assembler listing with LTO, add to LDFLAGS: -Wa,-adhln=$@.listing,--listing-rhs-width=200
# for better annotations add -dA -dP
# to generate assembler source with LTO, add to LDFLAGS: -save-temps=cwd

OUT = ciademo

forward-to-backward = $(subst /,\,$1)

subdirs := $(wildcard */)
VPATH = $(subdirs)
cpp_sources := $(wildcard *.cpp) $(wildcard $(addsuffix *.cpp,$(subdirs)))
cpp_objects := $(addprefix obj/,$(patsubst %.cpp,%.o,$(notdir $(cpp_sources))))
c_sources := $(wildcard *.c) $(wildcard $(addsuffix *.c,$(subdirs)))
c_objects := $(addprefix obj/,$(patsubst %.c,%.o,$(notdir $(c_sources))))
s_sources := $(subst $(OUT).s,,$(wildcard *.s) $(wildcard $(addsuffix *.s,$(subdirs))))
s_objects := $(addprefix obj/,$(patsubst %.s,%.o,$(notdir $(s_sources))))
objects := $(cpp_objects) $(c_objects) $(s_objects)

# https://stackoverflow.com/questions/4036191/sources-from-subdirectories-in-makefile/4038459
# http://www.microhowto.info/howto/automatically_generate_makefile_dependencies.html

CC = m68k-amiga-elf-gcc

CCFLAGS = -g -MP -MMD -m68000 -Ofast -nostdlib	\
 -fdata-sections				\
 -ffunction-sections			\
 -flto							\
 -fno-exceptions				\
 -fno-tree-loop-distribution	\
 -fomit-frame-pointer			\
 -fwhole-program				\
 -pedantic-errors				\
 -Wall							\
 -Wdangling-else				\
 -Werror						\
 -Wextra						\
 -Wlogical-op					\
 -Wmisleading-indentation		\
 -Wno-unused-function			\
 -Wno-volatile-register-var		\
 -Wnull-dereference				\
 -Wpedantic						\
 -Wshadow						\
 -Wstrict-overflow=2			\
 -Wtrampolines					\
 -Wunsafe-loop-optimizations	\
 -D DEBUG						\
#-Og

CPPFLAGS = $(CCFLAGS) -fno-rtti -fno-use-cxa-atexit
ASFLAGS = -Wa,-g,--register-prefix-optional
LDFLAGS = -Wl,--gc-sections,--emit-relocs,-Ttext=0,-Map=$(OUT).map

all: $(OUT).exe

$(OUT).exe: $(OUT).elf
	$(info Elf2Hunk $(OUT).exe)
	@elf2hunk $(OUT).elf $(OUT).exe -s

$(OUT).elf: $(objects)
	$(info Linking $(OUT).elf)
	@$(CC) $(CCFLAGS) $(LDFLAGS) $(objects) -o $@
	@m68k-amiga-elf-objdump --disassemble --no-show-raw-ins --visualize-jumps -S $@ >$(OUT).s

clean:
	$(info Cleaning...)
	@del /q obj $(OUT).* 2>nul || rmdir obj 2>nul || ver>nul

-include $(objects:.o=.d)

$(cpp_objects) : obj/%.o : %.cpp
	@if not exist "$(call forward-to-backward,$(dir $@))" mkdir $(call forward-to-backward,$(dir $@))
	$(info Compiling $<)
	@$(CC) $(CPPFLAGS) -c -o $@ $(CURDIR)/$<

$(c_objects) : obj/%.o : %.c
	@if not exist "$(call forward-to-backward,$(dir $@))" mkdir $(call forward-to-backward,$(dir $@))
	$(info Compiling $<)
	@$(CC) $(CCFLAGS) -c -o $@ $(CURDIR)/$<

$(s_objects): obj/%.o : %.s
	$(info Assembling $<)
	@$(CC) $(CCFLAGS) $(ASFLAGS) -c -o $@ $(CURDIR)/$<
