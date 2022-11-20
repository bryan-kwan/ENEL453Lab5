`timescale 1ns/1ps
module CORDIC_tb();
    parameter   PW=12, // Phase width
                IW=6, // Input width (ie. i_xval, i_yval)
                OW=7, // Output width
                NSTAGES=31;
    parameter CLOCK_PERIOD = 20;
    
    logic clk = 1, enable=1;
    logic [IW-1:0] i_xval, i_yval;
    logic [PW-1:0] i_phase;
    logic [OW-1:0] o_xval, o_yval;

    // UUT

    CORDIC UUT(.clk(clk),.enable(enable),.i_xval(i_xval),.i_yval(i_yval),.i_phase(i_phase),.o_xval(o_xval),.o_yval(o_yval));

    always #(CLOCK_PERIOD/2) clk=~clk;
    // Stimulus
    initial begin
        $display("Start of testbench");
        $display("Testing sine generation, time=%t ps",$time);
        i_xval=31; i_yval=0; // Rotating (1,0), o_yval gives the sine function
        for(int i = 0; i<(2**PW); i+=1) begin
            $display("Applying phase = %h", i);
            i_phase = i; #((NSTAGES+4)*CLOCK_PERIOD);
        end
        // i_phase = 2**16;
        // #((NSTAGES)*CLOCK_PERIOD);
        $display("Finished testing sine generation, time=%t ps",$time);
        $display("End of testbench");
        $stop;
    end
    
endmodule