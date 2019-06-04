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
   reg [7:0] j;   
   wire [7:0] iic_data [0:22];
      
   assign iic_data_bus = {iic_data[0],  iic_data[1],  iic_data[2],  iic_data[3],  iic_data[4],  iic_data[5],  iic_data[6],  iic_data[7],  iic_data[8],  iic_data[9],  iic_data[10], iic_data[11], iic_data[12], iic_data[13],
                          iic_data[14], iic_data[15], iic_data[16], iic_data[17], iic_data[18], iic_data[19], iic_data[20], iic_data[21], iic_data[22]};
       
   always @(posedge i_clk or posedge i_rst)
     if(i_rst)
     begin
        usb_en <= 1'b0;
        usb_data <= 8'd0;
        i <= 8'd0;
        j <= 8'd0;
        o_iic_en <= 1'b0;
        
        o_led <= 1'd0;     
        
     end else begin     
        case (i)
         8'd0: if (i_start_en) begin i <= 8'd1; o_led <= 1'b1; end            
         8'd1: begin o_iic_en <= 1'b1; i <= 8'd2; end  
         8'd2: begin o_iic_en <= 1'b0; i <= 8'd5; end 
         
         8'd3: begin usb_en <= 1'b1; i <= 8'd4; end            
         8'd4: if (usb_done)begin i <= j; usb_en <= 1'b0; end  
          
         8'd5:  if (iic_done == 23'b000_0000_0000_0000_0001_1111) i <= 8'd6;  
         
         8'd6:  begin usb_data <= iic_data[00]; i <= 8'd3; j <= 8'd07; end  
         8'd7:  begin usb_data <= iic_data[01]; i <= 8'd3; j <= 8'd08; end     
         8'd8:  begin usb_data <= iic_data[02]; i <= 8'd3; j <= 8'd09; end  
         8'd9:  begin usb_data <= iic_data[03]; i <= 8'd3; j <= 8'd10; end          
         8'd10: begin usb_data <= iic_data[04]; i <= 8'd3; j <= 8'd01; end                                  
        endcase
        
       /************
        case (i)
            8'd0: begin usb_data <= j; i <= 8'd1; j <= j+1; end          
            8'd1: begin usb_en <= 1'b1; i <= 8'd2; end
            8'd2: begin usb_en <= 1'b0; i <= 8'd3; end       
            8'd3: if ( usb_done )begin i <= 8'd0; end 
        endcase
        ***********/
     end    
    
endmodule
