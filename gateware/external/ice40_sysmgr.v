
/*
 * sysmgr.v
 *
 * vim: ts=4 sw=4
 *
 * Mostly lifted from smunaut's 'ice40-playground'.
 *
 * Copyright (C) 2019  Sylvain Munaut <tnt@246tNt.com>
 * All rights reserved.
 *
 * BSD 3-clause, see LICENSE.bsd
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the <organization> nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

`default_nettype none

module ice40_sysmgr (
	input  wire clk_in,
	input  wire rst_in,
	output wire clk_2x_out,
	output wire clk_1x_out,
	output wire rst_out
);

	// Signals
	wire pll_lock;
	wire pll_reset_n;

	wire clk_2x_i;
	wire clk_1x_i;
	wire rst_i;
	reg [7:0] rst_cnt;

	// PLL instance
`ifdef SIM
	reg toggle = 1'b0;

	initial
		rst_cnt <= 8'h80;

	always @(posedge clk_in)
		toggle <= ~toggle;

	assign clk_1x_i = toggle;
	assign clk_2x_i = clk_in;
	assign pll_lock = pll_reset_n;
`else
`ifndef VERILATOR_LINT_ONLY
	SB_PLL40_2F_PAD #(
		.DIVR(4'b0000),
		.DIVF(7'b0111111),
		.DIVQ(3'b101),
		.FILTER_RANGE(3'b001),
		.FEEDBACK_PATH("SIMPLE"),
		.DELAY_ADJUSTMENT_MODE_FEEDBACK("FIXED"),
		.FDA_FEEDBACK(4'b0000),
		.SHIFTREG_DIV_MODE(2'b00),
		.PLLOUT_SELECT_PORTA("GENCLK"),
		.PLLOUT_SELECT_PORTB("GENCLK_HALF"),
	) pll_I (
		.PACKAGEPIN(clk_in),
		.PLLOUTGLOBALA(clk_2x_i),
		.PLLOUTGLOBALB(clk_1x_i),
		.EXTFEEDBACK(1'b0),
		.DYNAMICDELAY(8'h00),
		.RESETB(pll_reset_n),
		.BYPASS(1'b0),
		.LATCHINPUTVALUE(1'b0),
		.LOCK(pll_lock),
		.SDI(1'b0),
		.SDO(),
		.SCLK(1'b0)
	);
`endif
`endif

	assign clk_2x_out = clk_2x_i;
	assign clk_1x_out = clk_1x_i;

	// PLL reset generation
	assign pll_reset_n = ~rst_in;

	// Logic reset generation
	always @(posedge clk_1x_i or negedge pll_lock)
		if (!pll_lock)
			rst_cnt <= 8'h80;
		else if (rst_cnt[7])
			rst_cnt <= rst_cnt + 1;

	assign rst_i = rst_cnt[7];

`ifndef VERILATOR_LINT_ONLY
	SB_GB rst_gbuf_I (
		.USER_SIGNAL_TO_GLOBAL_BUFFER(rst_i),
		.GLOBAL_BUFFER_OUTPUT(rst_out)
	);
`endif

endmodule // sysmgr
