-- Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2016.2 (win64) Build 1577090 Thu Jun  2 16:32:40 MDT 2016
-- Date        : Tue Apr 04 12:14:25 2017
-- Host        : Michael running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               D:/USA/FT2232H/RTL/prj_ft2232h_bak_016_lower_100Mhz_to_25Mhz_get_all_data_correctly/prj_ft2232h/prj_ft2232h.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_stub.vhdl
-- Design      : clk_wiz_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a15tftg256-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clk_wiz_0 is
  Port ( 
    i_clk_100M : in STD_LOGIC;
    o_clk_25M : out STD_LOGIC;
    i_rst : in STD_LOGIC
  );

end clk_wiz_0;

architecture stub of clk_wiz_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "i_clk_100M,o_clk_25M,i_rst";
begin
end;
