# Project setup
PROJ      = vga-v1.2
DEVICE    = 5k
FOOTPRINT = sg48
YOSYS_OPTS= -noautowire # Generate errors if wires were implicitly created

# Files
FILES = vgav1.v

.PHONY: all clean burn

all:
	# synthesize using Yosys
	yosys -ql vga.log  -p 'synth_ice40 -json vgav1.json' vgav1.v
	# Place and route using arachne
	nextpnr-ice40 --up5k --package sg48 --freq 13 --json vgav1.json --pcf io.pcf --asc vgav1.asc
	icetime -c 13 -d up5k -mtr vgav1.rpt vgav1.asc
	# Convert to bitstream using IcePack
	icepack vgav1.asc vgav1.bin

prog_flash: all
	icesprog vgav1.bin

clean:
	rm *.asc *.rpt *.json *.log *.bin
