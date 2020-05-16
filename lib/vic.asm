/*

Before anyone kicks off,

yes this file is based on shallan50k's library file

I just dont like _ and prefer to use camel case

*/

	.const sprite0X = $d000
	.const sprite0Y = $d001

	.const sprite_1_x = $d002
	.const sprite_1_y = $d003

	.const sprite_2_x = $d004
	.const sprite_2_y = $d005

	.const sprite_3_x = $d006
	.const sprite_3_y = $d007

	.const sprite_4_x = $d008
	.const sprite_4_y = $d009

	.const sprite_5_x = $d00a
	.const sprite_5_y = $d00b

	.const sprite_6_x = $d00c
	.const sprite_6_y = $d00d

	.const sprite_7_x = $d00e
	.const sprite_7_y = $d00f

	.const spriteXMSB = $d010

	.const raster_y = $d012 

	.const spriteEnable = $d015
	.const scrollControl = $d016

	.const memorySetup = $d018

	.const interrupt_control = $d01a
	
	.const spriteMulticolour = $d01c

	.const borderColour = $d020
	.const backgroundColour = $d021
	.const extended_bg_color_1 = $d022
	.const extended_bg_color_2 = $d023

	.const sprite_multicolor_1 = $d025
	.const sprite_multicolor_2 = $d026

	.const spriteColour0 = $d027
	.const sprite_color_1 = $d028
	.const sprite_color_2 = $d029
	.const sprite_color_3 = $d02a
	.const sprite_color_4 = $d02b
	.const sprite_color_5 = $d02c
	.const sprite_color_6 = $d02d
	.const sprite_color_7 = $d02e

	.const screenRam = $c000
	.const colourRam = $d800
	.const spritePriority = $d01b
	.const sprite2SpriteCollision = $d01e

	.const spritePointers = screenRam + $3f8

	.const joystickPort2 = $dc00

	.const charMemory = $f000
