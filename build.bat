@ ECHO OFF
:: i am sorry for using batch files i promise i will switch to make one day
:: assemble all the asm files into object files
rgbasm -h -Wall -i src/inc/ -o obj\main.o src\main.asm
rgbasm -h -Wall -i src/inc/ -o obj\sub.o src\sub.asm
rgbasm -h -Wall -i src/inc/ -o obj\rand.o src\rand.z80
:: link the files, spit out a rom, a sym, and a map
rgblink -p 0xFF -m bin\packettest.map -n bin\packettest.sym -o bin\packettest.gb obj\main.o obj\sub.o obj\rand.o
:: fix the header
rgbfix -l 0x33 -j -s -v -p 0xFF -t "PACKET TEST" bin/packettest.gb
:: check the rom ussage (optional, i like how it looks)
romusage bin\packettest.map -g
:: done! pause to let the user see any errors
pause