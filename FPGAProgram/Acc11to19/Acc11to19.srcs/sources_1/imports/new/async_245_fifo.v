`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/26/2017 11:16:33 AM
// Design Name: 
// Module Name: sync_245_fifo
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

module async_245_fifo(
    input i_clk,
    input i_rst,    
    input i_rxf,            /* receive full (data to receive) - active low */
    input i_txe,            /* transmit empty (data can be sent) - active low */
            
    inout [7:0] io_data,    /* bi-directional data */
    output o_rd,            /* read data from fifo - active low */
    output o_wr,            /* write data to fifo - active low */
    output o_led,
    
  	output [22:0] scl,
    inout  [22:0] sda   
    );
    
    wire sys_rst;
    wire start_en;
    wire iic_en;   
    
    wire [7:0] usb_data;
    wire usb_en;
    wire usb_done;
    
    wire [22:0] iic_done;
    wire [7:0] iic_data [0:22];      
    wire [183:0] iic_data_bus;
    
    assign iic_data_bus = {iic_data[0],  iic_data[1],  iic_data[2],  iic_data[3],  iic_data[4],  iic_data[5],  iic_data[6],  iic_data[7],  iic_data[8],  iic_data[9],  iic_data[10], iic_data[11], iic_data[12], iic_data[13],
                           iic_data[14], iic_data[15], iic_data[16], iic_data[17], iic_data[18], iic_data[19], iic_data[20], iic_data[21], iic_data[22]};
    
    sys_rst SYS_RST(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .o_rst(sys_rst)
       ); 
       
    iic_demo IIC_NUM_05(
           .CLOCK(i_clk), 
           .RESET(sys_rst),      
           .en(iic_en),
           .pull_down(1'b1),
           .SCL(scl[5]),
           .SDA(sda[5]),
           .oData(iic_data[5]),
           .oDone(iic_done[5])
           );
    
    iic_demo IIC_NUM_06(
          .CLOCK(i_clk), 
          .RESET(sys_rst),      
          .en(iic_en),
          .pull_down(1'b1),
          .SCL(scl[6]),
          .SDA(sda[6]),
          .oData(iic_data[6]),
          .oDone(iic_done[6])
           );
         
   iic_demo IIC_NUM_07(
           .CLOCK(i_clk), 
           .RESET(sys_rst),      
           .en(iic_en),
           .pull_down(1'b1),
           .SCL(scl[7]),
           .SDA(sda[7]),
           .oData(iic_data[7]),
           .oDone(iic_done[7])
            );
            
   iic_demo IIC_NUM_08(
            .CLOCK(i_clk), 
            .RESET(sys_rst),      
            .en(iic_en),
            .pull_down(1'b1),
            .SCL(scl[8]),
            .SDA(sda[8]),
            .oData(iic_data[8]),
            .oDone(iic_done[8])
            );  
             
   iic_demo IIC_NUM_09(
           .CLOCK(i_clk), 
           .RESET(sys_rst),      
           .en(iic_en),
           .pull_down(1'b0),
           .SCL(scl[9]),
           .SDA(sda[9]),
           .oData(iic_data[9]),
           .oDone(iic_done[9])
           );   
                                                                                                                                                          
    /**/   
   fifo_proc(
            .i_clk(i_clk),
            .i_rst(sys_rst),  
               
            .i_start_en(start_en),            
            
            .o_iic_en(iic_en),            
            .iic_data_bus(iic_data_bus),
            .iic_done(iic_done),
            
            .o_led(o_led),               //if receive the correct data, light one led;
            
            .usb_en(usb_en),
            .usb_data(usb_data),
            .usb_done(usb_done)
           );    
       
       
   usb_handle USB_Handle(
        .i_clk(i_clk),
        .i_rst(sys_rst),    
        .i_rxf(i_rxf),               // receive full (data to receive) - active low
        .i_txe(i_txe),               // transmit empty (data can be sent) - active low 
        
        .io_data(io_data),           // bi-directional data 
        .o_rd(o_rd),                 // read data from fifo - active low 
        .o_wr(o_wr),                 // write data to fifo - active low 
        
        //.o_led(o_led),               //if receive the correct data, light one led;
        
        
        .o_start_en(start_en),           //enable iic communication;

        .send_data(usb_data),    //iic data from iic;
        .send_en(usb_en),
        .send_done(usb_done)              
      );
       
   /************************************
    clk_wiz_0 CLK_DIV
        (
        // Clock in ports
         .i_clk_100M(i_clk),
         // Clock out ports
         .o_clk_25M(clk_50M),
         // Status and control signals
         .i_rst(sys_rst)
        );   
    ******************************/       
        
 
    
endmodule
