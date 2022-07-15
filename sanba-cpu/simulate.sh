#!/usr/bin/env sh
# for why I'm using --ieee=synopsys --std=c93c -fexplicit: http://ghdl.free.fr/ghdl/IEEE-library-pitfalls.html
ghdl -a --ieee=synopsys --std=93c -fexplicit ./sanba-cpu/sanba-cpu\.srcs/sources_1/new/vga.vhd
ghdl -a --ieee=synopsys --std=93c -fexplicit ./sanba-cpu/sanba-cpu\.srcs/sources_1/new/videounit.vhd
ghdl -a --ieee=synopsys --std=93c -fexplicit ./sanba-cpu/sanba-cpu\.srcs/sources_1/new/memory.vhd
ghdl -a --ieee=synopsys --std=93c -fexplicit ./sanba-cpu/sanba-cpu\.srcs/sources_1/new/cpu.vhd
ghdl -a --ieee=synopsys --std=93c -fexplicit ./sanba-cpu/sanba-cpu\.srcs/sources_1/new/cpu_tb.vhd
ghdl -a --ieee=synopsys --std=93c -fexplicit ./sanba-cpu/sanba-cpu\.srcs/sources_1/new/sanbacpu.vhd
ghdl -e $1 && ghdl -r $1