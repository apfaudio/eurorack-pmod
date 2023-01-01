// VCO tuned to 1V/Oct.
//
// Mapping:
// - Input 0: V/Oct input, C3 is +3V
// - Output 0: VCO output (from wavetable)

module vco (
    input clk, // 12Mhz
    input sample_clk,
    input signed [15:0] sample_in0,
    input signed [15:0] sample_in1,
    input signed [15:0] sample_in2,
    input signed [15:0] sample_in3,
    output signed [15:0] sample_out0,
    output signed [15:0] sample_out1,
    output signed [15:0] sample_out2,
    output signed [15:0] sample_out3
);

// Look up table mapping from volts to frequency.
// Table indices are (mV*4) >> 6 (so correct index is just sample >> 6.
// Table values are amount to increment wavetable position, assuming
// wavetable position is N.F bits, where N is index into wavetable, and
// F matches frac_bits_delta in LUT generation script.
reg [15:0] v_oct_lut [0:511];
initial $readmemh("vco/v_oct_lut.hex", v_oct_lut);

reg [15:0] wavetable [0:255];
initial $readmemh("vco/wavetable.hex", wavetable);

// For < 0V input, clamp to bottom note.
wire signed [15:0] lut_index = sample_in0 >>> 6;
wire [9:0] lut_index_clamped = lut_index < 0 ? 0 : lut_index;

reg [31:0] wavetable_pos = 16'h0;
always @(posedge sample_clk) begin
    // TODO: linear interpolation between frequencies, silence oscillator
    // whenever we are outside the LUT bounds.
    wavetable_pos <= wavetable_pos + v_oct_lut[lut_index_clamped];
end

// Top 8 bits of the N.F representation are index into wavetable.
wire [7:0] wavetable_idx = wavetable_pos[17:10];
assign sample_out0 = wavetable[wavetable_idx];

endmodule