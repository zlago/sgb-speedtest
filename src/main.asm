; 

INCLUDE "hardware.inc" ; hardware definitions
INCLUDE "defines.inc" ; defines for.. things

SECTION "vsync", ROM0[$40]
	reti

SECTION "header", ROM0[$100]
; execution starts here
	di
	jp Init
	ds $150-@ ; pad for header

SECTION "main", ROM0
Main::
	.loop:
	halt
	call LengthUpdate
	; check things
	jr .loop

SECTION "data", ROMX
xScreen2bpp::
	incbin "screen.2bpp"
	.end::
xScreenTilemap::
	incbin "screen.tilemap"
	.end::
xFont2bpp::
	incbin "font.2bpp"
	.end::

SECTION "packets", ROMX
xPackets::
.attr::
db ATTR_DIV+1 ; divide
db %11_11_11 ; all areas palette 3
ds 16 - 2, $00 ; rest is whatever
.palres::
db PAL23+1
dw $0000 ; color 0
dw $0000, $0000, $0000 ; palette 2 (ignore)
dw $0000, $7fff, $001f ; palette 3
ds 16 - 15, $00 ; pad
.palset::
db PAL23+1
dw $0000 ; color 0
dw $0000, $0000, $0000 ; palette 2 (ignore)
dw $0000, $7fff, $03e0 ; palette 3
ds 16 - 15, $00 ; pad

SECTION "variables", HRAM
hPulse:: ds 1
hDelay:: ds 1

SECTION "vram", VRAM
vScreen::
	ds xScreen2bpp.end - xScreen2bpp
	.end::
vFont::
	ds xFont2bpp.end - xFont2bpp
	.end::