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
.macro pushFByte (%dado) #$1: Data to be saved;
	addi $t8 $t8 1
	sb %dado ($t8)
.end_macro

#Get a data from the FIFO List
.macro popFByte (%dado) #$s1 recives the data
	isFEmpty
	beq $v0 $0 return #Does nothing if FIFO List is empty
	nop
	lb %dado 1($t7)
	pushWord $t0
	pushWord %dado
	pushWord $t7 #Saves the pointer
loopPopF: #loop to move the elements in the FIFO List
	lb $t0 2($t7) #Get Next Value
	sb $t0 1($t7) #Store here
	addi $t7 $t7 1
	blt $t7 $t8 loopPopF
	nop
	popWord $t7
	popWord %dado
	popWord $t0
	addi $t8 $t8 -1 #Updates the last FIFO List position
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
	pushFByte $t2 #Sends movement to the FIFO List
	j end
	nop
end:
	popWord $t2
.end_macro

#Moves the piece according to the FIFO List
.macro mover (%p1, %p2, %p3, %p4) #$1 to 4: Pointesr to the piece to move; $v0: Returns 1 if no move is made.
	pushWord $t2
	isFEmpty
	and $t2 $v0 $v0 #Saves return of the function
	ori $v0 $0 1 #Set return to fail to be changed if the piece is moved
	beq $t2 $0 end #Jump if there is no moviment in FIFO List
	nop
	popFByte $t2 #Get move from the FIFO List
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
	and $v0 $0 $0 #Set return falg to indicates move made
	j end
	nop
Left:
	moveLeft %p1 %p2 %p3 %p4
	#and $v0 $0 $0 #Set return falg to indicates move made
	j end
	nop
Right:
	moveDown %p1 %p2 %p3 %p4
	#and $v0 $0 $0 #Set return falg to indicates move made
	j end
	nop
SoftDrop:
	moveRight %p1 %p2 %p3 %p4
	#and $v0 $0 $0 #Set return falg to indicates move made
#	j end #No need for this Jump
# nop

end:
	popWord $t2
.end_macro

#Moves down a block
.macro moveDown (%p1, %p2, %p3, %p4) #$1 to 4: Pointesr to the piece to move; $v0: Returns 1 if fails to move.
	pushWord $t2
	pushWord $t3
	pushWord $t4

	and $t3 %p1 %p1 #Copy the pointer
	nextSquareVertical $t3 1
	isBlockFree $t3
	beq $v0 $0 fail #Dont Move if space isn't free and returns a flag
	nop
	and $t3 %p2 %p2 #Copy the pointer
	nextSquareVertical $t3 1
	isBlockFree $t3
	beq $v0 $0 fail #Dont Move if space isn't free and returns a flag
	nop
	and $t3 %p3 %p3 #Copy the pointer
	nextSquareVertical $t3 1
	isBlockFree $t3
	beq $v0 $0 fail #Dont Move if space isn't free and returns a flag
	nop
	and $t3 %p4 %p4 #Copy the pointer
	nextSquareVertical $t3 1
	isBlockFree $t3
	beq $v0 $0 fail #Dont Move if space isn't free and returns a flag
	nop

	lw $t2 8(%p1) #(2*4) Get Light
	lw $t3 2104(%p1) #(16*32*4) + (14*4)Get Dark
	lw $t4 4112(%p1) #(16*32*4*2) + (4*4)Get Color

	paintSquare $0 %p1 0
	paintSquare $0 %p2 0
	paintSquare $0 %p3 0
	paintSquare $0 %p4 0
	nextSquareVertical %p1 1
	nextSquareVertical %p2 1
	nextSquareVertical %p3 1
	nextSquareVertical %p4 1
	paintBlock $t4 $t2 $t3 %p1 0
	paintBlock $t4 $t2 $t3 %p2 0
	paintBlock $t4 $t2 $t3 %p3 0
	paintBlock $t4 $t2 $t3 %p4 0

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
.macro moveRight (%p1, %p2, %p3, %p4) #$1 to 4: Pointesr to the piece to move; $v0: Returns 1 if fails to move.
	pushWord $t2
	pushWord $t3
	pushWord $t4

	and $t3 %p1 %p1 #Copy the pointer
	nextSquareHorizontal $t3 1
	isBlockFree $t3
	beq $v0 $0 fail #Dont Move if space isn't free
	nop
	and $t3 %p2 %p2 #Copy the pointer
	nextSquareHorizontal $t3 1
	isBlockFree $t3
	beq $v0 $0 fail #Dont Move if space isn't free
	nop
	and $t3 %p3 %p3 #Copy the pointer
	nextSquareHorizontal $t3 1
	isBlockFree $t3
	beq $v0 $0 fail #Dont Move if space isn't free
	nop
	and $t3 %p4 %p4 #Copy the pointer
	nextSquareHorizontal $t3 1
	isBlockFree $t3
	beq $v0 $0 fail #Dont Move if space isn't free
	nop

	lw $t2 8(%p1) #(2*4) Get Light
	lw $t3 2104(%p1) #(16*32*4) + (14*4)Get Dark
	lw $t4 4112(%p1) #(16*32*4*2) + (4*4)Get Color

	paintSquare $0 %p1 0
	paintSquare $0 %p2 0
	paintSquare $0 %p3 0
	paintSquare $0 %p4 0
	nextSquareHorizontal %p1 1
	nextSquareHorizontal %p2 1
	nextSquareHorizontal %p3 1
	nextSquareHorizontal %p4 1
	paintBlock $t4 $t2 $t3 %p1 0
	paintBlock $t4 $t2 $t3 %p2 0
	paintBlock $t4 $t2 $t3 %p3 0
	paintBlock $t4 $t2 $t3 %p4 0

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

