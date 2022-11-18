// Carrier frequency = 50 000 000 Hz / 128 = CLK_FREQ / MAX_COUNT_PWM_DAC = 390 kHz
// frequency_step_300kHz = 32'h0189374C

// Pipeline: overall delay of 2 cycles
// 0: mult
// 1: sine_am

module AM_DAC
 #(parameter                WIDTH = 13, // Bit width of distance
                            SINE_WIDTH=7, // Bit width of sine LUT data
                            PHASE_WIDTH=32, // Bit width of phase
                            PHASE_INTEGER_WIDTH=12,
                            LOG2_MAX_DIST=11, // Max distance of 2048
                            MAX_DIST=2**LOG2_MAX_DIST,
                            MULT_WIDTH=LOG2_MAX_DIST+SINE_WIDTH, 
                            RESULT_WIDTH=MULT_WIDTH-LOG2_MAX_DIST // result = distance * sine_value / MAX_DIST
                            )
  (input  logic             reset_n,
                            clk,
                            enable,
   input  logic [WIDTH-1:0] distance,
   output logic sine_pwm_out,
   output logic [SINE_WIDTH-1:0] sine_am_out);
    logic [SINE_WIDTH-1:0]  sine_value;
    logic [RESULT_WIDTH-1:0] sine_am;
    logic [PHASE_WIDTH-1:0] phase, freq_step;
    logic [MULT_WIDTH-1:0] mult; // mult = distance * sine_value
    
    assign count_value = -1;
    assign freq_step = 32'h33333333; // 10 MHz
    assign sine_am_out = sine_am[6:0];

    // Lower level modules
    sine_LUT sine_LUT_ins(.clk(clk),
        .enable(enable), 
        .phase(phase), // LUT uses the PHASE_INTEGER_WIDTH most significant bits of phase
        .sine(sine_value));

    // PWM_DAC #(.width(RESULT_WIDTH),.COUNT_WIDTH(COUNT_WIDTH)) PWM_DAC_ins(.clk(clk),.reset_n(reset_n),.enable(enable),
    //     .duty_cycle(sine_am),
    //     .count_value(count_value),.pwm_out(sine_pwm_out),.zero(zero));

    always_ff @(posedge clk, negedge reset_n)
        if(!reset_n) begin 
            phase<='0;
        end
        else if (enable) begin
            // AM multiplier
            if(distance<MAX_DIST) begin
                mult <= distance*sine_value;
                sine_am <= mult[MULT_WIDTH-1:MULT_WIDTH-SINE_WIDTH]; // Throw away the fractional bits
            end
            else
                sine_am <= sine_value; // Maximum value for unsigned logic
            // Phase accumulator
            // Uncomment for PWM --------------------------------
            // if(zero) // Increment phase every cycle of PWM_DAC
            //     phase <= phase + freq_step;
            // --------------------------------

            phase <= phase + freq_step;
        end

endmodule
