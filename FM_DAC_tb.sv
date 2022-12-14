`timescale 1ns/1ps
module FM_DAC_tb();
    parameter               WIDTH = 13, // Bit width of distance
                            SINE_WIDTH=8, // Bit width of sine LUT data
                            PHASE_WIDTH=32, // Bit width of phase
                            MAX_DIST=2000;
    parameter CLOCK_PERIOD = 20;
    
    logic clk = 1, reset_n = 1, enable=1;
    logic [WIDTH-1:0] distance;
    logic sine_pwm_out;
    logic [6:0] sine_fm_out;
    int max_cycles = 128; // MAX_COUNT
    // UUT
    FM_DAC UUT(.distance(distance),.reset_n(reset_n),.clk(clk),.enable(enable),
    //.sine_pwm_out(sine_pwm_out)
    .sine_fm_out(sine_fm_out));

    always #(CLOCK_PERIOD/2) clk=~clk;
    // Stimulus
    initial begin
        $display("Start of testbench");
        $display("Testing sine_pwm_out period, time=%t ps",$time);
        // Reset
        reset_n = 1; #(CLOCK_PERIOD);
        reset_n = 0; #(CLOCK_PERIOD);
        for(int i = 0; i<1.1*MAX_DIST; i+=500) begin
            $display("Applying distance = %d", i);
            distance = i; #(CLOCK_PERIOD);
            reset_n = 1; #(max_cycles*max_cycles*CLOCK_PERIOD);
            reset_n = 0; #(CLOCK_PERIOD);
        end

        $display("Finished testing sine_pwm_out period, time=%t ps",$time);
        $display("End of testbench");
        $stop;
    end
    
endmodule