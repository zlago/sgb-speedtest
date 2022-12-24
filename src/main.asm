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
	; load tilemap
	ld hl, xScreen2bpp
	ld de, _VRAM
	ld bc, xScreen2bpp.end - xScreen2bpp
	call SafeCpy
	; load tiles
	ld hl, xScreenTilemap
	ld de, _SCRN0
	ld bc, xScreenTilemap.end - xScreenTilemap
	call SafeCpy
	:jr:- ; endless loop

SECTION "data", ROMX
xScreen2bpp:
	incbin "screen.2bpp"
	.end
xScreenTilemap:
	incbin "screen.tilemap"
	.end
xFont:
	incbin "font.2bpp"
	.end