`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.05.2021 04:14:11
// Design Name: 
// Module Name: poly_reduction
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module poly_reduction(
        input  wire        clk,
        input  wire [23:0] in_1,
        input  wire [23:0] in_2,
        input  wire  [1:0] poly_q,
        output wire [12:0] out
    );

    reg [23:0] in_1_reg, in_2_reg;
    always @(posedge clk) begin
        in_1_reg <= in_1;
        in_2_reg <= in_2;
    end

    // lift the result from [0, q-1] to [-(q-1)/2, (q-1)/2]  (and also reduce to Q = 4096)
    wire [12:0] in_1_lifted = in_1_reg - (in_1_reg > 24'd6293504 ? 24'd12587009 : 24'd0);
    wire [12:0] in_2_lifted = in_2_reg - (in_2_reg > 24'd6293504 ? 24'd12587009 : 24'd0);

    // reduce by X^n - 1
    wire [12:0] reduced = in_1_lifted + in_2_lifted;
    
    // chop off bits
    assign out = { reduced[12:11] & poly_q, reduced[10:0] };

endmodule
