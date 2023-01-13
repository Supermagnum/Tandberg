

	Tandberg TDV-2200 Series Terminals


	This collection is ROMs from two complete Tandberg TDV-2200 class terminals, and three additional
	loose keyboard. The terminals in question is the TDV-2215, and ND320. The TDV-2215 is a general-
	purpose TDV-2200 ASCII-terminal, while the ND320 was a TDV-2200-9S terminal designed in particular
	for use with the Norsk Data ND-NOTIS suite of applications. NOTIS was a popular set of office-
	related applications running on Norsk Data NORD-100/NORD-500 mainframes, under the SINTRAN-III
	multi-user operating-system.

	The files follow a "label.part.designator" structure. The part is primarely for indicating pinout,
	and there may be slight variations on the actual boards. For example, an equalivent part with a
	different part-number might be used. The label-part is on the other hand written as accurately as
	possible, and will include revision or checkusm info where it is written on the actual labels.

	Keyboards runs an intel 8035, terminals runs an 8085. The two terminal-models are roughly the same,
	but the ND320 has a slightly enhanced motherboard over the TDV-2215, and a bitmap graphics-card
	expansion running its own Z80 and firmware. The first main difference in motherboard design between
	the two versions, is that the ND320 has a socket for a 27128 EPROM in addition to U31. Both of
	these sockets share the same chip-enable from the Address-Decoder. The second difference is that
	the ND320 has a whole lot more pages in the character-generator. Schematics and other documents for
	the TDV-2215 is available online at: http://sintran.com/sintran/library/libother/libother.html

							-Frode van der Meeren, "frodevan", 2020-04-20

	Keyboard IDs:

		(TDV-2215)	Keyboard, TDV 2200 Series, Item no.: 4024, Serial no.: 338705
		(TDV-2215)	Keyboard, TDV 2200 Series, Item no.: 4076, Serial no.: 376493
		(ND320)		Keyboard, TDV 2200S Series, Item no.: 4580, Serial no.: 682075
		(ND320)		Keyboard, TDV 2200S Series, Item no.: 4580, Serial no.: 707648

	Terminal IDs:

		(TDV-2215)	TDV 2200 Series, Basic Unit, TDV 2215, Serial no.: 302581
		(ND320)		TDV 2200S Series, Basic Unit, TDV 2200/9S, 1029789, 85. 

	ROMs:

		Keyboards

			961292 2.2716.u8		Item no. 4024, firmware
			961299 -3-.2716.u8		Item no. 4076, firmware
			965313 -0-.2716.u8		Item no. 4580, firmware
			xxxVT100S.u8			Siemens MTS 2000, firmware

		Basic Unit, TDV 2215

			961125.82S129.u27		Address Decoder
			961126.74S471.u67		Display Address Translation
			961127.82S131.u55		Attribute Lookup
			961133 0.2732.u63		Character Generator
			961264-10.2764.u31		Firmware 961755 Rev 11 part 1/3
			49032-2-11.2764.u32		Firmware 961755 Rev 11 part 2/3
			49032-11-3-.2716.u33		Firmware 961755 Rev 11 part 3/3

		Basic Unit, TDV 2200/9S

			961126 -0-.74S471.u67		Display Address Translation
			961127 -0-.82S131.u55		Attribute Lookup
			965190 -0-.82S129.u27		Address Decoder
			965115 -2-.27128.u63		Character Generator
			965090-24 -1-.27128.u93		Firmware 965090 Rev 23 part 1/2
			965094-24 -3-.2764.u32		Firmware 965090 Rev 23 part 2/2

			067141 92AF.2764.u61		Firmware TD720 Graphics Card 067 V1.4 part 1/2
			067142 229C.2764.u53		Firmware TD720 Graphics Card 067 V1.4 part 2/2

			U9 of the graphics card may be programmable, but unfortunately soldered down.
