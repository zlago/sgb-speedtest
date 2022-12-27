; 

INCLUDE "hardware.inc" ; hardware definitions

SECTION "vsync", ROM0[$40]
	reti

SECTION "header", ROM0[$100]
; execution starts here
	di
	jp Init
	ds $150-@ ; pad for header

SECTION "init", ROM0
Init: ; init code should go here
	; init graphics
		; load tilemap
		ld hl, xScreen2bpp
		ld de, vScreen
		ld bc, xScreen2bpp.end - xScreen2bpp
		call SafeCpy
		; load font
		ld hl, xFont2bpp
		ASSERT fail, vScreen + (xScreen2bpp.end - xScreen2bpp) == vFont, "VRAM assertion failed!"
		ld bc, xFont2bpp.end - xFont2bpp
		call SafeCpy
		; load tiles
		ld hl, xScreenTilemap
		ld de, _SCRN0
		ld bc, xScreenTilemap.end - xScreenTilemap
		call SafeCpy
	; 
	:jr:- ; endless loop

SECTION "data", ROMX
xScreen2bpp:
	incbin "screen.2bpp"
	.end
xScreenTilemap:
	incbin "screen.tilemap"
	.end
xFont2bpp:
	incbin "font.2bpp"
	.end

SECTION "vram", VRAM
vScreen:
	ds xScreen2bpp.end - xScreen2bpp
	.end
vFont:
	ds xFont2bpp.end - xFont2bpp
	.end