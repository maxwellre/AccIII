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
    wire [22:0] iic_en;   
    
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
       
    iic_demo IIC_NUM_00(
           .CLOCK(i_clk), 
           .RESET(sys_rst),      
           .en(iic_en[0]),
           .pull_down(1'b1),
           .SCL(scl[0]),
           .SDA(sda[0]),
           .oData(iic_data[0]),
           .oDone(iic_done[0])
           );
    
    iic_demo IIC_NUM_01(
          .CLOCK(i_clk), 
          .RESET(sys_rst),      
          .en(iic_en[1]),
          .pull_down(1'b1),
          .SCL(scl[1]),
          .SDA(sda[1]),
          .oData(iic_data[1]),
          .oDone(iic_done[1])
           );
         
   iic_demo IIC_NUM_02(
           .CLOCK(i_clk), 
           .RESET(sys_rst),      
           .en(iic_en[2]),
           .pull_down(1'b1),
           .SCL(scl[2]),
           .SDA(sda[2]),
           .oData(iic_data[2]),
           .oDone(iic_done[2])
            );
            
   iic_demo IIC_NUM_03(
            .CLOCK(i_clk), 
            .RESET(sys_rst),      
            .en(iic_en[3]),
            .pull_down(1'b1),
            .SCL(scl[3]),
            .SDA(sda[3]),
            .oData(iic_data[3]),
            .oDone(iic_done[3])
            );  
             
   iic_demo IIC_NUM_04(
           .CLOCK(i_clk), 
           .RESET(sys_rst),      
           .en(iic_en[4]),
           .pull_down(1'b0),
           .SCL(scl[4]),
           .SDA(sda[4]),
           .oData(iic_data[4]),
           .oDone(iic_done[4])
           );   
           
   iic_demo IIC_NUM_05(
           .CLOCK(i_clk), 
           .RESET(sys_rst),      
           .en(iic_en[5]),
           .pull_down(1'b1),
           .SCL(scl[5]),
           .SDA(sda[5]),
           .oData(iic_data[5]),
           .oDone(iic_done[5])
           );
        
   iic_demo IIC_NUM_06(
           .CLOCK(i_clk), 
           .RESET(sys_rst),      
           .en(iic_en[6]),
           .pull_down(1'b1),
           .SCL(scl[6]),
           .SDA(sda[6]),
           .oData(iic_data[6]),
           .oDone(iic_done[6])
           );
         
   iic_demo IIC_NUM_07(
           .CLOCK(i_clk), 
           .RESET(sys_rst),      
           .en(iic_en[7]),
           .pull_down(1'b1),
           .SCL(scl[7]),
           .SDA(sda[7]),
           .oData(iic_data[7]),
           .oDone(iic_done[7])
            );
            
   iic_demo IIC_NUM_08(
            .CLOCK(i_clk), 
            .RESET(sys_rst),      
            .en(iic_en[8]),
            .pull_down(1'b1),
            .SCL(scl[8]),
            .SDA(sda[8]),
            .oData(iic_data[8]),
            .oDone(iic_done[8])
            );  
             
   iic_demo IIC_NUM_09(
           .CLOCK(i_clk), 
           .RESET(sys_rst),      
           .en(iic_en[9]),
           .pull_down(1'b0),
           .SCL(scl[9]),
           .SDA(sda[9]),
           .oData(iic_data[9]),
           .oDone(iic_done[9])
           );  
           
   iic_demo IIC_NUM_10(
           .CLOCK(i_clk), 
           .RESET(sys_rst),      
           .en(iic_en[10]),
           .pull_down(1'b1),
           .SCL(scl[10]),
           .SDA(sda[10]),
           .oData(iic_data[10]),
           .oDone(iic_done[10])
           );
        
    iic_demo IIC_NUM_11(
           .CLOCK(i_clk), 
           .RESET(sys_rst),      
           .en(iic_en[11]),
           .pull_down(1'b1),
           .SCL(scl[11]),
           .SDA(sda[11]),
           .oData(iic_data[11]),
           .oDone(iic_done[11])
           );
         
   iic_demo IIC_NUM_12(
           .CLOCK(i_clk), 
           .RESET(sys_rst),      
           .en(iic_en[12]),
           .pull_down(1'b1),
           .SCL(scl[12]),
           .SDA(sda[12]),
           .oData(iic_data[12]),
           .oDone(iic_done[12])
            );
            
   iic_demo IIC_NUM_13(
            .CLOCK(i_clk), 
            .RESET(sys_rst),      
            .en(iic_en[13]),
            .pull_down(1'b1),
            .SCL(scl[13]),
            .SDA(sda[13]),
            .oData(iic_data[13]),
            .oDone(iic_done[13])
            );  
             
   iic_demo IIC_NUM_14(
           .CLOCK(i_clk), 
           .RESET(sys_rst),      
           .en(iic_en[14]),
           .pull_down(1'b0),
           .SCL(scl[14]),
           .SDA(sda[14]),
           .oData(iic_data[14]),
           .oDone(iic_done[14])
           );      
           
   iic_demo IIC_NUM_15(
           .CLOCK(i_clk), 
           .RESET(sys_rst),      
           .en(iic_en[15]),
           .pull_down(1'b1),
           .SCL(scl[15]),
           .SDA(sda[15]),
           .oData(iic_data[15]),
           .oDone(iic_done[15])
           );
   
    iic_demo IIC_NUM_16(
          .CLOCK(i_clk), 
          .RESET(sys_rst),      
          .en(iic_en[16]),
          .pull_down(1'b1),
          .SCL(scl[16]),
          .SDA(sda[16]),
          .oData(iic_data[16]),
          .oDone(iic_done[16])
           );
         
   iic_demo IIC_NUM_17(
           .CLOCK(i_clk), 
           .RESET(sys_rst),      
           .en(iic_en[17]),
           .pull_down(1'b1),
           .SCL(scl[17]),
           .SDA(sda[17]),
           .oData(iic_data[17]),
           .oDone(iic_done[17])
            );
            
   iic_demo IIC_NUM_18(
            .CLOCK(i_clk), 
            .RESET(sys_rst),      
            .en(iic_en[18]),
            .pull_down(1'b1),
            .SCL(scl[18]),
            .SDA(sda[18]),
            .oData(iic_data[18]),
            .oDone(iic_done[18])
            );  
             
   iic_demo IIC_NUM_19(
           .CLOCK(i_clk), 
           .RESET(sys_rst),      
           .en(iic_en[19]),
           .pull_down(1'b0),
           .SCL(scl[19]),
           .SDA(sda[19]),
           .oData(iic_data[19]),
           .oDone(iic_done[19])
           );      
           
   iic_demo IIC_NUM_20(
           .CLOCK(i_clk), 
           .RESET(sys_rst),      
           .en(iic_en[20]),
           .pull_down(1'b1),
           .SCL(scl[20]),
           .SDA(sda[20]),
           .oData(iic_data[20]),
           .oDone(iic_done[20])
           );
   
    iic_demo IIC_NUM_21(
          .CLOCK(i_clk), 
          .RESET(sys_rst),      
          .en(iic_en[21]),
          .pull_down(1'b1),
          .SCL(scl[21]),
          .SDA(sda[21]),
          .oData(iic_data[21]),
          .oDone(iic_done[21])
           );
         
   iic_demo IIC_NUM_22(
           .CLOCK(i_clk), 
           .RESET(sys_rst),      
           .en(iic_en[22]),
           .pull_down(1'b1),
           .SCL(scl[22]),
           .SDA(sda[22]),
           .oData(iic_data[22]),
           .oDone(iic_done[22])
            );                                                                                                                                                                         
       
   fifo_proc(
            .i_clk(i_clk),
            .i_rst(sys_rst),  
               
            .i_start_en(start_en),            
            
            .o_iic_en(iic_en),            
            .iic_data_bus(iic_data_bus),
            .iic_done(iic_done),
            
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
        
        .o_led(o_led),               //if receive the correct data, light one led;
        
        
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
