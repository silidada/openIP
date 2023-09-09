/*
 * @Author: Haha Chen 
 * @Date: 2023-09-09 12:04:27 
 * @Last Modified by:   Haha Chen 
 * @Last Modified time: 2023-09-09 12:04:27 
 */
//
// This module generates an address signal that increments by one on each clock cycle when the start signal is high.
// The address signal is reset to zero when the reset signal is high.
//
// Inputs:
// - clk: clock signal
// - rst: reset signal
// - start: start signal
//
// Outputs:
// - addr: address signal (8-bit)
//
// Example usage:
// addr_gen addr_gen_inst (
//     .clk(clk),
//     .rst(rst),
//     .start(start),
//     .addr(addr)
// );
//
// The above example instantiates an addr_gen module with the given inputs and outputs.
module addr_gen(
    input wire clk,
    input wire rst,
    input wire start,
    
    output reg [7:0] addr
);

    always @(posedge clk) begin
        if (rst) begin
            addr <= 8'b0;
        end
        else begin
            if (start) begin
                addr <= addr + 8'b1;
            end
            else begin
                addr <= addr;
            end
        end
    end

endmodule