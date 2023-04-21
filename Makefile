################################################################################
# These are variables for the GBA toolchain build
# You can add others if you wish to
# ***** Long Lam *****
################################################################################

# TA-TODO: Put your application name here.
# This should be a just a name i.e MyFirstGBAProgram
# No SPACES AFTER THE NAME.
PROGNAME = App

# TA-TODO: Add the C files you want compiled here (replace extension with .o)
# Here you must put a list of all of the object files
# that will be compiled into your program. For example
# if you have main.c and myLib.c then in the following
# line you would put main.o and myLib.o
OFILES = gba.o font.o main.o images/zombie.o images/plant.o images/garden.o images/startScreen.o

################################################################################
# These are various settings used to make the GBA toolchain work
# DO NOT EDIT BELOW.
################################################################################

.PHONY: all
all: CFLAGS += $(CRELEASE) -I../shared
all: LDFLAGS += $(LDRELEASE)
all: $(PROGNAME).gba
	@echo "[FINISH] Created $(PROGNAME).gba"

include /opt/cs2110-tools/GBAVariables.mak

LDFLAGS += --specs=nosys.specs

# Adjust default compiler warnings and errors
CFLAGS += -Wstrict-prototypes -Wold-style-definition -Werror=vla

.PHONY: debug
debug: CFLAGS += $(CDEBUG) -I../shared
debug: LDFLAGS += $(LDDEBUG)
debug: $(PROGNAME).gba
	@echo "[FINISH] Created $(PROGNAME).gba"

$(PROGNAME).gba: $(PROGNAME).elf
	@echo "[LINK] Linking objects together to create $(PROGNAME).gba"
	@$(OBJCOPY) -O binary $(PROGNAME).elf $(PROGNAME).gba

$(PROGNAME).elf: crt0.o $(GCCLIB)/crtbegin.o $(GCCLIB)/crtend.o $(GCCLIB)/crti.o $(GCCLIB)/crtn.o $(OFILES) libc_sbrk.o
	$(CC) -o $(PROGNAME).elf $^ $(LDFLAGS)

.PHONY: release
release: CFLAGS += $(CRELEASE) -I../shared
release: LDFLAGS += $(LDRELEASE)
release: $(PROGNAME).gba
	@echo "Built $(PROGNAME).gba with release flags"

.PHONY: mgba
mgba: debug
	@echo "[EXECUTE] Running emulator mGBA"
	@echo "          Please see emulator.log if this fails"
	@mgba-qt $(PROGNAME).gba

.PHONY: gdb
gdb: debug
	@echo "[EXECUTE] Running Emulator MGBA with GDB"
	@echo "          Please see emulator.log if this fails"
	@mgba-qt $(PROGNAME).gba --gdb &
	# To give mgba some time to initialize and start up the GDB server.
	@sleep 0.5
	@gdb-multiarch -ex 'file $(PROGNAME).elf' -ex 'target remote 127.0.0.1:2345'

.PHONY: submit
submit: clean
	@rm -f submission.tar.gz
	@tar czvf submission.tar.gz *

.PHONY: clean
clean:
	@echo "[CLEAN] Removing all compiled files"
	rm -f *.o *.elf *.gba *.log */*.o *.sav
