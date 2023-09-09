/*
 * @Author: Haha Chen 
 * @Date: 2023-09-09 12:05:15 
 * @Last Modified by:   Haha Chen 
 * @Last Modified time: 2023-09-09 12:05:15 
 */
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/24 14:44:54
// Design Name: 
// Module Name: tb_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
// import axi4stream_vip_pkg::*;
// import design_1_axi4stream_vip_0_0_pkg::*;

module tb_top;


    bit         rd_0;
    bit         start_0;
    bit         we_0;
    bit         clk;
    bit         rst_n;

    bit         m_axis_tready_0 ;
    bit         m_axis_tvalid_0 ;
    bit         s_axis_tlast_0  ;
    bit         s_axis_tready_0 ;
    bit         s_axis_tready_1 ;
    bit         s_axis_tvalid_0 ;
    bit         s_axis_tvalid_1 ;

    bit [127:0] m_axis_tdata_0  ;
    bit [7:0]  s_axis_tdata_0  ;
    bit [63:0]  s_axis_tdata_1  ;


design_1_wrapper uut(
    .aclk_0             (clk) ,
    .aresetn_0          (rst_n) ,
    .m_axis_tdata_0     (m_axis_tdata_0) ,
    .m_axis_tready_0    (m_axis_tready_0) ,
    .m_axis_tvalid_0    (m_axis_tvalid_0) ,
    .rd_0               (rd_0) ,
    .s_axis_tdata_0     (s_axis_tdata_0) ,
    .s_axis_tdata_1     (s_axis_tdata_1) ,
    .s_axis_tlast_0     (s_axis_tlast_0 ) ,
    .s_axis_tready_0    (s_axis_tready_0) ,
    .s_axis_tready_1    (s_axis_tready_1) ,
    .s_axis_tvalid_0    (s_axis_tvalid_0) ,
    .s_axis_tvalid_1    (s_axis_tvalid_1) ,
    .start_0            (start_0) ,
    .we_0               (we_0)
);

    always #10 clk = ~clk;


    initial begin
        clk = 0;
        rst_n = 0;

        s_axis_tlast_0 = 0;
        m_axis_tvalid_0 = 0;
        s_axis_tdata_0 = 0;

        # 100;
        rst_n = 1;

        # 100;
        start_0 = 1;
        we_0 = 1;
        rd_0 = 0;
        # 20;
        // send_int(1000);
        send_enc();
    end



    task send_int(int num);
        int i;
        for(i=0;i<num;i=i+1)
        begin
            @(posedge clk);
            while(!s_axis_tready_0)
                @(posedge clk);
            if(i==num-1) begin
                s_axis_tlast_0 = 1;
            end
            else begin
                s_axis_tlast_0 = 0;
            end
            m_axis_tvalid_0 = 1;
            s_axis_tdata_0 = i%256;
        end

    endtask

    task send_enc;
        integer fid;
        fid =  $fopen("huffman_code.txt","r");

        for(int i = 0; i < 256; i++) begin
            @(posedge clk);
            while(!s_axis_tready_1)
                @(posedge clk);
            s_axis_tvalid_1 = 1;
            // s_axis_tvalid_1 = 0;
            $fscanf(fid,"%b",s_axis_tdata_1);
            $display(s_axis_tdata_1);
        end
    endtask

endmodule
