

A repository for Tandberg Data Keyboards technical information an ROM's.


It was used for:
https://en.wikipedia.org/wiki/TDV_2200

The keycaps looks like Devlin Z series.
https://www.devlin.co.uk/products/components/keycaps.html

They actually are Siemens STB 11/21.
The swtitches are described here:

Early models:
https://deskthority.net/wiki/Siemens_STB_11

Later:
https://deskthority.net/wiki/Siemens_STB_21



Tech details that I have been told: 
The keyboard runs standard UART over RS-485, 2400 baud from the keyboard and 600 baud to the keyboard. This is worth noting, as one does not always expect the speed of Rx and Tx to be different. Bytes sent from the keyboard are mostly pure ASCII codes when regular buttons are pressed.

Other keys have codes with bit 7 set to 1, often with the bottom 7 bits set to an equivalent ASCII code/function. Bytes you send to the keyboard are commands, like turning on/off "beep" at keystrokes, reading out key status, controlling the lights, and things like that.

What's available of commands varies slightly based on what firmware is in.

The biggest challenge is that, broadly speaking, the keyboard only sends characters when a button is pressed. Fine for typing, but not very much when one needs to press certain button combinations in Windows or Linux for example.


Source site:
https://sites.google.com/site/tingox/tdv2200


Adapter, it is for TDV2215 keyboard.
It also works for the 2200.
It should be possible to hack it to use a usb port.
https://github.com/Frodevan/Tandberg-Adapter

-----------------

TDV-5000 Series

A Quote from Frode van der Meeren:
Tandberg made these keyboards in the late 80s specifically for PC ports of Norsk-Data software (especially the NOTIS word processor). This was ten years before it was common to have a lot of extra buttons on the keyboard, so Tandberg naturally created his own system for these buttons. This system doesn't understand keyboard controllers on modern PCs (and certainly not drivers on modern operating systems), so the extra 20 buttons here are usually useless without a fix. The patch fixes this, and makes all the extra buttons output valid codes for "extra buttons" that have become standard in recent times.
The patch must be written to an 8051-compatible chip, but otherwise it is just a matter of replacing the controller that is in it with this one.

You can find the file here: https://github.com/Supermagnum/Tandberg/tree/TDV-5000/tdv_5000_patch.zip
You need an 8051 burner and an unprogrammed chip, but quite a few EPROM programmers handle this just fine.

Will only work with Tandberg-produced keyboards using Siemens-style switches (will NOT work with the later Cherry-OEM boards).

Relevant links:
https://deskthority.net/viewtopic.php?p=510471

https://deskthority.net/wiki/Tandberg_Data_TDV_5000_Series



-----------------
Controller Pcb measures: Generally:

* 51mm depth on the entire circuit board
* The width is not as critical, there is room for close to 400mm inside the rail in which it is mounted.

From the left edge of the circuit board, same side as the PS/2 connector:

* 11mm towards the right to the center of the PS/2 connector
* 57mm towards the right to the center of the first pin on the first flat cable
* 162mm towards the right to the center of the first pin on the second flat cable

Else
* 7mm downwards from the upper long side to the first pin on the flat cable
* 19mm length between the first and last pin on each flat cable (16 conductors, so approx. 1.24mm pitch).

Connectors:
LIF (Low Insertion Force) FFC socket. The pitch is 1.25mm

https://connectorbook.com/identification.html?m=NNK&n=ffc_fpc_lif_sockets&fl=000000000000-f-||1.25

* MANUF. - SERIES
* Adam Tech - PCB 1.25mm
* [JST](https://www.jst.com/products/ffc-fpc-connectors/fe-connector/) - [FE](https://www.jst.com/wp-content/uploads/2021/03/eFE.pdf) (pdf) - [digikey](https://www.digikey.ee/short/qz85mbb3)
* Molex - 52044 - [digikey](https://www.digikey.ee/short/bcqq5vn9)
* Molex - 52045 - [digikey](https://www.digikey.ee/short/rfdtp9t1)
* [TE](https://www.te.com/usa-en/products/connectors/pcb-connectors/wire-to-board-connectors/ffc-fpc-ribbon-connectors/fpc-connectors.html?tab=pgp-story) - 84533 - [digikey](https://www.digikey.ee/short/54bfrwrh)
* [TE](https://www.te.com/usa-en/products/connectors/pcb-connectors/wire-to-board-connectors/ffc-fpc-ribbon-connectors/fpc-connectors.html?tab=pgp-story) - 84534 - [digikey](https://www.digikey.ee/short/54bfrwrh)

Drop in PCB attempt, with modern controller and USB 
https://github.com/Supermagnum/Tandberg/tree/main/Tandberg-USB

Suggested firmware that has to be written:
https://qmk.fm/

https://get.vial.today/

