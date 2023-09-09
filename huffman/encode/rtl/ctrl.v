/*
 * @Author: Haha Chen 
 * @Date: 2023-09-09 12:04:41 
 * @Last Modified by:   Haha Chen 
 * @Last Modified time: 2023-09-09 12:04:41 
 */
/**
 * The `ctrl` module is responsible for controlling the Huffman encoding and decoding process.
 *
 * @param DATA_WIDTH The width of the data bus.
 * @param LEN_WIDTH The width of the length bus.
 *
 * @param clk The clock input.
 * @param rst The reset input.
 * @param start The start signal input.
 * @param we The write signal input for writing to the Huffman code table.
 * @param rd The read signal input for reading from the Huffman code table.
 * @param fifo_i_valid The input FIFO valid signal.
 * @param fifo_i_data The input FIFO data bus.
 * @param fifo_i_last The input FIFO last signal.
 * @param fifo_o_ready The output FIFO ready signal.
 * @param enc_fifo_i_valid The input encoding FIFO valid signal.
 * @param addr The address bus for the Huffman code table.
 * @param concat_busy The busy signal for the concatenation process.
 * @param concat_result_ready The result ready signal for the concatenation process.
 * @param analsys_len_busy The busy signal for the length analysis process.
 * @param analsys_len_result_ready The result ready signal for the length analysis process.
 * @param addr_gen1_addr The address bus for the first address generator.
 * @param addr_gen2_addr The address bus for the second address generator.
 * @param rom_dout The output data bus for the ROM.
 * @param rom_we The write signal output for writing to the ROM.
 * @param rom_addr The address bus for the ROM.
 * @param concat_last The last signal output for the concatenation process.
 * @param concat_start The start signal output for the concatenation process.
 * @param concat_din The input data bus for the concatenation process.
 * @param analsys_len_we The write signal output for writing to the length analysis module.
 * @param len_regs_we The write signal output for writing to the length registers.
 * @param len_regs_addr The address bus for the length registers.
 * @param fifo_i_ready The input FIFO ready signal.
 * @param fifo_o_valid The output FIFO valid signal.
 * @param enc_fifo_i_ready The input encoding FIFO ready signal.
 * @param addr_gen1_start The start signal output for the first address generator.
 * @param addr_gen1_rst The reset signal output for the first address generator.
 * @param addr_gen2_start The start signal output for the second address generator.
 * @param addr_gen2_rst The reset signal output for the second address generator.
 *
 * @example
 * // Instantiate the `ctrl` module with a data width of 64 and a length width of 6.
 * ctrl #(
 *     .DATA_WIDTH(64),
 *     .LEN_WIDTH(6)
 * ) ctrl_inst (
 *     .clk(clk),
 *     .rst(rst),
 *     .start(start),
 *     .we(we),
 *     .rd(rd),
 *     .fifo_i_valid(fifo_i_valid),
 *     .fifo_i_data(fifo_i_data),
 *     .fifo_i_last(fifo_i_last),
 *     .fifo_o_ready(fifo_o_ready),
 *     .enc_fifo_i_valid(enc_fifo_i_valid),
 *     .addr(addr),
 *     .concat_busy(concat_busy),
 *     .concat_result_ready(concat_result_ready),
 *     .analsys_len_busy(analsys_len_busy),
 *     .analsys_len_result_ready(analsys_len_result_ready),
 *     .addr_gen1_addr(addr_gen1_addr),
 *     .addr_gen2_addr(addr_gen2_addr),
 *     .rom_dout(rom_dout),
 *     .rom_we(rom_we),
 *     .rom_addr(rom_addr),
 *     .concat_last(concat_last),
 *     .concat_start(concat_start),
 *     .concat_din(concat_din),
 *     .analsys_len_we(analsys_len_we),
 *     .len_regs_we(len_regs_we),
 *     .len_regs_addr(len_regs_addr),
 *     .fifo_i_ready(fifo_i_ready),
 *     .fifo_o_valid(fifo_o_valid),
 *     .enc_fifo_i_ready(enc_fifo_i_ready),
 *     .addr_gen1_start(addr_gen1_start),
 *     .addr_gen1_rst(addr_gen1_rst),
 *     .addr_gen2_start(addr_gen2_start),
 *     .addr_gen2_rst(addr_gen2_rst)
 * );
 */
 
 module ctrl#(
    parameter integer DATA_WIDTH = 64,
    parameter integer LEN_WIDTH = 6
)
(
    input wire clk,
    input wire rst,


    // 更顶层的控制
    input wire start,
    
    input wire we, // 写哈夫曼编码表
    input wire rd, // 读哈夫曼编码表

    // from input fifo
    input wire fifo_i_valid,
    input wire [7:0] fifo_i_data,
    input wire fifo_i_last,

    // from output fifo
    input wire fifo_o_ready,

    // from input enc fifo
    input wire enc_fifo_i_valid,
    //input wire [7:0] addr, // 哈夫曼编码表地址

    // from concat
    input wire concat_busy,
    input wire concat_result_ready,

    // from analsys_len
    input wire analsys_len_busy,
    input wire analsys_len_result_ready,

    // from addr gen1
    input wire [7:0] addr_gen1_addr,

    // from addr gen2
    input wire [7:0] addr_gen2_addr,

    // from rom
    input wire [DATA_WIDTH-1:0] rom_dout,

    // to rom
    output wire rom_we, // 写rom
    output wire [7:0] rom_addr, // rom地址

    // to concat
    output wire concat_last,
    output wire concat_start,
    output wire [DATA_WIDTH-1:0] concat_din,

    // to analsys_len
    output wire analsys_len_we,

    // to len_regs
    output wire len_regs_we,
    output wire [7:0] len_regs_addr,

    // to input fifo
    output wire fifo_i_ready,

    // to output fifo
    output wire fifo_o_valid,

    // to input enc fifo
    output wire enc_fifo_i_ready,

    // to addr gen1
    output wire addr_gen1_start,
    output wire addr_gen1_rst,

    // to addr gen2
    output wire addr_gen2_start,
    output wire addr_gen2_rst
);

