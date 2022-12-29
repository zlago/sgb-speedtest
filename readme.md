### super game boy packet speed test

this test rom is made to test how fast you can send bits to the
ICD because beware wanted better SGB accuracy and
[nerd-sniped](https://xkcd.com/356/) me into doing it

### testing

to run the test, first, if the square is green, press B
(Y on snes) to set the color to red, then
decrement either pulse or delay (left or down),
and press A (A on snes) to create and send a packet

if the square is green, then the packet got sent,
if its still red, then the packet failed to send

id recommend resetting and setting a few more
times to make sure the result is consistent

repeat untill you find the lowest consistently working delays

id also recommend trying to reach just the lowest pulse,
and just the lowest delay in separate tests cause i have
no idea if the two happen to affect each other

### compiling

[rgbds](https://github.com/gbdev/rgbds) is all you need
oh and something that runs batch files

### source

i have been informed that the source
code may or may not be insane

read it at your own risk