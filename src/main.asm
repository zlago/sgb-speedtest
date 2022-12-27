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
	; process length stuff
	call LengthUpdate
	; process nonlength stuff
	ldh a, [hInput1]
	ld b, a
	ldh a, [hInput1.diff]
	and b
	ld b, a
	and PADF_B
	jr .loop

SECTION "reset", ROM0
Reset::
	; reset palette
	ld hl, xPackets.palres
	call Packet
	; stall for 4 frames
	ld a, 4
	.loop
	halt
	push af
	call LengthUpdate
	pop af
	dec a
	jr nz, .loop
	jp Main

SECTION "test", ROM0
Test::

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
; pulse and delay lengths
hPulse:: ds 1
hDelay:: ds 1
; used by delay plotter
hBytes:: ds 1
hCode:: ds 10

SECTION "code ram", WRAMX
wRAMCode::
	ds 4096

SECTION "vram", VRAM[_VRAM]
align 4
vScreen::
	ds xScreen2bpp.end - xScreen2bpp
	.end::
align 4
vFont::
	ds xFont2bpp.end - xFont2bpp
	.end::