reg [DATA_WIDTH-1:0] concat_data;
reg [7:0] rom_addr_d; // 存储rom地址，busy信号来的时候，rom地址不变
wire concat_start_;
wire [7:0] rom_addr_select;
reg [7:0] len_regs_addr_d;

assign concat_start_ = fifo_i_valid & fifo_i_ready & (~concat_busy);

// 写rom
assign rom_we = start & enc_fifo_i_valid & we;
assign enc_fifo_i_ready = start & we & (~analsys_len_busy);// TODO
assign addr_gen1_rst = (~start) | (~we);
assign addr_gen1_start = start & enc_fifo_i_valid & we & enc_fifo_i_ready;

// 读rom 编码的 fifo
assign fifo_i_ready = start & rd & (~concat_busy);

// rom 地址
assign rom_addr_select = (we == 1'b1) ? addr_gen1_addr : fifo_i_data;
assign rom_addr = (concat_busy) ? rom_addr_d : rom_addr_select;

// analsys_len
assign analsys_len_we = start & we & enc_fifo_i_valid & enc_fifo_i_ready;
assign addr_gen2_start = analsys_len_result_ready;
assign addr_gen2_rst = (~start) | (~we);

// output fifo
assign fifo_o_valid = concat_result_ready;

// len_regs 
assign len_regs_we = analsys_len_result_ready;
assign len_regs_addr = len_regs_we ? addr_gen2_addr : len_regs_addr_d;

assign concat_din = rom_dout;
assign concat_last = fifo_i_last;
assign concat_start = concat_start_;

// // concat
// always @(posedge clk) begin
//     if (rst) begin
//         concat_start <= 1'b0;
//         concat_last <= 1'b0;
//         concat_data <= 0;
//     end
//     else begin
//         concat_start <= concat_start_;
//         concat_last <= fifo_i_last;
//         if (concat_busy) begin
//             concat_data <= concat_data;
//         end
//         else begin
//             concat_data <= rom_dout;
//         end
//     end
// end
// concat_data_reg
always @(posedge clk) begin
    if (rst) begin
        rom_addr_d <= 0;
    end
    else begin
        if (concat_busy) begin
            rom_addr_d <= rom_addr_d;
        end
        else begin
            rom_addr_d <= rom_addr;
        end
    end
end

// len_d
always @(posedge clk) begin
    if (rst) begin
        len_regs_addr_d <= 0;
    end
    else begin
        if (concat_busy) begin
            len_regs_addr_d <= len_regs_addr_d;
        end
        else begin
            len_regs_addr_d <= fifo_i_data;
        end
    end
end

endmodule