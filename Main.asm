#######################
# Macros para a Pilha #
#######################

.macro pushWord (%dado)
	addi $sp $sp -4
	sw %dado ($sp)
.end_macro
.macro popWord (%dado)
	lw %dado ($sp)
	addi $sp $sp 4
.end_macro

##############################
# Macros para mover ponteiro #
##############################

#Moves the pointer to the next 'n' square horizontalçy
.macro nextSquareHorizontal (%ponteiro, %range) #$1: Memori Poniter; $2: Quantity of Squares to jump
	pushWord $t0
	and $t0 $0 $0
loop:
	addi %ponteiro %ponteiro 64 # 16*6
	addi $t0 $t0 1
	blt $t0 %range loop
	nop
	popWord $t0
.end_macro

#Moves the pointer to the next 'n' square vertically
.macro nextSquareVertical (%ponteiro, %range) #$1: Memory Poniter; $2: Quantity of Squares to jump
	pushWord $t0
	and $t0 $0 $0
loop:
	addi %ponteiro %ponteiro 32768 #64 * 32 * 16
	addi $t0 $t0 1
	blt $t0 %range loop
	nop
	popWord $t0
.end_macro

#Moves the pointer 'n' line(s) down
.macro nextPixelLine (%pointer, %range) #$1: Memory Poninter; $2: Quantity of lines to jump
	pushWord $t0
	and $t0 $0 $0
loop:
	addi %pointer %pointer 2048
	addi $t0 $t0 1
	blt $t0 %range loop
	nop
	popWord $t0
.end_macro

#############################
# Macros para pintar pixels #
#############################

#Paint a single pixel
.macro paintPixel (%color, %pointer)
	sw %color (%pointer)
	addi %pointer %pointer 4
.end_macro

#Pinte a line of 'n' pixels
.macro paintPixelLine (%cor, %ponteiro, %range, %flag) #$1: Color to paint; $2: Poniter to line start; $3: Size of the line; $4: '0' returns origal pointer, else returns the finish pointer;
	pushWord $t0
	pushWord %ponteiro
	and $t0 $zero $zero
loopLinha:
	sw %cor (%ponteiro)
	addi %ponteiro %ponteiro 4 #Next Pixel
	addi $t0 $t0 1
	blt $t0 %range loopLinha
	nop
	beq $zero %flag StartPointer
	nop
	popWord $t0 #Descarda a posição antiga do ponteiro
	popWord $t0
	j return
	nop
StartPointer:
	popWord %ponteiro #Poniter returns at start position
	popWord $t0
return:
.end_macro

###################################
# Macros para a printar Quadrados #
###################################

#Paint with ($2) color the square that starts and pointer($2)
.macro paintSquare (%cor, %ponteiro, %flag) #$1: Color to paint; $2: square pointer; $3: '0' returns origal pointer, else returns the finish pointer;
	pushWord $t0
	pushWord $t1
	pushWord %ponteiro
	and $t0 $zero $zero
	and $t1 $zero $zero
loopLinha:
	sw %cor, (%ponteiro)
	addi %ponteiro %ponteiro 4 #Next Pixel
	addi $t0 $t0 1 #Line counter increment
	blt $t0 16 loopLinha
	nop
	and $t0 $zero $zero
	addi %ponteiro %ponteiro 1984 #Next line of the square((512-16)*4)
	addi $t1 $t1 1
	blt $t1 16 loopLinha
	nop
	beq $zero %flag StartPointer
	nop
	popWord $t1 #Descarda a posição antiga do ponteiro
	popWord $t1
	popWord $t0
	j return
	nop
StartPointer:
	popWord %ponteiro #Poniter returns at start position
	popWord $t1
	popWord $t0
return:
.end_macro

#Paint a full squareline
.macro paintFullLine (%cor, %ponteiro, %flag) #$1: Color to paint; $2: square pointer; $3: '0' returns origal pointer, else returns the finish pointer;
	pushWord $t0
	pushWord %ponteiro
	and $t0 $zero $zero
loopLinha:
	sw %cor (%ponteiro)
	addi %ponteiro %ponteiro 4 #Next Pixel
	add $t0 $t0 1
	blt $t0 8192 loopLinha #8192 (512*16)
	nop
	beq $zero %flag StartPointer
	nop
	popWord $t0 #Descarda a posição antiga do ponteiro
	popWord $t0
	j return
	nop
StartPointer:
	popWord %ponteiro #Poniter returns at start position
	popWord $t0
return:
.end_macro

#Paint a line of 'n' squares
.macro paintLine (%cor, %ponteiro, %range, %flag)#$1 Color to paint; $2: start pixel pointer; $3 Number of squares to paint; $4: '0' returns origal pointer, else returns the finish pointer;
	pushWord $t0
	pushWord %ponteiro
	and $t0 $zero $zero
