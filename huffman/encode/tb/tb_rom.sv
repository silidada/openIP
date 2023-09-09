/*
 * @Author: Haha Chen 
 * @Date: 2023-09-09 12:05:12 
 * @Last Modified by:   Haha Chen 
 * @Last Modified time: 2023-09-09 12:05:12 
 */
`timescale 1ns/1ps
module tb_rom;

  // Parameters
  localparam ROM_NUM = 2;
  localparam ADDR_WIDTH = 8;
  localparam DATA_WIDTH = 64;

  // Inputs
  reg clk;
  reg [ROM_NUM*ADDR_WIDTH-1:0] addr;
  reg we;
  reg [DATA_WIDTH*ROM_NUM-1:0] din;

  // Outputs
  wire [DATA_WIDTH*ROM_NUM-1:0] dout;

  // Instantiate the Unit Under Test (UUT)
  roms #(
    .ROM_NUM(ROM_NUM)
  ) uut (
    .clk(clk),
    .addr(addr),
    .we(we),
    .din(din),
    .dout(dout)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Stimulus
  initial begin
    $display("Start test roms");
    // Initialize Inputs
    clk = 0;
    addr = 0;
    we = 0;
    din = 0;

    // test write data
    for (int i = 0; i<256; i=i+1) begin
      addr = i;
      din = {64'd256+i, 64'b0+i};
      we = 1;
      #10;
    end

    // test read data
    $display("Start test read data");
    
    for (int i = 0; i<256; i=i+1) begin
      we = 0;
      addr = i;
      $display("dout = %d, expected = %d, addr = %d", dout, {64'd256+i, 64'b0+i}, i);
      assert (dout == {64'd256+i, 64'b0+i}) 
      #10;
    end

    // test read write data
    for (int i = 0; i<256; i=i+1) begin
      we = 1;
      addr = i;
      din = {64'd512+i, 64'd768+i};
      #10;
      we = 0;
      addr = i;
      assert (dout == {64'd512+i, 64'd768+i}) 
      #10;
    end
    

    $finish;
  end

endmodule