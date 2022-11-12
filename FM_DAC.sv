// NCO design based on https://zipcpu.com/dsp/2017/12/09/nco.html

// Specs used in frequency step LUT (use the Python script to generate ROM file)
    // CLK_FREQ=50 000 000,
    // BASE_FREQ = 300 000,
    // LOW_FREQ =  290 000,
    // HIGH_FREQ = 310 000, 
    // MIN_DIST = 0,
    // MAX_DIST = 2000,
    // MAX_COUNT = 128,
    // f_sine = MAX_COUNT * f_target (MAX_COUNT gets divided out later by the PWM_DAC)

module FM_DAC
 #(int                      WIDTH = 13, // Bit width of distance
                            SINE_WIDTH=8, // Bit width of sine LUT data
                            PHASE_WIDTH=32, // Bit width of phase
                            COUNT_WIDTH=7 // Count of 128 so f_PWM = f_sine / 128
                            )
  (input  logic             reset_n,
                            clk,
                            enable,
   input  logic [WIDTH-1:0] distance,
   output logic sine_pwm_out);
    logic [SINE_WIDTH-1:0]  sine_fm;
    logic [COUNT_WIDTH-1:0] count_value;
    logic [PHASE_WIDTH-1:0] phase, freq_step;
    
    assign count_value=-1; // Maximum value

    // Lower level modules
    dist2freq_step_LUT dist2freq_step_LUT_ins(.clk(clk),.enable(enable),.address(distance),.freq_step(freq_step));
    sine_LUT sine_LUT_ins(.clk(clk),.enable(enable),
        .phase(phase), // LUT uses the most significant 8 bits of phase
        .sine(sine_fm));

    PWM_DAC #(.width(COUNT_WIDTH)) PWM_DAC_ins(.clk(clk),.reset_n(reset_n),.enable(enable),
        .duty_cycle(sine_fm[SINE_WIDTH-1:SINE_WIDTH-COUNT_WIDTH]), // Truncate the last bits to match width with count_value
        .count_value(count_value),.pwm_out(sine_pwm_out));

    always_ff @(posedge clk, negedge reset_n)
        if(!reset_n) begin 
            // sine_fm<='0;
            // freq_step<='0;
            phase<='0;
        end
        else if (enable) begin
            // Phase accumulator
            phase <= phase + freq_step;
        end

endmodule