loopLine:
	paintSquare %cor, %ponteiro, 0
	addi $t0 $t0 1
	addi %ponteiro %ponteiro 64 #Next block (16*4)
	blt $t0 %range loopLine
	nop
	beq $zero %flag StartPointer
	nop
	popWord $t0 #Descarda a posição antiga do ponteiro
	popWord $t0
	j return
	nop
StartPointer:
	popWord %ponteiro #Poniter returns at start position
	popWord $t0
return:
.end_macro

#This is some magic that's necessary so things wouldn't fall apart
.macro magicMoveEndLine (%pointer)
	addi %pointer %pointer 30720 #Magic numbers muah ha ha (16*32*15*4)	
.end_macro

#Paint a column of 'n' squares
.macro paintColumn (%cor, %ponteiro, %range, %flag)#$1 Color to paint; $2: square pointer; $3 Number of squares to paint; $4: '0' returns origal pointer, else returns the finish pointer;
	pushWord $t0
	pushWord %ponteiro
loopColuna:
	paintSquare %cor, %ponteiro, 1
	addi $t0 $t0 1
	blt $t0 %range loopColuna
	nop
	beq $zero %flag StartPointer
	nop
	popWord $t0 #Descarda a posição antiga do ponteiro
	popWord $t0
	j return
	nop
StartPointer:
	popWord %ponteiro #Poniter returns at start position
	popWord $t0
return:
.end_macro

########################
# Paint Numbers Macros #
########################

#Paint a white zero with a black background
.macro paintZero (%pointer, %flag) #$1 Pointer to the start of the number box; $2: '0' returns origal pointer, else returns the finish pointer;
	pushWord $t2
	pushWord $t3
	pushWord %pointer
	ori $t2 $0 0x000000 #Black Collor
	ori $t3 $0 0xFFFFFF #White Collor

	#Line1 & Line 2
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1

	#Line3
	pushWord %pointer #Saves the StartLine
	paintPixelLine $t2 %pointer 6 1
	paintPixelLine $t3 %pointer 4 1
	paintPixelLine $t2 %pointer 6 1
	popWord %pointer #Get the StartLine Back
	nextPixelLine %pointer 1

	#Line4
	pushWord %pointer #Saves the StartLine
	paintPixelLine $t2 %pointer 4 1
	paintPixelLine $t3 %pointer 3 1
	paintPixelLine $t2 %pointer 2 1
	paintPixelLine $t3 %pointer 3 1
	paintPixelLine $t2 %pointer 4 1
	popWord %pointer #Get the StartLine Back
	nextPixelLine %pointer 1

	#Line5
	pushWord %pointer #Saves the StartLine
	paintPixelLine $t2 %pointer 3 1
	paintPixelLine $t3 %pointer 2 1
	paintPixelLine $t2 %pointer 6 1
	paintPixelLine $t3 %pointer 2 1
	paintPixelLine $t2 %pointer 3 1
	popWord %pointer #Get the StartLine Back
	nextPixelLine %pointer 1

	#Line6
	pushWord %pointer #Saves the StartLine
	paintPixelLine $t2 %pointer 3 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 8 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 3 1
	popWord %pointer #Get the StartLine Back
	nextPixelLine %pointer 1

	#Line7
	pushWord %pointer #Saves the StartLine
	paintPixelLine $t2 %pointer 2 1
	paintPixelLine $t3 %pointer 2 1
	paintPixelLine $t2 %pointer 8 1
	paintPixelLine $t3 %pointer 2 1
	paintPixelLine $t2 %pointer 2 1
	popWord %pointer #Get the StartLine Back
	nextPixelLine %pointer 1

	#Line8
	pushWord %pointer #Saves the StartLine
	paintPixelLine $t2 %pointer 2 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 10 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 2 1
	popWord %pointer #Get the StartLine Back
	nextPixelLine %pointer 1

	#Line9
	pushWord %pointer #Saves the StartLine
	paintPixelLine $t2 %pointer 2 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 10 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 2 1
	popWord %pointer #Get the StartLine Back
	nextPixelLine %pointer 1

	#Line10
	pushWord %pointer #Saves the StartLine
	paintPixelLine $t2 %pointer 2 1
	paintPixelLine $t3 %pointer 2 1
	paintPixelLine $t2 %pointer 8 1
	paintPixelLine $t3 %pointer 2 1
	paintPixelLine $t2 %pointer 2 1
	popWord %pointer #Get the StartLine Back
	nextPixelLine %pointer 1

	#Line11
	pushWord %pointer #Saves the StartLine
	paintPixelLine $t2 %pointer 3 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 8 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 3 1
	popWord %pointer #Get the StartLine Back
	nextPixelLine %pointer 1

	#Line12
	pushWord %pointer #Saves the StartLine
	paintPixelLine $t2 %pointer 3 1
	paintPixelLine $t3 %pointer 2 1
	paintPixelLine $t2 %pointer 6 1
	paintPixelLine $t3 %pointer 2 1
	paintPixelLine $t2 %pointer 3 1
	popWord %pointer #Get the StartLine Back
	nextPixelLine %pointer 1

	#Line13
	pushWord %pointer #Saves the StartLine
	paintPixelLine $t2 %pointer 4 1
	paintPixelLine $t3 %pointer 3 1
	paintPixelLine $t2 %pointer 2 1
	paintPixelLine $t3 %pointer 3 1
	paintPixelLine $t2 %pointer 4 1
	popWord %pointer #Get the StartLine Back
	nextPixelLine %pointer 1

	#Line14
	pushWord %pointer #Saves the StartLine
	paintPixelLine $t2 %pointer 6 1
	paintPixelLine $t3 %pointer 4 1
	paintPixelLine $t2 %pointer 6 1
	popWord %pointer #Get the StartLine Back
	nextPixelLine %pointer 1

	#Line15 & Line 16
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1

	#Pointer flag control
	beq $zero %flag StartPointer
	nop
	popWord $t3 #Descarda a posição antiga do ponteiro
	popWord $t3
	popWord $t2
	j return
	nop
