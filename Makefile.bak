BOARD    := ice40_generic
CABLE    := ft232
BINDIR   := Bin-to-flash
LOADER   := openFPGALoaderWSL.bat
BINFILE  := $(firstword $(wildcard $(BINDIR)/*.bin))

.DEFAULT_GOAL := load
.PHONY: load flash detect

load:
	$(LOADER) -b $(BOARD) -c $(CABLE) $(BINFILE)

flash:
	$(LOADER) -b $(BOARD) -c $(CABLE) -f $(BINFILE)

detect:
	$(LOADER) -b $(BOARD) -c $(CABLE) --detect

