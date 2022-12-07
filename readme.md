Tech details that I have been told: 
The keyboard runs standard UART over RS-485, 2400 baud from the keyboard and 600 baud to the keyboard. This is worth noting, as one does not always expect the speed of Rx and Tx to be different. Bytes sent from the keyboard are mostly pure ASCII codes when regular buttons are pressed.

Other keys have codes with bit 7 set to 1, often with the bottom 7 bits set to an equivalent ASCII code/function. Bytes you send to the keyboard are commands, like turning on/off "beep" at keystrokes, reading out key status, controlling the lights, and things like that.

What's available of commands varies slightly based on what firmware is in.

The biggest challenge is that, broadly speaking, the keyboard only sends characters when a button is pressed. Fine for typing, but not very much when one needs to press certain button combinations in Windows or Linux for example.



Source site:
https://sites.google.com/site/tingox/tdv2200

From the site:
8035 info: port 1 is P10 - P17 (pin 27 - 34), port 2 is P20 - P23 (pin pin 21 - 24) and P24 - P27 (pin 35 - 38), bus is DB0 - DB7 (pin 12 - 19), test inputs T0 (pin 1) and T1 (pin 39), interrupt line INT (pin 6)
location 0 - reset (start) address
location 3 - INT causes jump to subroutine here
location 7 - timer / counter interrupt (from timer overflow) - jump to subroutine here

History:
2018-03-26: from a PM on VCFED forums; speed is 2400 baud from keyboard, and 600 baud to keyboard. Interesting.

2016-05-12: Bitraf build night - more testing. I added a decoupling capacitor (100 nF) between VCC and GND on the MAX485. I used a different keyboard this time, and unsoldered the buzzer ("BIPP") to avoid the irritating sound whenever I connect the keyboard. Tested:
- changed line resistor on TRANS line from 120 ohm to 220 ohm
- added a second MAX485, with 100 nF decoupling capacitor, connected REC line to A and B on MAX485, and connected DI on MAX485 to pin 11 on Arduino. RE inverted and DI on the MAX485 are connected high.
- connected pin 4 (DI) to GND

2016-04-24: I need decoupling capacitors on the MAX485's. 0.1 microF (100 nF) is suggested.

2016-04-21: Bitraf - SoftwareSerial library uses 8-n-1 data format. Maybe the keyboard doesn't use that?
2016-04-21: Bitraf - connected up a MAX485 on a breadboard. pin 6 (A) to TRANS (pin 9 on DE9) and pin 7 (B) to TRANS inverted (pin 4 on DE9). A 120 ohm resistor is connected between pins 6 and 7. GND to pin 5 (and pin 6 on DE9, and to GND on Arduino Uno). VCC to pin 8 (and to pin 3 on DE9, and to + 5V on Arduino Uno). Pin 3 (DI) and pin 2 (RE inverted) are connected to GND. Pin 1 (RO) is connected to pin 10 on Arduino Uno (which is configured as RX in SoftwareSerial). Unfortunately, I couldn't get it to work yet. The sketch is based on SoftwareSerialExample, and I stole the MirrorByte function from here.
sketch:
#include <SoftwareSerial.h>

SoftwareSerial mySerial(10, 11, true); // RX, TX, inverse_logic

void setup()
{
  // Open serial communications and wait for port to open:
  Serial.begin(57600);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for Leonardo only
  }


  Serial.println("Goodnight moon!");

  // set the data rate for the SoftwareSerial port
  mySerial.begin(2400);
  // mySerial.println("Hello, world?");
}

byte MirrorByte(byte x)
  {
    x = (((x&0xaa)>>1) + ((x&0x55)<<1));
    x = (((x&0xcc)>>2) + ((x& 0x33)<<2));
    return((x>>4) + (x<<4));
  }

void loop() // run over and over
{
  byte b, c;
  if (mySerial.available()>0){
    b = mySerial.read();
    // reverse byte
    c = MirrorByte(b);
    Serial.print(c,HEX);
    Serial.println();
  }
 // if (Serial.available())
    mySerial.print(Serial.read(),HEX);
}
ok.
2016-04-21: Bitraf - RS-422 termination - 120 ohms.
2016-04-21: Bitraf - measured power consumption - about 375 - 379 mA.

2016-04-15: I got a MAX485 module for Raspberry Pi that I ordered on eBay. It operates on 5V.

