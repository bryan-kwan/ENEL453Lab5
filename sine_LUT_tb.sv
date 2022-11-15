
`timescale 1ns/1ps

module sine_LUT_tb();
	logic clk=0;
	logic enable;
    logic [31:0] phase;
    logic [7:0] sine;
	parameter CLOCK_PERIOD = 20;
	
	// Instantiate UUTs
	sine_LUT UUT(.clk(clk), .enable(enable),.phase(phase),.sine(sine));
	
	// Apply stimulus
	always #(CLOCK_PERIOD/2) clk = ~clk;
	initial begin 
		$display("---  Testbench started  ---");
		//Apply stimulus
        enable=1;
        for(int i = 0; i<256;i++) begin
            phase[31:25] = i; #(CLOCK_PERIOD);
        end
		$display("\n===  Testbench ended  ===");
		$stop;
	end
 endmodule