#Moves a block to the left
.macro moveLeft (%p1, %p2, %p3, %p4) #$1 to 4: Pointesr to the piece to move; $v0: Returns 1 if fails to move.
	pushWord $t2
	pushWord $t3
	pushWord $t4

	and $t3 %p1 %p1 #Copy the pointer
	previousSquareHorizontal $t3 1
	isBlockFree $t3
	beq $v0 $0 fail #Dont Move if space isn't free
	nop
	and $t3 %p2 %p2 #Copy the pointer
	previousSquareHorizontal $t3 1
	isBlockFree $t3
	beq $v0 $0 fail #Dont Move if space isn't free
	nop
	and $t3 %p3 %p3 #Copy the pointer
	previousSquareHorizontal $t3 1
	isBlockFree $t3
	beq $v0 $0 fail #Dont Move if space isn't free
	nop
	and $t3 %p4 %p4 #Copy the pointer
	previousSquareHorizontal $t3 1
	isBlockFree $t3
	beq $v0 $0 fail #Dont Move if space isn't free
	nop

	lw $t2 8(%p1) #(2*4) Get Light
	lw $t3 2104(%p1) #(16*32*4) + (14*4)Get Dark
	lw $t4 4112(%p1) #(16*32*4*2) + (4*4)Get Color

	paintSquare $0 %p1 0
	paintSquare $0 %p2 0
	paintSquare $0 %p3 0
	paintSquare $0 %p4 0
	previousSquareHorizontal %p1 1
	previousSquareHorizontal %p2 1
	previousSquareHorizontal %p3 1
	previousSquareHorizontal %p4 1
	paintBlock $t4 $t2 $t3 %p1 0
	paintBlock $t4 $t2 $t3 %p2 0
	paintBlock $t4 $t2 $t3 %p3 0
	paintBlock $t4 $t2 $t3 %p4 0

	and $v0 $0 $0
	j end
	nop
fail:
	ori $v0 $0 1
end:
	popWord $t4
	popWord $t3
	popWord $t2
.end_macro

######################
# Drown Piece Macros #
######################

