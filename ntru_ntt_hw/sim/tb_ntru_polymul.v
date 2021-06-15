`timescale 1ns / 1ps

`define CLK_PERIOD 6
`define CLK_HALF 3
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.05.2021 02:50:43
// Design Name: 
// Module Name: tb_ntru_polymul
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



module tb_ntru_polymul();

	// parameter POLY_Q = 2048;
	// parameter POLY_N = 443;
    // parameter IN_STREAM = "test/in_stream_2048443.mem";
    // parameter OUT_STREAM = "test/out_stream_2048443.mem";

	// parameter POLY_Q = 2048;
	// parameter POLY_N = 509;
    // parameter IN_STREAM = "test/in_stream_2048509.mem";
    // parameter OUT_STREAM = "test/out_stream_2048509.mem";

	// parameter POLY_Q = 8192;
	// parameter POLY_N = 701;
    // parameter IN_STREAM = "test/in_stream_8192701.mem";
    // parameter OUT_STREAM = "test/out_stream_8192701.mem";

	// parameter POLY_Q = 2048;
	// parameter POLY_N = 677;
    // parameter IN_STREAM = "test/in_stream_2048677.mem";
    // parameter OUT_STREAM = "test/out_stream_2048677.mem";

	// parameter POLY_Q = 2048;
	// parameter POLY_N = 743;
    // parameter IN_STREAM = "test/in_stream_2048743.mem";
    // parameter OUT_STREAM = "test/out_stream_2048743.mem";

	parameter POLY_Q = 4096;
	parameter POLY_N = 821;
    parameter IN_STREAM = "test/in_stream_4096821.mem";
    parameter OUT_STREAM = "test/out_stream_4096821.mem";

    parameter INTERRUPT_AXI_STREAM = 0;



    reg         clk = 0;
    reg         resetn = 0;
    integer     cycleCount;

    reg         correct;
    wire [31:0] S_AXIS_MM2S_tdata;
    reg         in_valid;
    wire        S_AXIS_MM2S_tready;
	reg  [31:0] in_stream [POLY_N-1:0];
    reg   [9:0] in_stream_index;
    reg         reg_block_input;
	initial
		$readmemh(IN_STREAM, in_stream);
    always @(posedge clk) begin
        reg_block_input <= S_AXIS_MM2S_tready && block_input;
        in_stream_index <= resetn ? -1 : in_stream_index + (S_AXIS_MM2S_tready && !reg_block_input);
        in_valid <= !(S_AXIS_MM2S_tready && block_input);
    end
    assign S_AXIS_MM2S_tdata = in_stream[in_stream_index];
    wire S_AXIS_MM2S_tvalid = (in_stream_index < POLY_N) && in_valid;


    wire [31:0] M_AXIS_MM2S_tdata;
    wire        M_AXIS_MM2S_tvalid;
    reg         out_ready;
    wire        M_AXIS_MM2S_tlast;
	reg  [31:0] out_stream [POLY_N-1:0];
	reg  [31:0] out_stream_expected [POLY_N-1:0];
    reg   [9:0] out_stream_index;
    reg         is_done;
	initial
		$readmemh(OUT_STREAM, out_stream_expected);
    always @(posedge clk) begin
        out_stream_index <= resetn ? 0 : out_stream_index + (M_AXIS_MM2S_tvalid && out_ready && !reg_block_input);
        if (M_AXIS_MM2S_tvalid)
            out_stream[out_stream_index] <= M_AXIS_MM2S_tdata;
        out_ready <= !(M_AXIS_MM2S_tvalid && block_input);
        is_done <= M_AXIS_MM2S_tlast;
    end
    wire M_AXIS_MM2S_tready = (out_stream_index < POLY_N) && out_ready;


    reg block_input = 1;
    ntru_polymul ntru_polymul(
        .clk(clk),
        .resetn(resetn),
        .S_AXIS_MM2S_tdata(S_AXIS_MM2S_tdata),
        .S_AXIS_MM2S_tvalid(S_AXIS_MM2S_tvalid),
        .S_AXIS_MM2S_tready(S_AXIS_MM2S_tready),
        .M_AXIS_MM2S_tdata(M_AXIS_MM2S_tdata),
        .M_AXIS_MM2S_tvalid(M_AXIS_MM2S_tvalid),
        .M_AXIS_MM2S_tready(M_AXIS_MM2S_tready),
        .M_AXIS_MM2S_tlast(M_AXIS_MM2S_tlast),
        .poly_n(POLY_N),
        .poly_q(POLY_Q == 8192 ? 2'b11 : POLY_Q == 4096 ? 2'b01 : 2'b00)
    );

    
    initial begin
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        forever begin
            @(posedge clk);
            @(posedge clk);
            block_input = INTERRUPT_AXI_STREAM;
            @(posedge clk);
            block_input = 0;
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            block_input = INTERRUPT_AXI_STREAM;
            @(posedge clk);
            block_input = 0;
        end
    end

    always @(posedge clk) begin
        if (resetn)
            cycleCount <= 0;
        else if (!is_done)
            cycleCount <= cycleCount + 1;
    end


    integer i;
    initial begin
        for (i=0; i< 12; i=i+1)
            @(posedge clk);
        resetn   <= 1;
        for (i=0; i< 9; i=i+1)
            @(posedge clk);
        resetn   <= 0;
             
        @(posedge is_done);
                
        correct <= 1;
        for (i=0; i < POLY_N; i=i+1)
            if (out_stream[i] != out_stream_expected[i])
                correct <= 0;
        
        for (i=0; i < 50; i=i+1)
            @(posedge clk);

        $finish;
    end


    
    always clk = #`CLK_HALF ~clk;

endmodule