2016-03-24: information (seen from the terminal view, but still) from the TDV 2200 Service Manual (Partno. 961326, Oubl. no. 5214), Mainboard (Partno. 391522, Publ. no. 5224, January 1982, Revision no. 1), Chapter 3, Block Diagram Description, 3.11 Keyboard Interface: "Converts serial data from the Keyboard (RxKB) to parallel data clocked by KBCLK (2400 baud) and generates in interrupt request (KBINT) for each keyboard entry. Converts parallel data from the CPU to serial data (TxRB) to be transmitted to the Keyboard clocked by LACLK (2400 baud). Furthermore the CPU can read status signals from the Keyboard or send commands to it when the chip enable signal CKBPR is true.". I wonder if this information is correct. A MC6850 ACIA (asynchronous Communications Interface Adapter) that is used as the converter to / from serial. Facts: LACLK is connected to pin 4 (Tx clk)  and KBCLK to pin 3 (Rx clk) on the MC6850, so that part seems correct. CKBPR (bar) is connected to pin 9 on the MC6850, which is CS2 (bar).

2013-03-27: verifying the keyboard cable, using both visual inspection and a multimeter:
J2 is the internal connector, DE9 is the external, 9-pins that connects to the terminal.
J2 - DE9 - signal
1 - 3 - +5V (red)
2 - 7 - REC (blue)
3 - 2 - REC (inverted) (white)
4 - 9 - TRANS (brown)
5 - 4 - TRANS (inverted) (yellow)
6 - 6 - GND (black)
Note: all these are as seen from the keyboard, TRANS is to the terminal, REC is from the terminal.
2013-03-27: looking at the schematic for the TDV 2200 keyboard, a few key things:
receive (serial input to the keyboard) is connected via a 26LS32 to the T0 pin (pin 1) on the 8035.
send (serial output from the keyboard) is from the P15 pin (pin 32) on the 8035, via a 26LS31.

 the keyboard uses V.11 / RS-422 to at 2400 baud communicate with the terminal. The external keyboard connector (E1) is a 9 pin connector. Pinout is
1 - protective ground CHGND
2 - transmit to keyb. TXKB (bar)
3 - +5V
4 - receive from keyb.RXKB (bar)
5 -
6 - GND
7 - transmit to keyboard TXKB
8 -
9 - receive from keyboard RXKB
The keyboard uses a 26LS31 line driver (U10) and a 26LS32 line receiver (U9) which converts TTL to RS-422 signals. The mainboard uses the same circuits.

2013-03-27: description how the keyboard works (from the schematic notes): Clocked by a 5.76 MHz crystal oscillator the microprocessor continuously generates a cyclic 4-bit address for the scan decoder which scans the 16 vertical lines of the key matrix and pulls one line at a time low. At the same time the microprocessor reads the status of the eight horizontal matrix lines.

When a key is depressed, the "LOW" from the scan decoder is propagated through the key switch to a vertical line. Based on the present scan decoder address and the bus input from the (key) matrix, the microprocessor identifies the key that has been depressed, and retains this information as an indication that this particular key is depressed (it might just be contact bounce). If the same key is identified during the next scan (7 ms later), the microprocessor will acknowledge the key, and according to status information generate the appropriate address for the PROM where all the character codes are stored.

One extra status scan is provided during which none of the scan decoder outputs are active. The processor then reads the status of the control keys (SHIFT, LOCK, CTRL, etc.) which are all on the same vertical line. If one of these keys have been depressed in additon to a character key, it will affect the character code to be transmitted to the terminal.

2013-03-27: circuit description:
the keyboard has 16 vertical lines connected to the scan decoder (U4 - 74LS154) which enables one line at a time. The scan decoder is driven by the P10 - P13 (pin 27 - 30) lines of the 8035.
a 17th vertical line for the control keys enabled directly by the microprocessor. Controlled by P14 (pin 31) of the 8035.
8 horizontal lines feeding into the processor data bus ("bus"). They are going through a buffer (U2 and U3, 14502B), latched by the RD signal from the 8035.
Each of the 121 keys (when depressed) connects a vertical line and a horizontal line. The buffer connects the horizontal lines to the microprocessor.
The security lock option provides the possibility for installing one or two key lock switches, to protect against un-authorized use of the terminal (see Reference Manual, publ. no. 5302). THe lock switches are designated "AL1" and "AL2" in the schematic, and are connected to the control keys line.
The microprocessor (8035) does the following:
- generates addresses for the scan decoder
- identifies the key that has been depressed and determines the associated code address
- fetches the character from the PROM
- converts the code from parallel to serial form and transmits it to the terminal
- decodes serial codes from the terminal and accordingly sets mode, engages bell, reads status and sets lamps. Initiates keyboard self-check

Address latch and PROM. The PROM  (U8, 2716) contains the program instructions for the microprocessor and all the character codes. The eight least significant bits of the PROM address are latched into the Address latch (U7, 74LS373) from the processor bus. The three most significant address bits are applied to the PROM directly from the CPU. Read-out from the PROM is enabled by the PESEN signal (pin 9 on the 8035). A8, A9 and A10 on the PROM are P20 (pin 21) , P21 (pin 22) and P22 (pin 23) on the 8035.

