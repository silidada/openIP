/*
 * @Author: Haha Chen 
 * @Date: 2023-09-09 12:04:43 
 * @Last Modified by:   Haha Chen 
 * @Last Modified time: 2023-09-09 12:04:43 
 */
module huffman#(
    parameter integer BUS_WIDTH = 64, // 码表传输进来的编码每一次的位宽
    parameter integer LEN_WIDTH = 8,  // 编码器内部，记录编码长度的位宽
    parameter integer DATA_WIDTH = 64,  // 编码器内部，编码的位宽
    parameter integer OUT_WIDTH = 128, // 编码后，concat结束后，最终的输出位宽
    parameter integer ROM_NUM = 2,
    parameter integer ROM_ADDR_WIDTH = 8,
    parameter integer ROM_DATA_WIDTH = 64,
    parameter integer EXPAND_LEVEL = 1,
    parameter integer REG_NUM = 16
)
(
    input wire clk,
    input wire rst,
    input wire start,
    // 编码输入fifo
    input wire fifo_i_valid,
    input wire [8-1:0] fifo_i_data,
    input wire fifo_i_last,
    // 码表输入fifo
    input wire enc_fifo_i_valid,
    input wire [BUS_WIDTH-1:0] enc_fifo_i_data,

    input wire fifo_o_ready,

    input wire we,
    input wire rd,


    output wire fifo_i_ready,
    output wire enc_fifo_i_ready,
    output wire fifo_o_valid,
    output wire [OUT_WIDTH-1:0] concat_dout
);

wire [7:0] addr_gen1_addr;
wire [7:0] addr_gen2_addr;
wire analsy_len_result_ready;
wire analsy_len_we;
wire analsy_len_busy;
wire [BUS_WIDTH-1:0] analsy_len_result;
wire concat_busy;
wire concat_result_ready;

wire [$clog2(OUT_WIDTH)-1:0]concat_len_last_out;
wire [DATA_WIDTH-1:0] len_regs_data_out;
wire [63:0] roms_dout;
wire rom_we;
wire [7:0] rom_addr;
wire concat_last;
wire concat_start;
wire [DATA_WIDTH-1:0] concat_din;
wire len_regs_we;
wire [7:0] len_regs_addr;
wire addr_gen1_start;
wire addr_gen1_rst;
wire addr_gen2_start;
wire addr_gen2_rst;



addr_gen addr_gen_inst1 (
    .clk(clk),
    .rst(addr_gen1_rst),
    .start(addr_gen1_start),
    .addr(addr_gen1_addr)
);

addr_gen addr_gen_inst2 (
    .clk(clk),
    .rst(addr_gen2_rst),
    .start(addr_gen2_start),
    .addr(addr_gen2_addr)
);

analsy_len #(
    .END_(6'b010010),
    .BUS_WIDTH(BUS_WIDTH),
    .EXPAND_LEVEL(1)
) analsy_len_inst (
    .clk(clk),
    .rst(rst),
    .din(enc_fifo_i_data),
    .we(analsy_len_we),
    .result_ready(analsy_len_result_ready),
    .busy(analsy_len_busy),
    .result(analsy_len_result)
);



concat #(
    .DATA_WIDTH(DATA_WIDTH),
    .LEN_WIDTH(DATA_WIDTH),
    .OUT_WIDTH(OUT_WIDTH)
) concat_inst (
    .clk(clk),
    .rst(rst),
    .din(concat_din),
    .len(len_regs_data_out),
    .start(concat_start),
    .last(concat_last),

    .busy(concat_busy),
    .result_ready(concat_result_ready),
    .dout(concat_dout),
    .len_last_out(concat_len_last_out)
);

len_regs #(
    .BUS_WIDTH(8),
    .REG_NUM(16)
) len_regs_inst (
    .len(analsy_len_result),
    .addr(len_regs_addr),
    .we(len_regs_we),

    .dout(len_regs_data_out)
);

roms #(
    .ROM_NUM(1)
) roms_inst (
    .clk(clk),
    .addr(rom_addr),
    .we(rom_we),
    .din(enc_fifo_i_data),

    .dout(roms_dout)
);

ctrl #(
    .DATA_WIDTH(64),
    .LEN_WIDTH(6)
) ctrl_inst (
    .clk(clk),
    .rst(rst),
    .start(start),
    .we(we),
    .rd(rd),
    .fifo_i_valid(fifo_i_valid),
    .fifo_i_data(fifo_i_data),
    .fifo_i_last(fifo_i_last),
    .fifo_o_ready(fifo_o_ready),
    .enc_fifo_i_valid(enc_fifo_i_valid),
    // .addr(addr),
    .concat_busy(concat_busy),
    .concat_result_ready(concat_result_ready),
    .analsys_len_busy(analsys_len_busy),
    .analsys_len_result_ready(analsys_len_result_ready),
    .addr_gen1_addr(addr_gen1_addr),
    .addr_gen2_addr(addr_gen2_addr),
    .rom_dout(roms_dout),
    .rom_we(rom_we),
    .rom_addr(rom_addr),
    .concat_last(concat_last),
    .concat_start(concat_start),
    .concat_din(concat_din),
    .analsys_len_we(analsy_len_we),
    .len_regs_we(len_regs_we),
    .len_regs_addr(len_regs_addr),
    .fifo_i_ready(fifo_i_ready),
    .fifo_o_valid(fifo_o_valid),
    .enc_fifo_i_ready(enc_fifo_i_ready),
    .addr_gen1_start(addr_gen1_start),
    .addr_gen1_rst(addr_gen1_rst),
    .addr_gen2_start(addr_gen2_start),
    .addr_gen2_rst(addr_gen2_rst)
);

endmodule