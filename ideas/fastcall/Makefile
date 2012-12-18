# Makefile description.
# basic build file for mrbcc executable

# project-specific macros
# extension of the executable-file is modifiable(.exe .out ...)
export CC = gcc
export LL = gcc
export AR = ar

BASEDIR = ../../mruby/src
BUILDDIR = .
TARGET := ./mrbcc_out
LIBR := ../../mruby/lib/libmruby.a
ifeq ($(OS),Windows_NT)
EXE := $(TARGET).exe
else
EXE := $(TARGET)
endif
OBJ0 := $(patsubst %.c,%.o,$(BUILDDIR)/mrbcc_out.c)
OBJS := $(OBJ0)

# libraries, includes
LIBS = -lm
INCLUDES = -I$(BASEDIR) -I$(BASEDIR)/../include

# compiler, linker (gcc)
ifeq ($(strip $(COMPILE_MODE)),)
  # default compile option
  COMPILE_MODE = debug
endif

ifeq ($(COMPILE_MODE),debug)
  CFLAGS = -g -O0
else ifeq ($(COMPILE_MODE),release)
  CFLAGS = -O0
else ifeq ($(COMPILE_MODE),small)
  CFLAGS = -Os
endif

ALL_CFLAGS = -Wall -Werror-implicit-function-declaration $(CFLAGS)
ifeq ($(OS),Windows_NT)
  MAKE_FLAGS = CC=$(CC) LL=$(LL) ALL_CFLAGS="$(ALL_CFLAGS)"
else
  MAKE_FLAGS = CC='$(CC)' LL='$(LL)' ALL_CFLAGS='$(ALL_CFLAGS)'
endif

##############################
# generic build targets, rules

.PHONY : all
all : $(LIBR) $(EXE)

# executable constructed using linker from object files
$(EXE) : $(LIBR) $(OBJS) $(EXTS)
	$(LL) -o $@ $(CFLAGS) $(OBJS) $(LIBR) $(LIBS)

-include $(OBJS:.o=.d)

# objects compiled from source
$(OBJS) : %.o : %.c
	$(CC) $(ALL_CFLAGS) -MMD $(INCLUDES) -c $< -o $@

# C library compile
$(LIBR) :
	@$(MAKE) -C $(BASEDIR) $(MAKE_FLAGS)

# clean up
.PHONY : clean #cleandep
clean :
	$(MAKE) clean -C ../../mruby/mrblib $(MAKE_FLAGS)
	@echo "make: removing targets, objects and depend files of `pwd`"
	rm -f $(EXE) $(OBJS)
	rm -f $(OBJS:.o=.d)