StartPointer:
	popWord %pointer #Poniter returns at start position
	popWord $t3
	popWord $t2
return:
.end_macro

#Paint a white one with a black background
.macro paintOne (%pointer, %flag) #$1 Pointer to the start of the number box; $2: '0' returns origal pointer, else returns the finish pointer;
	pushWord $t2
	pushWord $t3
	pushWord %pointer
	ori $t2 $0 0x000000 #Black Collor
	ori $t3 $0 0xFFFFFF #White Collor

	#Line 1 & Line 2
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1

	#Line 3
	pushWord %pointer #Saves the StartLine
	paintPixelLine $t2 %pointer 8 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 7 1
	popWord %pointer #Get the StartLine Back
	nextPixelLine %pointer 1

	#Line 4
	pushWord %pointer #Saves the StartLine
	paintPixelLine $t2 %pointer 7 1
	paintPixelLine $t3 %pointer 2 1
	paintPixelLine $t2 %pointer 7 1
	popWord %pointer #Get the StartLine Back
	nextPixelLine %pointer 1

	#Line 5
	pushWord %pointer #Saves the StartLine
	paintPixelLine $t2 %pointer 6 1
	paintPixel $t3 %pointer
	paintPixel $t2 %pointer
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 7 1
	popWord %pointer #Get the StartLine Back
	nextPixelLine %pointer 1

	#Line 6
	pushWord %pointer #Saves the StartLine
	paintPixelLine $t2 %pointer 5 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 2 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 7 1
	popWord %pointer #Get the StartLine Back
	nextPixelLine %pointer 1

	#Line 7
	pushWord %pointer #Saves the StartLine
	paintPixelLine $t2 %pointer 4 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 3 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 7 1
	popWord %pointer #Get the StartLine Back
	nextPixelLine %pointer 1

	#Line 8
	pushWord %pointer #Saves the StartLine
	paintPixelLine $t2 %pointer 3 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 4 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 7 1
	popWord %pointer #Get the StartLine Back
	nextPixelLine %pointer 1

	#Line 9 to 13
	pushWord %pointer #Saves the StartLine
	paintPixelLine $t2 %pointer 8 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 7 1
	popWord %pointer #Get the StartLine Back
	nextPixelLine %pointer 1

	pushWord %pointer #Saves the StartLine
	paintPixelLine $t2 %pointer 8 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 7 1
	popWord %pointer #Get the StartLine Back
	nextPixelLine %pointer 1

	pushWord %pointer #Saves the StartLine
	paintPixelLine $t2 %pointer 8 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 7 1
	popWord %pointer #Get the StartLine Back
	nextPixelLine %pointer 1

	pushWord %pointer #Saves the StartLine
	paintPixelLine $t2 %pointer 8 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 7 1
	popWord %pointer #Get the StartLine Back
	nextPixelLine %pointer 1

	pushWord %pointer #Saves the StartLine
	paintPixelLine $t2 %pointer 8 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 7 1
	popWord %pointer #Get the StartLine Back
	nextPixelLine %pointer 1

	#Line 14
	pushWord %pointer #Saves the StartLine
	paintPixelLine $t2 %pointer 4 1
	paintPixelLine $t3 %pointer 9 1
	paintPixelLine $t2 %pointer 4 1
	popWord %pointer #Get the StartLine Back
	nextPixelLine %pointer 1

	#Line 15 & Line 16
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1


	#Pointer flag control
	beq $zero %flag StartPointer
	nop
	popWord $t3 #Descarda a posição antiga do ponteiro
	popWord $t3
	popWord $t2
	j return
	nop
StartPointer:
	popWord %pointer #Poniter returns at start position
	popWord $t3
	popWord $t2
