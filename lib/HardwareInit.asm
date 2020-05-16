// file name HardwareInit.asm

setup:{

	initHardware: {

	    //Disable CIA IRQ's to prevent crashes
		lda #$7f	
		sta $dc0d
		sta $dd0d

		//bank out BASIC and Kernal
		lda $01
		and #%11111000
		ora #%00000101
		sta $01


		// set VIC to BANK 3
		lda $dd00
		and #11111100
		sta $dd00

		// set screen to char mem
		lda #%00001100
		sta $d018

		//  set multi colour mode
		lda scrollControl
		ora $10
		sta scrollControl

		rts

		
	}



}