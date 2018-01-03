proc start_step { step } {
  set stopFile ".stop.rst"
  if {[file isfile .stop.rst]} {
    puts ""
    puts "*** Halting run - EA reset detected ***"
    puts ""
    puts ""
    return -code error
  }
  set beginFile ".$step.begin.rst"
  set platform "$::tcl_platform(platform)"
  set user "$::tcl_platform(user)"
  set pid [pid]
  set host ""
  if { [string equal $platform unix] } {
    if { [info exist ::env(HOSTNAME)] } {
      set host $::env(HOSTNAME)
    }
  } else {
    if { [info exist ::env(COMPUTERNAME)] } {
      set host $::env(COMPUTERNAME)
    }
  }
  set ch [open $beginFile w]
  puts $ch "<?xml version=\"1.0\"?>"
  puts $ch "<ProcessHandle Version=\"1\" Minor=\"0\">"
  puts $ch "    <Process Command=\".planAhead.\" Owner=\"$user\" Host=\"$host\" Pid=\"$pid\">"
  puts $ch "    </Process>"
  puts $ch "</ProcessHandle>"
  close $ch
}

proc end_step { step } {
  set endFile ".$step.end.rst"
  set ch [open $endFile w]
  close $ch
}

proc step_failed { step } {
  set endFile ".$step.error.rst"
  set ch [open $endFile w]
  close $ch
}

set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000

start_step init_design
set rc [catch {
  create_msg_db init_design.pb
  set_property design_mode GateLvl [current_fileset]
  set_param project.singleFileAddWarning.threshold 0
  set_property webtalk.parent_dir D:/Hui/RTL/prj_ft2232h_bak_17_copy/prj_ft2232h/prj_ft2232h.cache/wt [current_project]
  set_property parent.project_path D:/Hui/RTL/prj_ft2232h_bak_17_copy/prj_ft2232h/prj_ft2232h.xpr [current_project]
  set_property ip_repo_paths d:/Hui/RTL/prj_ft2232h_bak_17_copy/prj_ft2232h/prj_ft2232h.cache/ip [current_project]
  set_property ip_output_repo d:/Hui/RTL/prj_ft2232h_bak_17_copy/prj_ft2232h/prj_ft2232h.cache/ip [current_project]
  set_property XPM_LIBRARIES {XPM_CDC XPM_MEMORY} [current_project]
  add_files -quiet D:/Hui/RTL/prj_ft2232h_bak_17_copy/prj_ft2232h/prj_ft2232h.runs/synth_1/async_245_fifo.dcp
  add_files -quiet d:/Hui/RTL/prj_ft2232h_bak_17_copy/prj_ft2232h/prj_ft2232h.srcs/sources_1/ip/fifo_IIC/fifo_IIC.dcp
  set_property netlist_only true [get_files d:/Hui/RTL/prj_ft2232h_bak_17_copy/prj_ft2232h/prj_ft2232h.srcs/sources_1/ip/fifo_IIC/fifo_IIC.dcp]
  read_xdc -mode out_of_context -ref fifo_IIC -cells U0 d:/Hui/RTL/prj_ft2232h_bak_17_copy/prj_ft2232h/prj_ft2232h.srcs/sources_1/ip/fifo_IIC/fifo_IIC_ooc.xdc
  set_property processing_order EARLY [get_files d:/Hui/RTL/prj_ft2232h_bak_17_copy/prj_ft2232h/prj_ft2232h.srcs/sources_1/ip/fifo_IIC/fifo_IIC_ooc.xdc]
  read_xdc -ref fifo_IIC -cells U0 d:/Hui/RTL/prj_ft2232h_bak_17_copy/prj_ft2232h/prj_ft2232h.srcs/sources_1/ip/fifo_IIC/fifo_IIC/fifo_IIC.xdc
  set_property processing_order EARLY [get_files d:/Hui/RTL/prj_ft2232h_bak_17_copy/prj_ft2232h/prj_ft2232h.srcs/sources_1/ip/fifo_IIC/fifo_IIC/fifo_IIC.xdc]
  read_xdc D:/Hui/RTL/prj_ft2232h_bak_17_copy/prj_ft2232h/prj_ft2232h.srcs/constrs_1/new/ft2232_constraint.xdc
  link_design -top async_245_fifo -part xc7a15tftg256-1
  write_hwdef -file async_245_fifo.hwdef
  close_msg_db -file init_design.pb
} RESULT]
if {$rc} {
  step_failed init_design
  return -code error $RESULT
} else {
  end_step init_design
}

start_step opt_design
set rc [catch {
  create_msg_db opt_design.pb
  opt_design 
  write_checkpoint -force async_245_fifo_opt.dcp
  report_drc -file async_245_fifo_drc_opted.rpt
  close_msg_db -file opt_design.pb
} RESULT]
if {$rc} {
  step_failed opt_design
  return -code error $RESULT
} else {
  end_step opt_design
}

start_step place_design
set rc [catch {
  create_msg_db place_design.pb
  implement_debug_core 
  place_design 
  write_checkpoint -force async_245_fifo_placed.dcp
  report_io -file async_245_fifo_io_placed.rpt
  report_utilization -file async_245_fifo_utilization_placed.rpt -pb async_245_fifo_utilization_placed.pb
  report_control_sets -verbose -file async_245_fifo_control_sets_placed.rpt
  close_msg_db -file place_design.pb
} RESULT]
if {$rc} {
  step_failed place_design
  return -code error $RESULT
} else {
  end_step place_design
}

start_step route_design
set rc [catch {
  create_msg_db route_design.pb
  route_design 
  write_checkpoint -force async_245_fifo_routed.dcp
  report_drc -file async_245_fifo_drc_routed.rpt -pb async_245_fifo_drc_routed.pb
  report_timing_summary -warn_on_violation -max_paths 10 -file async_245_fifo_timing_summary_routed.rpt -rpx async_245_fifo_timing_summary_routed.rpx
  report_power -file async_245_fifo_power_routed.rpt -pb async_245_fifo_power_summary_routed.pb -rpx async_245_fifo_power_routed.rpx
  report_route_status -file async_245_fifo_route_status.rpt -pb async_245_fifo_route_status.pb
  report_clock_utilization -file async_245_fifo_clock_utilization_routed.rpt
  close_msg_db -file route_design.pb
} RESULT]
if {$rc} {
  step_failed route_design
  return -code error $RESULT
} else {
  end_step route_design
}

start_step write_bitstream
set rc [catch {
  create_msg_db write_bitstream.pb
  catch { write_mem_info -force async_245_fifo.mmi }
  write_bitstream -force async_245_fifo.bit -bin_file
  catch { write_sysdef -hwdef async_245_fifo.hwdef -bitfile async_245_fifo.bit -meminfo async_245_fifo.mmi -file async_245_fifo.sysdef }
  catch {write_debug_probes -quiet -force debug_nets}
  close_msg_db -file write_bitstream.pb
} RESULT]
if {$rc} {
  step_failed write_bitstream
  return -code error $RESULT
} else {
  end_step write_bitstream
}