return:
.end_macro

#Paint a white one with a black background
.macro paintTwo (%pointer, %flag) #$1 Pointer to the start of the number box; $2: '0' returns origal pointer, else returns the finish pointer;
	pushWord $t2
	pushWord $t3
	pushWord %pointer
	ori $t2 $0 0x000000 #Black Collor
	ori $t3 $0 0xFFFFFF #White Collor

	#Line 1 & Line 2
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1

	#Line 3
	pushWord %pointer #Saves the StartLine
	paintPixelLine $t2 %pointer 6 1
	paintPixelLine $t3 %pointer 4 1
	paintPixelLine $t2 %pointer 6 1
	popWord %pointer #Get the StartLine Back
	nextPixelLine %pointer 1

	#Line 4
	pushWord %pointer #Saves the StartLine
	paintPixelLine $t2 %pointer 5 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 4 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 5 1
	popWord %pointer #Get the StartLine Back
	nextPixelLine %pointer 1

	#Line 5
	pushWord %pointer #Saves the StartLine
	paintPixelLine $t2 %pointer 4 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 6 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 4 1
	popWord %pointer #Get the StartLine Back
	nextPixelLine %pointer 1
	
	#Line 6
	pushWord %pointer #Saves the StartLine
	paintPixelLine $t2 %pointer 3 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 7 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 4 1
	popWord %pointer #Get the StartLine Back
	nextPixelLine %pointer 1
	
	#Line 7
	pushWord %pointer #Saves the StartLine
	paintPixelLine $t2 %pointer 3 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 7 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 4 1
	popWord %pointer #Get the StartLine Back
	nextPixelLine %pointer 1
	
	#Line 8
	pushWord %pointer #Saves the StartLine
	paintPixelLine $t2 %pointer 3 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 6 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 5 1
	popWord %pointer #Get the StartLine Back
	nextPixelLine %pointer 1
	
	#Line 9
	pushWord %pointer #Saves the StartLine
	paintPixelLine $t2 %pointer 9 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 6 1
	popWord %pointer #Get the StartLine Back
	nextPixelLine %pointer 1
	
	#Line 10
	pushWord %pointer #Saves the StartLine
	paintPixelLine $t2 %pointer 8 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 7 1
	popWord %pointer #Get the StartLine Back
	nextPixelLine %pointer 1
	
	#Line 11
	pushWord %pointer #Saves the StartLine
	paintPixelLine $t2 %pointer 7 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 8 1
	popWord %pointer #Get the StartLine Back
	nextPixelLine %pointer 1
	
	#Line 12
	pushWord %pointer #Saves the StartLine
	paintPixelLine $t2 %pointer 6 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 9 1
	popWord %pointer #Get the StartLine Back
	nextPixelLine %pointer 1
	
	#Line 13
	pushWord %pointer #Saves the StartLine
	paintPixelLine $t2 %pointer 5 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 10 1
	popWord %pointer #Get the StartLine Back
	nextPixelLine %pointer 1
	
	#Line 14
	pushWord %pointer #Saves the StartLine
	paintPixelLine $t2 %pointer 4 1
	paintPixelLine $t3 %pointer 9 1
	paintPixelLine $t2 %pointer 3 1
	popWord %pointer #Get the StartLine Back
	nextPixelLine %pointer 1
	
	#Line 15 & Line 16
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1

	#Pointer flag control
	beq $zero %flag StartPointer
	nop
	popWord $t3 #Descarda a posição antiga do ponteiro
	popWord $t3
	popWord $t2
	j return
	nop
StartPointer:
	popWord %pointer #Poniter returns at start position
	popWord $t3
	popWord $t2
return:
.end_macro

#Paint a white three with a black background
.macro paintThree (%pointer, %flag) #$1 Pointer to the start of the number box; $2: '0' returns origal pointer, else returns the finish pointer;
	pushWord $t2
	pushWord $t3
	pushWord %pointer
	ori $t2 $0 0x000000 #Black Collor
	ori $t3 $0 0xFFFFFF #White Collor

	#Line 1 & Line 2
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1

	#Line 3
	pushWord %pointer
	paintPixelLine $t2 %pointer 5 1
	paintPixelLine $t3 %pointer 6 1
	paintPixelLine $t2 %pointer 5 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 4
	pushWord %pointer
	paintPixelLine $t2 %pointer 4 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 6 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 4 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 5 & Line 6
	pushWord %pointer
	paintPixelLine $t2 %pointer 3 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 8 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 3 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	pushWord %pointer
	paintPixelLine $t2 %pointer 3 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 8 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 3 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 7
	pushWord %pointer
	paintPixelLine $t2 %pointer 12 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 3 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 8
	pushWord %pointer
	paintPixelLine $t2 %pointer 7 1
	paintPixelLine $t3 %pointer 5 1
	paintPixelLine $t2 %pointer 4 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 9 & Line 10
	pushWord %pointer
	paintPixelLine $t2 %pointer 12 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 3 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	pushWord %pointer
	paintPixelLine $t2 %pointer 12 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 3 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 11 & Line 12
	pushWord %pointer
	paintPixelLine $t2 %pointer 3 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 8 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 3 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	pushWord %pointer
	paintPixelLine $t2 %pointer 3 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 8 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 3 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 13
	pushWord %pointer
	paintPixelLine $t2 %pointer 4 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 6 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 4 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 14
	pushWord %pointer
	paintPixelLine $t2 %pointer 5 1
	paintPixelLine $t3 %pointer 6 1
	paintPixelLine $t2 %pointer 5 1
	popWord %pointer
	nextPixelLine %pointer 1

	#Line 15 & Line 16
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1

	#Pointer flag control
	beq $zero %flag StartPointer
	nop
	popWord $t3 #Descarda a posição antiga do ponteiro
	popWord $t3
	popWord $t2
	j return
	nop
