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
              
        output reg [22:0] o_iic_en,      
        input [183:0] iic_data_bus,
        input [22:0] iic_done,
        
        output reg usb_en,
        output reg [7:0] usb_data,
        input usb_done
    );
  
   reg [7:0] i;
   reg [7:0] j;      
   reg [7:0] i0;
   reg [7:0] j0;   
   reg [8:0] k0;  
      
   wire [7:0] iic_data [0:22];
   wire [7:0] fifo_out [0:1];
  // wire [7:0] fifo_in [0:1];  
   
   reg [7:0] fifo_out_r [0:1];
   reg [7:0] fifo_in_r [0:1];  
    
   wire full;
   wire empty;
   reg wr_en;
   reg rd_en;
   
   wire [15:0] fifo_data_out;
   wire [15:0] fifo_data_in;   
   
   wire wr_ack, valid;
      
   assign {iic_data[00], iic_data[01], iic_data[02], iic_data[03], iic_data[04], iic_data[05], iic_data[06], iic_data[07], iic_data[08], iic_data[09],  
           iic_data[10], iic_data[11], iic_data[12], iic_data[13], iic_data[14], iic_data[15], iic_data[16], iic_data[17], iic_data[18], iic_data[19], 
           iic_data[20], iic_data[21], iic_data[22]} =  iic_data_bus;                      
                         
   assign fifo_data_in = {fifo_in_r[0], fifo_in_r[1]};                            
   assign {fifo_out[0], fifo_out[1]} = fifo_data_out;     
                          
    fifo_IIC FIFO_IIC(
          .clk(i_clk),
          .srst(i_rst),
          .din(fifo_data_in),
          .wr_en(wr_en),
          .rd_en(rd_en),
          .dout(fifo_data_out),
          .full(full),
          .wr_ack(wr_ack),
          .empty(empty),
          .valid(valid)
        );     
        
   always @(posedge i_clk or posedge i_rst)        //save data;
      if(i_rst)
      begin        
            i0 <= 8'd0;
            j0 <= 8'd0;
            k0 <= 8'd0;
            wr_en <= 1'b0;
            o_iic_en <= 23'b000_0000_0000_0000_0000_0000;;
      end else begin
        case (i0)
            8'd0: if (i_start_en) begin i0 <= 8'd1; end        //system start: 
                   
            8'd1: begin o_iic_en <= 23'b111_1111_1111_1111_1111_1111; i0 <= 8'd2; end   //iic_start:
            8'd2: begin o_iic_en <= 23'b000_0000_0000_0000_0000_0000; i0 <= 8'd3; end
           
            8'd3:  if (iic_done[0]  == 1'b1) begin fifo_in_r[0] <= 8'd0;  fifo_in_r[1] <= iic_data[0];  i0 <= 8'd26; j0 <= 8'd4;  k0 <= 8'd29; end else begin i0 <= 8'd4;  end
            8'd4:  if (iic_done[1]  == 1'b1) begin fifo_in_r[0] <= 8'd1;  fifo_in_r[1] <= iic_data[1];  i0 <= 8'd26; j0 <= 8'd5;  k0 <= 8'd31; end else begin i0 <= 8'd5;  end
            8'd5:  if (iic_done[2]  == 1'b1) begin fifo_in_r[0] <= 8'd2;  fifo_in_r[1] <= iic_data[2];  i0 <= 8'd26; j0 <= 8'd6;  k0 <= 8'd33; end else begin i0 <= 8'd6;  end
            8'd6:  if (iic_done[3]  == 1'b1) begin fifo_in_r[0] <= 8'd3;  fifo_in_r[1] <= iic_data[3];  i0 <= 8'd26; j0 <= 8'd7;  k0 <= 8'd35; end else begin i0 <= 8'd7;  end
            8'd7:  if (iic_done[4]  == 1'b1) begin fifo_in_r[0] <= 8'd4;  fifo_in_r[1] <= iic_data[4];  i0 <= 8'd26; j0 <= 8'd8;  k0 <= 8'd37; end else begin i0 <= 8'd8;  end
            8'd8:  if (iic_done[5]  == 1'b1) begin fifo_in_r[0] <= 8'd5;  fifo_in_r[1] <= iic_data[5];  i0 <= 8'd26; j0 <= 8'd9;  k0 <= 8'd39; end else begin i0 <= 8'd9;  end
            8'd9:  if (iic_done[6]  == 1'b1) begin fifo_in_r[0] <= 8'd6;  fifo_in_r[1] <= iic_data[6];  i0 <= 8'd26; j0 <= 8'd10; k0 <= 8'd41; end else begin i0 <= 8'd10; end
            8'd10: if (iic_done[7]  == 1'b1) begin fifo_in_r[0] <= 8'd7;  fifo_in_r[1] <= iic_data[7];  i0 <= 8'd26; j0 <= 8'd11; k0 <= 8'd43; end else begin i0 <= 8'd11; end
            8'd11: if (iic_done[8]  == 1'b1) begin fifo_in_r[0] <= 8'd8;  fifo_in_r[1] <= iic_data[8];  i0 <= 8'd26; j0 <= 8'd12; k0 <= 8'd45; end else begin i0 <= 8'd12; end
            8'd12: if (iic_done[9]  == 1'b1) begin fifo_in_r[0] <= 8'd9;  fifo_in_r[1] <= iic_data[9];  i0 <= 8'd26; j0 <= 8'd13; k0 <= 8'd47; end else begin i0 <= 8'd13; end    
            8'd13: if (iic_done[10] == 1'b1) begin fifo_in_r[0] <= 8'd10; fifo_in_r[1] <= iic_data[10]; i0 <= 8'd26; j0 <= 8'd14; k0 <= 8'd49; end else begin i0 <= 8'd14; end
            8'd14: if (iic_done[11] == 1'b1) begin fifo_in_r[0] <= 8'd11; fifo_in_r[1] <= iic_data[11]; i0 <= 8'd26; j0 <= 8'd15; k0 <= 8'd51; end else begin i0 <= 8'd15; end
            8'd15: if (iic_done[12] == 1'b1) begin fifo_in_r[0] <= 8'd12; fifo_in_r[1] <= iic_data[12]; i0 <= 8'd26; j0 <= 8'd16; k0 <= 8'd53; end else begin i0 <= 8'd16; end
            8'd16: if (iic_done[13] == 1'b1) begin fifo_in_r[0] <= 8'd13; fifo_in_r[1] <= iic_data[13]; i0 <= 8'd26; j0 <= 8'd17; k0 <= 8'd55; end else begin i0 <= 8'd17; end
            8'd17: if (iic_done[14] == 1'b1) begin fifo_in_r[0] <= 8'd14; fifo_in_r[1] <= iic_data[14]; i0 <= 8'd26; j0 <= 8'd18; k0 <= 8'd57; end else begin i0 <= 8'd18; end
            8'd18: if (iic_done[15] == 1'b1) begin fifo_in_r[0] <= 8'd15; fifo_in_r[1] <= iic_data[15]; i0 <= 8'd26; j0 <= 8'd19; k0 <= 8'd59; end else begin i0 <= 8'd19; end
            8'd19: if (iic_done[16] == 1'b1) begin fifo_in_r[0] <= 8'd16; fifo_in_r[1] <= iic_data[16]; i0 <= 8'd26; j0 <= 8'd20; k0 <= 8'd61; end else begin i0 <= 8'd20; end
            8'd20: if (iic_done[17] == 1'b1) begin fifo_in_r[0] <= 8'd17; fifo_in_r[1] <= iic_data[17]; i0 <= 8'd26; j0 <= 8'd21; k0 <= 8'd63; end else begin i0 <= 8'd21; end
            8'd21: if (iic_done[18] == 1'b1) begin fifo_in_r[0] <= 8'd18; fifo_in_r[1] <= iic_data[18]; i0 <= 8'd26; j0 <= 8'd22; k0 <= 8'd65; end else begin i0 <= 8'd22; end
            8'd22: if (iic_done[19] == 1'b1) begin fifo_in_r[0] <= 8'd19; fifo_in_r[1] <= iic_data[19]; i0 <= 8'd26; j0 <= 8'd23; k0 <= 8'd67; end else begin i0 <= 8'd23; end       
            8'd23: if (iic_done[20] == 1'b1) begin fifo_in_r[0] <= 8'd20; fifo_in_r[1] <= iic_data[20]; i0 <= 8'd26; j0 <= 8'd24; k0 <= 8'd69; end else begin i0 <= 8'd24; end
            8'd24: if (iic_done[21] == 1'b1) begin fifo_in_r[0] <= 8'd21; fifo_in_r[1] <= iic_data[21]; i0 <= 8'd26; j0 <= 8'd25; k0 <= 8'd71; end else begin i0 <= 8'd25; end
            8'd25: if (iic_done[22] == 1'b1) begin fifo_in_r[0] <= 8'd22; fifo_in_r[1] <= iic_data[22]; i0 <= 8'd26; j0 <= 8'd3;  k0 <= 8'd73; end else begin i0 <= 8'd3;  end                         
      
            8'd26: if (full == 1'b0) begin wr_en <= 1'b1; i0 <= 8'd27; end          //fifo save data;  
            8'd27: begin wr_en <= 1'b0; i0 <= 8'd28; end      
            8'd28: if (wr_ack) begin  i0 <= k0; end else begin i0 <= 8'd26; end
             
            8'd29: begin o_iic_en[0] <= 1'b1; i0 <= 8'd30; end
            8'd30: begin o_iic_en[0] <= 1'b0; i0 <= j0; end       
            
            8'd31: begin o_iic_en[1] <= 1'b1; i0 <= 8'd32; end
            8'd32: begin o_iic_en[1] <= 1'b0; i0 <= j0; end  
            
            8'd33: begin o_iic_en[2] <= 1'b1; i0 <= 8'd34; end
            8'd34: begin o_iic_en[2] <= 1'b0; i0 <= j0; end  
            
            8'd35: begin o_iic_en[3] <= 1'b1; i0 <= 8'd36; end
            8'd36: begin o_iic_en[3] <= 1'b0; i0 <= j0; end  
            
            8'd37: begin o_iic_en[4] <= 1'b1; i0 <= 8'd38; end
            8'd38: begin o_iic_en[4] <= 1'b0; i0 <= j0; end        
            
            8'd39: begin o_iic_en[5] <= 1'b1; i0 <= 8'd40; end
            8'd40: begin o_iic_en[5] <= 1'b0; i0 <= j0; end       
            
            8'd41: begin o_iic_en[6] <= 1'b1; i0 <= 8'd42; end
            8'd42: begin o_iic_en[6] <= 1'b0; i0 <= j0; end  
           
            8'd43: begin o_iic_en[7] <= 1'b1; i0 <= 8'd44; end
            8'd44: begin o_iic_en[7] <= 1'b0; i0 <= j0; end  
            
            8'd45: begin o_iic_en[8] <= 1'b1; i0 <= 8'd46; end
            8'd46: begin o_iic_en[8] <= 1'b0; i0 <= j0; end  
            
            8'd47: begin o_iic_en[9] <= 1'b1; i0 <= 8'd48; end
            8'd48: begin o_iic_en[9] <= 1'b0; i0 <= j0; end 
            
            8'd49: begin o_iic_en[10] <= 1'b1; i0 <= 8'd50; end
            8'd50: begin o_iic_en[10] <= 1'b0; i0 <= j0; end       
            
            8'd51: begin o_iic_en[11] <= 1'b1; i0 <= 8'd52; end
            8'd52: begin o_iic_en[11] <= 1'b0; i0 <= j0; end  
            
            8'd53: begin o_iic_en[12] <= 1'b1; i0 <= 8'd54; end
            8'd54: begin o_iic_en[12] <= 1'b0; i0 <= j0; end  
            
            8'd55: begin o_iic_en[13] <= 1'b1; i0 <= 8'd56; end
            8'd56: begin o_iic_en[13] <= 1'b0; i0 <= j0; end  
            
            8'd57: begin o_iic_en[14] <= 1'b1; i0 <= 8'd58; end
            8'd58: begin o_iic_en[14] <= 1'b0; i0 <= j0; end 
            
            8'd59: begin o_iic_en[15] <= 1'b1; i0 <= 8'd60; end
            8'd60: begin o_iic_en[15] <= 1'b0; i0 <= j0; end       
            
            8'd61: begin o_iic_en[16] <= 1'b1; i0 <= 8'd62; end
            8'd62: begin o_iic_en[16] <= 1'b0; i0 <= j0; end  
            
            8'd63: begin o_iic_en[17] <= 1'b1; i0 <= 8'd64; end
            8'd64: begin o_iic_en[17] <= 1'b0; i0 <= j0; end  
            
            8'd65: begin o_iic_en[18] <= 1'b1; i0 <= 8'd66; end
            8'd66: begin o_iic_en[18] <= 1'b0; i0 <= j0; end  
            
            8'd67: begin o_iic_en[19] <= 1'b1; i0 <= 8'd68; end
            8'd68: begin o_iic_en[19] <= 1'b0; i0 <= j0; end 
            
            8'd69: begin o_iic_en[20] <= 1'b1; i0 <= 8'd70; end
            8'd70: begin o_iic_en[20] <= 1'b0; i0 <= j0; end       
            
            8'd71: begin o_iic_en[21] <= 1'b1; i0 <= 8'd72; end
            8'd72: begin o_iic_en[21] <= 1'b0; i0 <= j0; end  
            
            8'd73: begin o_iic_en[22] <= 1'b1; i0 <= 8'd74; end
            8'd74: begin o_iic_en[22] <= 1'b0; i0 <= j0; end              
                                                                                         
        endcase
      end
                                   
       
   always @(posedge i_clk or posedge i_rst)            //read data;
     if(i_rst)
     begin
        rd_en <= 1'b0; 
        usb_en <= 1'b0;
        usb_data <= 8'd0;
        i <= 8'd0;
        j <= 8'd0;
     end else begin     
        case (i)
             8'd0: if (i_start_en) begin i <= 8'd1; end      
             8'd1: if (empty == 1'b0) begin rd_en <= 1'b1; i <= 8'd2; end  
             8'd2: if(valid) 
                   begin fifo_out_r[0] <= fifo_out[0]; 
                         fifo_out_r[1] <= fifo_out[1]; 
                         rd_en <= 1'b0; 
                         i <= 8'd6; 
                   end else begin i <= 8'd1; end               //read one chunk of data;
             
             8'd3: begin usb_en <= 1'b1; i <= 8'd4; end
             8'd4: begin usb_en <= 1'b0; i <= 8'd5; end                
             8'd5: if (usb_done)begin i <= j; end  
             
             8'd6:  begin usb_data <= fifo_out_r[0]; i <= 8'd3; j <= 8'd7; end  
             8'd7:  begin usb_data <= fifo_out_r[1]; i <= 8'd3; j <= 8'd1; end         
       //      8'd6:  begin usb_data <= 8'd1; i <= 8'd3; j <= 8'd7; end  
       //      8'd7:  begin usb_data <= 8'd2; i <= 8'd3; j <= 8'd0; end                                       
        endcase
     end    
    
endmodule
