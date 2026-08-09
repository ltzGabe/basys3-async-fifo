`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.07.2026 21:19:02
// Design Name: 
// Module Name: fifo_tb
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


module fifo_tb;  

    logic wr_clk;
    logic rd_clk;
    logic wr_rst, rd_rst;
    logic wr_en, rd_en;
    logic [15:0] wr_data;
    logic [15:0] rd_data;
    logic full, almost_full, empty, almost_empty;
    initial wr_clk = 0;
    initial rd_clk = 0;   
    initial begin 
        wr_rst = 0; 
        rd_rst = 0;
        #30 wr_rst = 1; 
        #30 rd_rst = 1; 
        #30 wr_rst = 0;
        #30 rd_rst = 0; 
    end
    always #7  wr_clk = ~wr_clk;
    always #13 rd_clk = ~rd_clk;
    initial begin 
            for (int i = 0; i < 63; i = i + 1) begin 
                @(posedge wr_clk);
                wr_en = 1;
                wr_data = i * 3'd2;
                
                $display("When the FIFO was %0d full the value for almost full and full was %0b, and %0b", i, almost_full, full);
            end      
            wr_en = 0;
  
       end
    FIFO dut (
        .wr_clk(wr_clk),
        .wr_rst(wr_rst),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .full(full),
        .almost_full(almost_full),
        .rd_clk(rd_clk),
        .rd_rst(rd_rst),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .empty(empty),
        .almost_empty(almost_empty)
    );

endmodule
