`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.04.2021 21:04:07
// Design Name: 
// Module Name: sub_mod
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


module add_mod(
        input  wire        clk,
        input  wire [23:0] a,
        input  wire [23:0] b,
        output wire [23:0] out
    );
    reg [24:0] sum;
    always @(posedge clk)
        sum <= a + b;
    assign out = sum - (sum >= 24'd12587009 ? 24'd12587009 : 23'd0);
endmodule
