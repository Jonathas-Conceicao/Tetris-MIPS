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

##################
# Macros da Fila #
##################

#Start the FIFO List Struct
.macro startFila #Takes no arguments;
	la $t8 0x10000000 #Set Start of the List
	and $t7 $t8 $t8
.end_macro

#Teste of if FIFO List is empty
.macro isFEmpty #$v0: Returns 0 if FIFO List is empty and 1 otherwise;
	sne $v0 $t8 0x10000000
# beq $t8 0x10000000 empty
# 	nop
# 	ori $v0 $0 0x1
# 	j end
# 	nop
# empty:
# 	and $v0 $0 $0
# end:
.end_macro

#Saves data to the FIFO List
.macro pushFWord (%dado) #$1: Data to be saved;
	addi $t8 $t8 4
	sw %dado ($t8)
.end_macro

#Get a data from the FIFO List
.macro popFWord (%dado) #$s1 recives the data
	isFEmpty
	beq $v0 $0 return #Does nothing if FIFO List is empty
	nop
	lw %dado 4($t7)
	pushWord $t0
	pushWord %dado
	pushWord $t7 #Saves the pointer
loopPopF: #loop to move the elements in the FIFO List
	lw $t0 8($t7) #Get Next Value
	sw $t0 4($t7) #Store here
	addi $t7 $t7 4
	blt $t7 $t8 loopPopF
	nop
	popWord $t7
	popWord %dado
	popWord $t0
	addi $t8 $t8 -4 #Updates the last FIFO List position
	return:
.end_macro

##############################
# Macros para mover ponteiro #
##############################

#Moves the pointer to the next 'n' square horizontalçy
.macro nextSquareHorizontal (%pointer, %range) #$1: Memori Pointer; $2: Quantity of Squares to jump
	pushWord $t0
	and $t0 $0 $0
loop:
	addi %pointer %pointer 64 # 16*6
	addi $t0 $t0 1
	blt $t0 %range loop
	nop
	popWord $t0
.end_macro

#Moves the pointer to the previous 'n' square horizontaly
.macro previousSquareHorizontal (%pointer, %range) #$1: Memori Poniter; $2: Quantity of Squares to jump
	pushWord $t0
	and $t0 $0 $0
loop:
	addi %pointer %pointer -64 #16 * 4
	addi $t0 $t0 1
	blt $t0 %range loop
	nop
	popWord $t0
.end_macro

#Moves the pointer to the next 'n' square vertically
.macro nextSquareVertical (%pointer, %range) #$1: Memory Pointer; $2: Quantity of Squares to jump
	pushWord $t0
	and $t0 $0 $0
loop:
	addi %pointer %pointer 32768 #64 * 32 * 16
	addi $t0 $t0 1
	blt $t0 %range loop
	nop
	popWord $t0
.end_macro

#Moves the pointer to the previous 'n' square vertically
.macro previousSquareVertical (%ponteiro, %range) #$1: Memory Poniter; $2: Quantity of Squares to jump
	pushWord $t0
	and $t0 $0 $0
loop:
	addi %ponteiro %ponteiro -32768 #64 * 32 * 16
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
.macro paintPixel (%cor, %pointer)
	sw %cor (%pointer)
	addi %pointer %pointer 4
.end_macro

#Pinte a line of 'n' pixels
.macro paintPixelLine (%cor, %pointer, %range, %flag) #$1: Color to paint; $2: Pointer to line start; $3: Size of the line; $4: '0' returns origal pointer, else returns the finish pointer;
	pushWord $t0
	pushWord %pointer
	and $t0 $zero $zero
loopLinha:
	sw %cor (%pointer)
	addi %pointer %pointer 4 #Next Pixel
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
	popWord %pointer #Pointer returns at start position
	popWord $t0
return:
.end_macro

###################################
# Macros para a printar Quadrados #
###################################

#Paint with ($1) color the square that starts and pointer($2)
.macro paintSquare (%cor, %pointer, %flag) #$1: Color to paint; $2: square pointer; $3: '0' returns origal pointer, else returns the finish pointer;
	pushWord $t0
	pushWord $t1
	pushWord %pointer
	and $t0 $zero $zero
	and $t1 $zero $zero
loopLinha:
	sw %cor, (%pointer)
	addi %pointer %pointer 4 #Next Pixel
	addi $t0 $t0 1 #Line counter increment
	blt $t0 16 loopLinha
	nop
	and $t0 $zero $zero
	addi %pointer %pointer 1984 #Next line of the square((512-16)*4)
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
	popWord %pointer #Pointer returns at start position
	popWord $t1
	popWord $t0
