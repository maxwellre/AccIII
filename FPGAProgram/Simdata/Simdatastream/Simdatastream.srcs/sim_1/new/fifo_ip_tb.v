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

`define wrclk_period 20
`define rdclk_period 10

module fifo_ip_tb();

    reg rst;
    reg wr_clk;
    reg rd_clk;
    reg [7:0] din;
    reg wr_en;
    reg rd_en;
    
    wire [7:0] dout;
    wire full;
    wire empty;

fifo_ip FIFO_IP_U1
  (
    .rst(rst),
    .wr_clk(wr_clk),
    .rd_clk(rd_clk),
    .din(din),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .dout(dout),
    .full(full),
    .empty(empty)
  );
  
  //generaetor write clock
  initial wr_clk = 1;
  always #(`wrclk_period/2) wr_clk = ~wr_clk;
  
  //generator read clock
  initial rd_clk = 1;
  always #(`rdclk_period/2) rd_clk = ~rd_clk;
  
  integer i, j;
  
  initial begin
        //initial data;
        din = 0;
        wr_en = 0;
        rd_en = 0;
        rst = 0;
        #`wrclk_period;
        
        rst = 1;  //begin to reset;
        #`wrclk_period;
        
        rst = 0;   //finish reset;
        #(`wrclk_period * 3);  //here must 3 time clock, please see the ip document.
 
        #`wrclk_period;
        //begin to write data into the FIFO
        for (i = 0; i <= 5; i = i + 1) begin
            wr_en = 1;
            din = i;       //here write i into din;
            #`wrclk_period;
        end
        
        wr_en = 0;     //stop write
        #`wrclk_period;
        
        #`rdclk_period;   //begin to read data from FIFO
        for(j = 0; j <= 5; j = j + 1) begin
             rd_en = 1;
             #`rdclk_period;
        end
        
        rd_en = 0;   //stop read;
        #`rdclk_period; 
        
        $stop; 
  end
    
  
endmodule
