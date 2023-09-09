/*
 * @Author: Haha Chen 
 * @Date: 2023-09-09 12:04:37 
 * @Last Modified by:   Haha Chen 
 * @Last Modified time: 2023-09-09 12:04:37 
 */
//! { signal: [
//!  { name: "clk",  wave: "P......" },
//!  { name: "dout",  wave: "x.=x...", data: ["data"] },
//!  { name: "result_ready", wave: "0.10..." }
//! ],
//!  head:{
//!     text:'dout和result的关系',
//!     tick:0,
//!     every:2
//!   }}

//! { signal: [
//!  { name: "clk",  wave: "P......" },
//!  { name: "last",  wave: "0.10..."},
//!  { name: "busy", wave: "0..1.0." },
//!  { name: "result_ready", wave: "0....10" }
//! ],
//!  head:{
//!     text:'出数据',
//!     tick:0,
//!     every:2
//!   }}

//! { signal: [
//!  { name: "clk",  wave: "P......." },
//!  { name: "last",  wave: "0.10...."},
//!  { name: "overflow",  wave: "0.10...."},
//!  { name: "busy", wave: "0.1..0." },
//!  { name: "result_ready", wave: "0...1.0" },
//!  { name: "dout",  wave: "x...==x.", data: ["data1", "data2"] }
//! ],
//!  head:{
//!     text:'刚好最后一个数据满了，overflow和last同时来了',
//!     tick:0,
//!     every:2
//!   }}

/**
 * The `concat` module concatenates two input data streams into one output data stream.
 * It has a double buffer to store the input data and a state machine to control the concatenation process.
 * 
 * @module concat
 * @param {integer} DATA_WIDTH - The width of the input data.
 * @param {integer} LEN_WIDTH - The width of the input length.
 * @param {integer} OUT_WIDTH - The width of the output data.
 * @param {wire} clk - The clock signal.
 * @param {wire} rst - The reset signal.
 * @param {wire[DATA_WIDTH-1:0]} din - The input data.
 * @param {wire[LEN_WIDTH-1:0]} len - The input length.
 * @param {wire} start - The start signal.
 * @param {wire} last - The last signal.
 * @param {wire} busy - The busy signal.
 * @param {wire} result_ready - The result ready signal.
 * @param {wire[OUT_WIDTH-1:0]} dout - The output data.
 * @param {wire[$clog2(OUT_WIDTH)-1:0]} len_last_out - The length of the last output data.
 *
 * @example
 * 
 * // Instantiate the `concat` module with the following parameters:
 * // DATA_WIDTH = 8, LEN_WIDTH = 8, OUT_WIDTH = 16
 * // Connect the input signals `din`, `len`, `start`, and `last` to the corresponding input ports.
 * // Connect the output signals `busy`, `result_ready`, `dout`, and `len_last_out` to the corresponding output ports.
 * 
 * concat #(
 *     .DATA_WIDTH(8),
 *     .LEN_WIDTH(8),
 *     .OUT_WIDTH(16)
 * ) concat_inst (
 *     .clk(clk),
 *     .rst(rst),
 *     .din(din),
 *     .len(len),
 *     .start(start),
 *     .last(last),
 *     .busy(busy),
 *     .result_ready(result_ready),
 *     .dout(dout),
 *     .len_last_out(len_last_out)
 * );
 */