StartPointer:
	popWord %pointer #Poniter returns at start position
	popWord $t3
	popWord $t2
return:
.end_macro

#Paint a white four with a black background
.macro paintFour (%pointer, %flag) #$1 Pointer to the start of the number box; $2: '0' returns origal pointer, else returns the finish pointer;
	pushWord $t2
	pushWord $t3
	pushWord %pointer
	ori $t2 $0 0x000000 #Black Collor
	ori $t3 $0 0xFFFFFF #White Collor

	#Line 1 & Line 2
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1
	
	#Line 3
	pushWord %pointer
	paintPixelLine $t2 %pointer 9 1
	paintPixelLine $t3 %pointer 2 1
	paintPixelLine $t2 %pointer 5 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 4
	pushWord %pointer
	paintPixelLine $t2 %pointer 8 1
	paintPixel $t3 %pointer
	paintPixel $t2 %pointer
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 5 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 5
	pushWord %pointer
	paintPixelLine $t2 %pointer 7 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 2 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 5 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 6 & Line 7
	pushWord %pointer
	paintPixelLine $t2 %pointer 6 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 3 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 5 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	pushWord %pointer
	paintPixelLine $t2 %pointer 6 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 3 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 5 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 8
	pushWord %pointer
	paintPixelLine $t2 %pointer 5 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 4 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 5 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 9
	pushWord %pointer
	paintPixelLine $t2 %pointer 4 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 5 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 5 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 10 & Line 11
	pushWord %pointer
	paintPixelLine $t2 %pointer 3 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 6 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 5 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	pushWord %pointer
	paintPixelLine $t2 %pointer 3 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 6 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 5 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 12
	pushWord %pointer
	paintPixelLine $t2 %pointer 3 1
	paintPixelLine $t3 %pointer 10 1
	paintPixelLine $t2 %pointer 3 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 13 & Line 14
	pushWord %pointer
	paintPixelLine $t2 %pointer 10 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 5 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	pushWord %pointer
	paintPixelLine $t2 %pointer 10 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 5 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 15 & Line 16
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1
	
	#Pointer flag control
	beq $zero %flag StartPointer
	nop
	popWord $t3 #Descarda a posição antiga do ponteiro
	popWord $t3
	popWord $t2
	j return
	nop
StartPointer:
	popWord %pointer #Poniter returns at start position
	popWord $t3
	popWord $t2
return:
.end_macro

#Paint a white five with a black background
.macro paintFive (%pointer, %flag) #$1 Pointer to the start of the number box; $2: '0' returns origal pointer, else returns the finish pointer;
	pushWord $t2
	pushWord $t3
	pushWord %pointer
	ori $t2 $0 0x000000 #Black Collor
	ori $t3 $0 0xFFFFFF #White Collor

	#Line 1 & Line 2
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1
	
	#Line 3
	pushWord %pointer
	paintPixelLine $t2 %pointer 4 1
	paintPixelLine $t3 %pointer 9 1
	paintPixelLine $t2 %pointer 3 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 4 & Line 5 % Line 6
	pushWord %pointer
	paintPixelLine $t2 %pointer 3 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 12 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	pushWord %pointer
	paintPixelLine $t2 %pointer 3 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 12 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	pushWord %pointer
	paintPixelLine $t2 %pointer 3 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 12 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 7
	pushWord %pointer
	paintPixelLine $t2 %pointer 3 1
	paintPixelLine $t3 %pointer 6 1
	paintPixelLine $t2 %pointer 7 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 8
	pushWord %pointer
	paintPixelLine $t2 %pointer 9 1
	paintPixel $t3 %pointer
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 7 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 9
	pushWord %pointer
	paintPixelLine $t2 %pointer 11 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 4 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 10 & Line 11
	pushWord %pointer
	paintPixelLine $t2 %pointer 12 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 3 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	pushWord %pointer
	paintPixelLine $t2 %pointer 12 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 3 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 12
	pushWord %pointer
	paintPixelLine $t2 %pointer 11 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 4 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 13
	pushWord %pointer
	paintPixelLine $t2 %pointer 9 1
	paintPixel $t3 %pointer
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 7 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 14
	pushWord %pointer
	paintPixelLine $t2 %pointer 3 1
	paintPixelLine $t3 %pointer 6 1
	paintPixelLine $t2 %pointer 7 1
	popWord %pointer
	nextPixelLine %pointer 1

	#Line 15 & Line 16
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1
	
	#Pointer flag control
	beq $zero %flag StartPointer
	nop
	popWord $t3 #Descarda a posição antiga do ponteiro
	popWord $t3
	popWord $t2
	j return
	nop
