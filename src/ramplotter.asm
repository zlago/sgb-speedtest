INCLUDE "hardware.inc" ; hw
INCLUDE "defines.inc" ; mnems

SECTION "ram plotter", ROM0
RAMPlotter::
	; place the delays
		ld hl, wPacketDelayCode
		ld de, wRAMCode
		ld a, [wPacketDelayBytes]
		ld b, a
		ld c, 128 + 1 + 1
	.delaysLoop
		push bc
			push hl
				inc de
				call ShortCpy
			pop hl
		pop bc
		dec c
		jr nz, .delaysLoop
	; place the loads
		ld hl, wPacketLoads
		ld de, wRAMCode
		ld a, [wPacketDelayBytes]
		inc a
		ld c, a
		ld b, 128 + 1 + 1
	.loadsLoop
		ld a, [hl+]
		ld [de], a
		ld a, c
		; add de, a
			add a, e
			ld e, a
			adc a, d
			sub a, e
			ld d, a
		dec b
		jr nz, .loadsLoop
	; place the ret
		ld a, MNEM_RET
		ld [de], a
	; done
	ret