return:
.end_macro

#Paints a block of the game
.macro paintBlock (%cor %light %shadow %pointer %flag) #$1 - $t3: Colors to paint the block; $2: square pointer; $3: '0' returns origal pointer, else returns the finish pointer;
	pushWord %pointer

	#Sstarts paiting
	#Line 1
	pushWord %pointer
	paintPixel $0 %pointer
	paintPixel $0 %pointer
	paintPixelLine %light %pointer 12 1
	paintPixel $0 %pointer
	paintPixel $0 %pointer
	popWord %pointer
	nextPixelLine %pointer 1
	#Line 2
	pushWord %pointer
	paintPixel $0 %pointer
	paintPixelLine %light %pointer 13 1
	paintPixel %shadow  %pointer
	paintPixel $0 %pointer
	popWord %pointer
	nextPixelLine %pointer 1
	#Line 3
	pushWord %pointer
	paintPixel %light %pointer
	paintPixel %light %pointer
	paintPixel %light %pointer
	paintPixelLine %cor %pointer 11 1
	paintPixel %shadow  %pointer
	paintPixel %shadow  %pointer
	popWord %pointer
	nextPixelLine %pointer 1
	#Line 4 to Line 13
	pushWord %pointer
	paintPixel %light %pointer
	paintPixel %light %pointer
	paintPixelLine %cor %pointer 12 1
	paintPixel %shadow  %pointer
	paintPixel %shadow  %pointer
	popWord %pointer
	nextPixelLine %pointer 1
	pushWord %pointer
	paintPixel %light %pointer
	paintPixel %light %pointer
	paintPixelLine %cor %pointer 12 1
	paintPixel %shadow  %pointer
	paintPixel %shadow  %pointer
	popWord %pointer
	nextPixelLine %pointer 1
	pushWord %pointer
	paintPixel %light %pointer
	paintPixel %light %pointer
	paintPixelLine %cor %pointer 12 1
	paintPixel %shadow  %pointer
	paintPixel %shadow  %pointer
	popWord %pointer
	nextPixelLine %pointer 1
	pushWord %pointer
	paintPixel %light %pointer
	paintPixel %light %pointer
	paintPixelLine %cor %pointer 12 1
	paintPixel %shadow  %pointer
	paintPixel %shadow  %pointer
	popWord %pointer
	nextPixelLine %pointer 1
	pushWord %pointer
	paintPixel %light %pointer
	paintPixel %light %pointer
	paintPixelLine %cor %pointer 12 1
	paintPixel %shadow  %pointer
	paintPixel %shadow  %pointer
	popWord %pointer
	nextPixelLine %pointer 1
	pushWord %pointer
	paintPixel %light %pointer
	paintPixel %light %pointer
	paintPixelLine %cor %pointer 12 1
	paintPixel %shadow  %pointer
	paintPixel %shadow  %pointer
	popWord %pointer
	nextPixelLine %pointer 1
	pushWord %pointer
	paintPixel %light %pointer
	paintPixel %light %pointer
	paintPixelLine %cor %pointer 12 1
	paintPixel %shadow  %pointer
	paintPixel %shadow  %pointer
	popWord %pointer
	nextPixelLine %pointer 1
	pushWord %pointer
	paintPixel %light %pointer
	paintPixel %light %pointer
	paintPixelLine %cor %pointer 12 1
	paintPixel %shadow  %pointer
	paintPixel %shadow  %pointer
	popWord %pointer
	nextPixelLine %pointer 1
	pushWord %pointer
	paintPixel %light %pointer
	paintPixel %light %pointer
	paintPixelLine %cor %pointer 12 1
	paintPixel %shadow  %pointer
	paintPixel %shadow  %pointer
	popWord %pointer
	nextPixelLine %pointer 1
	pushWord %pointer
	paintPixel %light %pointer
	paintPixel %light %pointer
	paintPixelLine %cor %pointer 12 1
	paintPixel %shadow  %pointer
	paintPixel %shadow  %pointer
	popWord %pointer
	nextPixelLine %pointer 1
	#Line 14
	pushWord %pointer
	paintPixel %light %pointer
	paintPixel %light %pointer
	paintPixelLine %cor %pointer 11 1
	paintPixel %shadow  %pointer
	paintPixel %shadow  %pointer
	paintPixel %shadow  %pointer
	popWord %pointer
	nextPixelLine %pointer 1
	#Line 15
	pushWord %pointer
	paintPixel $0 %pointer
	paintPixel %light %pointer
	paintPixelLine %shadow %pointer 13 1
	paintPixel $0 %pointer
	popWord %pointer
	nextPixelLine %pointer 1
	#Line 16
	pushWord %pointer
	paintPixel $0 %pointer
	paintPixel $0 %pointer
	paintPixelLine %shadow %pointer 12 1
	paintPixel $0 %pointer
	paintPixel $0 %pointer
	popWord %pointer
	nextPixelLine %pointer 1
	beq $zero %flag StartPointer
	nop
	popWord $v0 #Descarda a posição antiga do ponteiro
	j return
	nop
