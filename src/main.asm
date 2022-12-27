; 

INCLUDE "hardware.inc" ; hardware definitions

SECTION "vsync", ROM0[$40]
	reti

SECTION "header", ROM0[$100]
; execution starts here
	di
	jp Init
	ds $150-@ ; pad for header

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