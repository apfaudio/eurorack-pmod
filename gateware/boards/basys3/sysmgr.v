`default_nettype none
module sysmgr (
    input  wire clk_in,     // 100 MHz Basys 3 oscillator
    input  wire rst_in,
    output wire clk_256fs,
    output wire rst_out
);

// MMCM: 100 MHz in -> 12 MHz out, fs = 46,875 Hz (matches iCEbreaker/ECPIX-5)
// D = 1, M = 9, O = 75, all plain integers, no fractional counter engaged.
// PFD = 100 MHz, VCO = 900 MHz: dead centre of the -1 speed grade's
// 600-1200 MHz window (DS181 Table 37), comfortably clear of the
// 10-450 MHz PFD ceiling too.
wire clk_256fs_unbuf;
wire clkfb;
wire locked;

`ifndef VERILATOR_LINT_ONLY
MMCME2_BASE #(
    .BANDWIDTH          ("OPTIMIZED"),
    .CLKIN1_PERIOD      (10.000),
    .CLKFBOUT_MULT_F    (9.000),
    .DIVCLK_DIVIDE      (1),
    .CLKOUT0_DIVIDE_F   (75.000),
    .CLKOUT0_DUTY_CYCLE (0.5),
    .STARTUP_WAIT       ("FALSE")
) mmcm_I (
    .CLKIN1   (clk_in),
    .CLKFBIN  (clkfb),
    .CLKFBOUT (clkfb),      // internal feedback: no BUFG in this loop
    .CLKOUT0  (clk_256fs_unbuf),
    .LOCKED   (locked),
    .PWRDWN   (1'b0),
    .RST      (rst_in)
);

BUFG clk_gbuf_I (
    .I(clk_256fs_unbuf),
    .O(clk_256fs)
);
`else
assign clk_256fs = clk_in;
assign locked = 1'b1;
`endif

// Power-on reset generator.
//
// DELIBERATELY does not use the MMCM's LOCKED output.
//
// Reason: LOCKED is a candidate for openXC7 emitting a primitive that
// builds and routes clean but misbehaves on silicon, which has already
// happened twice on this port (inferred tristate; ODDR/IDDR). If LOCKED
// never asserts, any reset gated on it holds the whole design down
// forever while MCLK still looks perfectly healthy on a scope.
//
// Instead this waits a fixed time that comfortably exceeds the worst-case
// lock time. Counter is 12 bits, so reset releases after 2048 cycles of
// clk_256fs = ~171 us at 12 MHz. MMCM_TLOCKMAX is 100 us (DS181 Table 37),
// and the counter cannot even start until clk_256fs is toggling, so the
// real margin is larger than that. Trades a slightly longer startup for
// not depending on a signal this toolchain may not wire up correctly.
//
// `locked` is left connected but unused so it stays visible in the netlist
// and can be probed or brought out to an LED without editing the MMCM.
/* verilator lint_off UNUSED */
wire locked_unused = locked;
/* verilator lint_on UNUSED */

logic [11:0] rst_cnt = 0;
assign rst_out = ~rst_cnt[11];
always_ff @(posedge clk_256fs) begin
    if (rst_in)
        rst_cnt <= 12'h0;
    else if (~rst_cnt[11])
        rst_cnt <= rst_cnt + 1;
end

endmodule
