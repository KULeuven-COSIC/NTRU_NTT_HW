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


// module add_mod_d(
//         input  wire        clk,
//         input  wire [22:0] a,
//         input  wire [22:0] b,
//         output reg  [22:0] out
//     );

//     wire [22:0] ab;
//     add_mod adder_a_b(
//         .a(a),
//         .b(b),
//         .out(ab)
//     );

//     always @(posedge clk)
//         out <= ab;

// endmodule


// module add_4_mod_d(
//         input  wire        clk,
//         input  wire [22:0] a,
//         input  wire [22:0] b,
//         input  wire [22:0] c,
//         input  wire [22:0] d,
//         output wire [22:0] out
//     );

//     wire [22:0] ab;
//     add_mod_d adder_a_b(
//         .clk(clk),
//         .a(a),
//         .b(b),
//         .out(ab)
//     );
//     wire [22:0] cd;
//     add_mod_d adder_c_d(
//         .clk(clk),
//         .a(c),
//         .b(d),
//         .out(cd)
//     );
//     add_mod_d adder_a_d(
//         .clk(clk),
//         .a(ab),
//         .b(cd),
//         .out(out)
//     );
// endmodule


// 10 cycle mul_mod
module mul_mod(
        input  wire        clk,
        input  wire        resetn,
        input  wire [23:0] a,
        input  wire [23:0] b,
        output reg  [23:0] out
    );


    reg  [23:0] a_reg, b_reg;
    always @(posedge clk) begin
        a_reg <= a;
        b_reg <= b;
    end

    wire [47:0] mul;
    mul_24b_3c mul_ab (
        .CLK(clk),
        .A(a_reg),
        .B(b_reg),
        .P(mul)
    );
    
    localparam XRN_DELAY = 5;
    reg [48*XRN_DELAY-1:0] regs_mul;
    always @(posedge clk)
        regs_mul = { regs_mul, mul };
    wire [47:0] mul_delayed = regs_mul[48*XRN_DELAY-1:48*(XRN_DELAY-1)];

    wire [23:0] xr;
    
    mul_22362340_upper_3c mul_xr(
        .CLK(clk),
        .A(mul),
        .P(xr)
    );
    wire [24:0] xrn;
    mul_12587009_2c mul_t(
        .CLK(clk),
        .A(xr),
        .P(xrn)
    );
    wire [24:0] t = mul_delayed - xrn;
    
    always @(posedge clk)
        out <= t >= 24'd12587009 ? t - 24'd12587009 : t;
        
    // https://www.nayuki.io/page/barrett-reduction-algorithm

    wire [47:0] refmul = a * b;
    wire [23:0] ref = refmul % 24'd12587009;
    


    // wire [23:0] xr = mul * 25'd9586979;
    // wire [23:0] t = mul - xr * 23'd7340033;

    // assign out = t >= 23'd7340033 ? t - 23'd7340033;

    // // 6 cycle multiplier for testing purposes
    // reg [22:0] reg_a, reg_b;
    // reg [45:0] mul2;
    // reg [45:0] tmp1;
    // reg [45:0] tmp2;
    // reg [45:0] tmp3;
    // reg [22:0] out2;
    // // reg [32:0] red;
    // always @(posedge clk) begin
    //     // reg_a <= a;
    //     // reg_b <= b;
    //     // mul2 <= reg_a * reg_b;
    //     // tmp1 <= mul2;
    //     // tmp2 <= tmp1;
    //     // tmp3 <= tmp2;
    //     // // red <= mul % 33'd7516193792;
    //     // out2 <= tmp3 % 23'd7340033;

    //     out <= mul % 23'd7340033;
    // end


// module mul_mod(
//         input  wire        clk,
//         input  wire [22:0] a,
//         input  wire [22:0] b,
//         output reg  [22:0] out
//     );
    

//     // 6 cycle multiplier for testing purposes
//     wire [45:0] mul;
    
//     mult_23b_5c mult (
//         .CLK(clk),
//         .A(a),
//         .B(b),
//         .P(mul)
//     );
//         // 6 cycle multiplier for testing purposes
//     reg [22:0] reg_a, reg_b, outref;
//     reg [45:0] mul2;
//     reg [45:0] tmp1;
//     reg [45:0] tmp2;
//     reg [45:0] tmp3;
//     // reg [32:0] red;
//     always @(posedge clk) begin
//         reg_a <= a;
//         reg_b <= b;
//         mul2 <= reg_a * reg_b;
//         tmp1 <= mul2;
//         tmp2 <= tmp1;
//         tmp3 <= tmp2;
//         // red <= mul % 33'd7516193792;
//         out <= tmp3 % 23'd7340033;

