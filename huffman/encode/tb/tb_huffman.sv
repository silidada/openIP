/*
 * @Author: Haha Chen 
 * @Date: 2023-09-09 12:05:10 
 * @Last Modified by:   Haha Chen 
 * @Last Modified time: 2023-09-09 12:05:10 
 */
`timescale 1ns/1ps
module tb_huffman;

    // Parameters
    localparam BUS_WIDTH = 64;
    localparam LEN_WIDTH = 8;
    localparam DATA_WIDTH = 64;
    localparam OUT_WIDTH = 128;
    localparam ROM_NUM = 2;
    localparam ROM_ADDR_WIDTH = 8;
    localparam ROM_DATA_WIDTH = 64;
    localparam EXPAND_LEVEL = 1;
    localparam REG_NUM = 16;

    // Inputs
    reg clk;
    reg rst;
    reg start;
    reg fifo_i_valid;
    reg [7:0] fifo_i_data;
    reg fifo_i_last;
    reg enc_fifo_i_valid;
    reg [BUS_WIDTH-1:0] enc_fifo_i_data;
    reg fifo_o_ready;
    reg we;
    reg rd;

    // Outputs
    wire fifo_i_ready;
    wire enc_fifo_i_ready;
    wire fifo_o_valid;

  // Instantiate the Unit Under Test (UUT)
    huffman #(
    .BUS_WIDTH(BUS_WIDTH),
    .LEN_WIDTH(LEN_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .OUT_WIDTH(OUT_WIDTH),
    .ROM_NUM(ROM_NUM),
    .ROM_ADDR_WIDTH(ROM_ADDR_WIDTH),
    .ROM_DATA_WIDTH(ROM_DATA_WIDTH),
    .EXPAND_LEVEL(EXPAND_LEVEL),
    .REG_NUM(REG_NUM)
    ) uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .fifo_i_valid(fifo_i_valid),
        .fifo_i_data(fifo_i_data),
        .fifo_i_last(fifo_i_last),
        .enc_fifo_i_valid(enc_fifo_i_valid),
        .enc_fifo_i_data(enc_fifo_i_data),
        .fifo_o_ready(fifo_o_ready),
        .we(we),
        .rd(rd),
        .fifo_i_ready(fifo_i_ready),
        .enc_fifo_i_ready(enc_fifo_i_ready),
        .fifo_o_valid(fifo_o_valid)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Stimulus
    initial begin
        // Reset
        clk = 1;
        rst = 1;
        #10;
        rst = 0;

        // Write data to the encoding FIFO
        enc_fifo_i_valid = 1;
        enc_fifo_i_data = 64'h0123456789ABCDEF;
        #10;
        enc_fifo_i_valid = 0;

        // Wait for the encoding FIFO to be processed
        repeat (10) @(posedge clk);
        assert(enc_fifo_i_ready === 1);

        // Write data to the input FIFO
        fifo_i_valid = 1;
        fifo_i_data = 8'h01;
        fifo_i_last = 0;
        #10;
        fifo_i_data = 8'h02;
        #10;
        fifo_i_data = 8'h03;
        fifo_i_last = 1;
        #10;
        fifo_i_valid = 0;

        // Wait for the input FIFO to be processed
        repeat (10) @(posedge clk);
        assert(fifo_i_ready === 1);

        // Start the Huffman encoding process
        start = 1;
        #10;
        start = 0;

        // Wait for the output FIFO to be ready
        repeat (10) @(posedge clk);
        assert(fifo_o_valid === 1);

        // Read data from the output FIFO
        fifo_o_ready = 1;
        #10;
        assert(fifo_o_ready === 0);
        assert(fifo_o_valid === 0);

        $finish;
    end

endmodule