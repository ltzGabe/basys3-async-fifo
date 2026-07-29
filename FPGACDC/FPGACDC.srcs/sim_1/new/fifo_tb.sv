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

    logic sequential_done;
    logic test2_start_read;
    logic test2_write_done, test2_read_done;
    logic test3_start_write;
    logic test3_read_done, test3_write_done;
    logic reset_test_done;

    initial wr_clk = 0;
    initial rd_clk = 0;
    always #7  wr_clk = ~wr_clk;
    always #13 rd_clk = ~rd_clk;   
    
    // Write then read sequential test 
    initial begin 
        wr_rst = 0; 
        rd_rst = 0;
        #30 wr_rst = 1; 
        #30 rd_rst = 1; 
        #30 wr_rst = 0;
        #30 rd_rst = 0; 

        wr_en = 1;
        for (int i = 0; i < 66; i = i + 1) begin 
            @(posedge wr_clk);
            wr_data = i * 3'd2;
            $display("When the FIFO was %0d full the value for almost full and full was %0b, and %0b", i, almost_full, full);
        end      
        wr_en = 0;
        #50;
        rd_en = 1;
        for (int j = 0; j < 66; j = j + 1) begin 
            @(posedge rd_clk);
            $display("When the FIFO was %0d empty the value for almost empty and empty was %0b, and %0b and the read data was %0d", j, almost_empty, empty, rd_data);
        end  
        rd_en = 0;
        sequential_done = 1;
    end
       
    initial begin 
        wait(sequential_done) begin
            wr_en = 1;
            for (int i = 0; i < 66; i = i + 1) begin 
                @(posedge wr_clk);         
                wr_data = i * 3'd2;
                if (i == 33)
                    test2_start_read = 1;
                $display("When the FIFO was %0d full the value for almost full and full was %0b, and %0b", i, almost_full, full);
            end 
            wr_en = 0;    
            test2_write_done = 1;
        end
    end

    initial begin 
        wait(test2_start_read) begin
            rd_en = 1;
            for (int j = 0; j < 66; j = j + 1) begin 
                @(posedge rd_clk);
                $display("When the FIFO was %0d empty the value for almost empty and empty was %0b, and %0b and the read data was %0d", j, almost_empty, empty, rd_data);
            end  
            rd_en = 0;    
            test2_read_done = 1;
        end       
    end

    // reset with data still in the fifo
    initial begin
        wait(test2_write_done && test2_read_done) begin
            wr_en = 1;
            for (int i = 0; i < 5; i = i + 1) begin
                @(posedge wr_clk);
                wr_data = i * 3'd2;
            end
            wr_en = 0;

            @(posedge wr_clk);
            wr_rst = 1;
            rd_rst = 1;
            $display("reset asserted: full=%0b empty=%0b", full, empty);
            @(posedge wr_clk);
            @(posedge rd_clk);
            wr_rst = 0;
            rd_rst = 0;
            $display("reset released: full=%0b empty=%0b", full, empty);

            reset_test_done = 1;
        end
    end
       
    initial begin 
        wait(reset_test_done) begin
            rd_en = 1;
            for (int j = 0; j < 66; j = j + 1) begin 
                @(posedge rd_clk);
                if (j == 33)
                    test3_start_write = 1;
                $display("Read-first test: FIFO %0d empty, almost_empty=%0b, empty=%0b, rd_data=%0d", j, almost_empty, empty, rd_data);
            end  
            rd_en = 0;    
            test3_read_done = 1;
        end       
    end

    initial begin
        wait(test3_start_write) begin
            wr_en = 1;
            for (int i = 0; i < 66; i = i + 1) begin
                @(posedge wr_clk);
                wr_data = i * 3'd2;
                $display("Read-first test: FIFO %0d full, almost_full=%0b, full=%0b", i, almost_full, full);
            end
            wr_en = 0;
            test3_write_done = 1;
        end
    end

    initial begin
        wait(test3_read_done && test3_write_done);
        $finish;
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


