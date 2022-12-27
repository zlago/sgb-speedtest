INCLUDE "hardware.inc" ; defs

DEF FONT_TILE EQUS "(vFont - _VRAM) >> 4" ; used when displaying
DEF DELAY_SCRN EQU $996a
DEF PULSE_SCRN EQU $998a
SECTION "length update", ROM0
; reads joypad and updates the pulse/delay accordingly
LengthUpdate::
	call Joy
	; fetch newly pressed keys
	ldh a, [hInput1]
	ld b, a
	ldh a, [hInput1.diff]
	and b
	ld b, a
	; update hDelay
		; load hDelay into c
		ld a, [hDelay]
		ld c, a
		; check for and process UP
		ld a, PADF_UP
		and b
		jr z, .skipUp
		inc c ; increment if up pressed
		.skipUp
		; check for and process DOWN
		ld a, PADF_DOWN
		and b
		jr z, .skipDown
		dec c ; decrement if down pressed
		.skipDown
		; fix and store
		ld a, c
		and a ; if zero, wrap to 2
		jr nz, .skipDelayOver
		ld a, 2
		.skipDelayOver
		cp 1 ; if 1, wrap to 255
		jr nz, .skipDelayUnder
		ld a, $ff
		.skipDelayUnder
		ldh [hDelay], a
	; done, repeat for hPulse
		; load hPulse into c
		ld a, [hPulse]
		ld c, a
		; check for and process RIGHT
		ld a, PADF_RIGHT
		and b
		jr z, .skipRight
		inc c ; increment if right pressed
		.skipRight
		; check for and process LEFT
		ld a, PADF_LEFT
		and b
		jr z, .skipLeft
		dec c ; decrement if left pressed
		.skipLeft
		; fix and store
		ld a, c
		and a ; if zero, wrap to 2
		jr nz, .skipPulseOver
		ld a, 2
		.skipPulseOver
		cp 1 ; if 1, wrap to 255
		jr nz, .skipPulseUnder
		ld a, $ff
		.skipPulseUnder
		ldh [hPulse], a
		; done
	; update the displayed tiles
		ld e, $0f ; bitmask
		ld d, FONT_TILE
		; display delay
			ld a, [hDelay]
			ld hl, DELAY_SCRN
			ld b, a ; low nibble
			ld c, a
			swap c ; high nibble
			; display delay high
			ld a, c
			and e
			add d
			ld [hl+], a
			; display delay low
			ld a, b
			and e
			add d
			ld [hl+], a
		; display pulse
			ld a, [hPulse]
			ld hl, PULSE_SCRN
			ld b, a ; low nibble
			ld c, a
			swap c ; high nibble
			; display pulse high
			ld a, c
			and e
			add d
			ld [hl+], a
			; display pulse low
			ld a, b
			and e
			add d
			ld [hl+], a
	; done
	ret