StartPointer:
	popWord %pointer #Pointer returns at start position
	popWord $t1
popWord $t0
return:

.end_macro

#Paint a full squareline
.macro paintFullLine (%cor, %pointer, %flag) #$1: Color to paint; $2: square pointer; $3: '0' returns origal pointer, else returns the finish pointer;
	pushWord $t0
	pushWord %pointer
	and $t0 $zero $zero
loopLinha:
	sw %cor (%pointer)
	addi %pointer %pointer 4 #Next Pixel
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
	popWord %pointer #Pointer returns at start position
	popWord $t0
return:
.end_macro

#Paint a line of 'n' squares
.macro paintLine (%cor, %pointer, %range, %flag)#$1 Color to paint; $2: start pixel pointer; $3 Number of squares to paint; $4: '0' returns origal pointer, else returns the finish pointer;
	pushWord $t0
	pushWord %pointer
	and $t0 $zero $zero
loopLine:
	paintSquare %cor, %pointer, 0
	addi $t0 $t0 1
	addi %pointer %pointer 64 #Next block (16*4)
	blt $t0 %range loopLine
	nop
	beq $zero %flag StartPointer
	nop
	popWord $t0 #Descarda a posição antiga do ponteiro
	popWord $t0
	j return
	nop
StartPointer:
	popWord %pointer #Pointer returns at start position
	popWord $t0
return:
.end_macro

#This is some magic that's necessary so things wouldn't fall apart
.macro magicMoveEndLine (%pointer)
	addi %pointer %pointer 30720 #Magic numbers muah ha ha (16*32*15*4)
.end_macro

#Paint a column of 'n' squares
.macro paintColumn (%cor, %pointer, %range, %flag)#$1 Color to paint; $2: square pointer; $3 Number of squares to paint; $4: '0' returns origal pointer, else returns the finish pointer;
	pushWord $t0
	pushWord %pointer
loopColuna:
	paintSquare %cor, %pointer, 1
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
	popWord %pointer #Pointer returns at start position
	popWord $t0
return:
.end_macro

#####################
# Move Piece Macros #
#####################

#Testes if a block can be moved to that space
.macro isBlockFree (%pointer) #$1: Pointer of block to be tested; $v0: Returns 1 if empty, otherwise returns 0
	pushWord $t0
	lw $t0 (%pointer)
	seq $v0 $t0 $0 #If $t0 == $0 then $v0 = 1, else $v0 = 0
	popWord $t0
.end_macro

#Saves the moviment of the piece
.macro salvarMovimento #Takes no arguments
	pushWord $t2
	lw $t2 0xffff0000 #Read the 'Ready Bit'
	beq $t2 $0 end #No new Value read
	nop
	lw $t2 0xffff0004 #Read the action
	beq $t2 0x57 store #If read 'W'
	nop
	beq $t2 0x77 store #If read 'w'
	nop
	beq $t2 0x41 store #If read 'A'
	nop
	beq $t2 0x61 store #If read 'a'
	nop
	beq $t2 0x53 store #If read 'S'
	nop
	beq $t2 0x73 store #If read 's'
	nop
	beq $t2 0x44 store #If read 'D'
	nop
	beq $t2 0x64 store #If read 'd'
	nop
	j end #Invalid key
	nop
store:
	pushFWord $t2 #Sends movement to the FIFO List
	j end
	nop
end:
	popWord $t2
.end_macro