//         outref <= mul % 23'd7340033;
//     end

    // wire [24:0] xr = mul * 25'd33489007;
    // wire [24:0] t = mul - xr * 23'd2101249;

    // assign out = t >= 23'd2101249 ? t - 23'd2101249;


    // wire [22:0] x = mul[22:0] * 23'd2101247;
    // wire [45:0] c = mul + x * 23'd2101249;
    // assign out = c[45:23];

    // reg  [22:0] reg_a;
    // reg  [22:0] reg_b;
    // always @(posedge clk) begin
    //     reg_a <= a;
    //     reg_b <= b;
    // end
    // wire [22:0] add_1_2;
    // add_mod_d adder_1_2(
    //     .clk(clk),
    //     .a((reg_a <<  1) * reg_b[ 1]),
    //     .b((reg_a <<  2) * reg_b[ 2]),
    //     .out(add_1_2)
    // );
    // wire [22:0] add_0_2;
    // reg  [22:0] reg_a_0;
    // always @(posedge clk)
    //     reg_a_0 <= reg_a * reg_b[ 0];
    // add_mod_d adder_0_2(
    //     .clk(clk),
    //     .a(reg_a_0),
    //     .b(add_1_2),
    //     .out(add_0_2)
    // );
    // wire [22:0] add_3_6;
    // add_4_mod_d adder_3_6(
    //     .clk(clk),
    //     .a((reg_a <<  3) * reg_b[ 3]),
    //     .b((reg_a <<  4) * reg_b[ 4]),
    //     .c((reg_a <<  5) * reg_b[ 5]),
    //     .d((reg_a <<  6) * reg_b[ 6]),
    //     .out(add_3_6)
    // );
    // wire [22:0] add_0_6;
    // reg  [22:0] reg_add_0_6;
    // always @(posedge clk)
    //     reg_add_0_6 <= add_0_6;
    // add_mod_d adder_0_6(
    //     .clk(clk),
    //     .a(add_0_2),
    //     .b(add_3_6),
    //     .out(add_0_6)
    // );

    // wire [22:0] add_7_10;
    // add_4_mod_d adder_7_10(
    //     .clk(clk),
    //     .a((reg_a <<  7) * reg_b[ 7]),
    //     .b((reg_a <<  8) * reg_b[ 8]),
    //     .c((reg_a <<  9) * reg_b[ 9]),
    //     .d((reg_a << 10) * reg_b[10]),
    //     .out(add_7_10)
    // );
    // wire [22:0] add_11_14;
    // add_4_mod_d adder_11_14(
    //     .clk(clk),
    //     .a((reg_a << 11) * reg_b[11]),
    //     .b((reg_a << 12) * reg_b[12]),
    //     .c((reg_a << 13) * reg_b[13]),
    //     .d((reg_a << 14) * reg_b[14]),
    //     .out(add_11_14)
    // );
    // wire [22:0] add_15_18;
    // add_4_mod_d adder_15_18(
    //     .clk(clk),
    //     .a((reg_a << 15) * reg_b[15]),
    //     .b((reg_a << 16) * reg_b[16]),
    //     .c((reg_a << 17) * reg_b[17]),
    //     .d((reg_a << 18) * reg_b[18]),
    //     .out(add_15_18)
    // );
    // wire [22:0] add_19_22;
    // add_4_mod_d adder_19_22(
    //     .clk(clk),
    //     .a((reg_a << 19) * reg_b[19]),
    //     .b((reg_a << 20) * reg_b[20]),
    //     .c((reg_a << 21) * reg_b[21]),
    //     .d((reg_a << 22) * reg_b[22]),
    //     .out(add_19_22)
    // );

    // wire [22:0] add_7_22;
    // add_4_mod_d adder_7_22(
    //     .clk(clk),
    //     .a(add_7_10),
    //     .b(add_11_14),
    //     .c(add_15_18),
    //     .d(add_19_22),
    //     .out(add_7_22)
    // );

    // add_mod_d adder_0_22(
    //     .clk(clk),
    //     .a(reg_add_0_6),
    //     .b(add_7_22),
    //     .out(out)
    // );

endmodule
