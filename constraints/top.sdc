create_clock -name CLOCK_50 -period 20.000 [get_ports CLOCK_50]

# clk_25 is a ripple clock from a toggle flip-flop inside vga_clock
create_generated_clock -name clk_25 \
    -source [get_ports CLOCK_50] -divide_by 2 \
    [get_registers {vga_clock:clock_unit|clk_25}]

derive_clock_uncertainty

# asynchronous board I/O
set_false_path -from [get_ports {KEY[*]}] -to *
set_false_path -from [get_ports {SW[*]}]  -to *
set_false_path -from * -to [get_ports {LEDR[*]}]
set_false_path -from * -to [get_ports {VGA_R[*] VGA_G[*] VGA_B[*]}]
set_false_path -from * -to [get_ports {VGA_HS VGA_VS VGA_BLANK_N VGA_SYNC_N}]
