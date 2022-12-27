; SGB packet defines
DEF PAL01    EQU $00<<3 ; Set SGB Palette 0 & 1
DEF PAL23    EQU $01<<3 ; Set SGB Palette 2 & 3
DEF PAL03    EQU $02<<3 ; Set SGB Palette 0 & 3
DEF PAL12    EQU $03<<3 ; Set SGB Palette 1 & 2
DEF ATTR_BLK EQU $04<<3 ; “Block” Area Designation Mode
DEF ATTR_LIN EQU $05<<3 ; “Line” Area Designation Mode
DEF ATTR_DIV EQU $06<<3 ; “Divide” Area Designation Mode
DEF ATTR_CHR EQU $07<<3 ; “1CHR” Area Designation Mode
DEF SOUND    EQU $08<<3 ; Sound On/Off
DEF SOU_TRN  EQU $09<<3 ; Transfer Sound PRG/DATA
DEF PAL_SET  EQU $0a<<3 ; Set SGB Palette Indirect
DEF PAL_TRN  EQU $0b<<3 ; Set System Color Palette Data
DEF ATRC_EN  EQU $0c<<3 ; Enable/disable Attraction Mode
DEF TEST_EN  EQU $0d<<3 ; Speed Function
DEF ICON_EN  EQU $0e<<3 ; SGB Function
DEF DATA_SND EQU $0f<<3 ; SUPER NES WRAM Transfer 1
DEF DATA_TRN EQU $10<<3 ; SUPER NES WRAM Transfer 2
DEF MLT_REQ  EQU $11<<3 ; Multiple Controllers Request
DEF JUMP     EQU $12<<3 ; Set SNES Program Counter
DEF CHR_TRN  EQU $13<<3 ; Transfer Character Font Data
DEF PCT_TRN  EQU $14<<3 ; Set Screen Data Color Data
DEF ATTR_TRN EQU $15<<3 ; Set Attribute from ATF
DEF ATTR_SET EQU $16<<3 ; Set Data to ATF
DEF MASK_EN  EQU $17<<3 ; Game Boy Window Mask
DEF OBJ_TRN  EQU $18<<3 ; Super NES OBJ Mode

; mnemonic byte defines
DEF MNEM_NOP     EQU $00
DEF MNEM_LD_HL_B EQU $70
DEF MNEM_LD_HL_C EQU $71
DEF MNEM_LD_HL_D EQU $72
DEF MNEM_LD_HL_E EQU $73
DEF MNEM_LD_HL_H EQU $74
DEF MNEM_LD_HL_L EQU $75
DEF MNEM_LD_HL_A EQU $77
DEF MNEM_CALL    EQU $cd
DEF MNEM_RET     EQU $c9

; used by all "hCode" type labels
DEF DELAY_BYTES EQU 9