/*
 * @Author: Haha Chen 
 * @Date: 2023-09-09 12:05:01 
 * @Last Modified by:   Haha Chen 
 * @Last Modified time: 2023-09-09 12:05:01 
 */
`timescale 1ns/1ps
module tb_analsy_len;

    // Parameters
    localparam BUS_WIDTH = 64;
    localparam EXPAND_LEVEL = 1;

    // Inputs
    reg clk;
    reg rst;
    reg [BUS_WIDTH-1:0] din;
    reg we;

    // Outputs
    wire result_ready;
    wire busy;
    wire [BUS_WIDTH-1:0] result;

    // Instantiate the Unit Under Test (UUT)
    analsy_len #(
        .BUS_WIDTH(BUS_WIDTH),
        .EXPAND_LEVEL(EXPAND_LEVEL)
    ) uut (
        .clk(clk),
        .rst(rst),
        .din(din),
        .we(we),
        .result_ready(result_ready),
        .busy(busy),
        .result(result)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Stimulus
    initial begin
        int i ;
        clk = 1;
        // Reset
        rst = 1;
        #10;
        rst = 0;

        // Write data
        we = 1;
        din = {{20{1'b0}}, 6'b010010, 36'h012345678, 2'b00};
        #10;
        we = 0;

        // Wait for result
        
        i = 0;
        while (i < 100) begin
            #10;
            if(result_ready == 1) begin
                $display("result = %d", result);
                $display("i = %d", i);
                break;
            end
            i++;
            
        end

        $finish;
    end

endmodule