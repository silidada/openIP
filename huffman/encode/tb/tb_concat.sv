/*
 * @Author: Haha Chen 
 * @Date: 2023-09-09 12:05:03 
 * @Last Modified by:   Haha Chen 
 * @Last Modified time: 2023-09-09 12:05:03 
 */
`timescale 1ns/1ps
/*
add wave -position end  sim:/tb_concat/clk
add wave -position end  sim:/tb_concat/rst
add wave -position end  sim:/tb_concat/din
add wave -position end  sim:/tb_concat/len
add wave -position end  sim:/tb_concat/start
add wave -position end  sim:/tb_concat/last
add wave -position end  sim:/tb_concat/busy
add wave -position end  sim:/tb_concat/result_ready
add wave -position end  sim:/tb_concat/dout
add wave -position end  sim:/tb_concat/len_last_out
add wave -position end  sim:/tb_concat/uut/din
add wave -position end  sim:/tb_concat/uut/len
add wave -position end  sim:/tb_concat/uut/start
add wave -position end  sim:/tb_concat/uut/last
add wave -position end  sim:/tb_concat/uut/busy
add wave -position end  sim:/tb_concat/uut/result_ready
add wave -position end  sim:/tb_concat/uut/dout
add wave -position end  sim:/tb_concat/uut/len_last_out
add wave -position end  sim:/tb_concat/uut/state
add wave -position end  sim:/tb_concat/uut/next_state
add wave -position end  sim:/tb_concat/uut/buffs
add wave -position end  sim:/tb_concat/uut/index
add wave -position end  sim:/tb_concat/uut/len_reg
add wave -position end  sim:/tb_concat/uut/din_d
add wave -position end  sim:/tb_concat/uut/len_left
add wave -position end  sim:/tb_concat/uut/overflow
*/

module tb_concat;

    // Parameters
    localparam DATA_WIDTH = 64;
    localparam LEN_WIDTH = 64;
    localparam OUT_WIDTH = 128;

    // Inputs
    reg clk;
    reg rst;
    reg [DATA_WIDTH-1:0] din;
    reg [LEN_WIDTH-1:0] len;
    reg start;
    reg last;

    // Outputs
    wire busy;
    wire result_ready;
    wire [OUT_WIDTH-1:0] dout;
    wire [$clog2(OUT_WIDTH)-1:0] len_last_out;

    // Instantiate the Unit Under Test (UUT)
    concat #(
        .DATA_WIDTH(DATA_WIDTH),
        .LEN_WIDTH(LEN_WIDTH),
        .OUT_WIDTH(OUT_WIDTH)
    ) uut (
        .clk(clk),
        .rst(rst),
        .din(din),
        .len(len),
        .start(start),
        .last(last),
        .busy(busy),
        .result_ready(result_ready),
        .dout(dout),
        .len_last_out(len_last_out)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Stimulus
    initial begin
        // $display("Start test");
        static logic [OUT_WIDTH-1:0] result_expected = 0;
        static logic [OUT_WIDTH-1:0] result_expected_d = 0;
        static integer len_expected = 0;
        clk = 1;
        // Reset
        rst = 1;
        #10;
        rst = 0;

        // Write data
        $display("Start test");
        start = 1;
        for (int i = 0; i < 30; i++) begin
            
            if (i == 29) begin
                last = 1;
                start = 0;
            end
            else begin
                last = 0;
                start = 1;
            end
            len = 64'h0000000000000007;
            din = 64'h000000000000005F;
            len_expected += 7;
            // $display("len_expected: %d", len_expected);
            if(len_expected <= OUT_WIDTH) begin
                result_expected = {result_expected[OUT_WIDTH-7-1:0], din[6:0]};
                // 10111111011111101111110111111011111101111110111111011111101111110111111011111101111110111111011111101111110111111011111101111110
                // 10111111011111101111110111111011111101111110111111011111101111110111111011111101111110111111011111101111110111111011111101111110
                // 1111110111111011111101111110111111011111101111111
                //0001 0111 1110 1111 1101 1111
            end
            else begin
                result_expected = (result_expected << (7 - (len_expected - OUT_WIDTH))) | (din >> (len_expected - OUT_WIDTH));
            end
            #10;
            while (busy) begin
                #10;
            end
            if (result_ready) begin
                $display("get result");
                assert(len_expected < OUT_WIDTH);
                assert(dout === result_expected_d);
                // $display("Result: %b", dout);
                // $display("Result expected: %b", result_expected_d);
            end
            result_expected_d = result_expected;
            if(len_expected >= OUT_WIDTH) begin
                len_expected -= OUT_WIDTH;
                result_expected = din & (~({DATA_WIDTH{1'b1}} << len_expected));
            end
            
        end

        $display("final result: %b", dout);
        $display("final len_last_out: %b", len_last_out);
        #10;
        start = 0;

        $display("End test");
        // $finish;

        // Wait for result
        // repeat (10) @(posedge clk);
        // assert(result_ready === 1);
        // assert(busy === 0);
        // assert(dout === {64'h0000000000000008, 64'h0123456789ABCDEF});
        // assert(len_last_out === 1);

        // $finish;
    end

endmodule