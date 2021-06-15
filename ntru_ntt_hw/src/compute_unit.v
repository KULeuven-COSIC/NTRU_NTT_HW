`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.05.2021 03:50:36
// Design Name: 
// Module Name: compute_unit
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


module compute_unit(
    input  wire        clk,
    input  wire        resetn,
    input  wire [23:0] in_a,
    input  wire [23:0] in_b,
    input  wire [23:0] in_w,
    input  wire        forward, // combined butterfly: true for CT butterfly, false for GS.
    input  wire        reg_forward,
    input  wire        forward_delayed,
    input  wire        index_poly,
    input  wire        point_mul,
    input  wire        reduction_delayed,
    input  wire [23:0] reduction_other_a_delayed,
    input  wire [23:0] reduction_other_b_delayed,
    input  wire        reduction_sel_delayed,
    output wire [12:0] reduction_out,
    input  wire  [1:0] poly_q,
    output reg  [23:0] out_a,
    output reg  [23:0] out_b
    );
    

    wire [23:0] a_add_b;
    wire [23:0] a_sub_b;
    add_mod add_reverse(
        .clk(clk),
        .a(in_a),
        .b(in_b),
        .out(a_add_b)
    );
            
    sub_mod sub_reverse(
        .clk(clk),
        .a(in_a),
        .b(in_b),
        .out(a_sub_b)
    );
    
    localparam MUL_DELAY = 11; // cycles for multiplier in butterfly
    reg [24*(MUL_DELAY-1)-1:0] regs_in_a;
    reg                 [23:0] reg_in_b;
    reg                 [23:0] reg_in_w;
    always @(posedge clk) begin
        regs_in_a <= { regs_in_a, forward ? in_a : a_add_b};
        reg_in_b <= in_b;
        reg_in_w <= in_w;
    end
    wire [23:0] in_a_delayed = regs_in_a[24*(MUL_DELAY-1)-1:24*(MUL_DELAY-2)];

    wire [23:0] out_a_forward;
    wire [23:0] out_b_forward;
    always @(posedge clk) begin
        out_a <= forward_delayed ? out_a_forward : in_a_delayed;
        out_b <= forward_delayed ? out_b_forward : mul_out;
    end
            

    wire [23:0] mul_out;
    mul_mod mul(
        .clk(clk),
        .resetn(resetn),
        .a(point_mul ? regs_in_a[23:0] : reg_forward ? in_b : a_sub_b),
        .b(point_mul ? reg_in_b : reg_forward ? in_w : reg_in_w),
        .out(mul_out)
    );

    // also used as add_reverse_2 in the last layer of reverse ntt for the second input set
    add_mod add_forward(
        .clk(clk),
        .a(reduction_delayed ? reduction_other_a_delayed : in_a_delayed),
        .b(reduction_delayed ? reduction_other_b_delayed : mul_out),
        .out(out_a_forward)
    );
            
    sub_mod sub_forward(
        .clk(clk),
        .a(in_a_delayed),
        .b(mul_out),
        .out(out_b_forward)
    );

    poly_reduction poly_reduction(
        .clk(clk),
        .in_1(reduction_sel_delayed ? mul_out : in_a_delayed),
        .in_2(out_a_forward),
        .poly_q(poly_q),
        .out(reduction_out)
    );
    
endmodule