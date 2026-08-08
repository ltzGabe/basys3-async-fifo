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


module fifo_tb;   // no ports - this is the simulation top

    // Signals to drive/observe the FIFO - these ARE what would have been ports
    logic wr_clk;
    logic rd_clk;
    logic wr_rst, rd_rst;
    logic wr_en, rd_en;
    logic [15:0] wr_data;
    logic [15:0] rd_data;
    logic full, almost_full, empty, almost_empty;

    always #7  wr_clk = ~wr_clk;
    always #13 rd_clk = ~rd_clk;

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
