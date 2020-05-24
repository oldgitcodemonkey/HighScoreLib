/*

	High score librabry

	17 May 2020

	By Andrew Shore

	lincence: MIT

	.showHighScore 				- displays the high score table
	.updateHighScore 			- checks the current score and gets a new name if relevent

*/

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
		beq !skipPrint+							// if its a space dont print anything

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
		.byte 0 

	onHighScore:
		.byte 0

	updateHighScore:{

		// convert the player score to text to compate with high score table

		/* 	replace currentScore with the variable containing the current score
			 note this assumes the score is stored in little endian formate and is converted
			 into readbale text

			 If score is stored in bigendian change the order the currentScoe is converted

		*/
			

		lda currentScore
		and #$0F 									// get low nibble
		clc
		adc #ascii0 								// convert it to ascii
		sta playerScore + 3

		lda currentScore
		lsr
		lsr 										// shift the top nibble into the bottom nibble
		lsr
		lsr
		adc #ascii0									// convert to ascii
		sta playerScore + 2

		lda currentScore + 1
		and #$0F 									// get low nibble
		clc
		adc #ascii0 								// convert it to ascii
		sta playerScore + 1

		// dont need to bother about 1st character as scores are 3 digits

		// now check if the score is better that the existing ones

		ldx #0										// pointer to start of score table
	!testScoreLoop:

		ldy #0 										// pointer to start of player score
	!nextDigitTest:
		lda scores,x 								// compare this score to current score
		cmp playerScore,y

		bmi !foundHighScore+ 						// if current score is greater then insert new score
		bne !skipToNextScore+						// if current score is less than then go down a line

		iny 										// increase index
		inx 										// next high score table entry


		cpy #$04									// passed the end of the score, check next one down
		bne !nextDigitTest-

		jmp !testEndOfList+

	!skipToNextScore:								// if you get here the current score is higher than the player socre
		txa  										// so skip to the next score
		clc
		adc #$04									// add 4 to get to the necxt score
		and #%11111100								// mask out lower 2 bits to make sure the pointer starts at the begining
		tax 										// put the result back into the register

	!testEndOfList:	
		cpx #$13									// reached the bottom of the high score table?
		bmi !testScoreLoop-

		// if you get here then you're not on the high score table
		
		lda #$ff									// set the on-high-score flag to be nope
		sta onHighScore
		rts

	!foundHighScore:
		txa 										// get x into A to math
		lsr 										// push the bottom two bit off to give
		lsr  										// the position of the score

		sta savePosition
		sta onHighScore 							// save the position for input routine


	// now move all the lower names down 16 bytes to make space for the new one

	

	/*
		To scroll the list down 

		x holds the the row that needs moving down

		y will hold the pointer into the data

	*/

		sec
		sbc #$05								// this mess is the same as A - 4
		eor #$ff  

		asl
		asl										// multiply by  16 to give the number of bytes to move
		asl
		asl

		tax 									// get a into x as a counter
		ldy #$40								// point to the end of the name list

		beq !noShift+ 							// if this is the last entry in the list then there is no point shifting stuff

	!nameMoveLoop:
		lda playerNames,y 						// get a letter
		sta playerNames +16 ,y 					// move it down a letter

		dey 									// move back up the list
		dex 									// decrease the counter
		bpl !nameMoveLoop- 						// loop if there are still chars to moce

	!noShift:

		// now clear the current name

		// add 16 back to y or y will become negative

		tya
		clc
		adc #$20
		and #$f0
		tay
		dey

		lda #$10								// load A with space char
		ldx #$0f
	!clearLoop:
		sta playerNames,y 						// write space to table
		dey
		dex
		bpl !clearLoop-
 

		// now do the same to the scores but this time we will

		lda savePosition

		sec
		sbc #$05								// this mess is the same as A - 4
		eor #$ff  

		asl
		asl										// multiply by 4 to give the number of bytes to move


		tax 									// get a into x as a counter
		dex
		ldy #$0f 								// point to the end of the name list

	!nameMoveLoop:

		lda scores,y 						 	// get a letter
		sta scores+4,y 						   // move it down a letter

		dey 									// move back up the list
		dex 									// decrease the counter
		bpl !nameMoveLoop- 						// loop if there are still chars to moce


		// insert player score

		// add 4 back onto y
		iny
		iny
		iny										// quicker than dicking about with a
		iny


		ldx #$03
	!clearLoop:
		lda playerScore,x
		sta scores,y 						// write space to table
		dey
		dex
		bpl !clearLoop-

		lda #0
		sta $d020

		// lda #0
		// sta $d020

		jsr highScore.showHighScore	

	

		// now type in the new name of the player

		lda savePosition				// retrieve the line of the current score
		asl 							// double it to use as an index into a 16 bit table
		tay 							// put it in index register

		asl
		asl 							// multiply the line by 16 to get the offset into the playernames
		asl

		tax 							// x hold pointer into high score table

		lda namePositions,y 			// get LSB for screen position
		sta inputSelfMod + 1 			// update self mod LSB
		lda namePositions + 1,y 		// Get MSB
		sta inputSelfMod + 2 			// update seld mod MSB


		ldy #$00 						// set the pointer to the begining
		sty delDebounce 				// clear the intital debounce flag
	!inputLoop:
		txa 							// save the registers to the stack as the Keyboard routine
		pha
		tya 							// destroys them
		pha 

	!waitForKey:
		jsr Keyboard 					// returns value in A carry clear signifys key pressed	
		php
		cmp #$ff
		beq !testflag+
 		ldy #0
 		sty delDebounce
	!testflag:
		plp
		bcs !waitForKey-

		// debounce delete key

		ldy delDebounce
		beq !noDebounce+

		jmp !waitForKey-

!noDebounce:
		stx keyPressedX
		sta keyPressed					// save the key

		pla 							// get the index registers back
		tay
		pla
		tax

		lda keyPressed

		cmp #$ff 						// A = FF means special code in X which we saved to KeyPressX
		bne !notSpecialKey+
		
		lda keyPressedX
		cmp #$02 						// X=2 means return
		beq !enterPressed+				// our work is done

		cmp #$01 						// X=1 means back space
		bne !inputLoop- 				// anyother special key we dont care about

		// delete pressed


		// check debounce

		lda delDebounce
		bne !inputLoop- 				// debounce the delete key

		lda  #$01
		sta delDebounce 		 		// set flag		

		cpy #$00
		beq !inputLoop- 				// if at start cant go back more

		dey 							// decrease pointer
		dex		

		lda #$20 						// set char to space

		jmp !printLetter+




	!notSpecialKey:

		cpy #$0f 						// check how many letters
		bpl !inputLoop-					// too many chars

		// check for Valid Chars - A to Z and 0 to 9

		cmp #$01   					 	// A
		bmi !inputLoop-

		cmp #$1b 						// Z
		bpl !notAlpha+

		// map keyboard to char set a-z

		lda #firstLetter - 1 			// offset to char set
		clc
		adc keyPressed 					// add on letter

		jmp !printLetter+

	
	!notAlpha:

		// check for numberics

		cmp #$30 						// 0
		bmi !inputLoop-					// less than 0

		cmp #$3a 						// 9
		bmi !isANumber+					// in the range

		jmp !inputLoop- 				// try  again

	!isANumber:
		// map keyboard to char set 0-9
		sec 							// map the key value down to the numberic value
		sbc #$30
		clc
		adc #firstNumber    			// offset to char set
		jmp inputSelfMod
		// put the letter on screen and into the hight score table
	!printLetter:


		cmp #$20 						// if this is space we need to swap in the space char for the screen
		bne inputSelfMod

		lda #$00						// space char

	inputSelfMod:
		sta $B00B,y	 					//update screen

		// store names in ascii
		
  
		sta keyPressed 				// subract to the letter pressed from the base ASCII for A
		lda #asciiA-1
		clc
		adc keyPressed
		sta playerNames,x 				// update high code table

		lda keyPressed
		cmp #$00 						// if del pressed then dont increase the pointer
		bne !incCounter+				// jump too long

		jmp !inputLoop-

	!incCounter:
		inx 							//increase table index
		iny 							//increase 

		jmp !inputLoop-

	!enterPressed:

		lda #10
		sta $d020

		rts




	}

	playerScore:
		.text "    "

	savePosition:
		.byte 0

	keyPressed:
		.byte 0

	keyPressedX:
		.byte 0

	delDebounce:
		.byte 0
}