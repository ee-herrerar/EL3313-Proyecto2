## ============================================================
## CLOCK - 100 MHz
## ============================================================

set_property -dict { PACKAGE_PIN W5 IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]


## ============================================================
## BUTTONS
## ============================================================

# BTN Center -> Reset
set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports reset]

# BTN Left -> Seleccion de dificultad
set_property -dict { PACKAGE_PIN W19 IOSTANDARD LVCMOS33 } [get_ports BTN_SEL_RAW]

# BTN Right -> Confirmar
set_property -dict { PACKAGE_PIN T17 IOSTANDARD LVCMOS33 } [get_ports BTN_OK_RAW]


## ============================================================
## LEDs
## ============================================================

set_property -dict { PACKAGE_PIN U16 IOSTANDARD LVCMOS33 } [get_ports {led[0]}]
set_property -dict { PACKAGE_PIN E19 IOSTANDARD LVCMOS33 } [get_ports {led[1]}]
set_property -dict { PACKAGE_PIN U19 IOSTANDARD LVCMOS33 } [get_ports {led[2]}]
set_property -dict { PACKAGE_PIN V19 IOSTANDARD LVCMOS33 } [get_ports {led[3]}]
set_property -dict { PACKAGE_PIN W18 IOSTANDARD LVCMOS33 } [get_ports {led[4]}]
set_property -dict { PACKAGE_PIN U15 IOSTANDARD LVCMOS33 } [get_ports {led[5]}]
set_property -dict { PACKAGE_PIN U14 IOSTANDARD LVCMOS33 } [get_ports {led[6]}]
set_property -dict { PACKAGE_PIN V14 IOSTANDARD LVCMOS33 } [get_ports {led[7]}]
set_property -dict { PACKAGE_PIN V13 IOSTANDARD LVCMOS33 } [get_ports {led[8]}]
set_property -dict { PACKAGE_PIN V3  IOSTANDARD LVCMOS33 } [get_ports {led[9]}]
set_property -dict { PACKAGE_PIN W3  IOSTANDARD LVCMOS33 } [get_ports {led[10]}]
set_property -dict { PACKAGE_PIN U3  IOSTANDARD LVCMOS33 } [get_ports {led[11]}]
set_property -dict { PACKAGE_PIN P3  IOSTANDARD LVCMOS33 } [get_ports {led[12]}]
set_property -dict { PACKAGE_PIN N3  IOSTANDARD LVCMOS33 } [get_ports {led[13]}]
set_property -dict { PACKAGE_PIN P1  IOSTANDARD LVCMOS33 } [get_ports {led[14]}]
set_property -dict { PACKAGE_PIN L1  IOSTANDARD LVCMOS33 } [get_ports {led[15]}]


## ============================================================
## 7 SEGMENT DISPLAY
## ============================================================

set_property -dict { PACKAGE_PIN W7 IOSTANDARD LVCMOS33 } [get_ports {seg[0]}]
set_property -dict { PACKAGE_PIN W6 IOSTANDARD LVCMOS33 } [get_ports {seg[1]}]
set_property -dict { PACKAGE_PIN U8 IOSTANDARD LVCMOS33 } [get_ports {seg[2]}]
set_property -dict { PACKAGE_PIN V8 IOSTANDARD LVCMOS33 } [get_ports {seg[3]}]
set_property -dict { PACKAGE_PIN U5 IOSTANDARD LVCMOS33 } [get_ports {seg[4]}]
set_property -dict { PACKAGE_PIN V5 IOSTANDARD LVCMOS33 } [get_ports {seg[5]}]
set_property -dict { PACKAGE_PIN U7 IOSTANDARD LVCMOS33 } [get_ports {seg[6]}]

set_property -dict { PACKAGE_PIN V7 IOSTANDARD LVCMOS33 } [get_ports dp]

set_property -dict { PACKAGE_PIN U2 IOSTANDARD LVCMOS33 } [get_ports {an[0]}]
set_property -dict { PACKAGE_PIN U4 IOSTANDARD LVCMOS33 } [get_ports {an[1]}]
set_property -dict { PACKAGE_PIN V4 IOSTANDARD LVCMOS33 } [get_ports {an[2]}]
set_property -dict { PACKAGE_PIN W4 IOSTANDARD LVCMOS33 } [get_ports {an[3]}]


## ============================================================
## USB UART
## ============================================================

set_property -dict { PACKAGE_PIN B18 IOSTANDARD LVCMOS33 } [get_ports uart_rx]
set_property -dict { PACKAGE_PIN A18 IOSTANDARD LVCMOS33 } [get_ports uart_tx]


## ============================================================
## PMODCLP J1 -> BASYS 3 JB
## DATA DB0..DB7
## ============================================================

# J1-1 DB0 -> JB1
set_property -dict { PACKAGE_PIN A14 IOSTANDARD LVCMOS33 } [get_ports {lcd_data[0]}]

# J1-2 DB1 -> JB2
set_property -dict { PACKAGE_PIN A16 IOSTANDARD LVCMOS33 } [get_ports {lcd_data[1]}]

# J1-3 DB2 -> JB3
set_property -dict { PACKAGE_PIN B15 IOSTANDARD LVCMOS33 } [get_ports {lcd_data[2]}]

# J1-4 DB3 -> JB4
set_property -dict { PACKAGE_PIN B16 IOSTANDARD LVCMOS33 } [get_ports {lcd_data[3]}]

# J1-7 DB4 -> JB7
set_property -dict { PACKAGE_PIN A15 IOSTANDARD LVCMOS33 } [get_ports {lcd_data[4]}]

# J1-8 DB5 -> JB8
set_property -dict { PACKAGE_PIN A17 IOSTANDARD LVCMOS33 } [get_ports {lcd_data[5]}]

# J1-9 DB6 -> JB9
set_property -dict { PACKAGE_PIN C15 IOSTANDARD LVCMOS33 } [get_ports {lcd_data[6]}]

# J1-10 DB7 -> JB10
set_property -dict { PACKAGE_PIN C16 IOSTANDARD LVCMOS33 } [get_ports {lcd_data[7]}]


## ============================================================
## PMODCLP J2 -> BASYS 3 JC7..JC12
## CONTROL
## ============================================================

# J2-1 RS -> JC7
set_property -dict { PACKAGE_PIN L17 IOSTANDARD LVCMOS33 } [get_ports lcd_rs]

# J2-2 R/W -> JC8
set_property -dict { PACKAGE_PIN M19 IOSTANDARD LVCMOS33 } [get_ports lcd_rw]

# J2-3 E -> JC9
set_property -dict { PACKAGE_PIN P17 IOSTANDARD LVCMOS33 } [get_ports lcd_e]

# J2-4 -> JC10 = NC
# J2-5 -> GND
# J2-6 -> 3.3 V


## ============================================================
## BUZZER - RESERVADO EN JC1
## ============================================================

set_property -dict { PACKAGE_PIN K17 IOSTANDARD LVCMOS33 } [get_ports buzzer]


## ============================================================
## CONFIGURATION
## ============================================================

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]