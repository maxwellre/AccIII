set_property SRC_FILE_INFO {cfile:d:/USA/FT2232H/RTL/prj_ft2232h_bak_016_lower_100Mhz_to_25Mhz_get_all_data_correctly/prj_ft2232h/prj_ft2232h.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xdc rfile:../../../prj_ft2232h.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xdc id:1 order:EARLY scoped_inst:inst} [current_design]
set_property src_info {type:SCOPED_XDC file:1 line:57 export:INPUT save:INPUT read:READ} [current_design]
set_input_jitter [get_clocks -of_objects [get_ports i_clk_100M]] 0.1
