`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/23/2017 09:35:20 PM
// Design Name: 
// Module Name: fifo_proc
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

module fifo_proc(
        input i_clk,
        input i_rst, 
        
        input i_start_en,    
            
        output reg o_iic_en,      
        input [183:0] iic_data_bus,
        input [22:0] iic_done,
        
        output reg o_led,       //if receive the correct data, light one led;
        
        output reg usb_en,
        output reg [7:0] usb_data,
        input usb_done
    );
  
   reg [7:0] i;
   reg [31:0] j;   
   wire [7:0] iic_data [0:22];
      
   assign iic_data_bus = {iic_data[0],  iic_data[1],  iic_data[2],  iic_data[3],  iic_data[4],  iic_data[5],  iic_data[6],  iic_data[7],  iic_data[8],  iic_data[9],  iic_data[10], iic_data[11], iic_data[12], iic_data[13],
                          iic_data[14], iic_data[15], iic_data[16], iic_data[17], iic_data[18], iic_data[19], iic_data[20], iic_data[21], iic_data[22]};
       
   always @(posedge i_clk or posedge i_rst)
     if(i_rst)
     begin
        usb_en <= 1'b0;
        usb_data <= 8'd0;
        i <= 8'd0;
        j <= 32'd0;
        o_iic_en <= 1'b0;
        
        o_led <= 1'b0;
        
     end else begin     
        case (i)
            8'd0: begin 
                o_led <= 1'b1; 
                j <= j+1'b1;   
                                        
               if( j == 32'd134217727 ) 
                begin 
                    j <= 32'd0; 
                    i <= 8'd1; 
                end  
            end
            8'd1: begin 
                o_led <= 1'b0; 
                j <= j+1'b1;   
                                        
               if( j == 32'd134217727 ) 
                begin 
                    j <= 32'd0; 
                    i <= 8'd0; 
                end  
            end

        endcase
     end    
    
endmodule
