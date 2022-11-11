module dist2freq_step_LUT #(parameter WIDTH=32, // Bit width of ROM data and output
                            ADDRESS_WIDTH=13
                )
    (input logic    clk,
                    enable,
     input logic [ADDRESS_WIDTH-1:0] address,
     output logic [WIDTH-1:0] freq_step 
    );

  logic [WIDTH-1:0] my_rom[2**ADDRESS_WIDTH-1:0]; // i.e. [data_width-1:0] my_rom[2**addr_width-1:0];
  
  initial begin 
    $readmemh("dist2freq_step_rom.txt",my_rom);
  end
    
  always @(posedge clk)
    if(enable)
        freq_step = my_rom[address];
endmodule