#Paint a blue Piece based on %p1 position and set the 4 arguments to the 4 squares
#Returns 1 if fail to create
.macro bluePiece (%p1, %p2, %p3, %p4) #$1 - 4: Pointers to the piece;
	pushWord $t2
	pushWord $t3
	pushWord $t4

	ori $t2 $0 0x4141FF #Color
	ori $t3 $0 0x5182FF #Light
	ori $t4 $0 0x2800ba #Dark

	#No need to set %p1

	#Set %p2
	and %p2 %p1 %p1
	nextSquareVertical %p2 1 #Set %p2

	#Set %p3
	and %p3 %p2 %p2
	previousSquareHorizontal %p3 1 #Set %p3

	#Set %p3
	and %p4 %p2 %p2
	nextSquareHorizontal %p4 1 #Set %p4

	isBlockFree %p1 #Returns 0 if block isn't free for moving
	beq $v0 $0 end
	nop
	isBlockFree %p2 #Returns 0 if block isn't free for moving
	beq $v0 $0 end
	nop
	isBlockFree %p3 #Returns 0 if block isn't free for moving
	beq $v0 $0 end
	nop
	isBlockFree %p4 #Returns 0 if block isn't free for moving
	beq $v0 $0 end
	nop

	paintBlock $t2 $t3 $t4 %p1 0
	paintBlock $t2 $t3 $t4 %p2 0
	paintBlock $t2 $t3 $t4 %p3 0
	paintBlock $t2 $t3 $t4 %p4 0

	end:
	popWord $t4
	popWord $t3
	popWord $t2
.end_macro

#Paint a purple Piece based on %p1 position and set the 4 arguments to the 4 squares
#Returns 1 if fail to create
.macro purplePiece (%p1, %p2, %p3, %p4) #$1 - 4: Pointers to the piece;
	pushWord $t2
	pushWord $t3
	pushWord $t4

	ori $t2 $0 0x9241F3 #Color
	ori $t3 $0 0xA271FF #Light
	ori $t4 $0 0x6110A2 #Dark

	#No need to set %p1

	#Set %p2
	and %p2 %p1 %p1
	nextSquareVertical %p2 1 #Set %p2

	#Set %p3
	and %p3 %p2 %p2
	nextSquareVertical %p3 1 #Set %p3

	#Set %p3
	and %p4 %p3 %p3
	nextSquareVertical %p4 1 #Set %p4

	isBlockFree %p1 #Returns 0 if block isn't free for moving
	beq $v0 $0 end
	nop
	isBlockFree %p2 #Returns 0 if block isn't free for moving
	beq $v0 $0 end
	nop
	isBlockFree %p3 #Returns 0 if block isn't free for moving
	beq $v0 $0 end
	nop
	isBlockFree %p4 #Returns 0 if block isn't free for moving
	beq $v0 $0 end
	nop

	paintBlock $t2 $t3 $t4 %p1 0
	paintBlock $t2 $t3 $t4 %p2 0
	paintBlock $t2 $t3 $t4 %p3 0
	paintBlock $t2 $t3 $t4 %p4 0

	end:
	popWord $t4
	popWord $t3
	popWord $t2
.end_macro

#Paint a orange Piece based on %p1 position and set the 4 arguments to the 4 squares
#Returns 1 if fail to create
.macro orangePiece (%p1, %p2, %p3, %p4) #$1 - 4: Pointers to the piece;
	pushWord $t2
	pushWord $t3
	pushWord $t4

	ori $t2 $0 0xE35100 #Color
	ori $t3 $0 0xFF7930 #Light
	ori $t4 $0 0xA23000 #Dark

	#No need to set %p1

	#Set %p2
	and %p2 %p1 %p1
	nextSquareHorizontal %p2 1 #Set %p2

	#Set %p3
	and %p3 %p1 %p1
	nextSquareVertical %p3 1 #Set %p3

	#Set %p3
	and %p4 %p3 %p3
	nextSquareHorizontal %p4 1 #Set %p4

	isBlockFree %p1 #Returns 0 if block isn't free for moving
	beq $v0 $0 end
	nop
	isBlockFree %p2 #Returns 0 if block isn't free for moving
	beq $v0 $0 end
	nop
	isBlockFree %p3 #Returns 0 if block isn't free for moving
	beq $v0 $0 end
	nop
	isBlockFree %p4 #Returns 0 if block isn't free for moving
	beq $v0 $0 end
	nop

	paintBlock $t2 $t3 $t4 %p1 0
	paintBlock $t2 $t3 $t4 %p2 0
	paintBlock $t2 $t3 $t4 %p3 0
	paintBlock $t2 $t3 $t4 %p4 0

	end:
	popWord $t4
	popWord $t3
	popWord $t2
.end_macro

