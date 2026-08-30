## Clock, 100 MHz oscillator
set_property PACKAGE_PIN W5 [get_ports CLK]
set_property IOSTANDARD LVCMOS33 [get_ports CLK]

## Reset button (BTNC)
set_property PACKAGE_PIN U18 [get_ports RESET_BUTTON]
set_property IOSTANDARD LVCMOS33 [get_ports RESET_BUTTON]

## Debug/calibration UART, FPGA TX into FTDI's RX
set_property PACKAGE_PIN A18 [get_ports UART_TX]
set_property IOSTANDARD LVCMOS33 [get_ports UART_TX]

## eurorack-pmod on JA
set_property PACKAGE_PIN J1 [get_ports PMOD_SDIN1]
set_property IOSTANDARD LVCMOS33 [get_ports PMOD_SDIN1]
set_property PACKAGE_PIN L2 [get_ports PMOD_SDOUT1]
set_property IOSTANDARD LVCMOS33 [get_ports PMOD_SDOUT1]
set_property PACKAGE_PIN J2 [get_ports PMOD_LRCK]
set_property IOSTANDARD LVCMOS33 [get_ports PMOD_LRCK]
set_property PACKAGE_PIN G2 [get_ports PMOD_BICK]
set_property IOSTANDARD LVCMOS33 [get_ports PMOD_BICK]
set_property PACKAGE_PIN H1 [get_ports PMOD_I2C_SCL]
set_property IOSTANDARD LVCMOS33 [get_ports PMOD_I2C_SCL]
set_property PACKAGE_PIN K2 [get_ports PMOD_I2C_SDA]
set_property IOSTANDARD LVCMOS33 [get_ports PMOD_I2C_SDA]
set_property PACKAGE_PIN H2 [get_ports PMOD_PDN]
set_property IOSTANDARD LVCMOS33 [get_ports PMOD_PDN]
set_property PACKAGE_PIN G3 [get_ports PMOD_MCLK]
set_property IOSTANDARD LVCMOS33 [get_ports PMOD_MCLK]