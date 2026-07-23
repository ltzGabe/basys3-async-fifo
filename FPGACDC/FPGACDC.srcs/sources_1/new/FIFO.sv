`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.07.2026 19:43:54
// Design Name: 
// Module Name: FIFO
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

module FIFO (
    // Write domain
    input  logic                   wr_clk,
    input  logic                   wr_rst,      // async assert, sync deassert - your choice how deep
    input  logic                   wr_en,
    input  logic [15:0]  wr_data,
    output logic                   full,
    output logic                   almost_full,

    // Read domain
    input  logic                   rd_clk,
    input  logic                   rd_rst,
    input  logic                   rd_en,
    output logic [15:0]  rd_data,
    output logic                   empty,
    output logic                   almost_empty
);
    localparam DATA_WIDTH = 16;
    localparam ADDR_WIDTH = 5 ;      
    
    logic [ADDR_WIDTH:0] rd_ptr ;
    logic [ADDR_WIDTH:0] wr_ptr ;
    
    logic [ADDR_WIDTH-1:0] wr_addr;
    logic [ADDR_WIDTH-1:0] rd_addr;
    logic  rd_wrap;
    logic  wr_wrap;

    assign rd_addr = rd_ptr[ADDR_WIDTH-1:0];
    assign wr_addr = wr_ptr[ADDR_WIDTH-1:0];
    assign rd_wrap = rd_ptr[ADDR_WIDTH];
    assign wr_wrap = wr_ptr[ADDR_WIDTH];


    logic [ADDR_WIDTH:0] grayCode_rd_ptr ;
    logic [ADDR_WIDTH:0] grayCode_wr_ptr ;
    
    logic [ADDR_WIDTH:0] rd_ptr_syncronizer;
    logic [ADDR_WIDTH:0] wr_ptr_syncronizer;

    logic [ADDR_WIDTH:0] grayCode_rd_ptr_synced;
    logic [ADDR_WIDTH:0] grayCode_wr_ptr_synced;
    
    logic [ADDR_WIDTH:0] binary_rd_ptr_synced;
    logic [ADDR_WIDTH:0] binary_wr_ptr_synced;

    logic [DATA_WIDTH-1:0] data [(2**ADDR_WIDTH)-1:0];   
        
    assign grayCode_rd_ptr =  rd_ptr ^ rd_ptr >> 1;
    assign grayCode_wr_ptr =  wr_ptr ^ wr_ptr >>1;
    
    genvar i;
     generate
          for(i=0;i<ADDR_WIDTH;i++) begin
          assign binary_rd_ptr_synced[i] = ^(grayCode_rd_ptr_synced >> i);
          assign binary_wr_ptr_synced[i] = ^(grayCode_wr_ptr_synced >> i);
     end
    endgenerate

    always_ff@(posedge wr_clk, posedge wr_rst) begin 
        //Syncronizer
        rd_ptr_syncronizer <= grayCode_rd_ptr;
        grayCode_rd_ptr_synced <= rd_ptr_syncronizer;
        
        if(wr_rst) begin 
            almost_full <= 0;
            full  <= 0;
            wr_ptr <= 0;          
        end
        else begin 
                if (wr_ptr - rd_ptr >= 30 ) begin 
                    almost_full <=1; 
                end
                else begin 
                    almost_full <=0;
                    if((wr_addr == binary_rd_ptr_synced[ADDR_WIDTH-1:0]) && (wr_wrap != binary_rd_ptr_synced[ADDR_WIDTH]))
                        full <= 1;
                    else begin 
                        full <= 0;
                        if(wr_en & !full & !almost_full) begin 
                            data[wr_addr] <= wr_data;
                            wr_ptr <= wr_ptr +1;
                        end
                    end
                end
         end
        
    end 
    
endmodule