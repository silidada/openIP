/*
 * @Author: Haha Chen 
 * @Date: 2023-09-09 12:04:59 
 * @Last Modified by:   Haha Chen 
 * @Last Modified time: 2023-09-09 12:04:59 
 */
`timescale 1ns/1ps
module tb_addr_gen;

  // Inputs
  reg clk;
  reg rst;
  reg start;

  // Outputs
  wire [7:0] addr;

  // Instantiate the Unit Under Test (UUT)
  addr_gen uut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .addr(addr)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Stimulus
  initial begin
    clk = 1;
    start = 0;
    // Reset
    rst = 1;
    #10;
    rst = 0;

    // Wait for a few cycles
    repeat (5) @(posedge clk);

    // Start generating addresses
    start = 1;
    #10;

    // Check the first few addresses
    assert(addr === 8'h01);
    #10;
    assert(addr === 8'h02);
    #10;
    assert(addr === 8'h03);
    #10;

    // Stop generating addresses
    start = 0;
    #10;

    // Check that the address generator stops
    assert(addr === 8'h03);
    #10;
    assert(addr === 8'h03);
    #10;
    assert(addr === 8'h03);

    // $finish;
  end

endmodule