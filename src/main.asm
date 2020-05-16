//
// test harness for high scrore rouines
//

BasicUpstart2(main)

*=$1000

// import constants and variable files
#import "../lib/vic.asm"


main:{

	jsr setup.initHardware

	// quick char Ram test

	lda #1
	ldy #0
	!:
	sta screenRam,y
	iny
	cpy #$ff
	bne !-

	jsr highScore.showHighScore

	rts

}

//import library routines
#import "../lib/hardwareInit.asm"
#import "./highscore.asm"


*=$f000

//import char set
.import binary "../assets/quickchars.bin"