StartPointer:
	popWord %pointer #Poniter returns at start position
	popWord $t3
	popWord $t2
return:
.end_macro

#Paint a white six with a black background
.macro paintSix (%pointer, %flag) #$1 Pointer to the start of the number box; $2: '0' returns origal pointer, else returns the finish pointer;
	pushWord $t2
	pushWord $t3
	pushWord %pointer
	ori $t2 $0 0x000000 #Black Collor
	ori $t3 $0 0xFFFFFF #White Collor

	#Line 1 & Line 2
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1
	
	#Line 3
	pushWord %pointer
	paintPixelLine $t2 %pointer 7 1
	paintPixelLine $t3 %pointer 4 1
	paintPixelLine $t2 %pointer 5 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 4
	pushWord %pointer
	paintPixelLine $t2 %pointer 5 1
	paintPixel $t3 %pointer
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 9 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 5 & Line 6
	pushWord %pointer
	paintPixelLine $t2 %pointer 4 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 11 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	pushWord %pointer
	paintPixelLine $t2 %pointer 4 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 11 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 7
	pushWord %pointer
	paintPixelLine $t2 %pointer 3 1
	paintPixel $t3 %pointer
	paintPixel $t2 %pointer
	paintPixel $t2 %pointer
	paintPixelLine $t3 %pointer 4 1
	paintPixelLine $t2 %pointer 6 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 8
	pushWord %pointer
	paintPixelLine $t2 %pointer 3 1
	paintPixelLine $t3 %pointer 3 1
	paintPixelLine $t2 %pointer 4 1
	paintPixel $t3 %pointer
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 4 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 9 & Line 10 & Line 11 & Line 12
	pushWord %pointer
	paintPixelLine $t2 %pointer 3 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 8 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 3 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	pushWord %pointer
	paintPixelLine $t2 %pointer 3 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 8 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 3 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	pushWord %pointer
	paintPixelLine $t2 %pointer 3 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 8 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 3 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	pushWord %pointer
	paintPixelLine $t2 %pointer 3 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 8 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 3 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 13
	pushWord %pointer
	paintPixelLine $t2 %pointer 4 1
	paintPixel $t3 %pointer
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 4 1
	paintPixel $t3 %pointer
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 4 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 14
	pushWord %pointer
	paintPixelLine $t2 %pointer 6 1
	paintPixelLine $t3 %pointer 4 1
	paintPixelLine $t2 %pointer 6 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 15 & Line 16
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1
	
	#Pointer flag control
	beq $zero %flag StartPointer
	nop
	popWord $t3 #Descarda a posição antiga do ponteiro
	popWord $t3
	popWord $t2
	j return
	nop
StartPointer:
	popWord %pointer #Poniter returns at start position
	popWord $t3
	popWord $t2
return:
.end_macro

#Paint a white seven with a black background
.macro paintSeven (%pointer, %flag) #$1 Pointer to the start of the number box; $2: '0' returns origal pointer, else returns the finish pointer;
	pushWord $t2
	pushWord $t3
	pushWord %pointer
	ori $t2 $0 0x000000 #Black Collor
	ori $t3 $0 0xFFFFFF #White Collor

	#Line 1 & Line 2
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1
	
	#Line 3
	pushWord %pointer
	paintPixelLine $t2 %pointer 3 1
	paintPixelLine $t3 %pointer 10 1
	paintPixelLine $t2 %pointer 3 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 4
	pushWord %pointer
	paintPixelLine $t2 %pointer 11 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 4 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 5
	pushWord %pointer
	paintPixelLine $t2 %pointer 10 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 5 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 6
	pushWord %pointer
	paintPixelLine $t2 %pointer 9 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 6 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 7 & Line 8
	pushWord %pointer
	paintPixelLine $t2 %pointer 8 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 7 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	pushWord %pointer
	paintPixelLine $t2 %pointer 8 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 7 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 9
	pushWord %pointer
	paintPixelLine $t2 %pointer 7 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 8 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 10 & Line 11
	pushWord %pointer
	paintPixelLine $t2 %pointer 6 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 9 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	pushWord %pointer
	paintPixelLine $t2 %pointer 6 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 9 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 12
	pushWord %pointer
	paintPixelLine $t2 %pointer 5 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 10 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 13
	pushWord %pointer
	paintPixelLine $t2 %pointer 4 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 11 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 14
	pushWord %pointer
	paintPixelLine $t2 %pointer 3 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 12 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 15 & Line 16
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1
	
	#Pointer flag control
	beq $zero %flag StartPointer
	nop
	popWord $t3 #Descarda a posição antiga do ponteiro
	popWord $t3
	popWord $t2
	j return
	nop
