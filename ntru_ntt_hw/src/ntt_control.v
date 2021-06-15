`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.04.2021 04:38:43
// Design Name: 
// Module Name: ntt_control
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


module ntt_control(
        input  wire        clk,
        input  wire        step,
        input  wire        start,
        input  wire        poly_large_n, // activate 11th bit, difference between size 1024 and size 2048 NTT
        output reg         forward, // combined control logic: true for CT butterfly, false for GS.
        output reg         forward_first_layer,
        output wire        first_layer_first_half,
        output wire        first_layer_first_part,
        input  wire  [8:0] first_layer_stop_at, // for early stop during first layer on forward operation
        output wire        last_layer,
        output wire        point_mul,
        output wire [10:0] index_a,
        output wire [10:0] index_b,
        output wire [10:0] index_w,
        output wire        done
    );
    
    reg  [10:0] counterT;
    reg  [10:0] counterJ;
    reg  [10:0] counterW;
    reg         first_part;
    wire        first_layer_skip_reached = forward_first_layer && counterW[2] && !first_part;
    wire [10:0] counterJIncr = first_layer_skip_reached ? 11'd0 : counterJ + 1;
    wire [10:0] counterJNext = (counterJIncr + (counterJIncr & counterT)) & (poly_large_n ? 11'd2047 : 11'd1023);
    assign      point_mul = counterT == 11'd0;

    always @(posedge clk) begin
        if (start) begin
            forward <= 1'b1;
            counterJ <= 11'b0;
            counterT <= poly_large_n ? 11'd512 : 11'd256; // skip the first layer during forward operation
            counterW <= 11'd3; // skip first two layers during forward operation, they are addressed externally
            forward_first_layer <= 1'b1;
            first_part <= 1'b1;
        end else if (step) begin
            if (done && forward) begin
                counterT <= 11'b1;
                forward <= 1'b0;
            end else if (!done)
                counterT <= counterJNext ? counterT : ((forward ? counterT >> 1 : counterT << 1) & (poly_large_n ? 11'd2047 : 11'd1023));

            forward_first_layer <= forward_first_layer && counterJNext;
            counterJ <= counterJNext;
            counterW <= counterW + (counterJIncr & counterT ? 11'd1 : 11'd0);
            first_part <= (counterJNext & ~(forward_first_layer ? (poly_large_n ? 11'd1024 : 11'd512) : 11'd0)) < first_layer_stop_at;
        end 
    end
    
    // on forward pass, do one extra counting iteration over the whole list for pointmul
    assign done = point_mul && (!forward || !counterJNext);
    assign last_layer = (counterT == (forward ? 11'd1 : (poly_large_n ? 11'd1024 : 11'd512))) && !done;
    wire [10:0] counterJ_corrected = counterJ & ~(forward_first_layer ? (poly_large_n ? 11'd1024 : 11'd512) : 11'd0);
    assign first_layer_first_half = forward_first_layer && !(poly_large_n ? counterJ[10] : counterJ[9]);
    assign first_layer_first_part = first_layer_first_half && first_part;
    assign index_a = counterJ_corrected;
    assign index_b = counterJ_corrected + counterT;
    assign index_w = counterW;
    
endmodule
