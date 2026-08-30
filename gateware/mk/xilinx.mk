DEFINES = "$(ADD_DEFINES) -DXILINX -D$(HW_REV) -D$(TOUCH)"

all: $(BUILD)/$(PROJ).bit

$(BUILD)/%.json: %.sv $(ADD_SRC) $(ADD_DEPS)
	yosys -f "verilog -sv $(DEFINES)" -ql $(BUILD)/$*.log \
	-p 'synth_xilinx -nodsp -flatten -abc9 -arch xc7 -top top -json $@' $< $(ADD_SRC)

%.fasm: $(PIN_DEF) %.json
	nextpnr-xilinx \
	--chipdb $(CHIPDB) \
	--xdc $< \
	--json $(filter-out $<,$^) \
	--fasm $@

%.frames: %.fasm
	fasm2frames --part $(DEVICE) --db-root $(DB_ROOT) $< > $@

%.bit: %.frames
	xc7frames2bit \
	--part-file $(DB_ROOT)/$(DEVICE)/part.yaml \
	--part-name $(DEVICE) \
	--frm-file $< \
	--output-file $@

.SECONDARY:
.PHONY: all prog