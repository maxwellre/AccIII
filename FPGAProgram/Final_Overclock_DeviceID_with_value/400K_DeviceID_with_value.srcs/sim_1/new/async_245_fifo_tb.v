`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/24/2017 11:03:28 AM
// Design Name: 
// Module Name: async_245_fifo_tb
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

module async_245_fifo_tb();

    reg clk;
    reg rst;
    reg rxf;
    reg txe;
    reg [7:0] D_in;
    
    wire [7:0] io_data;
    wire rd;
    wire wr;
    wire led;
    
    async_245_fifo ASYNC_245_FIFO(
      .i_clk(clk),
      .i_rst(rst),    
      .i_rxf(rxf),        /* receive full (data to receive) - active low */
      .i_txe(txe),        /* transmit empty (data can be sent) - active low */
              
      .io_data(io_data),           /* bi-directional data */
      .o_rd(rd),          /* read data from fifo - active low */
      .o_wr(wr),          /* write data to fifo - active low */
      .o_led(led),
      .o_siwua(o_siwua)
      );
      
    
    assign io_data = (~rd&wr) ? D_in : 8'hz;
    
    //generaetor clock
    initial clk = 1;
    always #(`clk_period/2) clk = ~clk;
  
    initial begin
    // Initialize Inputs
    rxf = 1;
    txe = 1;
    D_in = 8'd0;
    
    rst = 0;      
    #`clk_period;
    
    rst = 1;  //begin to reset;
    #`clk_period;
    
    rst = 0;   //finish reset;
    #(`clk_period * 3);  //here must 3 time clock, please see the ip document.
    
    /* read test according to spec */
    
    rxf = 0;
    @(negedge rd) #14;
    D_in = 8'h55;
    #16;
    rxf = 1;
    #`clk_period;  
   
    /* write test according to spec */
    txe = 0;
    @(negedge wr) #14 txe = 1;
    #49 txe = 0;
    
    #400;
    
    $finish;
    end 
  
endmodule
