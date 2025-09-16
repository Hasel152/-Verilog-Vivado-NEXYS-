## =============================================================================
## Master XDC File for password_lock_top (FINAL CORRECTED VERSION)
## Board: Digilent Nexys4 DDR
## This file is verified against the official board schematic.
## =============================================================================

## Clock signal
set_property -dict { PACKAGE_PIN E3   IOSTANDARD LVCMOS33 } [get_ports {clk}]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} [get_ports {clk}]

## CPU Reset Button (for rst_n)
set_property -dict { PACKAGE_PIN C12  IOSTANDARD LVCMOS33 } [get_ports {rst_n}]

## Switches (for nums_onehot_in)
set_property -dict { PACKAGE_PIN J15  IOSTANDARD LVCMOS33 } [get_ports {sw_nums[0]}]
set_property -dict { PACKAGE_PIN L16  IOSTANDARD LVCMOS33 } [get_ports {sw_nums[1]}]
set_property -dict { PACKAGE_PIN M13  IOSTANDARD LVCMOS33 } [get_ports {sw_nums[2]}]
set_property -dict { PACKAGE_PIN R15  IOSTANDARD LVCMOS33 } [get_ports {sw_nums[3]}]
set_property -dict { PACKAGE_PIN R17  IOSTANDARD LVCMOS33 } [get_ports {sw_nums[4]}]
set_property -dict { PACKAGE_PIN T18  IOSTANDARD LVCMOS33 } [get_ports {sw_nums[5]}]
set_property -dict { PACKAGE_PIN U18  IOSTANDARD LVCMOS33 } [get_ports {sw_nums[6]}]
set_property -dict { PACKAGE_PIN R13  IOSTANDARD LVCMOS33 } [get_ports {sw_nums[7]}]
set_property -dict { PACKAGE_PIN T8   IOSTANDARD LVCMOS33 } [get_ports {sw_nums[8]}]
set_property -dict { PACKAGE_PIN U8   IOSTANDARD LVCMOS33 } [get_ports {sw_nums[9]}]

## Push Buttons (for function inputs)
set_property -dict { PACKAGE_PIN M18  IOSTANDARD LVCMOS33 } [get_ports {set_btn_raw}]     
set_property -dict { PACKAGE_PIN P18  IOSTANDARD LVCMOS33 } [get_ports {open_sw_raw}]      
set_property -dict { PACKAGE_PIN M17  IOSTANDARD LVCMOS33 } [get_ports {admin_rst_btn_raw}]
set_property -dict { PACKAGE_PIN N17  IOSTANDARD LVCMOS33 } [get_ports {confirm_btn_raw}]  
set_property -dict { PACKAGE_PIN P17  IOSTANDARD LVCMOS33 } [get_ports {backspace_btn_raw}]
## LEDs
set_property -dict { PACKAGE_PIN H17  IOSTANDARD LVCMOS33 } [get_ports {led[0]}]
set_property -dict { PACKAGE_PIN K15  IOSTANDARD LVCMOS33 } [get_ports {led[1]}]
set_property -dict { PACKAGE_PIN J13  IOSTANDARD LVCMOS33 } [get_ports {led[2]}]
set_property -dict { PACKAGE_PIN N14  IOSTANDARD LVCMOS33 } [get_ports {led[3]}]
set_property -dict { PACKAGE_PIN R18  IOSTANDARD LVCMOS33 } [get_ports {led[4]}]
set_property -dict { PACKAGE_PIN V17  IOSTANDARD LVCMOS33 } [get_ports {led[5]}]
set_property -dict { PACKAGE_PIN U17  IOSTANDARD LVCMOS33 } [get_ports {led[6]}]
set_property -dict { PACKAGE_PIN U16  IOSTANDARD LVCMOS33 } [get_ports {led[7]}]
set_property -dict { PACKAGE_PIN V16  IOSTANDARD LVCMOS33 } [get_ports {led[8]}]
set_property -dict { PACKAGE_PIN T15  IOSTANDARD LVCMOS33 } [get_ports {led[9]}]
set_property -dict { PACKAGE_PIN U14  IOSTANDARD LVCMOS33 } [get_ports {led[10]}]
set_property -dict { PACKAGE_PIN T16  IOSTANDARD LVCMOS33 } [get_ports {led[11]}]
set_property -dict { PACKAGE_PIN V15  IOSTANDARD LVCMOS33 } [get_ports {led[12]}]
set_property -dict { PACKAGE_PIN V14  IOSTANDARD LVCMOS33 } [get_ports {led[13]}]
set_property -dict { PACKAGE_PIN V12  IOSTANDARD LVCMOS33 } [get_ports {led[14]}]
set_property -dict { PACKAGE_PIN V11  IOSTANDARD LVCMOS33 } [get_ports {led[15]}]
## 7-Segment Display - Segments
set_property -dict { PACKAGE_PIN T10  IOSTANDARD LVCMOS33 } [get_ports {seg[0]}]
set_property -dict { PACKAGE_PIN R10  IOSTANDARD LVCMOS33 } [get_ports {seg[1]}]
set_property -dict { PACKAGE_PIN K16  IOSTANDARD LVCMOS33 } [get_ports {seg[2]}]
set_property -dict { PACKAGE_PIN K13  IOSTANDARD LVCMOS33 } [get_ports {seg[3]}]
set_property -dict { PACKAGE_PIN P15  IOSTANDARD LVCMOS33 } [get_ports {seg[4]}]
set_property -dict { PACKAGE_PIN T11  IOSTANDARD LVCMOS33 } [get_ports {seg[5]}]
set_property -dict { PACKAGE_PIN L18  IOSTANDARD LVCMOS33 } [get_ports {seg[6]}]

## 7-Segment Display - Anodes
set_property -dict { PACKAGE_PIN J17   IOSTANDARD LVCMOS33 } [get_ports {an[0]}]
set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 } [get_ports {an[1]}]
set_property -dict { PACKAGE_PIN T9    IOSTANDARD LVCMOS33 } [get_ports {an[2]}]
set_property -dict { PACKAGE_PIN J14   IOSTANDARD LVCMOS33 } [get_ports {an[3]}]
set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33 } [get_ports {an[4]}]
set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33 } [get_ports {an[5]}]
set_property -dict { PACKAGE_PIN K2    IOSTANDARD LVCMOS33 } [get_ports {an[6]}]
set_property -dict { PACKAGE_PIN U13   IOSTANDARD LVCMOS33 } [get_ports {an[7]}]