`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/21/2017 11:33:46 AM
// Design Name: 
// Module Name: iic_demo
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

module iic_demo
(
     input  CLOCK, RESET,
     input  en,
     input  pull_down,
	 output SCL,
	 inout  SDA,
	 output [7:0]oData,
	 output oDone
);
    wire [7:0]r_data_wire;
	wire DoneU1;
	
	reg [7:0]i; 
	reg [7:0]j;
    reg [7:0]reg_addr; 
    reg [7:0]w_data;
    reg [7:0]r_data;
    reg [1:0]isCall;
    reg isDone;
    reg sel;

    iic_savemod U1
	 (
	      .CLOCK( CLOCK ),
		  .RESET( RESET ),
		  .SCL( SCL ),            // > top
		  .SDA( SDA ),            // <> top
		  .iCall( isCall ),       // < core
		  .oDone( DoneU1 ),       // > core
		  .SEL( sel ),
		  .iAddr( reg_addr ),         // < core
		  .iData( w_data ),           // < core
		  .oData( r_data_wire )       // > core
	 );
	 
	 /***************************/
	 /*  LIS3DSHTR:                                            */
	 /*  WHO_AM_I (0Fh) ---- value: 0x3F                       */
	 /*  Sub Address: 0011 110X --- SEL -> ground;  X==1, read; X==0, write;    */
	 /*                          */	 	 	 
	 /***************************/
	 
    assign oDone = isDone; 
    assign oData = r_data;
	  
    always @ ( posedge CLOCK or negedge RESET )	// core
	     if( RESET )
		      begin
				     i <= 8'd0;
				     j <= 8'd2;
					 {reg_addr, w_data, r_data} <= {8'd0, 8'd0, 8'd0};
					 isCall <= 2'b00;
					 isDone <= 1'b0;
					 sel <= 1'b1;
					 
					 isDone <= 1'b1;
					 r_data <= 8'haa;
				end
/********************** else 
		  
		      case (i)
		          0: 
		          if (en) begin isDone <= 1'b0; i <= j; end
		          
		          1:
                  begin  isDone <= 1'b1; i <= 8'd0; end
		          
		          2:
		          if( DoneU1 ) begin isCall <= 2'b00; i <= 8'd3; end
                  else begin sel <= 1'b1; isCall <= 2'b10; w_data <= 8'h9F; reg_addr <= 8'h20;end
                  
                  3:
                  if( DoneU1 ) begin isCall <= 2'b00; i <= 8'd4; end
                  else begin isCall <= 2'b10; w_data <= 8'h20; reg_addr <= 8'h24; end                   
                  
		          4:
                  if( DoneU1 ) begin isCall <= 2'b00; i <= 8'd5; end
                  else if (pull_down) begin sel <= 1'b0; isCall <= 2'b10; w_data <= 8'h9F; reg_addr <= 8'h20; end else begin i <= 8'd6; end                                 
         
                  5:
                  if( DoneU1 ) begin isCall <= 2'b00;  i <= 8'd6; end
                  else begin isCall <= 2'b10; w_data <= 8'h20; reg_addr <= 8'h24; end                   
		          
		          6:
		          if( DoneU1 ) begin r_data <= r_data_wire; isCall <= 2'b00; i <= 8'd1; j <= 8'd7; end       //send the chip id out;  //if (pull_down == 1'b1) sel <= !sel; 
                  else begin sel <= 1'b1; isCall <= 2'b01; r_data <= 8'd0; reg_addr <= 8'h0F; end                       
                  
                  7:
                  if( DoneU1 ) begin r_data <= r_data_wire; isCall <= 2'b00; i <= 8'd1; j <= 8'd8; end       //send the chip id out;  //if (pull_down == 1'b1) sel <= !sel; 
                  else if (pull_down) begin sel <= 1'b0; isCall <= 2'b01; r_data <= 8'd0; reg_addr <= 8'h0F; end else begin r_data <= 8'd0; i <= 8'd1; j <= 8; end                                                                      
                  
                  8:
                  if( DoneU1 ) begin r_data <= r_data_wire; isCall <= 2'b00; i <= 8'd9; end
                  else begin sel <= 1'b1; isCall <= 2'b01; r_data <= 8'd0; reg_addr <= 8'h27;end               //check the reg27 to see whether there is available data;
                  
                  9:
                  if ( r_data[3] == 1'b1) begin i <= 8'd10; end
                  else i <= 8'd08;
                                   
				  10:
                  if( DoneU1 ) begin r_data <= r_data_wire; isCall <= 2'b00; i <= 8'd1; j <= 8'd11; end 
                  else begin isCall <= 2'b01; r_data <= 8'd0; reg_addr <= 8'h28;end                    
                  
                  11:
                  if( DoneU1 ) begin r_data <= r_data_wire; isCall <= 2'b00; i <= 8'd1; j <= 8'd12; end 
                  else begin isCall <= 2'b01; r_data <= 8'd0; reg_addr <= 8'h29;end                               //x ?             
                      
                  12:
                  if( DoneU1 ) begin r_data <= r_data_wire; isCall <= 2'b00; i <= 8'd1; j <= 8'd13; end  
                  else begin isCall <= 2'b01; r_data <= 8'd0; reg_addr <= 8'h2A;end         
              
                  13:
                  if( DoneU1 ) begin r_data <= r_data_wire; isCall <= 2'b00; i <= 8'd1; j <= 8'd14; end  
                  else begin isCall <= 2'b01; r_data <= 8'd0; reg_addr <= 8'h2B;end                                //y?               
                  
                  14:
                  if( DoneU1 ) begin r_data <= r_data_wire; isCall <= 2'b00; i <= 8'd1; j <= 8'd15; end  
                  else begin isCall <= 2'b01; r_data <= 8'd0; reg_addr <= 8'h2C;end  
                
                  15:
                  if( DoneU1 ) begin r_data <= r_data_wire; isCall <= 2'b00; i <= 8'd1; if (pull_down) begin j <= 8'd16; end else begin j <= 8'd24; end end 
                  else begin isCall <= 2'b01; r_data <= 8'd0; reg_addr <= 8'h2D;end                                 //z?                      
                                    
                  16:
                  if( DoneU1 ) begin r_data <= r_data_wire; isCall <= 2'b00; i <= 8'd17; end
                  else begin sel <= 1'b0; isCall <= 2'b01; r_data <= 8'd0; reg_addr <= 8'h27;end                    //check the reg27 to see whether there is available data;                  
                  
                  17:
                  if ( r_data[3] == 1'b1)  begin i <= 8'd18; end
                  else i <= 8'd16;
                  
				  18:
                  if( DoneU1 ) begin r_data <= r_data_wire; isCall <= 2'b00; i <= 8'd1; j <= 8'd19; end
                  else begin isCall <= 2'b01; r_data <= 8'd0; reg_addr <= 8'h28;end          
                  
                  19:
                  if( DoneU1 ) begin r_data <= r_data_wire; isCall <= 2'b00; i <= 8'd1; j <= 8'd20; end
                  else begin isCall <= 2'b01; r_data <= 8'd0; reg_addr <= 8'h29;end                               //x ?         
                  
                  20:
                  if( DoneU1 ) begin r_data <= r_data_wire; isCall <= 2'b00; i <= 8'd1; j <= 8'd21; end
                  else begin isCall <= 2'b01; r_data <= 8'd0; reg_addr <= 8'h2A;end                  
                  
                  21:
                  if( DoneU1 ) begin r_data <= r_data_wire; isCall <= 2'b00; i <= 8'd1; j <= 8'd22; end
                  else begin isCall <= 2'b01; r_data <= 8'd0; reg_addr <= 8'h2B;end                     
                  
                  22:
                  if( DoneU1 ) begin r_data <= r_data_wire; isCall <= 2'b00; i <= 8'd1; j <= 8'd23; end
                  else begin isCall <= 2'b01; r_data <= 8'd0; reg_addr <= 8'h2C;end                    
                  
                  23:
                  if( DoneU1 ) begin r_data <= r_data_wire; isCall <= 2'b00; i <= 8'd1; j <= 8'd8; end
                  else begin isCall <= 2'b01; r_data <= 8'd0; reg_addr <= 8'h2D;end              
                  
                  24: 
                  begin r_data <= 8'd0; i <= 8'd1; j <= 8'd25; end      

                  25: 
                  begin r_data <= 8'd0; i <= 8'd1; j <= 8'd26; end    
                  
                  26: 
                  begin r_data <= 8'd0; i <= 8'd1; j <= 8'd27; end    
                  
                  27: 
                  begin r_data <= 8'd0; i <= 8'd1; j <= 8'd28; end    
                  
                  28: 
                  begin r_data <= 8'd0; i <= 8'd1; j <= 8'd29; end    
                  
                  29: 
                  begin r_data <= 8'd0; i <= 8'd1; j <= 8'd8; end                                                                                                                                                                                      
                                    
               endcase
***************************************************/
endmodule

