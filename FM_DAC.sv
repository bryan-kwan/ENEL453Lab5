// NCO design based on https://zipcpu.com/dsp/2017/12/09/nco.html

module FM_DAC
 #(int                      WIDTH = 13, // Bit width of distance
                            SINE_WIDTH=8, // Bit width of sine LUT data
                            PHASE_WIDTH=32, // Bit width of phase
                            // Specs used in frequency step LUT (use the Python script to generate ROM file)
                            // CLK_FREQ=50 000 000,
                            // BASE_FREQ = 300 000,
                            // LOW_FREQ =  290 000,
                            // HIGH_FREQ = 310 000, 
                            // MIN_DIST = 0,
                            // MAX_DIST = 2000,
                            )
  (input  logic             reset_n,
                            clk,
                            enable,
   input  logic [WIDTH-1:0] distance,
   output logic [SINE_WIDTH] sine_fm);

    logic [PHASE_WIDTH-1:0] phase, freq_step;

    // Lower level modules
    dist2freq_step_LUT dist2freq_step_LUT_ins(.clk(clk),.enable(enable),.address(distance),.freq_step(freq_step));
    sine_LUT sine_LUT_ins(.clk(clk),.enable(enable),.phase(phase),.sine(sine_fm));

    always_ff @(posedge clk, negedge reset_n)
        if(!reset_n) begin 
            sine_fm<='0;
            freq_step<='0;
        end
        else if (enable) begin
            // Phase accumulator
            phase <= phase + freq_step;
        end

endmodule
