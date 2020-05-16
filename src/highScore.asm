//
//High score librabry
//

// .showHighScore 				- displays the high score table
// .updateHighScore 			- checks the current score and gets a new name if relevent

.const firstLetter = 1							// the char number of A in the char set
.const asciiA = 65								// the ascii value of used by kick
.const charOffsetLetter = firstLetter - asciiA 	// map asci to the char set

.const firstNumber = 27							// 0 in the char set
.const ascii0 = 48 								// the acsii value for 0 used by kick	
.const charOffsetNumber = firstNumber - ascii0  // map ascii to the char set

.const titleLine = screenRam + 3*40 + 11		// memory address to start printing 



highScore:{

	showHighScore:{

		// clear the screen
		lda #0									// load a with blank char
		ldy #$c8								// 200 chars to delete
	!clearNext:
		sta screenRam-1,y						 // clear block 1
		sta screenRam+199,y						// clear block 2
		sta screenRam+399,y						// clear block 3
		sta screenRam+599,y						// clear block 4
		sta screenRam+799,y						// clear block 5

		dey 									
		bne !clearNext-							// next block


		// print Title

		ldy #$00								// character pointer
	!charLoop:
		lda titleText,y 						// get a char
		cmp #$ff
		beq !titleComplete+						// if this is terminator exist loop

		cmp #$20								// check for ascii space (32)
		beq !skipPrint+							// if its a spave dont print anything

		// check for a letter or number
		cmp #asciiA
		bcs !selectLetter+						// if its A or greater then set the print char to a letter

		// its a number
		clc
		adc #charOffsetNumber					// add the offset (we dont care about carry ot overflow)

		jmp !printChar+

	!selectLetter:
		// its a letter
		clc
		adc #charOffsetLetter					// add the offset (we dont care about carry ot overflow)

	!printChar:
		sta titleLine,y

	!skipPrint:
		iny										// move to next char
		jmp !charLoop-


	!titleComplete:


	// print the players names

		ldx #0										// start with highest score
	!playerLoop:

		txa											// put X into a so we can math
		asl 										// double A for 16 bit pointer into table

		tay  										// move a to y so we can use it as an index

		// FUCK ME SELF MOD CODE YUK

		lda namePositions,y 						// grabbing the screen address from the table
		sta selfMod + 1 							// updating the position of the start location
		lda namePositions+1,y 						// by hacking at the code
		sta selfMod +  2

		txa 										// now get the start of the name which is x * 16
		asl
		asl
		asl 										// 4 shifts gets us blocks of 16 chars
		asl

		tay 										// put it back in index
	!charLoop:
		lda playerNames,y 							// get letter
		cmp #$20 									// if its a space we're done
		beq !playerDone+

		sty namePointer								// save y as we need it and we're going to reuse the reister

		// check for a letter or number
		cmp #asciiA
		bcs !selectLetter+						// if its A or greater then set the print char to a letter

		// its a number
		clc
		adc #charOffsetNumber					// add the offset (we dont care about carry ot overflow)

		jmp !printChar+

	!selectLetter:
		// its a letter
		clc
		adc #charOffsetLetter					// add the offset (we dont care about carry ot overflow)

	!printChar:
		pha										// quick save A

		tya 									// get y into the acc
		and #$0f 								// get bottom 4 bits only
		tay 									// put it back in y

		pla 									// get a back

	selfMod:
		sta $b00b,y 							// print char

		ldy namePointer							// get pointer back
		iny 									// increase y

		tya 									// need to math again
		and #$0f 								// mask bottom 4 bits
		bne !charLoop- 							// if its not zero then print next letter

	!playerDone:

		// now print their score

		txa 									// get the player ID
		asl 									// doube it for 16 bit index
		tay 									// stick it in y to use as index

		// more dirty self mod code
		lda scorePositions,y 						// grabbing the screen address from the table
		sta selfMod2 + 1 							// updating the position of the start location
		lda scorePositions+1,y 						// by hacking at the code
		sta selfMod2 + 2	

		txa 									// get the current player number
		asl 
		asl 									// multiply by 4 (each score is 4 chars)
		tay 									// stick it in the index register

	!scoreCharLoop:
		lda scores,y 							// get score digit
		sty namePointer 						// save y we're going to corrupt it

		cmp #$20 								// if its a space this time we skip but carry on
		beq !skipSpace+

		// this time we know its a number, its a score
		clc
		adc #charOffsetNumber	

		// use y now for screen offset
		pha										// quick save A

		tya 									// get y into the acc
		and #$03 								// get bottom 4 bits only
		tay 									// put the result in y

		pla 									// get a back




	selfMod2:
		sta $b00b,y								// put char on screen
	!skipSpace:
		ldy namePointer							// retore y
		iny										// next char

		tya
		and #$3
		bne !scoreCharLoop-
	
		// next player

		inx 									// next player name
		cpx #$05								// all names printed ?

		bne !playerLoop-



		// ldy #$0
		// !:
		// 	lda highScore.playerNames,y
		// 	clc
		// 	adc #charOffset
		// 	sta screenRam,y

		// 	iny
		// 	cpy #$50
		// 	bne !-

		rts


	}

	titleText:
		.text "TODAYS TOP MARIOS"
		.byte 255

	playerNames:
		//	   0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef
		.text "CHILLI          HAYESMAKER64    WILLOW          JASMINE         AMK             "

	scores:
		.text " 900 800 700 600 500"

	namePositions:
		.word screenRam + 40*6 + 10, screenRam + 40*8 + 10, screenRam + 40*10 + 10,screenRam + 40*12 + 10,screenRam + 40*14 + 10

	scorePositions:
		.word screenRam + (40*6) + 26, screenRam + 40*8 + 26, screenRam + 40*10 + 26,screenRam + 40*12 + 26,screenRam + 40*14 + 26

	namePointer:
		.byte

}