## Generated SDC file "PFC.out.sdc"

## Copyright (C) 1991-2010 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 10.1 Build 153 11/29/2010 SJ Web Edition"

## DATE    "Wed May 15 18:24:41 2013"

##
## DEVICE  "EP4CE22F17C6"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk} -period 20.000 -waveform { 0.000 10.000 } [get_ports {clk}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {pll_inst|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {pll_inst|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 4 -master_clock {clk} [get_pins {pll_inst|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {pll_inst|altpll_component|auto_generated|pll1|clk[1]} -source [get_pins {pll_inst|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 8 -divide_by 25 -master_clock {clk} [get_pins {pll_inst|altpll_component|auto_generated|pll1|clk[1]}] 
create_generated_clock -name {adc_ncs} -source [get_ports {adc_clk}] -edges { 28 34 60 } -master_clock {pll_inst|altpll_component|auto_generated|pll1|clk[1]} [get_keepers {adc:adc_il0_inst|c_ncs adc:adc_un0_inst|c_ncs adc:adc_uo1_inst|c_ncs}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {pll_inst|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {pll_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.020 
set_clock_uncertainty -rise_from [get_clocks {pll_inst|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {pll_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.020 
set_clock_uncertainty -fall_from [get_clocks {pll_inst|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {pll_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.020 
set_clock_uncertainty -fall_from [get_clocks {pll_inst|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {pll_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.020 
set_clock_uncertainty -rise_from [get_clocks {pll_inst|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {pll_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.020 
set_clock_uncertainty -rise_from [get_clocks {pll_inst|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {pll_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.020 
set_clock_uncertainty -rise_from [get_clocks {pll_inst|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {adc_ncs}]  0.020 
set_clock_uncertainty -rise_from [get_clocks {pll_inst|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {adc_ncs}]  0.020 
set_clock_uncertainty -fall_from [get_clocks {pll_inst|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {pll_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.020 
set_clock_uncertainty -fall_from [get_clocks {pll_inst|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {pll_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.020 
set_clock_uncertainty -fall_from [get_clocks {pll_inst|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {adc_ncs}]  0.020 
set_clock_uncertainty -fall_from [get_clocks {pll_inst|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {adc_ncs}]  0.020 
set_clock_uncertainty -rise_from [get_clocks {adc_ncs}] -rise_to [get_clocks {pll_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.020 
set_clock_uncertainty -rise_from [get_clocks {adc_ncs}] -fall_to [get_clocks {pll_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.020 
set_clock_uncertainty -rise_from [get_clocks {adc_ncs}] -rise_to [get_clocks {adc_ncs}]  0.030 
set_clock_uncertainty -rise_from [get_clocks {adc_ncs}] -fall_to [get_clocks {adc_ncs}]  0.030 
set_clock_uncertainty -fall_from [get_clocks {adc_ncs}] -rise_to [get_clocks {pll_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.020 
set_clock_uncertainty -fall_from [get_clocks {adc_ncs}] -fall_to [get_clocks {pll_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.020 
set_clock_uncertainty -fall_from [get_clocks {adc_ncs}] -rise_to [get_clocks {adc_ncs}]  0.030 
set_clock_uncertainty -fall_from [get_clocks {adc_ncs}] -fall_to [get_clocks {adc_ncs}]  0.030 


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

