`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/26/2017 11:21:43 AM
// Design Name: 
// Module Name: sys_rst
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


module sys_rst(
    input i_clk,
    input i_rst,
    output reg o_rst
    );
    
    //here it will use the outside i_rst to create one new reset signal o_rst
    
    reg rst_state0;
   //We use async to reset, so i_rst in the sense list,
   always @(posedge i_clk or posedge i_rst)
      if (i_rst) begin
         rst_state0 <= 1'b1;   
         o_rst <= 1'b1;     //here when i_rst come, output rst signal immediately.
      end else begin
         rst_state0 <= 1'b0;
         o_rst <= rst_state0; //here come rst release, o_rst will sync release with clock;
      end

endmodule
