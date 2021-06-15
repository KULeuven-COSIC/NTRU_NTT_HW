`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.04.2021 21:18:02
// Design Name: 
// Module Name: polymul
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


module polymul(
        input  wire        clk,
        input  wire        resetn,
        input  wire [12:0] in_stream_poly_1,
        input  wire  [1:0] in_stream_poly_2,
        input  wire        in_stream_valid,
        output wire        in_stream_ready,
        output wire [12:0] out_stream,
        output wire        out_stream_valid,
        input  wire        out_stream_ready,
        input  wire  [9:0] poly_n,
        input  wire  [1:0] poly_q,
        output wire [11:0] addr_w,
        input  wire [23:0] read_w,
        output wire [11:0] addr_a_1,
        output wire [23:0] write_a_1,
        output wire        en_a_1,
        output wire        we_a_1,
        input  wire [23:0] read_a_1,
        output wire [11:0] addr_b_1,
        output wire [23:0] write_b_1,
        output wire        en_b_1,
        output wire        we_b_1,
        input  wire [23:0] read_b_1,
        output wire [11:0] addr_a_2,
        output wire [23:0] write_a_2,
        output wire        en_a_2,
        output wire        we_a_2,
        input  wire [23:0] read_a_2,
        output wire [11:0] addr_b_2,
        output wire [23:0] write_b_2,
        output wire        en_b_2,
        output wire        we_b_2,
        input  wire [23:0] read_b_2,
        output wire        done
    );

    reg   [9:0] reg_poly_n;
    reg   [9:0] reg_poly_n_minus_1;
    reg   [1:0] reg_poly_q;
    wire        poly_large_n = reg_poly_n[9];

    wire        forward;
    wire        reg_forward, reg2_forward, reg3_forward;
    reg  [12:0] reg_in_stream_poly_1, reg2_in_stream_poly_1;
    reg   [1:0] reg_in_stream_poly_2, reg2_in_stream_poly_2;
    // precalculated { 2, 1, 0 } -> { -1, 1, 0 } -> { Q - 1 / N, 1 / N, 0 }
    wire [24:0] minus_Ninv_mod_Q = poly_large_n ? 24'd6146 : 24'd12292;
    wire [24:0] Ninv_mod_Q = poly_large_n ? 24'd12580863 : 24'd12574717;
    wire [23:0] reg_in_stream_poly_2_NInv = reg_in_stream_poly_2[1] ? minus_Ninv_mod_Q : reg_in_stream_poly_2[0] ? Ninv_mod_Q : 24'd0;
    wire [23:0] reg2_in_stream_poly_2_NInv = reg2_in_stream_poly_2[1] ? minus_Ninv_mod_Q : reg2_in_stream_poly_2[0] ? Ninv_mod_Q : 24'd0;
    reg   [1:0] poly_sel;
    wire        ntt_done;
    wire        forward_first_layer, last_layer;
    reg         reg_forward_first_layer, reg2_forward_first_layer;
    reg         reg_last_layer, reg2_last_layer, reg3_last_layer, reg4_last_layer;
    
    wire [10:0] index_a;
    wire [10:0] index_b;
    wire [10:0] ntt_control_a;
    wire [10:0] ntt_control_b;
    wire [10:0] index_w;
    wire        first_step_write_stage;
    reg         reg_first_step_write_stage;
    wire        first_layer_first_part;
    reg         reg_first_layer_first_part;

    wire        point_mul;
    wire        reg_point_mul, reg2_point_mul, reg3_point_mul;
    wire        needs_in_stream = forward_first_layer;
    wire        in_valid = (!needs_in_stream || in_stream_valid) && (out_stream_valid ? out_stream_ready : 1'b1) && !reg_end_reduction;
    reg         reg_in_valid;
    wire        after_first_layer_write_stall = reg_first_step_write_stage && !first_step_write_stage;
    wire        ntt_step = forward ? ((!poly_sel && in_valid && !after_first_layer_write_stall) || point_mul) : !reg_last_layer;
    wire        do_reduction = reg4_last_layer && !forward && !reg_end_reduction;
    wire        end_reduction = reduction_in1_addr == reg_poly_n_minus_1;
    reg         reg_end_reduction;
    reg   [9:0] reduction_in1_addr;
    reg  [10:0] reduction_in2_addr;

    always @(posedge clk) begin
        if (resetn) begin
            poly_sel <= 2'b0;
            reg_forward_first_layer <= 1'b1;
            reg2_forward_first_layer <= 1'b1;
            reg_first_step_write_stage <= 1'b1;
            reg_first_layer_first_part <= 1'b1;
            reduction_in1_addr <= 0;
            reduction_in2_addr <= poly_n;
            reg_in_valid <= 0;
            reg_poly_n <= poly_n;
            reg_poly_n_minus_1 <= poly_n - 1;
            reg_poly_q <= poly_q;
            reg_last_layer <= 0;
            reg2_last_layer <= 0;
            reg3_last_layer <= 0;
            reg4_last_layer <= 0;
            reg_end_reduction <= 0;
        end else begin
            if (forward && in_valid && !first_layer_first_part && !after_first_layer_write_stall && !point_mul)
                poly_sel <= (poly_sel + 1) & { forward_first_layer && !reg_first_step_write_stage, 1'b1 };
            reg_first_step_write_stage <= first_step_write_stage;
            reg_first_layer_first_part <= first_layer_first_part;
            reg_forward_first_layer <= forward_first_layer;
            reg2_forward_first_layer <= reg_forward_first_layer;
            if (do_reduction_delayed_4less && !end_reduction && (out_stream_valid ? out_stream_ready : 1'b1)) begin
                reduction_in1_addr <= reduction_in1_addr + 10'd1;
                reduction_in2_addr <= reduction_in2_addr + 10'd1;
            end
            reg_in_valid <= in_valid;
            reg_last_layer <= last_layer;
            reg2_last_layer <= reg_last_layer;
            reg3_last_layer <= reg2_last_layer;
            reg4_last_layer <= reg3_last_layer;
            reg_end_reduction <= end_reduction;
        end
        reg_in_stream_poly_1 <= in_stream_poly_1; // delay to match bram delay
        reg_in_stream_poly_2 <= in_stream_poly_2;
        reg2_in_stream_poly_1 <= reg_in_stream_poly_1;
        reg2_in_stream_poly_2 <= reg_in_stream_poly_2;
    end

    wire        reduction_sel = (reduction_in2_addr & (poly_large_n ? 12'd1024 : 12'd512)) != 0;
        
    wire [11:0] read_addr_a_2 = index_b_delayed_3less;
    wire [11:0] read_addr_b_2 = index_b_delayed_3less | (poly_large_n ? 12'd1024 : 12'd512);
    assign index_a = do_reduction ? reduction_in2_addr & ~(poly_large_n ? 12'd1024 : 12'd512) : ntt_control_a;
    assign index_b = do_reduction ? reduction_in2_addr | (poly_large_n ? 12'd1024 : 12'd512) : ntt_control_b;

    
    wire index_poly = !poly_sel[0] && reg_forward;
    wire [11:0] read_addr_a_1 = { index_poly, index_a };
    wire [11:0] read_addr_b_1 = { index_poly || point_mul, index_b };
    assign addr_w = { !forward, index_w[10:3], forward_first_layer ? (poly_sel[1] != poly_sel[0] ? 3'd2 : 3'd3) : index_w[2:0] };

    assign in_stream_ready = needs_in_stream && (first_layer_first_part || (!poly_sel && in_valid) || ((ntt_control_a == 0) && forward_first_layer && (poly_sel == 1) && !in_stream_valid)) && !resetn;

    
    localparam MUL_DELAY = 11; // cycles for multiplier in butterfly
    reg [11*(MUL_DELAY+3)-1:0] regs_index_a;
    reg [11*(MUL_DELAY+3)-1:0] regs_index_b;
    reg        [MUL_DELAY+2:0] regs_index_poly;
    reg        [MUL_DELAY+2:0] regs_double_index_poly;
    reg        [MUL_DELAY+3:0] regs_valid;
    reg        [MUL_DELAY+2:0] regs_forward;
    reg        [MUL_DELAY+2:0] regs_point_mul;
    reg        [MUL_DELAY+2:0] regs_do_reduction;

    // wire [10:0] index_a_delayed_3less = regs_index_a[11*(MUL_DELAY-1)-1:11*(MUL_DELAY-2)];
    wire [10:0] index_b_delayed_3less = regs_index_b[11*(MUL_DELAY-1)-1:11*(MUL_DELAY-2)];
    wire [10:0] index_a_delayed = regs_index_a[11*(MUL_DELAY+2)-1:11*(MUL_DELAY+1)];
    wire [10:0] index_b_delayed = regs_index_b[11*(MUL_DELAY+2)-1:11*(MUL_DELAY+1)];
    wire [10:0] index_a_delayed_1more = regs_index_a[11*(MUL_DELAY+3)-1:11*(MUL_DELAY+2)];
    wire [10:0] index_b_delayed_1more = regs_index_b[11*(MUL_DELAY+3)-1:11*(MUL_DELAY+2)];
    wire        index_poly_delayed = regs_index_poly[MUL_DELAY+1];
    wire        index_poly_delayed_1more = regs_index_poly[MUL_DELAY+2];
    wire        double_index_poly_delayed = regs_double_index_poly[MUL_DELAY+1];
    wire        double_index_poly_delayed_1more = regs_double_index_poly[MUL_DELAY+2];
    wire        in_valid_delayed = regs_valid[MUL_DELAY+2];
    wire        reg_in_valid_delayed = regs_valid[MUL_DELAY+3];
    assign      reg_forward = regs_forward[0];
    assign      reg2_forward = regs_forward[1];
    assign      reg3_forward = regs_forward[2];
    wire        forward_delayed = regs_forward[MUL_DELAY+1];
    wire        reg_forward_delayed = regs_forward[MUL_DELAY+2];
    assign      reg_point_mul = regs_point_mul[0];
    assign      reg2_point_mul = regs_point_mul[1];
    assign      reg3_point_mul = regs_point_mul[2];
    wire        point_mul_delayed = regs_point_mul[MUL_DELAY+1];
    wire        reg_point_mul_delayed = regs_point_mul[MUL_DELAY+2];
    wire        do_reduction_delayed_4less = regs_do_reduction[MUL_DELAY-4];
    wire        do_reduction_delayed_2less = regs_do_reduction[MUL_DELAY-2];
    wire        do_reduction_delayed = regs_do_reduction[MUL_DELAY];
    wire        do_reduction_delayed_2more = regs_do_reduction[MUL_DELAY+2];

    wire [23:0] compute_in_a = read_a_1;
    wire [23:0] compute_in_b = reg2_forward_first_layer ? (regs_index_poly[1] ? reg2_in_stream_poly_2_NInv : reg2_in_stream_poly_1) : read_b_1;

    always @(posedge clk) begin
        regs_index_a <= { regs_index_a, index_a };
        regs_index_b <= { regs_index_b, do_reduction ? reduction_in1_addr : index_b };
        regs_index_poly <= resetn ? 0 : { regs_index_poly, (index_poly && !point_mul) || reduction_sel };
        regs_double_index_poly <= resetn ? 0 : { regs_double_index_poly, ((poly_sel[1] == poly_sel[0]) && forward_first_layer) || end_reduction };
        regs_valid <= resetn ? 0 : { regs_valid[MUL_DELAY+2:1], regs_valid[0], in_valid && ~first_step_write_stage && (!do_reduction || do_reduction_delayed_4less) };
        regs_forward <= resetn ? -1 : { regs_forward, forward };
        regs_point_mul <= resetn ? 0 : { regs_point_mul, point_mul };
        regs_do_reduction <= resetn ? 0 : { regs_do_reduction, do_reduction };
    end
    
    ntt_control controller(
        .clk(clk),
        .start(resetn),
        .step(ntt_step),
        .poly_large_n(poly_large_n),
        .forward(forward),
        .forward_first_layer(forward_first_layer),
        .first_layer_first_half(first_step_write_stage),
        .first_layer_first_part(first_layer_first_part),
        .first_layer_stop_at({ reg_poly_n_minus_1[8] & poly_large_n, reg_poly_n_minus_1[7:0] }),
        .last_layer(last_layer),
        .point_mul(point_mul),
        .done(ntt_done),
        .index_a(ntt_control_a),
        .index_b(ntt_control_b),
        .index_w(index_w)
    );

    wire [12:0] reduction_out;
    wire [23:0] compute_out_a, compute_out_b;
    compute_unit compute_unit(
        .clk(clk),
        .resetn(resetn),
        .in_a(compute_in_a),
        .in_b(compute_in_b),
        .in_w(read_w),
        .forward(reg2_forward),
        .reg_forward(reg3_forward),
        .forward_delayed(forward_delayed && !point_mul_delayed),
        .index_poly(index_poly_delayed),
        .point_mul(reg3_point_mul),
        .reduction_delayed(do_reduction_delayed),
        .reduction_other_a_delayed(read_a_2),
        .reduction_other_b_delayed(read_b_2),
        .reduction_sel_delayed(index_poly_delayed),
        .reduction_out(reduction_out),
        .poly_q(reg_poly_q),
        .out_a(compute_out_a),
        .out_b(compute_out_b)
    );

    wire en_bram = !resetn && (!end_reduction || do_reduction_delayed_2less);

    assign write_a_1 = reg_in_stream_poly_2_NInv;
    assign write_b_1 = reg_in_stream_poly_2_NInv;

    wire        first_layer_second_part_sel = reg_first_layer_first_part != index_poly;
    wire  [8:0] first_layer_second_part_write_addr = { poly_large_n ? regs_index_a[8] : first_layer_second_part_sel, regs_index_a[7:0] };
    wire [11:0] write_addr_a_1 = { 1'b1, poly_large_n, poly_large_n ? first_layer_second_part_sel : 1'b1, first_layer_second_part_write_addr };
    wire [11:0] write_addr_b_1 = { 1'b1, 1'b0        , poly_large_n ? first_layer_second_part_sel : 1'b0, first_layer_second_part_write_addr };

    wire we_1 = reg_first_step_write_stage && reg_in_valid;
    assign en_a_1 = en_bram;
    assign en_b_1 = en_bram;
    assign we_a_1 = we_1;
    assign we_b_1 = we_1;
    assign addr_a_1 = we_1 ? write_addr_a_1 : read_addr_a_1;
    assign addr_b_1 = we_1 ? write_addr_b_1 : read_addr_b_1;

    assign write_a_2 = reg_first_step_write_stage ? reg_in_stream_poly_1 : compute_out_b;
    assign write_b_2 = reg_first_step_write_stage ? reg_in_stream_poly_1 : compute_out_a;

    wire [11:0] write_addr_a_2 = reg_first_step_write_stage ? { 1'b0, poly_large_n, poly_large_n ? first_layer_second_part_sel : 1'b1, first_layer_second_part_write_addr } : { index_poly_delayed_1more, index_b_delayed_1more[10] || (double_index_poly_delayed_1more && poly_large_n), index_b_delayed_1more[9] || (double_index_poly_delayed_1more && !poly_large_n), index_b_delayed_1more[8:0] };
    wire [11:0] write_addr_b_2 = reg_first_step_write_stage ? { 1'b0, 1'b0        , poly_large_n ? first_layer_second_part_sel : 1'b0, first_layer_second_part_write_addr } : { index_poly_delayed_1more, index_a_delayed_1more[10] || (double_index_poly_delayed_1more && poly_large_n), index_a_delayed_1more[9] || (double_index_poly_delayed_1more && !poly_large_n), index_a_delayed_1more[8:0] };
    
    wire we_2 = we_1 || (reg_in_valid_delayed && !do_reduction_delayed_2less);
    assign en_a_2 = en_bram;
    assign en_b_2 = en_bram && !reg_point_mul_delayed;
    assign we_a_2 = we_2;
    assign we_b_2 = we_2;
    assign addr_a_2 = we_2 ? write_addr_a_2 : read_addr_a_2;
    assign addr_b_2 = we_2 ? write_addr_b_2 : read_addr_b_2;

    wire fifo_last;
    fifo fifo(
        .clk(clk),
        .resetn(resetn),
        .in(reduction_out),
        .in_valid(do_reduction_delayed_2more && !forward_delayed && in_valid_delayed),
        .out(out_stream),
        .out_ready(out_stream_ready),
        .out_valid(out_stream_valid),
        .out_last(fifo_last)
    );
    assign done = reg_end_reduction && !in_valid_delayed && (fifo_last || !out_stream_valid);

endmodule
