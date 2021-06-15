`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.06.2021 03:57:41
// Design Name: 
// Module Name: fifo
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


module fifo(
  input  wire        clk,
  input  wire        resetn,
  input  wire [12:0] in,
  input  wire        in_valid,
  output wire [12:0] out,
  input  wire        out_ready,
  output wire        out_valid,
  output wire        out_last
);
    
	reg  [12:0] fifo [15:0];
    reg   [3:0] rd_ptr;
    reg   [3:0] wt_ptr;
    wire  [3:0] rd_ptr_incr = rd_ptr + 1;

    always @(posedge clk)
        if (resetn) begin
            rd_ptr <= 4'd0;
            wt_ptr <= 4'd0;
        end else begin
            if (in_valid) begin
                fifo[wt_ptr] <= in;
                wt_ptr <= wt_ptr + 1;
            end
            if (out_ready && out_valid) begin
                rd_ptr <= rd_ptr_incr;
            end
        end

    assign out = fifo[rd_ptr];
    assign out_valid = rd_ptr != wt_ptr;
    assign out_last = rd_ptr_incr == wt_ptr;

endmodule
