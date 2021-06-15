`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.04.2021 20:23:17
// Design Name: 
// Module Name: ntru_polymul
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


module ntru_polymul(
        input  wire        clk,
        input  wire        resetn,

        input  wire [31:0] S_AXIS_MM2S_tdata,
        input  wire        S_AXIS_MM2S_tvalid,
        output wire        S_AXIS_MM2S_tready,

        output wire [31:0] M_AXIS_MM2S_tdata,
        output wire        M_AXIS_MM2S_tvalid,
        input  wire        M_AXIS_MM2S_tready,
        output wire        M_AXIS_MM2S_tlast,
        
        input  wire  [9:0] poly_n,
        input  wire  [1:0] poly_q
    );
    
    wire [11:0] addr_w;
    wire [23:0] read_w;
	wire [11:0] addr_a_1;
	wire [23:0] write_a_1;
	wire        en_a_1;
	wire        we_a_1;
	wire [23:0] read_a_1;
	wire [11:0] addr_b_1;
	wire [23:0] write_b_1;
	wire        en_b_1;
	wire        we_b_1;
	wire [23:0] read_b_1;
	wire [11:0] addr_a_2;
	wire [23:0] write_a_2;
	wire        en_a_2;
	wire        we_a_2;
	wire [23:0] read_a_2;
	wire [11:0] addr_b_2;
	wire [23:0] write_b_2;
	wire        en_b_2;
	wire        we_b_2;
	wire [23:0] read_b_2;
    
    double_dual_port_ram ram (
        .clk(clk),

	    .addr_a_1(addr_a_1),
	    .write_a_1(write_a_1),
	    .en_a_1(en_a_1),
	    .we_a_1(we_a_1),
	    .read_a_1(read_a_1),

	    .addr_b_1(addr_b_1),
	    .write_b_1(write_b_1),
	    .en_b_1(en_b_1),
	    .we_b_1(we_b_1),
	    .read_b_1(read_b_1),

	    .addr_a_2(addr_a_2),
	    .write_a_2(write_a_2),
	    .en_a_2(en_a_2),
	    .we_a_2(we_a_2),
	    .read_a_2(read_a_2),

	    .addr_b_2(addr_b_2),
	    .write_b_2(write_b_2),
	    .en_b_2(en_b_2),
	    .we_b_2(we_b_2),
	    .read_b_2(read_b_2)
    );
    
    single_port_rom rom (
        .clk(clk),
        .addr(addr_w),
        .read(read_w)
    );


    wire [12:0] out;
    polymul polymul(
        .clk(clk),
        .resetn(resetn),
        .in_stream_poly_1(S_AXIS_MM2S_tdata[12:0]),
        .in_stream_poly_2(S_AXIS_MM2S_tdata[17:16]),
        .in_stream_valid(S_AXIS_MM2S_tvalid),
        .in_stream_ready(S_AXIS_MM2S_tready),
        .out_stream(out),
        .out_stream_valid(M_AXIS_MM2S_tvalid),
        .out_stream_ready(M_AXIS_MM2S_tready),
        .poly_n(poly_n),
        .poly_q(poly_q),
        .addr_w(addr_w),
        .read_w(read_w),
	    .addr_a_1(addr_a_1),
	    .write_a_1(write_a_1),
	    .en_a_1(en_a_1),
	    .we_a_1(we_a_1),
	    .read_a_1(read_a_1),
	    .addr_b_1(addr_b_1),
	    .write_b_1(write_b_1),
	    .en_b_1(en_b_1),
	    .we_b_1(we_b_1),
	    .read_b_1(read_b_1),
	    .addr_a_2(addr_a_2),
	    .write_a_2(write_a_2),
	    .en_a_2(en_a_2),
	    .we_a_2(we_a_2),
	    .read_a_2(read_a_2),
	    .addr_b_2(addr_b_2),
	    .write_b_2(write_b_2),
	    .en_b_2(en_b_2),
	    .we_b_2(we_b_2),
	    .read_b_2(read_b_2),
        .done(M_AXIS_MM2S_tlast)
    );

    assign M_AXIS_MM2S_tdata = out;
            
endmodule
