
// Actual duty cycle is duty_cycle / count_value * 100%
// unless duty_cycle > count_value in which case duty cycle is 100%
module PWM_DAC
 #(int                      WIDTH = 9, COUNT_WIDTH=9)
  (input  logic             reset_n,
                            clk,
                            enable,
   input  logic [WIDTH-1:0] duty_cycle, // Number of clock cycles pwm_out is 1
   input  logic [COUNT_WIDTH-1:0] count_value, // Maximum count value before resetting to 0
   output logic             pwm_out, 
                            zero); // zero signal goes high when count = 0
                                      
  int counter;//,duty_cycle_int,count_value_int;
  
  always_ff @(posedge clk, negedge reset_n) begin
    if (!reset_n)
      counter <= 0;     
    else if (enable)
      if (counter < count_value)
        counter++;
      else
        counter <= 0;
  end
  
  always_comb begin
    if(counter==0) zero=1;
    else zero=0;
    if (counter < duty_cycle)
      pwm_out = 1;
    else 
      pwm_out = 0;      
  end
  
endmodule