StartPointer:
	popWord %pointer #Poniter returns at start position
	popWord $t3
	popWord $t2
return:
.end_macro

#Paint a white eight with a black background
.macro paintEight (%pointer, %flag) #$1 Pointer to the start of the number box; $2: '0' returns origal pointer, else returns the finish pointer;
	pushWord $t2
	pushWord $t3
	pushWord %pointer
	ori $t2 $0 0x000000 #Black Collor
	ori $t3 $0 0xFFFFFF #White Collor

	#Line 1 & Line 2
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1

	#Line 3
	pushWord %pointer
	paintPixelLine $t2 %pointer 6 1
	paintPixelLine $t3 %pointer 4 1
	paintPixelLine $t2 %pointer 6 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 4
	pushWord %pointer
	paintPixelLine $t2 %pointer 4 1
	paintPixel $t3 %pointer
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 4 1
	paintPixel $t3 %pointer
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 4 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 5 & Line 6 & Line 7
	pushWord %pointer
	paintPixelLine $t2 %pointer 3 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 8 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 3 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	pushWord %pointer
	paintPixelLine $t2 %pointer 3 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 8 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 3 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	pushWord %pointer
	paintPixelLine $t2 %pointer 3 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 8 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 3 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 8
	pushWord %pointer
	paintPixelLine $t2 %pointer 4 1
	paintPixelLine $t3 %pointer 8 1
	paintPixelLine $t2 %pointer 4 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 9 & Line 10 & Line 11 & Line 12
	pushWord %pointer
	paintPixelLine $t2 %pointer 3 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 8 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 3 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	pushWord %pointer
	paintPixelLine $t2 %pointer 3 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 8 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 3 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	pushWord %pointer
	paintPixelLine $t2 %pointer 3 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 8 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 3 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	pushWord %pointer
	paintPixelLine $t2 %pointer 3 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 8 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 3 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	
	#Line 13
	pushWord %pointer
	paintPixelLine $t2 %pointer 4 1
	paintPixel $t3 %pointer
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 4 1
	paintPixel $t3 %pointer
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 4 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 14
	pushWord %pointer
	paintPixelLine $t2 %pointer 6 1
	paintPixelLine $t3 %pointer 4 1
	paintPixelLine $t2 %pointer 6 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 15 & Line 16
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1
	
	#Pointer flag control
	beq $zero %flag StartPointer
	nop
	popWord $t3 #Descarda a posição antiga do ponteiro
	popWord $t3
	popWord $t2
	j return
	nop
StartPointer:
	popWord %pointer #Poniter returns at start position
	popWord $t3
	popWord $t2
return:
.end_macro
	
#Paint a white nine with a black background
.macro paintNine (%pointer, %flag) #$1 Pointer to the start of the number box; $2: '0' returns origal pointer, else returns the finish pointer;
	pushWord $t2
	pushWord $t3
	pushWord %pointer
	ori $t2 $0 0x000000 #Black Collor
	ori $t3 $0 0xFFFFFF #White Collor

	#Line 1 & Line 2
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1
	
	#Line 3
	pushWord %pointer
	paintPixelLine $t2 %pointer 6 1
	paintPixelLine $t3 %pointer 4 1
	paintPixelLine $t2 %pointer 6 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 4
	pushWord %pointer
	paintPixelLine $t2 %pointer 4 1
	paintPixel $t3 %pointer
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 4 1
	paintPixel $t3 %pointer
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 4 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 5 & Line 6 & Line 7 & Line 8
	pushWord %pointer
	paintPixelLine $t2 %pointer 3 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 8 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 3 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	pushWord %pointer
	paintPixelLine $t2 %pointer 3 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 8 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 3 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	pushWord %pointer
	paintPixelLine $t2 %pointer 3 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 8 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 3 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	pushWord %pointer
	paintPixelLine $t2 %pointer 3 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 8 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 3 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 9
	pushWord %pointer
	paintPixelLine $t2 %pointer 4 1
	paintPixel $t3 %pointer
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 4 1
	paintPixel $t3 %pointer
	paintPixel $t3 %pointer
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 3 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 10
	pushWord %pointer
	paintPixelLine $t2 %pointer 6 1
	paintPixelLine $t3 %pointer 4 1
	paintPixel $t2 %pointer
	paintPixel $t2 %pointer
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 3 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 11 & Line 12
	pushWord %pointer
	paintPixelLine $t2 %pointer 12 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 3 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	pushWord %pointer
	paintPixelLine $t2 %pointer 12 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 3 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 13
	pushWord %pointer
	paintPixelLine $t2 %pointer 3 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 7 1
	paintPixel $t3 %pointer
	paintPixelLine $t2 %pointer 4 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 14
	pushWord %pointer
	paintPixelLine $t2 %pointer 4 1
	paintPixelLine $t3 %pointer 7 1
	paintPixelLine $t2 %pointer 5 1
	popWord %pointer
	nextPixelLine %pointer 1
	
	#Line 15 & Line 16
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1
	paintPixelLine $t2 %pointer 16 0
	nextPixelLine %pointer 1
	
	#Pointer flag control
	beq $zero %flag StartPointer
	nop
	popWord $t3 #Descarda a posição antiga do ponteiro
	popWord $t3
	popWord $t2
	j return
	nop
