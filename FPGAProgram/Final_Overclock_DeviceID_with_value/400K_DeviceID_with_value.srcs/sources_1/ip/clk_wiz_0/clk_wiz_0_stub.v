// Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2016.2 (win64) Build 1577090 Thu Jun  2 16:32:40 MDT 2016
// Date        : Tue Apr 04 12:14:25 2017
// Host        : Michael running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               D:/USA/FT2232H/RTL/prj_ft2232h_bak_016_lower_100Mhz_to_25Mhz_get_all_data_correctly/prj_ft2232h/prj_ft2232h.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_stub.v
// Design      : clk_wiz_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a15tftg256-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_wiz_0(i_clk_100M, o_clk_25M, i_rst)
/* synthesis syn_black_box black_box_pad_pin="i_clk_100M,o_clk_25M,i_rst" */;
  input i_clk_100M;
  output o_clk_25M;
  input i_rst;
endmodule
