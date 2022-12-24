; various subroutines such as memcpys, specific memcpys,
; OAM DMA, joy polling, basic SGB communication

; theres also optimized div and mul, maybe ill go
; crazy and write even more maths stuff?

; i dont know why youd use this over pinos stuff

; the comments may be a bit lacking, but thats fine

; if for any crazy reason you do use any of these
; then please credit me, and like let me know,
; it makes the time i spent on this not feel like a waste

INCLUDE "hardware.inc" ; hardware definitions, really important
INCLUDE "macros.inc" ; helps with readability, at least a bit

SECTION "memcpy", ROM0
MemCpy:: ; hl - src, de - dest, bc - length
	; adjust for decloop
	dec bc
	inc b
	inc c
.loop ; copy a byte
	ld a, [hl+]
	ld [de], a
	inc de
	; decrement length
	dec c
	jr nz, .loop
	dec b
	jr nz, .loop
	ret

SECTION "shortcpy", ROM0
ShortCpy:: ; hl - src, de - dest, b - length
.loop	; copy a byte
	ld a, [hl+]
	ld [de], a
	inc de
	; decrement length
	dec b
	jr nz, .loop
	ret

SECTION "memset", ROM0
MemSet:: ; a - data, hl - dest, bc - length, clobbers e
	; adjust bc
	dec bc
	inc b
	inc c
.loop	; set a byte
	ld [hl+], a
	; decrement length
	dec c
	jr nz, .loop
	dec b
	jr nz, .loop
	ret

SECTION "shortset", ROM0
ShortSet:: ; a - data, hl - dest, b - length
.loop	; copy a byte, short as fu-
	ld [hl+], a
	; decrement length
	dec b
	jr nz, .loop
	ret

SECTION "palcpy", ROM0
PalCpy:: ; hl - src, a - AUTOINC | dest, c - OCPS/BCPS, b - length (bytes!!)
	; set addr
	ldh [c], a
	inc c
.loop	; copy a byte
	ld a, [hl+]
	ldh [c], a ; pal
	; dec length
	dec b
	jr nz, .loop
	ret

SECTION "safecpy", ROM0
SafeCpy:: ; hl - src, de - dest, bc - length, align 1!!
	; adjust for unroll (2), then adjust bc
	srl b
		rr c
	dec bc
	inc b
	inc c
.loop	; wait for safe VRAM access
	ldh a, [rSTAT]
	and STATF_BUSY
	jr nz, .loop
	; once its safe copy 2 bytes
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, [hl+]
	ld [de], a
	inc de
	; check if all bytes got copied
	dec c
	jr nz, .loop ; repeat
	dec b
	jr nz, .loop
	ret

SECTION "safeset", ROM0
SafeSet:: ; a - data, hl - dest, bc - length, clobbers e, align 2!!
	; adjust for unroll (4), then adjust bc
	REPT 2
		srl b
		rr c
		ENDR
	dec bc
		inc b
		inc c
	ld e, a ; a gets clobbered in the "safe" part
.loop	; wait for safe VRAM access
	ldh a, [rSTAT]
	and STATF_BUSY
	jr nz, .loop
	; once its safe set 4 bytes
	ld a, e ; restore accumulator
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	; check if all bytes got set
	dec c
	jr nz, .loop
	dec b
	jr nz, .loop ; repeat
	ret

; this is a popslide, as the name suggests it
; pops values off the stack, as its faster for
; copying lots of data (32 bytes or more)
; unfortunately it needs disabled interrupts
SECTION "popslide", ROM0
Popslide:: ; a - length, hl - src, de - dest, clobbers bc, align 4!!
	ld [wStack], sp ; save sp
	; PLEASE make sure IME=0
	ld sp, hl
	ld h, d
	ld l, e
	.loop
	FOR V, 16/2
		pop bc
		ld [hl], c
		inc l
		ld [hl], b
		IF V == 7
			inc hl
		ELSE
			inc l
		ENDC
	ENDR
	dec a
	jr nz, .loop
	ld sp, wStack
	pop hl
	ld sp, hl
	ret

