`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/26/2017 11:46:19 AM
// Design Name: 
// Module Name: fifo_ip_tb
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

`define clk_period 10

module fifo_ip_tb();

    reg rst;
    reg clk;
    reg [7:0] din;
    reg wr_en;
    reg rd_en;
    
    wire [7:0] dout;
    wire full;
    wire empty;

fifo_IIC FIFO_IIC_01(
    .clk(clk),
    .srst(rst),
    .din(din),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .dout(dout),
    .full(full),
    .empty(empty)
  );
  
    
  initial clk = 1;
  always #(`clk_period/2) clk = ~clk;  
  
  integer i, j;
  
  initial begin
        //initial data;
        din = 0;
        wr_en = 0;
        rd_en = 0;
        rst = 0;
        #`clk_period;
        
        rst = 1;  //begin to reset;
        #`clk_period;
        
        rst = 0;   //finish reset;
        #(`clk_period * 3);  //here must 3 time clock, please see the ip document.
 
        #`clk_period;
        //begin to write data into the FIFO
        for (i = 0; i <= 25; i = i + 1) begin
            wr_en = 1;
            din = i+1;       //here write i into din;
            #`clk_period;
        end
        
        wr_en = 0;     //stop write
        #`clk_period;
        
        #`clk_period;   //begin to read data from FIFO
        for(j = 0; j <= 25; j = j + 1) begin
             rd_en = 1;
             #`clk_period;
        end
        
        rd_en = 0;   //stop read;
        #`clk_period; 
        
        $stop; 
  end
    
  
endmodule
