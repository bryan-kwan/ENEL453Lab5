// NCO design based on https://zipcpu.com/dsp/2017/12/09/nco.html

// Specs used in frequency step LUT (use the Python script to generate ROM file)
    // CLK_FREQ=50 000 000,
    // BASE_FREQ = CLK_FREQ / (N_SINE_VALUES*PWM_COUNT) // PWM_COUNT=1 for R-2R ladder
    // CARRIER_FREQ = 10 MHz,
    // LOW_FREQ =  9 MHz,
    // HIGH_FREQ = 11 MHz, 
    // MIN_DIST = 0,
    // MAX_DIST = 2000,

module FM_DAC
 #(int                      WIDTH = 13, // Bit width of distance
                            SINE_WIDTH=7, // Bit width of sine LUT data
                            PHASE_WIDTH=32, // Bit width of phase
                            PHASE_INTEGER_WIDTH=12, // Number of bits designated to an integer table index
                            COUNT_WIDTH=8
                            )
  (input  logic             reset_n,
                            clk,
                            enable,
   input  logic [WIDTH-1:0] distance,
   //output logic sine_pwm_out, // PWM signal if desired; uncomment 3 sections below
   output logic [SINE_WIDTH-1:0] sine_fm_out);
    logic [SINE_WIDTH-1:0]  sine_fm;
    logic [PHASE_WIDTH-1:0] phase, freq_step;
    // Uncomment for PWM --------------------------------
    //logic [COUNT_WIDTH-1:0] count_value;
    //logic zero; // PWM_DAC raises zero high at the start of its counting sequence
    //assign count_value = 2**COUNT_WIDTH-1; // f_base = ~391 kHz
    // --------------------------------
    assign sine_fm_out = sine_fm;
    
    // Lower level modules
    dist2freq_step_LUT dist2freq_step_LUT_ins(.clk(clk),.enable(enable),.address(distance),.freq_step(freq_step));
    sine_LUT sine_LUT_ins(.clk(clk),
        .enable(enable),
        .phase(phase), // LUT uses the PHASE_INTEGER_WIDTH most significant bits of phase
        .sine(sine_fm));
    
    // CORDIC
    // logic [30:0] i_xval = 31'h3fffffff; // Initial vector for CORDIC rotation
    // logic [30:0] i_yval = 31'h0;
    // logic [31:0] o_xval, o_yval;
    // assign sine_fm = o_yval[31:25];
    // CORDIC CORDIC_ins(.clk(clk),.enable(enable),
    //     .i_xval(i_xval),.i_yval(i_yval),
    //     .i_phase(phase[PHASE_WIDTH-1:PHASE_WIDTH-PHASE_INTEGER_WIDTH]),
    //     .o_xval(o_xval),.o_yval(o_yval));
    // ----
    // Uncomment for PWM --------------------------------
    // PWM_DAC #(.width(SINE_WIDTH),.COUNT_WIDTH(COUNT_WIDTH)) PWM_DAC_ins(.clk(clk),.reset_n(reset_n),.enable(enable),
    //     .duty_cycle(sine_fm),
    //     .count_value(count_value),.pwm_out(sine_pwm_out),.zero(zero));
    // -------------------------------

    always_ff @(posedge clk, negedge reset_n)
        if(!reset_n) begin 
            phase<='0;
        end
        else if (enable) begin
            // Phase accumulator

            // Uncomment for PWM (comment out below phase increment) --------------------------------
            // if(zero) // Increment phase every cycle of PWM_DAC
            //     phase <= phase + freq_step;
            // --------------------------------

            phase <= phase + freq_step;
        end

endmodule