#Moves the piece according to the FIFO List
.macro mover (%pointer) #$1: Pointer to the piece to move
	pushWord $t2
	isFEmpty
	beq $v0 $0 end #Jump if there is no moviment in FIFO List
	nop
	popFWord $t2
	beq $t2 0x57 Spin #If read 'W'
	nop
	beq $t2 0x77 Spin #If read 'w'
	nop
	beq $t2 0x41 Left #If read 'A'
	nop
	beq $t2 0x61 Left #If read 'a'
	nop
	beq $t2 0x53 Right #If read 'S'
	nop
	beq $t2 0x73 Right #If read 's'
	nop
	beq $t2 0x44 SoftDrop #If read 'D'
	nop
	beq $t2 0x64 SoftDrop #If read 'd'
	nop
Spin:

	j end
Left:
	moveLeft %pointer
	j end

Right:
	moveDown %pointer
	j end
SoftDrop:
	moveRight %pointer
#	j end #No need for this Jump
# nop
end:
	popWord $t2
.end_macro

#Moves down a block
.macro moveDown (%pointer) #$1: Pointer to square; $v0: Returns 1 if fails to move down.
	pushWord $t2
	pushWord $t3
	pushWord $t4
	and $t3 %pointer %pointer #Copy the pointer
	nextSquareVertical $t3 1
	isBlockFree $t3
	beq $v0 $0 fail #Dont Move if space isn't free and returns a msn
	nop
	lw $t2 8(%pointer) #(2*4) Get Light
	lw $t3 2104(%pointer) #(16*32*4) + (14*4)Get Dark
	lw $t4 4112(%pointer) #(16*32*4*2) + (4*4)Get Color

	paintSquare $0 %pointer 0
	nextSquareVertical %pointer 1
	paintBlock $t4 $t2 $t3 %pointer 0
	and $v0 $0 $0 #Set return value to success
	j end
	nop
fail:
	ori $v0 $0 1
end:
	popWord $t4
	popWord $t3
	popWord $t2
.end_macro

#Moves a block to the right
.macro moveRight (%pointer) #$1: Pointer to square;
	pushWord $t2
	pushWord $t3
	pushWord $t4

	and $t3 %pointer %pointer #Copy the pointer
	nextSquareHorizontal $t3 1
	isBlockFree $t3
	beq $v0 $0 end #Dont Move if space isn't free
	nop
	lw $t2 8(%pointer) #(2*4) Get Light
	lw $t3 2104(%pointer) #(16*32*4) + (14*4)Get Dark
	lw $t4 4108(%pointer) #(16*32*4*2) + (3*4)Get Color

	paintSquare $0 %pointer 0
	nextSquareHorizontal %pointer 1
	paintBlock $t4 $t2 $t3 %pointer 0

end:
	popWord $t4
	popWord $t3
	popWord $t2
.end_macro

#Moves a block to the left
.macro moveLeft (%pointer) #$1: Pointer to square;
	pushWord $t2
	pushWord $t3
	pushWord $t4

	and $t3 %pointer %pointer #Copy the pointer
	previousSquareHorizontal $t3 1
	isBlockFree $t3
	beq $v0 $0 end #Dont Move if space isn't free
	nop
	lw $t2 8(%pointer) #(2*4) Get Light
	lw $t3 2104(%pointer) #(16*32*4) + (14*4)Get Dark
	lw $t4 4108(%pointer) #(16*32*4*2) + (3*4)Get Color

	paintSquare $0 %pointer 0
	previousSquareHorizontal %pointer 1
	paintBlock $t4 $t2 $t3 %pointer 0

end:
	popWord $t4
	popWord $t3
	popWord $t2
.end_macro

#############
# Main Code #
#############
.text
main:
	la $s0 0x797979
	and $s1 $gp $gp
	and $s7 $s1 $s1

	nextSquareVertical $s7 10
	paintFullLine $s0 $s7 0

	and $s1 $gp $gp #Pointer to block
	ori $s0 $0 0x51a200 #Color to the block
	ori $s4 $0 0x9aeb00 #Light to the block
	ori $s5 $0 0x386900 #Shadow to the block
	nextSquareVertical $s1 1
	nextSquareHorizontal $s1 9
	paintBlock $s0 $s4 $s5 $s1 0

	and $a0 $s1 $s1

MovePiece:
	startFila
	startFila
	and $t0 $0 $0

	loop:
	salvarMovimento
	addi $t0 $t0 1
	beq $t0 9999 autoMove #Time to move
	nop
	salvarMovimento
	mover $a0
	salvarMovimento
	j loop
	nop
	autoMove:
	salvarMovimento
	add $t0 $0 $0
	moveDown $a0
	salvarMovimento
	bne $v0 $0 stop	# if $v0 != 0 then
	nop
	j loop
	nop
	stop:
	# jr $ra
	# nop
