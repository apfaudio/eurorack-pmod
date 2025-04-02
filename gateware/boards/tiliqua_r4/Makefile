PROJ = top

DEVICE = 25k
PACKAGE = CABGA256
SPEEDGRADE = 7
PIN_DEF = ./boards/tiliqua_r4/pinmap.lpf
# UART: 115200 baud as RP2040 CDC converter assumes this.
ADD_DEFINES = -DSELECTED_DSP_CORE=$(CORE) -DINVERT_BUTTON=1 -DDEBUG_UART_CLKDIV=104

include ./mk/common.mk
include ./mk/ecp5.mk

ADD_SRC = boards/tiliqua_r2/sysmgr.v \
		  $(SRC_COMMON)

prog: $(BUILD)/$(PROJ).bin
	openFPGALoader -c dirtyJtag $(BUILD)/$(PROJ).bin
