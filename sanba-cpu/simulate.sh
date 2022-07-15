#!/usr/bin/env sh
# for why I'm using --ieee=synopsys --std=c93c -fexplicit: http://ghdl.free.fr/ghdl/IEEE-library-pitfalls.html
echo $(pwd)
for f in $(ls ./sanba-cpu/sanba-cpu\.srcs/sources_1/new/*.vhd)
do
    echo "$f"
    ghdl -a --ieee=synopsys --std=93c -fexplicit $f
done
ghdl -e $1 && ghdl -r $1