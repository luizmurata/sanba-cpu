#!/usr/bin/env sh
# for why I'm using -fsynopsys: http://ghdl.free.fr/ghdl/IEEE-library-pitfalls.html
# install ghdl dev because otherwise it will complain
ghdl -a --std=08 -fsynopsys ./sanba-cpu/sanba-cpu\.srcs/sources_1/new/vga.vhd
ghdl -a --std=08 -fsynopsys ./sanba-cpu/sanba-cpu\.srcs/sources_1/new/videounit.vhd
ghdl -a --std=08 -fsynopsys ./sanba-cpu/sanba-cpu\.srcs/sources_1/new/memory.vhd
ghdl -a --std=08 -fsynopsys ./sanba-cpu/sanba-cpu\.srcs/sources_1/new/cpu.vhd
ghdl -a --std=08 -fsynopsys ./sanba-cpu/sanba-cpu\.srcs/sources_1/new/cpu_tb.vhd
ghdl -a --std=08 -fsynopsys ./sanba-cpu/sanba-cpu\.srcs/sources_1/new/sanbacpu.vhd
ghdl -e --std=08 -fsynopsys $1 && ghdl -r --std=08 -fsynopsys $1 --vcd=out.vcd