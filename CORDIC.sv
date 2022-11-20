// CORDIC design based on https://zipcpu.com/dsp/2017/08/30/cordic.html
// Rotation matrix / algorithm:
// T(2^-k) = | 1        -2^-k |
//           | 2^-k     1     |
// 
// x_k+1 = x_k - y*2**-k
// y_k+1 = x_k*2**-k + y_k
//
// Rotation scheme: 
// Pre-rotate such that the remaining phase is between -45 and 45 deg
// 0-45 deg and 315-360 deg no change, rotation matrix works fine
// 45-90 deg and 90-135 deg, rotate 90 deg CCW
// 135-180 deg and 180-225 deg, rotate 180 deg
// 225-270 deg and 270-315 deg, rotate 270 deg CCW
// Then perform the CORDIC rotation

// Gain = 1.65, so rotating (1/1.65, 0) yields cosine and sine 
// Eliminate the gain by multiplying by 32'h_9B74EF47 then shifting 32 bits right

module CORDIC #(parameter   PW=12, // Phase width
                            IW=31, // Input width (ie. i_xval, i_yval)
                            OW=32, // Output width (word grows by 1 bit due to gain)
                            NSTAGES=11
                )
    (input logic clk, enable,
    input logic signed [IW-1:0] i_xval, i_yval, // Input vector
    input logic signed [PW-1:0] i_phase, // Requested rotation
    output logic signed [OW-1:0] o_xval, o_yval
    );

    // Constants ----
    logic [PW-1:0] ph_90deg = 12'b 0100_0000_0000; // 1/4 of a rotation
    logic [PW-1:0] angle_table [0:NSTAGES-1];
    // angle_table generated with COREGEN.py
    assign angle_table[00] = 12'h200;
    assign angle_table[01] = 12'h12E;
    assign angle_table[02] = 12'h09F;
    assign angle_table[03] = 12'h051;
    assign angle_table[04] = 12'h028;
    assign angle_table[05] = 12'h014;
    assign angle_table[06] = 12'h00A;
    assign angle_table[07] = 12'h005;
    assign angle_table[08] = 12'h002;
    assign angle_table[09] = 12'h001;
    assign angle_table[10] = 12'h000;
    // ----

    // Registers ----
    logic signed [OW-1:0] X [0:NSTAGES-1];
    logic signed [OW-1:0] Y [0:NSTAGES-1];
    logic signed [PW-1:0] P [0:NSTAGES-1]; // Phase
    // ----

    // Output
    assign o_xval = X[NSTAGES-1];
    assign o_yval = Y[NSTAGES-1];
    // ----

    // Pre-rotation processing ----
    always_ff @(posedge clk) begin
        if(enable) begin
            case (i_phase[PW-1:PW-3]) // Top three bits of phase (divides unit circle into 8 sections)
                3'b000: begin // 0-45 deg, keep the same
                    X[0] <= i_xval;
                    Y[0] <= i_yval;
                    P[0] <= i_phase;
                end
                3'b001: begin // 45-90 deg, rotate 90 deg CCW
                    X[0] <= -i_yval;
                    Y[0] <= i_xval;
                    P[0] <= i_phase - ph_90deg;
                end
                3'b010: begin // 90-135 deg, rotate 90 deg CCW
                    X[0] <= -i_yval;
                    Y[0] <= i_xval;
                    P[0] <= i_phase - ph_90deg;
                end
                3'b011: begin // 135-180 deg, rotate 180 deg
                    X[0] <= -i_xval;
                    Y[0] <= -i_yval;
                    P[0] <= i_phase - (2 * ph_90deg);
                end
                3'b100: begin // 180-225 deg, rotate 180 deg
                    X[0] <= -i_xval;
                    Y[0] <= -i_yval;
                    P[0] <= i_phase - (2 * ph_90deg);
                end
                3'b101: begin // 225-270 deg, rotate 270 deg CCW
                    X[0] <= i_yval;
                    Y[0] <= -i_xval;
                    P[0] <= i_phase - (3*ph_90deg);
                end
                3'b110: begin // 270-315 deg, rotate 270 deg CCW
                    X[0] <= i_yval;
                    Y[0] <= -i_xval;
                    P[0] <= i_phase - (3*ph_90deg);
                end
                3'b111: begin // 315-360 deg, keep the same
                    X[0] <= i_xval;
                    Y[0] <= i_yval;
                    P[0] <= i_phase;
                end
                default: begin
                    X[0] <= i_xval;
                    Y[0] <= i_yval;
                    P[0] <= i_phase;
                end
            endcase
        end
    end
    // ----

    // CORDIC rotation matrix
    genvar k;
    generate
        // x_k+1 = x_k - y*2**-k
        // y_k+1 = x_k*2**-k + y_k
        for(k=0; k<(NSTAGES-1); k++) begin : STAGES
            always_ff @(posedge clk) begin
                if(enable) begin
                    if(P[k][PW-1]) begin // If the first bit = 1, P[k]<0 so rotate CW ie. T(-2^-k)
                        X[k+1] <= X[k]              + (Y[k] >>> k); // Signed shift right
                        Y[k+1] <= -(X[k] >>> k)     + Y[k];
                        P[k+1] <= P[k]              + angle_table[k];
                    end 
                    else begin // Positive angle, CCW rotation ie. T(2^-k)
                        X[k+1] <= X[k]             - (Y[k] >>> k);
                        Y[k+1] <= (X[k]>>>k)       + Y[k];
                        P[k+1] <= P[k]             - angle_table[k];
                    end
                end
                
            end
        end 
    endgenerate
    // ----
endmodule