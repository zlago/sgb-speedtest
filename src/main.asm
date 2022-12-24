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
	
	:jr:- ; endless loop