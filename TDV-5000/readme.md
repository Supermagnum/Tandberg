
Tandberg Data TDV-5000 series

The TDV-5000 series was primarily made as a series of PC-compatible PS/2-keyboards. These have all 102 keys you would expect, and sometimes they come with additional keys. The additional keys are typically 20 extra keys for the NOTIS text editor, but
there were also a few other programs which would recognize these keys (given a proper driver was loaded).

As of the matrix vs index in the datatables, the keyboard uses 16 rows and 8 bits per row. The row number is represented by the lower four bits of the index/offset, while the column number within the row is represented by the upper three bits.


-----------------

Keyboard keynames:

	+-------------------------------------------------------------------------------------------------+
	|                                                                   O   O   O                     |
	|                                                                                                 |
	|  G00 G01 G02 G03 G04 G05 ** G07 G08 G09 G10    G12 G13 G14 G15   G47 G48<G49   G51 G52 G53 G54  |
	|                                                                  F47 F48 F49   F51 F52 F53 F54  |
	|    E00 E01 E02 E03 E04 E05 E06 E07 E08 E09 E10 E11 E12 E13<E14   E47 E48 E49   E51 E52 E53 E54  |
	|  D99 D00 D01 D02 D03 D04 D05 D06 D07 D08 D09 D10 D11 D12   D13   D47 D48 D49   D51 D52 D53 D54  |
	|  C99  C00 C01 C02 C03 C04 C05 C06 C07 C08 C09 C10 C11 C12        C47 C48 C49   C51 C52 C53 C54^ |
	|    B99  B00 B01 B02 B03 B04 B05 B06 B07 B08 B09 B10   B11  B12   B47 B48 B49   B51 B52 B53 B54  |
	|  A99      A00                 A05                 A10      A12   A47 A48 A49     A51   A53      |
	|                                                                                                 |
	+-------------------------------------------------------------------------------------------------+

		<	= E13A, G48A
		^	= C54A (duplicates C54)
		**	= G06  (duplicates G05)

Keynames in key datatable:

	Offset:
	00-0F	  B99  D99  C99  G00  E00  A00  A05  A47  A10  A51  A12  A49  ---  A48  G48A A99
	10-1F	  B00  D00  C00  G01  E01  B02  B12  B49  B47  A53  B48  B52  ---  B51  E13A B01
	20-2F	  C02  D01  C01  G02  E02  B03  B10  C47  B11  B54  D13  C49  B53  C48  D51  C51
	30-3F	  C04  D03  D04  G04  E04  B05  G15  G09  G10  C54A G14  F49  C53  G47  G48  C52
	40-4F	  C05  C06  D05  G05  E05  B07  F47  G12  E14  D54  G13  G51  D53  F48  G49  D52
	50-5F	  B04  D02  C03  G03  E03  B06  B09  C11  C10  E54  C12  D48  E53  D47  D49  E52
	60-6F	  C07  C08  D06  G07  E06  B08  E09  E08  E10  F54  E11  E48  F53  E47  F51  F52
	70-7F	  D09  D07  D08  G08  E07  C09  D12  D11  D10  G54  E12  E49  G53  E13  E51  G52

Key datatables in layout definition:

	Offset:
	000-07F		Base scancodes for Set 1
	080-0FF		Base scancodes for Set 2
	100-17F		Base scancodes for Set 3
	180-1FF		Key flags

	200-284		Key offsets, by Set 3 base scancode (reverse-lookup of table at offset 100-17F)

	There is also a 32-byte table between two subroutines in the firmware, where 2 bits are stored for
	every key. Those bits define default key-mode behaviour in scancode set 3.


-----------------

