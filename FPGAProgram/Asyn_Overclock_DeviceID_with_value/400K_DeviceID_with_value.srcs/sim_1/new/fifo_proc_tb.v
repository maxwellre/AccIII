`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/28/2017 09:23:56 PM
// Design Name: 
// Module Name: fifo_proc_tb
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

module fifo_proc_tb();
 
 reg i_clk;
 reg i_rst; 
 reg i_start_en;    
    
 wire [22:0] o_iic_en;      
 reg [183:0] iic_data_bus;
 reg [22:0] iic_done;

 wire usb_en;
 wire [7:0] usb_data;
 reg usb_done;
 
    fifo_proc FIFO_PROC(
        .i_clk(i_clk),
        .i_rst(i_rst), 
        
        .i_start_en(i_start_en),    
            
        .o_iic_en(o_iic_en),      
        .iic_data_bus(iic_data_bus),
        .iic_done(iic_done),
        
        .usb_en(usb_en),
        .usb_data(usb_data),
        .usb_done(usb_done)
    );
    
    initial i_clk = 1;
    always #(`clk_period/2) i_clk = ~i_clk;  
      
     initial begin
           //initial data;
          iic_data_bus = { 8'h10, 8'h11, 8'h12, 8'h13, 8'h14, 8'h15, 8'h16, 8'h17, 8'h18, 8'h19,
                           8'h20, 8'h21, 8'h22, 8'h23, 8'h24, 8'h25, 8'h26, 8'h27, 8'h28, 8'h29,
                           8'h30, 8'h31, 8'h32};           
           i_rst = 0;
           i_start_en = 0;
           iic_done = 23'd0;
           usb_done = 0;
           #`clk_period;
           
           i_rst = 1;  //begin to reset;
           #`clk_period;
           
           i_rst = 0;   //finish reset;
           #(`clk_period * 3);  //here must 3 time clock, please see the ip document.
           
           #`clk_period;
           i_start_en = 1;
           
            #`clk_period;
           iic_done = 23'b111_1111_1111_1111_1111_1111;
           usb_done = 1'b1;
          
            #`clk_period;
      
     end
endmodule
