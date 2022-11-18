
`timescale 1ns/1ps

module dist2freq_step_LUT_tb();
	logic clk=0;
	logic enable;
    logic [12:0] address;
    logic [31:0] freq_step;
	parameter CLOCK_PERIOD = 20;
	
	// Instantiate UUTs
	dist2freq_step_LUT UUT(.clk(clk), .enable(enable),.address(address),.freq_step(freq_step));
	
	// Apply stimulus
	always #(CLOCK_PERIOD/2) clk = ~clk;
	initial begin 
		$display("---  Testbench started  ---");
		//Apply stimulus
        enable=1;
        for(int i = 0; i<4096;i++) begin
            address = i; #(CLOCK_PERIOD);
        end
		$display("\n===  Testbench ended  ===");
		$stop;
	end
 endmodule