#Paint a green Piece based on %p1 position and set the 4 arguments to the 4 squares
#Returns 1 if fail to create
.macro greenPiece (%p1, %p2, %p3, %p4) #$1 - 4: Pointers to the piece;
	pushWord $t2
	pushWord $t3
	pushWord $t4

	ori $t2 $0 0x51a200 #Color
	ori $t3 $0 0x9aeb00 #Light
	ori $t4 $0 0x386900 #Shadow

	#No need to set %p1

	#Set %p2
	and %p2 %p1 %p1
	nextSquareVertical %p2 1 #Set %p2

	#Set %p3
	and %p3 %p2 %p2
	previousSquareHorizontal %p3 1 #Set %p3

	#Set %p3
	and %p4 %p3 %p3
	previousSquareHorizontal %p4 1 #Set %p4

	isBlockFree %p1 #Returns 0 if block isn't free for moving
	beq $v0 $0 end
	nop
	isBlockFree %p2 #Returns 0 if block isn't free for moving
	beq $v0 $0 end
	nop
	isBlockFree %p3 #Returns 0 if block isn't free for moving
	beq $v0 $0 end
	nop
	isBlockFree %p4 #Returns 0 if block isn't free for moving
	beq $v0 $0 end
	nop

	paintBlock $t2 $t3 $t4 %p1 0
	paintBlock $t2 $t3 $t4 %p2 0
	paintBlock $t2 $t3 $t4 %p3 0
	paintBlock $t2 $t3 $t4 %p4 0

	end:
	popWord $t4
	popWord $t3
	popWord $t2
.end_macro

#Paint a pink Piece based on %p1 position and set the 4 arguments to the 4 squares
#Returns 1 if fail to create
.macro pinkPiece (%p1, %p2, %p3, %p4) #$1 - 4: Pointers to the piece;
	pushWord $t2
	pushWord $t3
	pushWord $t4

	ori $t2 $0 0x51a200 #Color
	ori $t3 $0 0x9aeb00 #Light
	ori $t4 $0 0x386900 #Shadow

	#No need to set %p1

	#Set %p2
	and %p2 %p1 %p1
	nextSquareVertical %p2 1 #Set %p2

	#Set %p3
	and %p3 %p2 %p2
	nextSquareHorizontal %p3 1 #Set %p3

	#Set %p3
	and %p4 %p3 %p3
	nextSquareHorizontal %p4 1 #Set %p4

	isBlockFree %p1 #Returns 0 if block isn't free for moving
	beq $v0 $0 end
	nop
	isBlockFree %p2 #Returns 0 if block isn't free for moving
	beq $v0 $0 end
	nop
	isBlockFree %p3 #Returns 0 if block isn't free for moving
	beq $v0 $0 end
	nop
	isBlockFree %p4 #Returns 0 if block isn't free for moving
	beq $v0 $0 end
	nop

	paintBlock $t2 $t3 $t4 %p1 0
	paintBlock $t2 $t3 $t4 %p2 0
	paintBlock $t2 $t3 $t4 %p3 0
	paintBlock $t2 $t3 $t4 %p4 0

	end:
	popWord $t4
	popWord $t3
	popWord $t2
.end_macro

#Paint a yellow Piece based on %p1 position and set the 4 arguments to the 4 squares
#Returns 1 if fail to create
.macro yellowPiece (%p1, %p2, %p3, %p4) #$1 - 4: Pointers to the piece;
	pushWord $t2
	pushWord $t3
	pushWord $t4

	ori $t2 $0 0xEBD320 #Color
	ori $t3 $0 0xFFF392 #Light
	ori $t4 $0 0x8A8A00 #Shadow

	#No need to set %p1

	#Set %p2
	and %p2 %p1 %p1
	previousSquareHorizontal %p2 1 #Set %p2

	#Set %p3
	and %p3 %p1 %p1
	nextSquareVertical %p3 1 #Set %p3

	#Set %p3
	and %p4 %p3 %p3
	nextSquareHorizontal %p4 1 #Set %p4

	isBlockFree %p1 #Returns 0 if block isn't free for moving
	beq $v0 $0 end
	nop
	isBlockFree %p2 #Returns 0 if block isn't free for moving
	beq $v0 $0 end
	nop
	isBlockFree %p3 #Returns 0 if block isn't free for moving
	beq $v0 $0 end
	nop
	isBlockFree %p4 #Returns 0 if block isn't free for moving
	beq $v0 $0 end
	nop

	paintBlock $t2 $t3 $t4 %p1 0
	paintBlock $t2 $t3 $t4 %p2 0
	paintBlock $t2 $t3 $t4 %p3 0
	paintBlock $t2 $t3 $t4 %p4 0

	end:
	popWord $t4
	popWord $t3
	popWord $t2
