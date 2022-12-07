It was used for:
https://en.wikipedia.org/wiki/TDV_2200

The keycaps looks like Devlin Z series.
https://www.devlin.co.uk/products/components/keycaps.html


Tech details that I have been told: 
The keyboard runs standard UART over RS-485, 2400 baud from the keyboard and 600 baud to the keyboard. This is worth noting, as one does not always expect the speed of Rx and Tx to be different. Bytes sent from the keyboard are mostly pure ASCII codes when regular buttons are pressed.

Other keys have codes with bit 7 set to 1, often with the bottom 7 bits set to an equivalent ASCII code/function. Bytes you send to the keyboard are commands, like turning on/off "beep" at keystrokes, reading out key status, controlling the lights, and things like that.

What's available of commands varies slightly based on what firmware is in.

The biggest challenge is that, broadly speaking, the keyboard only sends characters when a button is pressed. Fine for typing, but not very much when one needs to press certain button combinations in Windows or Linux for example.


text:
https://github.com/Supermagnum/Tandberg/blob/main/site.txt

Source site:
https://sites.google.com/site/tingox/tdv2200






