module sine_LUT #(parameter WIDTH=8, // Bit width of ROM data and output
                            ROM_WIDTH=32 // Bit width of the table (ie. log2 of the ROM file size)
                )
    (input logic clk,
     input logic [ROM_WIDTH-1:0] phase,
     output logic [WIDTH-1:0] sine
    );

  logic [WIDTH-1:0] my_rom[2**ROM_WIDTH-1:0]; // i.e. [data_width-1:0] my_rom[2**addr_width-1:0];
  
  initial begin // normally we don't use initial in RTL code, this is an exception
    $readmemh("sine_rom.txt",my_rom); // reads hexadecimal data from v2d_rom and places into my_rom
  end
    
  always @(posedge clk)
    sine = my_rom[phase];
endmodule