.end_macro

#Paint a white Piece based on %p1 position and set the 4 arguments to the 4 squares
#Returns 1 if fail to create
.macro whitePiece (%p1, %p2, %p3, %p4) #$1 - 4: Pointers to the piece;
	pushWord $t2
	pushWord $t3
	pushWord $t4

	ori $t2 $0 0xEBEBEB #Color
	ori $t3 $0 0xFFFFFF #Light
	ori $t4 $0 0xB2B2B2 #Shadow

	#No need to set %p1

	#Set %p2
	and %p2 %p1 %p1
	nextSquareHorizontal %p2 1 #Set %p2

	#Set %p3
	and %p3 %p1 %p1
	previousSquareVertical %p3 1 #Set %p3

	#Set %p3
	and %p4 %p3 %p3
	previousSquareHorizontal %p4 1 #Set %p4

	isBlockFree %p1 #Returns 0 if block isn't free for moving
	beq $v0 $0 end
	nop
	isBlockFree %p2 #Returns 0 if block isn't free for moving
	beq $v0 $0 end
	nop
	isBlockFree %p3 #Returns 0 if block isn't free for moving
	beq $v0 $0 end
	nop
	isBlockFree %p4 #Returns 0 if block isn't free for moving
	beq $v0 $0 end
	nop

	paintBlock $t2 $t3 $t4 %p1 0
	paintBlock $t2 $t3 $t4 %p2 0
	paintBlock $t2 $t3 $t4 %p3 0
	paintBlock $t2 $t3 $t4 %p4 0

	end:
	popWord $t4
	popWord $t3
	popWord $t2
.end_macro


#############
# MAIN CODE #
#############
.text

	and $s1 $gp $gp #Pointer to block
	nextSquareVertical $s1 1
	nextSquareHorizontal $s1 9

	and $a0 $s1 $s1

	jal GeneratePiece
	nop

	jal MovePiece
	nop

	ori $v0 $0 0xA
	syscall #End the game

	GeneratePiece:
		pushWord $t0
		pushWord $a0
		ori $v0 $0 42 #Code to random number from range
		ori $t0 $0 7
		ori $a0 $0 1 #set Lower Value
		ori $a1 $0 9999 #Set Highter Value
		syscall #Generates a random number and saves on $a0
		div $a0 $t0 #Mod 7
		mfhi $t0

		popWord $a0

		beq $t0 0 green
		nop
		beq $t0 1 pink
		nop
		beq $t0 2 blue
		nop
		beq $t0 3 yellow
		nop
		beq $t0 4 white
		nop
		beq $t0 5 orange
		nop
		beq $t0 6 purple
		nop


	green:
		greenPiece $a0 $a1 $a2 $a3
		j end
		nop
	pink:
		pinkPiece $a0 $a1 $a2 $a3
		j end
		nop
	blue:
		bluePiece $a0 $a1 $a2 $a3
		j end
		nop
	yellow:
		yellowPiece $a0 $a1 $a2 $a3
		j end
		nop
	white:
		whitePiece $a0 $a1 $a2 $a3
		j end
		nop
	orange:
		orangePiece $a0 $a1 $a2 $a3
		j end
		nop
	purple:
		purplePiece $a0 $a1 $a2 $a3
		#j end
		#nop
	end:
	popWord $t0
	jr $ra
	nop

#Subrotine to move the piece
	MovePiece: #Takes 4 arguments, the pointers to the piece
		startFila
		and $t0 $0 $0

	loop:
		salvarMovimento
		addi $t0 $t0 1
		bgt $t0 19999 autoMove #Control time to move
		nop
		salvarMovimento
		mover $a0 $a1 $a2 $a3
		#salvarMovimento
		beq $v0 1 loop #If no move was made jump
		nop
		addi $t0 $t0 9999 #If move was made increment to drop a little faster
		j loop
		nop
	autoMove:
		salvarMovimento
		add $t0 $0 $0
		moveDown $a0 $a1 $a2 $a3
		salvarMovimento
		bne $v0 $0 stop	# if $v0 != 0 then
		nop
		j loop
		nop
	stop:
	jr $ra
	nop
