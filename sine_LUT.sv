module sine_LUT #(parameter WIDTH=8, // Bit width of ROM data and output
                            PHASE_WIDTH=32
                )
    (input logic    clk,
                    enable,
     input logic [PHASE_WIDTH-1:0] phase,
     output logic signed [WIDTH-1:0] sine 
    );

  logic [WIDTH-1:0] my_rom[2**WIDTH-1:0]; // i.e. [data_width-1:0] my_rom[2**addr_width-1:0];
  
  initial begin 
    $readmemh("sine_rom.txt",my_rom);
  end
    
  always @(posedge clk)
    if(enable)
        sine = my_rom[phase[PHASE_WIDTH-1:PHASE_WIDTH-WIDTH]]; // Takes the top WIDTH bits as the ROM address
endmodule