Scancode table:


	Table |  Base Scancode        |  Key behaviour and set-3 mode    |  Physical layout of keyboard (matrix board 967043)
	      |                       |                                  |
	Index |  Set 1  Set 2  Set 3  |  Flags        Release  Typematic |  IBM key |  Matrix      Key                     |  Comments
	------+-----------------------+----------------------------------+----------+--------------------------------------+------------------------------------------------
	0C    |  00     00     00     |  00.000.110   0        0         |          |              (not used)              |  Hardcoded, Keylock A footprint not on matrix
	1C    |  00     00     00     |  00.000.110   0        0         |          |              (not used)              |  Hardcoded, Keylock B footprint not on matrix
	------+-----------------------+----------------------------------+----------+--------------------------------------+------------------------------------------------
	13    |  2B     5D     53     |  10.000.111   1        0         |          |  G01         (not used)              |  May be used if cutout is made in chassis
	0E    |  34     34     49     |  10.000.111   0        0         |          |  G48A        (not used)              |  May be used if G48 and G49 are removed
	49    |  39     29     29     |  10.000.111   0        0         |          |  D54         (not used)              |  May be used if C54A relocates to C54
	------+-----------------------+----------------------------------+----------+--------------------------------------+------------------------------------------------
	01    |  11     1D     1D     |  11.000.111   1        0         |          |  D99         HJELP                   |  Help
	02    |  12     24     24     |  11.000.111   1        0         |          |  C99         /\/\/\                  |  Insert soft hyphen
	16    |  13     2D     2D     |  11.000.111   1        0         |          |  B12         [Stroked down-arrow]    |  Down five lines
	18    |  1F     1B     1B     |  00.000.111   0        1         |          |  B47         |<---                   |  Back-tab
	17    |  20     23     23     |  00.000.111   0        1         |          |  B49         --->|                   |  Forward-tab
	27    |  18     44     44     |  00.000.111   0        1         |          |  C47         >> <<                   |  Justify left-right
	2B    |  1E     1C     1C     |  00.000.111   0        1         |          |  C49         <> ><                   |  Justify full/center
	2D    |  19     4D     4D     |  00.000.111   0        1         |          |  C48         JUST                    |  Justify
	3B    |  17     43     43     |  11.000.111   1        0         |          |  F49         FLYTT                   |  Move
	46    |  14     2C     2C     |  11.000.111   1        0         |          |  F47         STRYK                   |  Erase
	4B    |  21     2B     2B     |  10.000.111   0        0         |          |  G51         MERK                    |  Select
	4D    |  16     3C     3C     |  11.000.111   1        0         |          |  F48         KOPI                    |  Copy
	69    |  32     3A     3A     |  11.000.111   1        0         |          |  F54         ORD                     |  Word
	6C    |  30     32     32     |  11.000.111   1        0         |          |  F53         SETN                    |  Sentence
	6E    |  26     4B     4B     |  11.000.111   1        0         |          |  F51         FELT                    |  Field
	6F    |  2F     2A     2A     |  11.000.111   1        0         |          |  F52         AVSN                    |  Paragraph
	79    |  25     42     42     |  10.000.111   0        0         |          |  G54         SLUTT                   |  End
	7C    |  23     33     33     |  10.000.111   0        0         |          |  G53         SKRIV                   |  Write
	7D    |  56     61     13     |  00.000.111   0        1         |          |  E13         [Sideways u-turn arrow] |  Start new paragraph
	7F    |  22     34     34     |  10.000.111   0        0         |          |  G52         ANGRE                   |  Undo
	------+-----------------------+----------------------------------+----------+--------------------------------------+------------------------------------------------
	04    |  29     0E     0E     |  00.000.000   0        1         |  1       |  E00         |  §                    |  
	14    |  02     16     16     |  00.000.000   0        1         |  2       |  E01         1 !                     |  
	24    |  03     1E     1E     |  00.000.000   0        1         |  3       |  E02         2 " @                   |  
	54    |  04     26     26     |  00.000.000   0        1         |  4       |  E03         3 # £                   |  
	34    |  05     25     25     |  00.000.000   0        1         |  5       |  E04         4 ¤ $                   |  
	44    |  06     2E     2E     |  00.000.000   0        1         |  6       |  E05         5 %                     |  
	64    |  07     36     36     |  00.000.000   0        1         |  7       |  E06         6 &                     |  
	74    |  08     3D     3D     |  00.000.000   0        1         |  8       |  E07         7 / {                   |  
	67    |  09     3E     3E     |  00.000.000   0        1         |  9       |  E08         8 ( [                   |  
	66    |  0A     46     46     |  00.000.000   0        1         |  10      |  E09         9 ) ]                   |  
	68    |  0B     45     45     |  00.000.000   0        1         |  11      |  E10         0 = }                   |  
	6A    |  0C     4E     4E     |  00.000.000   0        1         |  12      |  E11         + ?                     |  
	7A    |  0D     55     55     |  00.000.000   0        1         |  13      |  E12         \ ` ´                   |  
	1E    |  0E     66     66     |  00.000.000   0        1         |  15      |  E13A        Backspace               |  
	48    |  0E     66     66     |  00.000.000   0        1         |  15      |  E14         Backspace               |  
	11    |  0F     0D     0D     |  00.000.000   0        1         |  16      |  D00         Tab                     |  
	21    |  10     15     15     |  00.000.000   0        1         |  17      |  D01         Q                       |  
	51    |  11     1D     1D     |  00.000.000   0        1         |  18      |  D02         W                       |  
	31    |  12     24     24     |  00.000.000   0        1         |  19      |  D03         E                       |  
	32    |  13     2D     2D     |  00.000.000   0        1         |  20      |  D04         R                       |  
	42    |  14     2C     2C     |  00.000.000   0        1         |  21      |  D05         T                       |  
	62    |  15     35     35     |  00.000.000   0        1         |  22      |  D06         Y                       |  
	71    |  16     3C     3C     |  00.000.000   0        1         |  23      |  D07         U                       |  
	72    |  17     43     43     |  00.000.000   0        1         |  24      |  D08         I                       |  
	70    |  18     44     44     |  00.000.000   0        1         |  25      |  D09         O                       |  
	78    |  19     4D     4D     |  00.000.000   0        1         |  26      |  D10         P                       |  
	77    |  1A     54     54     |  00.000.000   0        1         |  27      |  D11         Å                       |  
	76    |  1B     5B     5B     |  00.000.000   0        1         |  28      |  D12         ¨ ^ ~                   |  
	12    |  3A     58     14     |  11.110.000   1        0         |  30      |  C00         Caps Lock               |  
	22    |  1E     1C     1C     |  00.000.000   0        1         |  31      |  C01         A                       |  
	20    |  1F     1B     1B     |  00.000.000   0        1         |  32      |  C02         S                       |  
	52    |  20     23     23     |  00.000.000   0        1         |  33      |  C03         D                       |  
	30    |  21     2B     2B     |  00.000.000   0        1         |  34      |  C04         F                       |  
	40    |  22     34     34     |  00.000.000   0        1         |  35      |  C05         G                       |  
	41    |  23     33     33     |  00.000.000   0        1         |  36      |  C06         H                       |  
	60    |  24     3B     3B     |  00.000.000   0        1         |  37      |  C07         J                       |  
	61    |  25     42     42     |  00.000.000   0        1         |  38      |  C08         K                       |  
	75    |  26     4B     4B     |  00.000.000   0        1         |  39      |  C09         L                       |  
	58    |  27     4C     4C     |  00.000.000   0        1         |  40      |  C10         Ø                       |  
	57    |  28     52     52     |  00.000.000   0        1         |  41      |  C11         Æ                       |  
	5A    |  2B     5D     53/5D* |  00.000.000   0        0         |  42      |  C12         ' *                     |  * 5D is a bug in v1.4, corrected to 53 by v2.1
	2A    |  1C     5A     5A     |  00.000.000   0        1         |  43      |  D13         Enter                   |  
	00    |  2A     12     12     |  11.001.000   1        0         |  44      |  B99         Left Shift              |  
	10    |  56     61     13     |  00.000.000   0        1         |  45      |  B00         < >                     |  
	1F    |  2C     1A     1A     |  00.000.000   0        1         |  46      |  B01         Z                       |  
	15    |  2D     22     22     |  00.000.000   0        1         |  47      |  B02         X                       |  
	25    |  2E     21     21     |  00.000.000   0        1         |  48      |  B03         C                       |  
	50    |  2F     2A     2A     |  00.000.000   0        1         |  49      |  B04         V                       |  
	35    |  30     32     32     |  00.000.000   0        1         |  50      |  B05         B                       |  
	55    |  31     31     31     |  00.000.000   0        1         |  51      |  B06         N                       |  
	45    |  32     3A     3A     |  00.000.000   0        1         |  52      |  B07         M                       |  
	65    |  33     41     41     |  00.000.000   0        1         |  53      |  B08         , ;                     |  
	56    |  34     49     49     |  00.000.000   0        1         |  54      |  B09         . :                     |  
	26    |  35     4A     4A     |  00.000.000   0        1         |  55      |  B10         - _                     |  
	28    |  36     59     59     |  11.010.000   1        0         |  57      |  B11         Right Shift             |  
	0F    |  1D     14     11     |  11.100.000   1        0         |  58      |  A99         Left Ctrl               |  
	05    |  38     11     19     |  11.011.000   1        0         |  60      |  A00         Left Alt                |  
	06    |  39     29     29     |  00.000.000   0        1         |  61      |  A05         Space                   |  
	08    |  38     11     39     |  10.011.001   0        0         |  62      |  A10         Right Alt               |  
	0A    |  1D     14     58     |  10.100.001   0        0         |  64      |  A12         Right Ctrl              |  
	6D    |  52     70     67     |  10.111.010   0        0         |  75      |  E47         Insert                  |  
	5D    |  53     71     64     |  00.000.010   0        1         |  76      |  D47         Del                     |  
	07    |  4B     6B     61     |  00.000.010   0        1         |  79      |  A47         Left Arrow              |  
	6B    |  47     6C     6E     |  10.000.010   0        0         |  80      |  E48         Home                    |  
	5B    |  4F     69     65     |  10.000.010   0        0         |  81      |  D48         End                     |  
	1A    |  48     75     63     |  00.000.010   0        1         |  83      |  B48         Up Arrow                |  
	0D    |  50     72     60     |  00.000.010   0        1         |  84      |  A48         Down Arrow              |  
	7B    |  49     7D     6F     |  10.000.010   0        0         |  85      |  E49         Page Up                 |  
	5E    |  51     7A     6D     |  10.000.010   0        0         |  86      |  D49         Page Down               |  
	0B    |  4D     74     6A     |  00.000.010   0        1         |  89      |  A49         Right Arrow             |  
	7E    |  45     77     76     |  10.101.000   0        0         |  90      |  E51         Num Lock                |  
	2E    |  47     6C     6C     |  10.000.000   0        0         |  91      |  D51         NumPad 7                |  
	2F    |  4B     6B     6B     |  10.000.000   0        0         |  92      |  C51         NumPad 4                |  
	1D    |  4F     69     69     |  10.000.000   0        0         |  93      |  B51         NumPad 1                |  
	5F    |  35     4A     77     |  10.000.011   0        0         |  95      |  E52         NumPad /                |  
	4F    |  48     75     75     |  10.000.000   0        0         |  96      |  D52         NumPad 8                |  
	3F    |  4C     73     73     |  10.000.000   0        0         |  97      |  C52         NumPad 5                |  
	1B    |  50     72     72     |  10.000.000   0        0         |  98      |  B52         NumPad 2                |  
	09    |  52     70     70     |  10.000.000   0        0         |  99      |  A51         NumPad 0                |  
	5C    |  37     7C     7E     |  10.000.000   0        0         |  100     |  E53         NumPad *                |  
	4C    |  49     7D     7D     |  10.000.000   0        0         |  101     |  D53         NumPad 9                |  
	3C    |  4D     74     74     |  10.000.000   0        0         |  102     |  C53         NumPad 6                |  
	2C    |  51     7A     7A     |  10.000.000   0        0         |  103     |  B53         NumPad 3                |  
	19    |  53     71     71     |  10.000.000   0        0         |  104     |  A53         NumPad ,                |  
	59    |  4A     7B     84     |  10.000.000   0        0         |  105     |  E54         NumPad -                |  
	39    |  4E     79     7C     |  00.000.000   0        1         |  106     |  C54/C54A*   NumPad +                |  * Duplicate on matrix, C54A is typically used
	29    |  1C     5A     79     |  10.000.001   0        0         |  108     |  B54         NumPad Enter            |  
	03    |  01     76     08     |  10.000.000   0        0         |  110     |  G00         Esc                     |  
	23    |  3B     05     07     |  10.000.000   0        0         |  112     |  G02         F1                      |  
	53    |  3C     06     0F     |  10.000.000   0        0         |  113     |  G03         F2                      |  
	33    |  3D     04     17     |  10.000.000   0        0         |  114     |  G04         F3                      |  
	43    |  3E     0C     1F     |  10.000.000   0        0         |  115     |  G05/G06*    F4                      |  * Duplicate on matrix, G05 is typically used
	63    |  3F     03     27     |  10.000.000   0        0         |  116     |  G07         F5                      |  
	73    |  40     0B     2F     |  10.000.000   0        0         |  117     |  G08         F6                      |  
	37    |  41     83     37     |  10.000.000   0        0         |  118     |  G09         F7                      |  
	38    |  42     0A     3F     |  10.000.000   0        0         |  119     |  G10         F8                      |  
	47    |  43     01     47     |  10.000.000   0        0         |  120     |  G12         F9                      |  
	4A    |  44     09     4F     |  10.000.000   0        0         |  121     |  G13         F10                     |  
	3A    |  57     78     56     |  10.000.000   0        0         |  122     |  G14         F11                     |  
	36    |  58     07     5E     |  10.000.000   0        0         |  123     |  G15         F12                     |  
	3D    |  37     7C     57     |  10.000.100   0        0         |  124     |  G47         PrintScreen             |  
	3E    |  46     7E     5F     |  10.000.000   0        0         |  125     |  G48         Scroll Lock             |  
	4E    |  00     00     62     |  10.000.101   0        0         |  126     |  G49         Pause/Break             |  
