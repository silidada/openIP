/*
 * @Author: Haha Chen 
 * @Date: 2023-09-09 12:04:46 
 * @Last Modified by:   Haha Chen 
 * @Last Modified time: 2023-09-09 12:04:46 
 */
//! { signal: [
//!  { name: "clk",  wave: "P......" },
//!  { name: "bus",  wave: "x.==.=x", data: ["head", "body", "tail", "data"] },
//!  { name: "wire", wave: "0.1..0." }
//! ],
//!  head:{
//!     text:'WaveDrom example',
//!     tick:0,
//!     every:2
//!   }}

/**
 * @brief This module implements a register file with configurable width and number of registers.
 * 
 * @param BUS_WIDTH The width of the data bus.
 * @param REG_NUM The number of registers in the file.
 * @param len The input data to be written to the register file.
 * @param addr The address of the register to be written to or read from.
 * @param we Write enable signal. When high, the input data is written to the register file.
 * @param dout The output data read from the register file.
 * 
 * @example
 * // Instantiate a len_regs module with 8-bit bus width and 16 registers
 * len_regs #(
 *     .BUS_WIDTH(8),
 *     .REG_NUM(16)
 * ) my_regs (
 *     .len(data_in),
 *     .addr(reg_addr),
 *     .we(write_en),
 *     .dout(data_out)
 * );
 */

module len_regs#(
    parameter integer BUS_WIDTH = 6,
    parameter integer REG_NUM = 256
)
(
    input wire [BUS_WIDTH-1:0] len,
    input wire [$clog2(REG_NUM) - 1:0] addr,
    input wire we,
    output reg [BUS_WIDTH-1:0] dout
);

reg [BUS_WIDTH-1:0] regs [0:REG_NUM-1];

always @(*) begin
    // 写优先
    if (we) begin
        regs[addr] <= len;
        dout <= len;
    end
    else begin
        regs[addr] <= regs[addr];
        dout <= regs[addr];
    end
end



endmodule