SECTION "DMA", ROM0
DMAcopy:: ; copy this to HRAM then call hDMA
LOAD "hDMA", HRAM
hDMA:: ; a = high(ShadowOAM)
	ldh [rDMA], a
	ld a, 40
	.wait
	dec a
	jr nz, .wait
	ret
	.end::
ENDL

; allocate shadow OAM
SECTION "shadowOAM", WRAM0, ALIGN[8]
	wSOAM:: ds 160
	.index:: ds 1
	.end::

if DEF(PLAYERS) == 0
	DEF PLAYERS EQU 1 ; default to 1 player
endc

SECTION "joy", ROM0 ; wow this is such a mess
Joy:: ; reads joypad, b - no. of joypads (if more than 1), clobbers (b)c, hl
	ld hl, hP1
	ld c, LOW(rP1)
.loop
	ld e, [hl] ; preserve for later
	ldh a, [c] ; get Dpad
	ld d, a
	ld a, P1F_GET_BTN
	ldh [c], a ; select buttons
	ld a, $0f
	and d
	swap a ; dpad goes in left nibble
	ld d, a
	ldh a, [c] ; get buttons
	and a, $0f
	or a, d ; merge states
	cpl ; invert
	ld [hl+], a ; buttons held
	xor a, e
	ld [hl+], a ; buttons changed
	ld a, P1F_GET_DPAD
	ldh [c], a ; select Dpad
	if PLAYERS > 1
		dec b
		jr nz, .loop
	endc
	ret

SECTION "joypads", HRAM
rept PLAYERS
	hP{x:PLAYERS}:: ds 1
	.x:: ds 1
endr

; someone please if youre reading this remind me to
; rewrite this entire thing at some point or something
SECTION "packet", ROM0 ; this looks like a mess..
Packet:: ; sends an SGB packet, hl - src
	lb bc, 16, LOW(rP1)
	xor a
		ldh [c], a ; 5 cycles
	ld a, $ff ; end pulse
		nop
		ldh [c], a ; 15 cycles
	.byte
		ld d, [hl]
		inc hl
		ld e, 8
		.bit
			xor a ; load A with SGB bit
				rr d ; fetch next bit
				ccf ; set accumulator in the dumbest way i could come up with
				adc a, a
				inc a
				swap a
				REPT 2
					nop
					ENDR
				ldh [c], a ; 5 cycles
			ld a, $ff ; end pulse
				nop
				ldh [c], a ; 15 cycles
			dec e
			jr nz, .bit
		dec b
		jr nz, .byte
	ld a, $20 ; stop bit
		REPT 6
			nop
			ENDR
		ldh [c], a
	ld a, $ff ; hi?
		nop
		;nop
		ldh [c], a
	ld a, P1F_GET_DPAD ; reselect buttons
		REPT 11
			nop
			ENDR
		ldh [c], a
	ret

SECTION "multiply", ROM0
; multiply by adding, except with bitshifts to reduce required additions
; this is all unsigned
; this takes * 12MSSBb + BS + 22 M-cycles (up to 114 M-cycles)
; where MSSBb is the most significant set bit of b
; and BS is number of set bits in b register
Multiply:: ; hl = b * c, clobbers a
	ld hl, 0
	ld a, b
	ld b, 0
	or a ; clears carry
.loop
	rra ; check bit 0, shift a, carry must be reset
	jr nc, :+
	add hl, bc ; add if carry set
:	sla c ; shift bc left
	rl b
	and a ; end as soon as out of bits, also clears carry
	jr nz, .loop
	ret