StartPointer:
	popWord %pointer #Poniter returns at start position
	popWord $t3
	popWord $t2
return:
.end_macro

####################
# Macros of Macros #
####################
#Prints part of the interface
.macro	printCleanLine (%cor %pointer %range)
	pushWord $t0
	and $t0 $zero $zero
loopCleanLine:
	paintSquare %cor %pointer 0
	nextSquareHorizontal %pointer 18 #17(camp) + 1(inicial column)
	paintLine %cor %pointer 14 1
	magicMoveEndLine %pointer
	addi $t0 $t0 1
	blt $t0 %range loopCleanLine
	nop
	popWord $t0
.end_macro

#Prints part of the interface(the line with the next space)
.macro printNextBlockLine (%cor %pointer %range)
	pushWord $t0
	and $t0 $zero $zero
loopNextBlock:
	paintSquare %cor %pointer 0
	nextSquareHorizontal %pointer 18 #17(camp) + 1(inicial column)
	paintLine %cor %pointer 4 1
	nextSquareHorizontal %pointer 6 #6(next camp)
	paintLine %cor %pointer 4 1
	magicMoveEndLine %pointer
	addi $t0 $t0 1
	blt $t0 %range loopNextBlock
	nop
	popWord $t0
.end_macro

#Reset to all 0's in the small box
.macro resetSmallBox (%pointer) #$1: Pointer to the start of the small box;
	pushWord %pointer
	paintZero %pointer 0
	nextSquareHorizontal %pointer 1
	paintZero %pointer 0
	nextSquareHorizontal %pointer 1
	paintZero %pointer 0
	nextSquareHorizontal %pointer 1
	paintZero %pointer 0
	nextSquareHorizontal %pointer 1
	popWord %pointer
.end_macro

.macro printSmallBoxLine (%cor %pointer %return)
	paintSquare %cor %pointer 0
	nextSquareHorizontal %pointer 18 #17(camp) + 1(inical column)
	paintLine %cor %pointer 5 1
	and %return %pointer %pointer #Set the return to the start of the SmallBox
	resetSmallBox %pointer
	nextSquareHorizontal %pointer 4 #Jump the small Box
	paintLine %cor %pointer 5 1
	magicMoveEndLine %pointer
.end_macro

#############
# MAIN CODE #
#############
.text
printBaseInterface:
	la $s0 0x797979 #Gray Border Color
	#la $s1 0x10000000 #Pointer to the start of the display
	and $s1 $gp $gp
	and $s2 $0 $s0 #Space for the Score Pointer
	and $s3 $s0 $s0 #Space for the Lines Pointer
	
	paintFullLine $s0 $s1 1
	printCleanLine $s0 $s1 2
	
	printNextBlockLine $s0 $s1 6
	
	printCleanLine $s0 $s1 2
	printSmallBoxLine $s0 $s1 $s2
	printCleanLine $s0 $s1 3
	printSmallBoxLine $s0 $s1 $s3
	
	printCleanLine $s0 $s1 15
	paintFullLine $s0 $s1 1
	
	#and $s1 $gp $gp
	#nextSquareHorizontal $s1 1
	#nextSquareVertical $s1 1
	#paintZero $s1 0
	#nextSquareHorizontal $s1 1
	#paintOne $s1 0
	#nextSquareHorizontal $s1 1
	#paintTwo $s1 0
	#nextSquareHorizontal $s1 1
	#paintThree $s1 0
	#nextSquareHorizontal $s1 1
	#paintFour $s1 0
	#nextSquareHorizontal $s1 1
	#paintFive $s1 0
	#nextSquareHorizontal $s1 1
	#paintSix $s1 0
	#nextSquareHorizontal $s1 1
	#paintSeven $s1 0
	#nextSquareHorizontal $s1 1
	#paintEight $s1 0
	#nextSquareHorizontal $s1 1
	#paintNine $s1 0
