//
// test harness for high scrore rouines
//

BasicUpstart2(main)


*=$1000

// import constants and variable files
#import "../lib/vic.asm"

.macro pressFire(){

	lda joystickPort2
	and #$10
	bne *-5
}

main:{

	jsr setup.initHardware

	// set a score in current score (this is bcd)
	// so current score = 250

	lda #$50
	sta currentScore
	lda #$06
	sta currentScore +1 

	jsr highScore.showHighScore
	pressFire()
	jsr highScore.updateHighScore
	pressFire()
	lda #0
	sta backgroundColour
	jsr highScore.showHighScore

	rts

}

// globals (too lazy to stick them in a globals file for this)

currentScore:
 	.word 0

//import library routines
#import "../lib/hardwareInit.asm"
#import "./highscore.asm"
#import "../lib/keyboard.asm"


*=$f000

//import char set
.import binary "../assets/quickchars.bin"