SECTION "divide", ROM0
; based on the "long division" method or whatever its called
; since this is binary you only need one check per digit
; big thanks to calc84maniac for pointing out a "nonbinding" optimization
; and evie/eievui for helping test and debug!
; division by zero returns a=l, hl=$ffff
; up to 203 M-cycles for a bit 7 reset, 236 M-cycles otherwise
; also this is unsigned division!!
Divide:: ; hl = hl / a, a = hl % a, clobbers de
	ld d, a
	ld e, 16 ; you could check if H is 0 and run for only 8 bits maybe?
	xor a
	bit 7, d
	jr nz, .loop8 ; 8 bit loop has a failsafe, at a small cycle penalty
	for V, 7, 9
.loop{d:V}
	add hl, hl ; shift hla left
	rla
	if V == 8 ; only for 8 bit loop
		jr c, .more{d:V} ; always sub if a overflows
	endc
	cp a, d ; check if can sub
	jr c, .less{d:V}
	.more{d:V} ; sub and shift a bit in hla
	sub d
	inc l
	.less{d:V}
	dec e ; repeat
	jr nz, .loop{d:V}
	ret
	endr

SECTION "crc", ROM0
DEF CRC32_POLY EQU $EDB88320 ; reflected $04c11db7
; this would be crc32ccitt if it was actually fucking
; properly documented i am so fucking mad who the fuck
; even wrote the god damn documentation
; please write your own converter or something if you want to use this
; cause i am not going to make it 1:1 compatibile with crc32ccitt untill someone
; writes actual documentation that actually explains what the fuck is going on there
; de - data to checksum, bc - data length
; hl = pointer to a 4 byte big endian checksum
; clobbers all registers
Crc32::
	inc bc ; it will skip processing the
		; last byte otherwise
	; init buffer
	ld hl, wCrc.crc
	ld a, $ff
	rept 4
		ld [hl+], a
	endr
.load ; load a byte
	ld a, [de]
	ld [wCrc.input], a
	inc de
	dec bc
	; check for end of data
	ld a, b
	or a, c
	jr z, .end
	push bc ; save byte counter
	ld b, 8 ; use b as bit counter instead
.shift ; shift the buffer
	ld l, LOW(wCrc.input)
	for V, 5
		rr [hl]
		if V < 4
			inc l
				ASSERT HIGH(wCrc) == HIGH(wCrc.end)
		endc
	endr
	jr c, .divide ; check for overflow
	dec b ; decrement bit count
	jr nz, .shift ; if bits > 0 keep going
	pop bc ; restore byte counter
	jr .load ; if out of bits load next byte

.divide ; divide buffer
	ld l, LOW(wCrc.crc)
	for V, 4 ; xor each byte with the polynomial
		ld a, [hl]
		xor LOW(CRC32_POLY>>((3-V)*8))
		ld [hl+], a
	endr
	dec b ; decrement bit count
	jr nz, .shift ; if bits > 0 keep going
	pop bc ; restore byte counter
	jr .load ; if out of bits load next byte

.end ; make hl point at the checksum
		ld l, LOW(wCrc.end)
		ld b, 4
			ASSERT wCrc.end - 4 == wCrc.crc
			; make sure that hl will be wCrc.crc when returning
		.outXorLoop ; bitflip the checksum
		dec l
		ld a, [hl]
		cpl
		ld [hl], a
		dec b
		jr nz, .outXorLoop
	ret

SECTION "crcram", WRAM0, ALIGN[3]
wCrc::
	.input ds 1 ; 8 bit buffer for bit by bit input processing
	.crc   ds 4 ; 32 bit buffer for processing the CRC
	.end

; allocate a stack
; if no stack size passed, default to 32
if ISCONST(STACK_SIZE) != 1 || DEF(STACK_SIZE) != 1
	DEF STACK_SIZE EQU 32
endc

SECTION "stack", WRAM0[$d000-(STACK_SIZE*2)] ; put the stack at the end
wStack:: ds (STACK_SIZE*2) ; stack operates on words
.origin:: ; ld sp, stack.origin