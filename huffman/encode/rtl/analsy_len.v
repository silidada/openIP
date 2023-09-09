/*
 * @Author: Haha Chen 
 * @Date: 2023-09-09 12:04:32 
 * @Last Modified by:   Haha Chen 
 * @Last Modified time: 2023-09-09 12:04:32 
 */
/**
 * @brief This module analyzes the length of a Huffman code and expands it to a specified level.
 *
 * @param END_ The end symbol of the Huffman code.
 * @param BUS_WIDTH The bus width of the input and output signals.
 * @param EXPAND_LEVEL The level to which the Huffman code is expanded.
 *
 * @param clk The clock signal.
 * @param rst The reset signal.
 * @param din The input signal containing the Huffman code.
 * @param we The write enable signal for the input signal.
 * @param result_ready The output signal indicating that the result is ready.
 * @param busy The output signal indicating that the module is busy.
 * @param result The output signal containing the expanded Huffman code.
 *
 * @example
 * // Instantiate the module with the default parameters.
 * analsy_len #(
 *     .END_(6'b010010),
 *     .BUS_WIDTH(64),
 *     .EXPAND_LEVEL(1)
 * ) al (
 *     .clk(clk),
 *     .rst(rst),
 *     .din(din),
 *     .we(we),
 *     .result_ready(result_ready),
 *     .busy(busy),
 *     .result(result)
 * );
 */
module analsy_len#(
    parameter integer END_ = 6'b010010,
    parameter integer BUS_WIDTH = 64,
    parameter integer EXPAND_LEVEL = 1
)
(
    input wire clk,
    input wire rst,
    input wire [BUS_WIDTH-1:0]din,
    input wire we,

    output reg result_ready,
    output reg busy,
    output reg [BUS_WIDTH-1:0] result
);

    localparam END_SYMBOL = {{(BUS_WIDTH-6){1'b0}}, END_[5:0]};
    
    localparam IDLE = 2'b00;
    localparam WRITING = 2'b01;
    localparam ANALSYSING = 2'b10;
    localparam DONE = 2'b11;

    reg [1:0] state;
    reg [BUS_WIDTH-1:0] regs [0:EXPAND_LEVEL-1];
    reg [63:0] index[0:EXPAND_LEVEL-1];
    wire [BUS_WIDTH-1:0] index_masked [0:EXPAND_LEVEL-1];
    wire ok;
    reg start;
    reg writing;
    wire [EXPAND_LEVEL-1:0] status;

    reg [BUS_WIDTH-1:0] din_d;

    assign ok = status || {EXPAND_LEVEL{1'b0}};

    // 状态
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
        end
        case (state)
            IDLE:  begin
                if (we) begin
                    state <= WRITING;
                end
                else begin
                    state <= IDLE;
                end
            end
            WRITING: begin
                state <= ANALSYSING;
            end
            ANALSYSING: begin
                if(ok) begin
                    state <= DONE;
                end
                else begin
                    state <= ANALSYSING;
                end
            end
            DONE: begin
                if(we) begin
                    state <= WRITING;
                end
                else begin
                state <= IDLE;
                end
            end
            default: begin
                state <= IDLE;
            end
        endcase
    end

    // 信号
    always@(*) begin
        if (rst) begin
            busy = 1'b0;
            result_ready = 1'b0;
            // ok = 1'b0;
            start = 1'b0;
            writing = 1'b0;
        end
        else begin
            case (state) 
                IDLE: begin
                    busy = 1'b0;
                    result_ready = 1'b0;
                    // ok = 1'b0;
                    start = 1'b0;
                    writing = 1'b0;
                end
                WRITING: begin
                    busy = 1'b1;
                    result_ready = 1'b0;
                    // ok = 1'b0;
                    start = 1'b0;
                    writing = 1'b1;
                end
                ANALSYSING: begin
                    busy = 1'b1;
                    result_ready = 1'b0;
                    // ok = 1'b0;
                    start = 1'b1;
                    writing = 1'b0;
                end
                DONE: begin
                    busy = 1'b0;
                    result_ready = 1'b1;
                    // ok = 1'b1;
                    start = 1'b0;
                    writing = 1'b0;
                end
                default: begin
                    busy = 1'b0;
                    result_ready = 1'b0;
                    // ok = 1'b0;
                    start = 1'b0;
                    writing = 1'b0;
                end
            endcase
        end
    end



    // 移位判断
    generate
        genvar i;
        for (i = 0; i < EXPAND_LEVEL; i=i+1)begin
            always @(posedge clk) begin
                if(rst) begin
                    regs[i] <= 'b0;
                    index[i] <= 64'b0;
                end
                else begin
                    if(writing) begin
                        regs[i] <= din_d;
                    end
                    else if(start) begin
                        index[i] <= index[i] + 1;
                        // regs[i] <= {{(EXPAND_LEVEL){1'b0}}, regs[i][(BUS_WIDTH-EXPAND_LEVEL-1):0]};
                        regs[i] <= (regs[i] >> 1);
                    end
                    else if(result_ready) begin
                        regs[i] <= 'b0;
                        index[i] <= 64'b0;
                    end
                    else begin
                        regs[i] <= regs[i];
                    end
                end
            end
        end
    endgenerate


    // 每个通道都要判断是不是等于结束符了
    generate
        genvar j;
        for (j = 0; j<EXPAND_LEVEL; j=j+1)begin
            assign status[j] = (regs[j] == END_SYMBOL);
            assign index_masked[j] = index[j] & {64{status[j]}};
        end
    endgenerate

    // TODO
    always @(posedge clk) begin
        if(rst) result <= 'b0;
        else result <= index_masked[0];
    end

    always @(posedge clk) begin
        if(rst) din_d <= 'b0;
        else din_d <= din;
    end

endmodule