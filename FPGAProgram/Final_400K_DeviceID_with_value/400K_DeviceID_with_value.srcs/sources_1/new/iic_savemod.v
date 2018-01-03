`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/21/2017 11:48:48 AM
// Design Name: 
// Module Name: iic_savemod
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


module iic_savemod
(
     input  CLOCK, RESET,
	 output SCL,
	 inout  SDA,
	 input  [1:0]iCall,
	 output oDone,
	 input  SEL,
	 input  [7:0]iAddr,
	 input  [7:0]iData,
	 output [7:0]oData
);

/**************************200K I2C********************************************************                           
	 parameter FCLK = 10'd500, FHALF = 10'd256, FQUARTER = 10'd128; //(1/400E+3)/(1/50E+6)
	 parameter THIGH = 10'd120, TLOW = 10'd260, TR = 10'd60, TF = 10'd60;
	 parameter THD_STA = 10'd120, TSU_STA = 10'd120, TSU_STO = 10'd120;
**************************************************************************************/

/**************************400K I2C********************************************************/                            
	 parameter FCLK = 10'd250, FHALF = 10'd128, FQUARTER = 10'd62; //(1/400E+3)/(1/50E+6)
	 parameter THIGH = 10'd60, TLOW = 10'd130, TR = 10'd30, TF = 10'd30;
	 parameter THD_STA = 10'd60, TSU_STA = 10'd60, TSU_STO = 10'd60;
/**************************************************************************************/

/*****************************800K I2C*****************************************************
	 parameter FCLK = 10'd125, FHALF = 10'd62, FQUARTER = 10'd31; //(1/400E+3)/(1/50E+6)
	 parameter THIGH = 10'd30, TLOW = 10'd65, TR = 10'd15, TF = 10'd15;
	 parameter THD_STA = 10'd30, TSU_STA = 10'd30, TSU_STO = 10'd30;
**************************************************************************************/

/********************************1.6M I2C******************************************************
    parameter FCLK = 10'd62, FHALF = 10'd31, FQUARTER = 10'd15; //(1/400E+3)/(1/50E+6)
    parameter THIGH = 10'd15, TLOW = 10'd32, TR = 10'd7, TF = 10'd7;
    parameter THD_STA = 10'd15, TSU_STA = 10'd15, TSU_STO = 10'd15;
***************************************************************************************/
	 parameter WRFUNC1 = 5'd7;
	 parameter WRFUNC2 = 5'd9, RDFUNC = 5'd19;
	 
	 reg [4:0]i;
	 reg [5:0]Go;
     reg [9:0]C1;
	 reg [7:0]D1;
	 reg [7:0]D_NOT_OUT1;
	 reg rSCL,rSDA;
	 reg isAck, isDone, isQ;
	 
	 always @ ( posedge CLOCK or negedge RESET )
	     if( RESET )
		      begin
				    { i,Go } <= { 5'd0,5'd0 };
					 C1 <= 10'd0;
					 D1 <= 8'd0;
					 D_NOT_OUT1 <= 8'd0;
					 { rSCL,rSDA,isAck,isDone,isQ } <= 5'b11101;
				end
		  else if( iCall[1] )
		      case( i )
				    
				    0: // Start
					 begin
					      isQ = 1;
					      rSCL <= 1'b1;
						  
					     if( C1 == 0 ) rSDA <= 1'b1; 
						  else if( C1 == (TR + THIGH) ) rSDA <= 1'b0;  
						  
						  if( C1 == (FCLK) -1) begin C1 <= 10'd0; i <= i + 1'b1; end
						  else C1 <= C1 + 1'b1;
					 end
					  
					 1: // Write Device Addr, here is the sub address;
					 if (SEL == 1'b1)
					 begin D_NOT_OUT1 <= {4'b0011, 3'b101, 1'b0}; i <= 5'd7; Go <= i + 1'b1; end   // Slave address is the first 7 bits and the eighth bit tells receive data or send data; '1' is Read; '0' is write;
					 else                                       // if down_sensor flag == 1'b1, it means it has one pair of sensors in one group; 
					 begin D_NOT_OUT1 <= {4'b0011, 3'b110, 1'b0}; i <= 5'd7; Go <= i + 1'b1; end   // LIS3DSH address is 0011_1xxW/R; if sel=1; it is 0011_101W/R; if sel=0, it is 0011_110W/R;
					 
					 2: // Wirte Word Addr  --- here is the register address;
					 begin D_NOT_OUT1 <= iAddr; i <= WRFUNC1; Go <= i + 1'b1; end
					
				     3: // Write Data   ---here is the write data;
					 begin D_NOT_OUT1 <= iData; i <= WRFUNC1; Go <= i + 1'b1; end
					 
					 /*************************/
					 
					 4: // Stop
					 begin
					     isQ = 1'b1;
						  
					     if( C1 == 0 ) rSCL <= 1'b0;
					     else if( C1 == FQUARTER ) rSCL <= 1'b1; 
		                  
						  if( C1 == 0 ) rSDA <= 1'b0;
						  else if( C1 == (FQUARTER + TR + TSU_STO ) ) rSDA <= 1'b1;
					 	  
						  if( C1 == (FQUARTER + FCLK) -1 ) begin C1 <= 10'd0; i <= i + 1'b1; end
						  else C1 <= C1 + 1'b1; 
					 end
					 
					 5:
					 begin isDone <= 1'b1; i <= i + 1'b1; end
					 
					 6: 
					 begin isDone <= 1'b0; i <= 5'd0; end
					 
					 /*******************************/ //function
					 
					 7,8,9,10,11,12,13,14:
					 begin
					      isQ = 1'b1;
						  rSDA <= D_NOT_OUT1[14-i];
						  
						  if( C1 == 0 ) rSCL <= 1'b0;
					      else if( C1 == (TF + TLOW) ) rSCL <= 1'b1; 
						  
						  if( C1 == FCLK -1 ) begin C1 <= 10'd0; i <= i + 1'b1; end
						  else C1 <= C1 + 1'b1;
					 end
					 
					 15: // waiting for acknowledge
					 begin
					      isQ = 1'b0;
					      if( C1 == FHALF ) isAck <= SDA;
						  
						  if( C1 == 0 ) rSCL <= 1'b0;
						  else if( C1 == FHALF ) rSCL <= 1'b1;
						  
						  if( C1 == FCLK -1 ) begin C1 <= 10'd0; i <= i + 1'b1; end
						  else C1 <= C1 + 1'b1; 
					 end
					 
					 16:
					 if( isAck != 0 ) i <= 5'd0;
					 else i <= Go; 
					 
					 /*******************************/ // end function
    					
				endcase
				
		  else if( iCall[0] ) 
		      case( i )
				
				    0: // Start
					 begin
					     isQ = 1; 
					     rSCL <= 1'b1;
						  
					     if( C1 == 0 ) rSDA <= 1'b1; 
						  else if( C1 == (TR + THIGH) ) rSDA <= 1'b0;  
						  
						  if( C1 == FCLK -1 ) begin C1 <= 10'd0; i <= i + 1'b1; end
						  else C1 <= C1 + 1'b1;
					 end
					  
					 1: // Write Device Addr
					 if (SEL == 1'b1)
					 begin D_NOT_OUT1 <= {4'b0011, 3'b101, 1'b0}; i <= 5'd9; Go <= i + 1'b1; end   // Slave address is the first 7 bits and the eighth bit tells receive data or send data; '1' is Read; '0' is write;
                     else
                     begin D_NOT_OUT1 <= {4'b0011, 3'b110, 1'b0}; i <= 5'd9; Go <= i + 1'b1; end   // LIS3DSH address is 0011_1xxW/R; if sel=1; it is 0011_101W/R; if sel=0, it is 0011_110W/R;
					 
					 2: // Wirte Word Addr
					 begin D_NOT_OUT1 <= iAddr; i <= WRFUNC2; Go <= i + 1'b1; end
					
					 3: // Start again
					 begin
					     isQ = 1'b1;
					      
					     if( C1 == 0 ) rSCL <= 1'b0;
						  else if( C1 == FQUARTER ) rSCL <= 1'b1;
						  else if( C1 == (FQUARTER + TR + TSU_STA + THD_STA + TF)  ) rSCL <= 1'b0;
						  
					      if( C1 == 0 ) rSDA <= 1'b0; 
						  else if( C1 == FQUARTER ) rSDA <= 1'b1;
						  else if( C1 == ( FQUARTER + TR + THIGH) ) rSDA <= 1'b0;  
						  
						  if( C1 == (FQUARTER + FCLK + FQUARTER) -1 ) begin C1 <= 10'd0; i <= i + 1'b1; end
						  else C1 <= C1 + 1'b1;
					 end
					 
					 4: // Write Device Addr ( Read )
					 if (SEL == 1'b1)
					 begin D_NOT_OUT1 <= {4'b0011, 3'b101, 1'b1}; i <= 5'd9; Go <= i + 1'b1; end       // Slave address is the first 7 bits and the eighth bit tells receive data or send data; '1' is Read; '0' is write;
                     else
                     begin D_NOT_OUT1 <= {4'b0011, 3'b110, 1'b1}; i <= 5'd9; Go <= i + 1'b1; end       // LIS3DSH address is 0011_1xxW/R; if sel=1; it is 0011_101W/R; if sel=0, it is 0011_110W/R;
					
				     5: // Read Data
					 begin D1 <= 8'd0; i <= RDFUNC; Go <= i + 1'b1; end
					 
					 6: // Stop
					 begin
					      isQ = 1'b1;
					 
                          if( C1 == 0 ) rSCL <= 1'b0;
					      else if( C1 == FQUARTER ) rSCL <= 1'b1; 
		                  
						  if( C1 == 0 ) rSDA <= 1'b0;
						  else if( C1 == (FQUARTER + TR + TSU_STO) ) rSDA <= 1'b1;					 	  
						  
						  if( C1 == (FCLK + FQUARTER) -1 ) begin C1 <= 10'd0; i <= i + 1'b1; end
						  else C1 <= C1 + 1'b1; 
					 end
					 
					 7:
					 begin isDone <= 1'b1; i <= i + 1'b1; end
					 
					 8: 
					 begin isDone <= 1'b0; i <= 5'd0; end
					 
					 /*******************************/ //function
					
					 9,10,11,12,13,14,15,16:
					 begin
					     isQ = 1'b1;
					      
						  rSDA <= D_NOT_OUT1[16-i];
						  
						  if( C1 == 0 ) rSCL <= 1'b0;
					     else if( C1 == (TF + TLOW) ) rSCL <= 1'b1; 
						  
						  if( C1 == FCLK -1 ) begin C1 <= 10'd0; i <= i + 1'b1; end
						  else C1 <= C1 + 1'b1;
					 end
			       
					 17: // waiting for acknowledge
					 begin
					     isQ = 1'b0;
					     
						  if( C1 == FHALF ) isAck <= SDA;
						  
						  if( C1 == 0 ) rSCL <= 1'b0;
						  else if( C1 == FHALF ) rSCL <= 1'b1;
						  
						  if( C1 == FCLK -1 ) begin C1 <= 10'd0; i <= i + 1'b1; end
						  else C1 <= C1 + 1'b1; 
					 end
					 
					 18:
					 if( isAck != 0 ) i <= 5'd0;
					 else i <= Go;
					 
					 /*****************************/
					 
					 19,20,21,22,23,24,25,26: // Read
					 begin
					     isQ = 1'b0;
					     if( C1 == FHALF ) D1[26-i] <= SDA;
						  
						  if( C1 == 0 ) rSCL <= 1'b0;
						  else if( C1 == FHALF  ) rSCL <= 1'b1; 
						  
						  if( C1 == FCLK -1 ) begin C1 <= 10'd0; i <= i + 1'b1; end
						  else C1 <= C1 + 1'b1;
					 end	  
					 
					 27: // no acknowledge
					 begin
					     isQ = 1'b1;
					     //if( C1 == 100 ) isAck <= SDA;
						  
						  if( C1 == 0 ) rSCL <= 1'b0;
						  else if( C1 == FHALF ) rSCL <= 1'b1;
						  
						  if( C1 == FCLK -1 ) begin C1 <= 10'd0; i <= Go; end
						  else C1 <= C1 + 1'b1; 
					 end
					 
					 /*************************************/ // end fucntion
				
				endcase
		
	 /***************************************/
	
    assign SCL = rSCL;
	assign SDA = isQ ? rSDA : 1'bz;	
    assign oDone = isDone;
	assign oData = D1;
	
    /***************************************/	
				
endmodule