module concat#(
    parameter integer DATA_WIDTH = 64,
    parameter integer LEN_WIDTH = 64,
    parameter integer OUT_WIDTH = 128
)(
    input wire clk,
    input wire rst,
    input wire [DATA_WIDTH-1:0] din,
    input wire [LEN_WIDTH-1:0] len,
    input wire start,
    input wire last,

    output reg busy,
    output reg result_ready,
    output reg [OUT_WIDTH-1:0] dout,
    output wire [$clog2(OUT_WIDTH)-1:0] len_last_out
);

    localparam  IDLE = 3'b000;
    localparam  CONCAT = 3'b001;
    localparam  LAST = 3'b010;
    localparam  PAD = 3'b011;
    localparam  SQUEEZE1 = 3'b100;
    localparam  SQUEEZE2 = 3'b101;

    // 注意：last信号尽量不要一个时钟就结束，不然可能有意外发生，特别是收到busy信号后
    // 收到busy信号后保持一个时钟周期，待busy结束了，再发下一个数据

    reg [2:0] state;
    reg [2:0] next_state;
    reg [OUT_WIDTH-1:0] buffs[0:1];  // 双缓冲
    reg index; // 在写哪一个缓冲
    reg [$clog2(OUT_WIDTH)-1:0] len_reg; // 记录长度
    reg [DATA_WIDTH-1:0] din_d; // 打一拍延迟
    // reg [DATA_WIDTH-1:0] din_dd; // 打两拍延迟
    // reg start_d; // 打一拍延迟
    // reg len_d; // 打一拍延迟
    // reg len_dd; // 打两拍延迟
    // reg last_d; // 打一拍延迟
    reg [$clog2(OUT_WIDTH)-1:0] len_left; // 上一个字符串剩余长度

    wire overflow;


    assign overflow = len_reg + len > OUT_WIDTH - 1'b1;
    assign len_last_out = len_reg;


    // 打拍
    always @(posedge clk) begin
        din_d <= din;

    end


    // 状态
    always@(posedge clk) begin: state_convert
        if(rst) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    // 下一个状态
    always@(*) begin: gen_next_state
        if (rst) begin
            next_state = IDLE;
            busy = 1'b0;
        end
        else begin
            case (state) 
                IDLE: begin
                    busy = 1'b0;
                    if (start) begin
                        next_state = CONCAT;
                    end
                    else begin
                        next_state = IDLE;
                    end
                end
                CONCAT: begin
                    
                    if (overflow) begin
                        busy = 1'b1;
                        next_state = SQUEEZE1;
                    end
                    else if (last) begin
                        busy = 1'b0;
                        next_state = PAD;
                    end
                    else begin
                        busy = 1'b0;
                        next_state = CONCAT;
                    end
                end
                LAST: begin
                    busy = 1'b1;
                    next_state = SQUEEZE1;
                end
                PAD: begin
                    busy = 1'b1;
                    next_state = SQUEEZE2;
                end
                SQUEEZE1: begin
                    
                    if (last) begin
                        busy = 1'b1;
                        next_state = SQUEEZE2;
                    end
                    else begin
                        busy = 1'b0;
                        next_state = CONCAT;
                    end
                end
                SQUEEZE2: begin
                    busy = 1'b1;
                    next_state = IDLE;
                end
                default :begin
                    next_state = IDLE;
                    busy = 1'b0;
                end
            endcase
        end 
    end

    // 状态动作
    always @(posedge clk) begin
        if (rst) begin
            // 中间变量
            buffs[0] <= 'b0;
            buffs[1] <= 'b0;
            index <= 1'b0;
            len_reg <= 'b0;
            len_left <= 'b0;
            // 输出
            
            result_ready <= 1'b0;
            dout <= 'b0;
        end
        else begin
            case (state)
                IDLE: begin
                    result_ready <= 1'b0;
                    dout <= 'b0;
                    buffs[0] <= 'b0;
                    buffs[1] <= 'b0;
                    index <= 1'b0;
                    len_reg <= 'b0;
                    len_left <= 'b0;
                end
                CONCAT: begin
                    if (overflow) begin
                        result_ready <= 1'b0;
                        dout <= 'b0;
                        buffs[index] <= (buffs[index] << (OUT_WIDTH - len_reg)) | {{(OUT_WIDTH-DATA_WIDTH){1'b0}}, (din >> (len - OUT_WIDTH + len_reg))};
                        index <= index;
                        len_reg <= 'b0;
                        len_left <= len - (OUT_WIDTH - len_reg);
                    end
                    else begin
                        result_ready <= 1'b0;
                        dout <= 'b0;
                        // TODO 拼接做法多多复习
                        buffs[index] <= (buffs[index] << len) | {{(OUT_WIDTH-DATA_WIDTH){1'b0}},din};
                        len_reg <= len_reg + len;
                        index <= index;
                        len_left <= 'b0;
                    end
                end
                LAST: begin
                    result_ready <= 1'b1;
                    dout <= 'b0;
                    buffs[index] <= (buffs[index] << (OUT_WIDTH - len_reg)) | {{(OUT_WIDTH-DATA_WIDTH){1'b0}}, (din >> (len - OUT_WIDTH + len_reg))};
                    index <= index;
                    len_reg <= 'b0;
                    len_left <= len - (OUT_WIDTH - len_reg);
                end
                SQUEEZE1: begin
                    result_ready <= 1'b1;
                    dout <= buffs[index];
                    
                    index <= ~index;
                    len_reg <= len_left;
                    len_left <= 'b0;
                    buffs[~index] <= {{(OUT_WIDTH-DATA_WIDTH){1'b0}}, ~({DATA_WIDTH{1'b1}} << len_left) & din_d};
                    buffs[index] <= buffs[index];
                end
                PAD: begin
                    result_ready <= 1'b0;
                    dout <= 'b0;
                    index <= index;
                    len_reg <= len_reg + len;
                    len_left <= 'b0;
                    buffs[index] <= (buffs[index] << len) | {{(OUT_WIDTH-DATA_WIDTH){1'b0}},din};
                end
                SQUEEZE2: begin
                    result_ready <= 1'b1;
                    dout <= buffs[index];
                    index <= 'b0;
                    len_reg <= len_reg;
                    len_left <= 'b0;
                    buffs[index] <= 'b0;
                    buffs[~index] <= 'b0;
                end
                default: begin
                    result_ready <= 1'b0;
                    dout <= 'b0;
                    buffs[0] <= 'b0;
                    buffs[1] <= 'b0;
                    index <= 1'b0;
                    len_reg <= 'b0;
                    len_left <= 'b0;
                end
            endcase
        end
    end

endmodule