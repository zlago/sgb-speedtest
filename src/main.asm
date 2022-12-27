; 

INCLUDE "hardware.inc" ; hardware definitions
INCLUDE "macros.inc"
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
	; set a to newly pressed buttons
		ldh a, [hInput1]
		ld b, a
		ldh a, [hInput1.diff]
		and b
	; if B pressed, reset palette
	ld b, a ; save for later
	and PADF_B
	jp nz, Reset
	; if A pressed, run test
	ld a, b ; restore
	and PADF_A
	jp nz, Test
	;loop
	jr .loop

SECTION "packet wait", ROM0
PacketWait:
	ld a, 4
.loop
	halt
	push af
	call LengthUpdate
	pop af
	dec a
	jr nz, .loop
	jp Main

SECTION "reset", ROM0
Reset::
	; reset palette
	ld hl, xPackets.palres
	call Packet
	; stall for 4 frames
	jp PacketWait

SECTION "test", ROM0
Test::
	; plot delay code
		; plot delay code for pulses
			ldh a, [hPulse]
			sub 2 ; ld overhead
			call DelayPlotter
			; copy to RAM
			ld hl, hBytes
			ld de, wPulseBytes
			ld b, hCode.end - hBytes
			call ShortCpy
		; plot delay code for delays
			ldh a, [hDelay]
			sub 2 ; ld overhead
			call DelayPlotter
			; copy to RAM
			ld hl, hBytes
			ld de, wDelayBytes
			ld b, hCode.end - hBytes
			call ShortCpy
		; plot the two together
			; fetch delay bytes for later
			ld a, [wDelayBytes]
			ld c, a
			; fetch pulse bytes for now
			ld a, [wPulseBytes]
			ld b, a
			; calc total bytes
			scf ; cooler than inc
			adc a, c ; add two byte counts together
			ld [wPacketDelayBytes], a ; and store
			; copy pulse length, b is preloaded with length
			ld de, wPacketDelayCode
			ld hl, wPulseCode
			call ShortCpy
			; insert the pulse end
			ld a, MNEM_LD_HL_H ; sets both P14 and P15 HIGH, ending the pulse
			ld [de], a
			inc de
			; copy delay length
			ld hl, wDelayCode
			ld b, c ; restore delay bytes
			call ShortCpy
	; plot lds for the packet
		; init
			ld hl, wPacketLoads
			ld de, xPackets.palset
			ld b, 16 ; load byte count into b
		; reset pulse
			ld a, MNEM_LD_HL_L
			ld [hl+], a
		.byteLoop ; read a byte
			ld a, [de] ; fetch a byte
			ld c, a ; and put it in c
			inc de
			push bc ; push byte count for later
			ld b, 8 ; load bit count into b
			.bitLoop ; process a bit
				rr c ; shift bit out
				ld a, (MNEM_LD_HL_B & MNEM_LD_HL_C) >> 1
				adc a ; shift bit in
					ASSERT MNEM_LD_HL_B ^ MNEM_LD_HL_C == %1
				ld [hl+], a ; store
				dec b ; repeat for all bits
				jr nz, .bitLoop
			pop bc ; restore byte count
			dec b ; repeat for all bytes
			jr nz, .byteLoop
		; end bit
			ld a, MNEM_LD_HL_B & MNEM_LD_HL_C
			ld [hl+], a
	; plot the loads and delays
		call RAMPlotter
	; run
		ld hl, rP1
		lb bc, P1F_5, P1F_4
		call wRAMCode
	jp PacketWait

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
; used by the delay plotter
hBytes:: ds 1
hCode:: ds DELAY_BYTES
	.end::

SECTION "nopslide", ROM0, align[8]
NopSlide::
	rept 256 - 10
		nop
		endr
	ret

SECTION "plotter scratch pad", WRAM0
; delay code for pulses
wPulseBytes:: ds 1
wPulseCode:: ds DELAY_BYTES
	.end::
; delay code for delays
wDelayBytes:: ds 1
wDelayCode:: ds DELAY_BYTES
	.end::
; final plotted delay code
wPacketDelayBytes:: ds 1
wPacketDelayCode:: ds (DELAY_BYTES * 2) + 1
; bytes for LDs
wPacketLoads:: ds 128 + 1 + 1

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