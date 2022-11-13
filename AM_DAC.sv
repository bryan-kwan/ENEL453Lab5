// Carrier frequency = 50 000 000 Hz / 128 = CLK_FREQ / MAX_COUNT_PWM_DAC = 390 kHz
// frequency_step_300kHz = 32'h0189374C

// Pipeline: overall delay of 2 cycles
// 0: mult
// 1: sine_am

module AM_DAC
 #(parameter                WIDTH = 13, // Bit width of distance
                            SINE_WIDTH=8, // Bit width of sine LUT data
                            PHASE_WIDTH=32, // Bit width of phase
                            COUNT_WIDTH=7,
                            LOG2_MAX_DIST=11, // Max distance of 2048
                            MAX_DIST=2**LOG2_MAX_DIST,
                            MULT_WIDTH=WIDTH+SINE_WIDTH,
                            RESULT_WIDTH=MULT_WIDTH-LOG2_MAX_DIST // result = distance * sine_value / MAX_DIST
                            )
  (input  logic             reset_n,
                            clk,
                            enable,
   input  logic [WIDTH-1:0] distance,
   output logic sine_pwm_out);
    logic [SINE_WIDTH-1:0]  sine_value;
    logic [RESULT_WIDTH-1:0] sine_am;
    logic [COUNT_WIDTH-1:0] count_value;
    logic [PHASE_WIDTH-1:0] phase, freq_step;
    logic zero; // PWM_DAC raises zero high at the start of its counting sequence
    logic [MULT_WIDTH-1:0] mult; // mult = distance * sine_value
    
    assign count_value = 127; // f_carrier = CLK_FREQ / (count_value+1) = ~390 kHz
    assign freq_step = 32'h0189374C; // 300 kHz

    // Lower level modules
    sine_LUT sine_LUT_ins(.clk(clk),
        .enable(zero), // Perform lookup at the start of every PWM_DAC cycle
        .phase(phase), // LUT uses the 7 most significant bits of phase
        .sine(sine_value));

    PWM_DAC #(.WIDTH(RESULT_WIDTH),.COUNT_WIDTH(COUNT_WIDTH)) PWM_DAC_ins(.clk(clk),.reset_n(reset_n),.enable(enable),
        .duty_cycle(sine_am),
        .count_value(count_value),.pwm_out(sine_pwm_out),.zero(zero));

    always_ff @(posedge clk, negedge reset_n)
        if(!reset_n) begin 
            phase<='0;
        end
        else if (enable) begin
            // AM multiplier
            mult <= distance*sine_value;
            sine_am <= mult[MULT_WIDTH-1:MULT_WIDTH-RESULT_WIDTH]; // Throw away the fractional bits
            // Phase accumulator
            if(zero) // Increment phase every cycle of PWM_DAC
                phase <= phase + freq_step;
        end

endmodule
