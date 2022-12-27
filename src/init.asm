INCLUDE "hardware.inc" ; hw defs

SECTION "init", ROM0
Init:: ; init code should go here
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