`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.05.2021 16:24:39
// Design Name: 
// Module Name: double_dual_port_ram
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








// true dual port ram.
module dual_port_ram (
	input  wire                  clk,
    
    input  wire                  en_1,
	input  wire [ADDR_WIDTH-1:0] addr_1,
	input  wire [DATA_WIDTH-1:0] write_1,
	input  wire                  we_1,
	output reg  [DATA_WIDTH-1:0] read_1,

    input  wire                  en_2,
	input  wire [ADDR_WIDTH-1:0] addr_2,
	input  wire [DATA_WIDTH-1:0] write_2,
	input  wire                  we_2,
	output reg  [DATA_WIDTH-1:0] read_2
);

	parameter DATA_WIDTH = 24;
	parameter ADDR_WIDTH = 11;

    (*RDADDR_COLLISION_HWCONFIG = "performance" *)
	reg [DATA_WIDTH-1:0] ram [2**ADDR_WIDTH-1:0]; 

    always @(posedge clk) // port 1
        if (en_1) begin
            if (we_1)
                ram[addr_1] <= write_1;
            else
                read_1 <= ram[addr_1];
        end
    
    always @(posedge clk) // port 2
        if (en_2) begin
            if (we_2)
                ram[addr_2] <= write_2;
            else
                read_2 <= ram[addr_2];
        end

endmodule


module count_bits(
    input  wire [11:0] in,
    output wire        out
);
    assign out = in[0] ^ in[1] ^ in[2] ^ in[3] ^ in[4] ^ in[5] ^ in[6] ^ in[7] ^ in[8] ^ in[9] ^ in[10] ^ in[11];
endmodule


// exploits correlation between 2 write addresses for NTT to effectively create true quad port block ram
module double_dual_port_ram (
	input  wire        clk,

	input  wire [11:0] addr_a_1,
	input  wire [23:0] write_a_1,
	input  wire        en_a_1,
	input  wire        we_a_1,        // also used for switching *both* port 1's between reading and writing
	output reg  [23:0] read_a_1,

	input  wire [11:0] addr_b_1,
	input  wire [23:0] write_b_1,
	input  wire        en_b_1,
	input  wire        we_b_1,
	output reg  [23:0] read_b_1,

	input  wire [11:0] addr_a_2,
	input  wire [23:0] write_a_2,
	input  wire        en_a_2,
	input  wire        we_a_2,        // also used for switching *both* port 2's between reading and writing
	output reg  [23:0] read_a_2,

	input  wire [11:0] addr_b_2,
	input  wire [23:0] write_b_2,
	input  wire        en_b_2,
	input  wire        we_b_2,
	output reg  [23:0] read_b_2
    );

    // selects which ram block to use for read_a. Using this pattern, it is guaranteed that b uses the other ram block for butterfly usage.

    wire        sel_1;
    count_bits block_sel_1(
        .in(addr_a_1),
        .out(sel_1)
    );

    wire        sel_2;
    count_bits block_read_sel_2(
        .in(addr_a_2),
        .out(sel_2)
    );
 
    wire [23:0] read_A_1, read_A_2;
    dual_port_ram ramA(
        .clk(clk),
        .en_1(sel_1 ? en_a_1 : en_b_1),
        .addr_1(sel_1 ? addr_a_1[11:1] : addr_b_1[11:1]),
        .write_1(sel_1 ? write_a_1 : write_b_1),
        .we_1(sel_1 ? we_a_1 : we_b_1),
        .read_1(read_A_1),
        .en_2(sel_2 ? en_a_2 : en_b_2),
        .addr_2(sel_2 ? addr_a_2[11:1] : addr_b_2[11:1]),
        .write_2(sel_2 ? write_a_2 : write_b_2),
        .we_2(sel_2 ? we_a_2 : we_b_2),
        .read_2(read_A_2)
    );

    wire [23:0] read_B_1, read_B_2;
    dual_port_ram ramB(
        .clk(clk),
        .en_1(sel_1 ? en_b_1 : en_a_1),
        .addr_1(sel_1 ? addr_b_1[11:1] : addr_a_1[11:1]),
        .write_1(sel_1 ? write_b_1 : write_a_1),
        .we_1(sel_1 ? we_b_1 : we_a_1),
        .read_1(read_B_1),
        .en_2(sel_2 ? en_b_2 : en_a_2),
        .addr_2(sel_2 ? addr_b_2[11:1] : addr_a_2[11:1]),
        .write_2(sel_2 ? write_b_2 : write_a_2),
        .we_2(sel_2 ? we_b_2 : we_a_2),
        .read_2(read_B_2)
    );
    
    reg reg_sel_1, reg_sel_2;
    always @(posedge clk) begin
        reg_sel_1 <= sel_1;
        reg_sel_2 <= sel_2;
    end
    always @(posedge clk) begin // no additional register at the end for now
        read_a_1 <= reg_sel_1 ? read_A_1 : read_B_1;
        read_b_1 <= reg_sel_1 ? read_B_1 : read_A_1;
        read_a_2 <= reg_sel_2 ? read_A_2 : read_B_2;
        read_b_2 <= reg_sel_2 ? read_B_2 : read_A_2;
    end

endmodule

