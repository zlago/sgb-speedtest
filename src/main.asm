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
	; init interrupts
	ld a, IEF_VBLANK
	ldh [rIE], a
	ei
	; init graphics
		; init PPU registers
		xor a ; 0 reset things
		ldh [rSCY], a
		ldh [rSCX], a
		ldh [rBGP], a ; palette will be init later
		ld a, LCDCF_ON | LCDCF_BGON | LCDCF_BLK01
		ldh [rLCDC], a
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
	; init variables
	ld a, 5 ; recommended pulse length
	ldh [hPulse], a
	ld a, 15 ; recommended pulse delay
	ldh [hDelay], a
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

SECTION "variables", HRAM
hPulse: ds 1
hDelay: ds 1

SECTION "vram", VRAM
vScreen:
	ds xScreen2bpp.end - xScreen2bpp
	.end
vFont:
	ds xFont2bpp.end - xFont2bpp
	.end