/*
 * @Author: Haha Chen 
 * @Date: 2023-09-09 12:04:49 
 * @Last Modified by:   Haha Chen 
 * @Last Modified time: 2023-09-09 12:04:49 
 */
/**
 * ROM module that generates one or more read-only memory blocks.
 *
 * @module roms
 * @param  {integer} ROM_NUM     - The number of ROM blocks to generate.
 * @param  {integer} ADDR_WIDTH  - The width of the address bus for each ROM block.
 * @param  {integer} DATA_WIDTH  - The width of the data bus for each ROM block.
 * @param  {wire}    clk         - The clock signal.
 * @param  {wire}    addr        - The address bus for all ROM blocks.
 * @param  {wire}    we          - The write enable signal for all ROM blocks.
 * @param  {wire}    din         - The data input bus for all ROM blocks.
 * @param  {wire}    dout        - The data output bus for all ROM blocks.
 *
 * @example
 * // Instantiate a ROM module with 2 ROM blocks, 8-bit address bus, and 64-bit data bus.
 * roms #(
 *   .ROM_NUM(2),
 *   .ADDR_WIDTH(8),
 *   .DATA_WIDTH(64)
 * ) my_rom (
 *   .clk(clk),
 *   .addr(addr),
 *   .we(we),
 *   .din(din),
 *   .dout(dout)
 * );
 */
`define ADDR_WIDTH 8
`define DATA_WIDTH 64

module roms #(
    parameter integer  ROM_NUM = 1
    // parameter integer ADDR_WIDTH = 8,
    // parameter integer DATA_WIDTH = 64
  )
  (
    input wire clk, 

    input wire [ROM_NUM*`ADDR_WIDTH-1:0] addr,
    input wire we,
    input wire [`DATA_WIDTH*ROM_NUM-1:0] din,
    output wire [`DATA_WIDTH*ROM_NUM-1:0] dout

  );

  generate
    genvar i;
    for (i = 0; i < ROM_NUM; i=i+1)
    begin
        blk_mem_gen_0 inst_rom (
            .clka(clk),    // input wire clka
            .wea(we),      // input wire [0 : 0] wea
            .addra(addr[(i+1)*`ADDR_WIDTH-1 : i*`ADDR_WIDTH]),  // input wire [7 : 0] addra
            .dina(din[(i+1)*`DATA_WIDTH-1 : i*`DATA_WIDTH]),    // input wire [63 : 0] dina
            .douta(dout[(i+1)*`DATA_WIDTH-1 : i*`DATA_WIDTH])  // output wire [63 : 0] douta
            );
    end
  endgenerate


endmodule
