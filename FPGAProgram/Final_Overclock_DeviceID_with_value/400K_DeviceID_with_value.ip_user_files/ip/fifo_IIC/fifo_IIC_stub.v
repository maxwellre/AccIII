// Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2016.2 (win64) Build 1577090 Thu Jun  2 16:32:40 MDT 2016
// Date        : Wed Sep 06 16:35:26 2017
// Host        : DESKTOP-1R4PJEI running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               D:/Hui/RTL/prj_ft2232h_bak_17_copy/prj_ft2232h/prj_ft2232h.srcs/sources_1/ip/fifo_IIC/fifo_IIC_stub.v
// Design      : fifo_IIC
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a15tftg256-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_1_1,Vivado 2016.2" *)
module fifo_IIC(clk, srst, din, wr_en, rd_en, dout, full, wr_ack, empty, valid)
/* synthesis syn_black_box black_box_pad_pin="clk,srst,din[15:0],wr_en,rd_en,dout[15:0],full,wr_ack,empty,valid" */;
  input clk;
  input srst;
  input [15:0]din;
  input wr_en;
  input rd_en;
  output [15:0]dout;
  output full;
  output wr_ack;
  output empty;
  output valid;
endmodule
