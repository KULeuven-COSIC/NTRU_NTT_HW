`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.05.2021 16:33:07
// Design Name: 
// Module Name: single_port_rom
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


module single_port_rom (
  input  wire                  clk,
  input  wire [ADDR_WIDTH-1:0] addr,
  output reg  [DATA_WIDTH-1:0] read
);
	parameter MEM_INIT_FILE = "C:/Users/Kris/Documents/school/thesis/ntt_ntru_accel/omega_combined.txt";
	parameter DATA_WIDTH = 24;
	parameter ADDR_WIDTH = 12;

	reg [DATA_WIDTH-1:0] ram [2**ADDR_WIDTH-1:0]; 

	initial
		if (MEM_INIT_FILE != "")
			$readmemh(MEM_INIT_FILE, ram);

	reg [DATA_WIDTH-1:0] tmp;
	always @(posedge clk) begin
		tmp <= ram[addr];
		read <= tmp;
	end
    
endmodule