Indicators and latch. The indicator latch (U5, 74LS373) holds the appropriate LED indicators on or off according to outputs from the processor which are accompanied by a WR strobe. The schematic doesn't indicate names of the LEDs, but a quick look at the keyboard shows this:
CR2 = EXP
CR3 = APP
CR4 = BUSY
CR5 = MSG
CR6 = LINE
CR7 = CAR
CR8 = WAIT
CR9 = ERROR

Line interface. Converts signal to be transmitted to the terminal to RS 422 level, and received signals to TTL level. Receive (to the keyboard) is on T0 (pin 1 on 8035), transmit (from the keyboard) is via P15 (pin 32 on 8035).

Bell and click circuit. May provide a bell sound in the 72nd and last character position on each line or when required by the application program. If enabled, the circuit will also provide an audible click each time a key is depressed and the associated code goes to the terminal, or each time a keyboard status code or card reader data is transmitted. P16 (pin 33 on 8035) is "Trans Flag" an P17 (pin 34 on 8035) is "Click inhibit".

The optional card reader circuit isn't described in the notes, but on the schematic I can see that CARD READY LED (aka "CR RDY LED") is controlled by P23 (pin 24 on 8035), CARD PRESENT (inverted, aka "CARD PRES") goes to P23 (pin 35 on 8035), CARD DATA (inverted)  goes to T1 (pin 39 on 8035), CARD CLOCK (inverted) goes to INT (pin 6 on 8035).
Other stuff: the "LOCK" LED is controlled by P26 (pin 37 on 8035), and the "CAPS" LED is controlled by P27 (pin 38 on 8035).

2013-03-26: use d48 to disassemble the file:
tingo@kg-v2$ ~/work/d52v336/d48 -d tdv2200k-8035

D48 8048/8041 Disassembler V 3.3.6
Copyright (C) 1996-2005 by J. L. Post
Released under the GNU General Public License
Initializing program spaces...
reading tdv2200k-8035.bin
Highest location = 07ff
Pass 1 - Reference search complete
Pass 2 - Source generation complete
Pass 3 - Equate generation complete
Done
The file tdv2200k-8035.d48 now contains the disassembled code. Nice.

2013-03-25: I dumped the ROM from the ND246 keyboard in Motorola S format using my Dataman S4. Then it is just to convert the file:
tingo@kg-t2$ dos2unix tdv2200k.log
tingo@kg-t2$ srec_cat tdv2200k.log -o tdv2200k-8035.rom -binary
srec_cat: tdv2200k.log: 2: warning: ignoring garbage lines
srec_cat: tdv2200k.log: 4: warning: no header record
tingo@kg-t2$ ll  t*rom
-rw-r--r--  1 tingo  users  - 4096 Mar 25 23:07 tdv2200k-8035.rom
Not sure why it ended up as 4096 bytes, it should be 2048 I think.
tingo@kg-t2$ hd tdv2200k-8035.rom | less
00000000  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
*
00000800  c5 a4 33 55 84 60 00 d5  af a5 23 fb 62 eb 37 1b  |Å¤3U.`.Õ¯¥#ûbë7.|
00000810  fa 96 1e 36 37 ba 08 bb  06 04 37 97 04 25 bb 04  |ú..67º.»..7..%».|
Ok, it is because of the 0800 starting address. I can skip 2048 zero bytes, I think.
Use dd to cut off the first 2048 bytes:
tingo@kg-v2$ dd bs=2048 skip=1 if=tdv2200k-8035.rom of=tdv2200k-8035.bin
1+0 records in
1+0 records out
2048 bytes transferred in 0.000055 secs (37185864 bytes/sec)
Cool.

2013-03-16: I opened up the ND246 keyboard. It has a NEC D8035LC microcontroller (ROMless) and a NEC D2716 EPROM.

2013-03-10: the keyboard uses V.11 / RS-422 at 2400 baud to communicate with the terminal. The external keyboard connector (E1) is a 9 pin connector. Pinout is (update: this pinout is wrong, see the 2013-03-27 "keyboard cable" entry!)
1 - protective ground CHGND
2 - transmit to keyb. TXKB (bar)
3 - +5V
4 - receive from keyb.RXKB (bar)
5 -
6 - GND
7 - transmit to keyboard TXKB
8 -
9 - receive from keyboard RXKB
The keyboard uses a 26LS31 line driver (U10) and a 26LS32 line receiver (U9) which converts TTL to RS-422 signals. The terminal mainboard uses the same circuits.

2011-04-02: Today I tested the spare ND 320 keyboard on the ND 320 terminal. (just a quick test), and it is working. Even the caps lock key (without the key cap) is working. I also tested the ND 246 keyboard (connected it to the ND 320 terminal) and it is working.
