

A repository for Tandberg Data Keyboards technical information an ROM's.


It was used for:
https://en.wikipedia.org/wiki/TDV_2200

The keycaps looks like Devlin Z series.
https://www.devlin.co.uk/products/components/keycaps.html

They actually are Siemens STB 11/21.
What the switches might be is described here:

Early models:
https://deskthority.net/wiki/Siemens_STB_11

Later:
https://deskthority.net/wiki/Siemens_STB_21



Tech details that I have been told: 
The keyboard runs standard UART over RS-485, 2400 baud from the keyboard and 600 baud to the keyboard. This is worth noting, as one does not always expect the speed of Rx and Tx to be different. Bytes sent from the keyboard are mostly pure ASCII codes when regular buttons are pressed.

Other keys have codes with bit 7 set to 1, often with the bottom 7 bits set to an equivalent ASCII code/function. Bytes you send to the keyboard are commands, like turning on/off "beep" at keystrokes, reading out key status, controlling the lights, and things like that.

What's available of commands varies slightly based on what firmware is in.

The biggest challenge is that, broadly speaking, the keyboard only sends characters when a button is pressed. Fine for typing, but not very much when one needs to press certain button combinations in Windows or Linux for example.

PDF files with characters, electric schemas:
https://github.com/Supermagnum/Tandberg/tree/main/pdf-files

ROM's:
https://github.com/Supermagnum/Tandberg/tree/main/TDV-2200%20ROM-files

text:
https://github.com/Supermagnum/Tandberg/blob/main/site.txt

Source site:
https://sites.google.com/site/tingox/tdv2200


Adapter, it is for TDV2215 keyboard.
It might work for the 2200.
It should be possible to hack it to use a usb port.
https://github.com/Frodevan/Tandberg-Adapter

A Quote from Frode van der Meeren:
Tandberg made these keyboards in the late 80s specifically for PC ports of Norsk-Data software (especially the NOTIS word processor). This was ten years before it was common to have a lot of extra buttons on the keyboard, so Tandberg naturally created his own system for these buttons. This system doesn't understand keyboard controllers on modern PCs (and certainly not drivers on modern operating systems), so the extra 20 buttons here are usually useless without a fix. The patch fixes this, and makes all the extra buttons output valid codes for "extra buttons" that have become standard in recent times.
The patch must be written to an 8051-compatible chip, but otherwise it is just a matter of replacing the controller that is in it with this one.

You can find the file here: https://inhale.ed.ntnu.no/tdv_5000_patch.zip or https://github.com/Supermagnum/Tandberg/blob/main/tdv_5000_patch.zip
You need an 8051 burner and an unprogrammed chip, but quite a few EPROM programmers handle this just fine.

-----------------



