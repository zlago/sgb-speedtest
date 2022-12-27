INCLUDE "hardware.inc" ; hardw
INCLUDE "defines.inc" ; mnemos

SECTION "delay plotter", ROM0 ; a - delay (M-cycles)
DelayPlotter::
	ldh [hBytes], a ; set length
	and a
	ret z ; exit if zero
	cp 10 ; check cycles
	jr nc, .delayCall

.delayNop ; if a < 10 delay with nops
	; fill code with nops
	ld b, a
	xor a
		ASSERT MNEM_NOP == 0
	ld hl, hCode
	jp ShortSet ; tail call

.delayCall ; if a > 10 delay with a CALL
	ld b, a ; save for later
	; set fixed length
	ld a, 3
	ldh [hBytes], a
	; set mnemonic byte
	ld a, MNEM_CALL
	ldh [hCode+0], a
	; calculate and set low address byte
	xor a
	sub a, b
	ldh [hCode+1], a
	; set high address byte
	ld a, HIGH(NopSlide)
	ldh [hCode+2], a
	; done
	ret