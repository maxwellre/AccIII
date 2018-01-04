`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/24/2017 09:06:40 AM
// Design Name: 
// Module Name: usb_handle
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


module usb_handle(
    input i_clk,
    input i_rst,    
    input i_rxf,            /* receive full (data to receive) - active low */
    input i_txe,            /* transmit empty (data can be sent) - active low */
        
    inout [7:0] io_data,    /* bi-directional data */
    output reg o_rd,        /* read data from fifo - active low */
    output reg o_wr,        /* write data to fifo - active low */
    
    output reg o_led,       //if receive the correct data, light one led;
    
    output reg o_start_en,      //enable iic communication;
    input [7:0] send_data,    //iic data from iic;
    input send_en,
    output reg send_done              
    );
        
    reg [15:0] i;
    reg [15:0] j;
    reg [7:0] data;
    reg [7:0] r_data;
    reg [27:0] count;
    reg isQ;
    
   assign io_data = isQ ? r_data : 8'hz;	       
       
   always @(posedge i_clk or posedge i_rst)
             if(i_rst)
             begin
                i <= 16'd0;
                j <= 16'd0;
                data <= 8'd0;
                r_data <= 8'd0;
                count <= 28'd0;
                
                o_rd <= 1'd1;
                o_wr <= 1'd1;
                isQ <= 1'd1;    
                
                o_led <= 1'd0;          
                
                o_start_en <= 1'd0;   
                send_done <= 1'd0;          
             end else begin
                case(i)
                //---------------------------------------------------
                16'd0   :if (i_rxf == 1'b0) 
                         begin 
                            o_rd <= 1'b0;          //begin to read data;
                            j <= j+1'b1; 
                            if( j == 16'd2 ) 
                            begin 
                                j <= 16'd0; 
                                i <= 16'd1; 
                            end 
                         end  
                //---------------------------------------------------         
                16'd1   :begin     
                            isQ <= 1'b0;            //set the input data direction;
                            data <= io_data;                      
                            j <= j+1'b1; 
                            if( j == 16'd2 ) 
                            begin 
                                o_rd <= 1'b1;       //end to read data;
                                j <= 16'd0; 
                                i <= 16'd2; 
                            end 
                         end
                //---------------------------------------------------
                16'd2   :begin  
                            if (data == 8'h55)       //receive 0x55 from PC;
                            begin 
                                o_led <= 1'b1; 
                                o_start_en <= 1'b1;    //enable iic module;
                                i <= 16'd3; 
                                isQ <= 1'd1;
                            end 
                            else
                                i <= 16'd0;          //go to receive data again;
                         end                       
                //---------------------------------------------------    
                16'd3   :if (send_en == 1'b1)  
                         begin  
                            r_data <= send_data;
                            send_done <= 1'd0;
                            i <= 16'd4; 
                         end                       
                16'd4   :if (i_txe == 1'b0)
                         begin  
                            o_wr <= 1'b0;             //begin to send data;
                            j <= j+1'b1; 
                            if( j == 16'd5 ) 
                            begin 
                               send_done <= 1'd1;
                               o_wr <= 1'b1;          //end to send data;
                               j <= 16'd0; 
                               i <= 16'd3;
                            end                             
                         end    
                                                                           
              default: ;
              endcase                
             end    
    
endmodule
