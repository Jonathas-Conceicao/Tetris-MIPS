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
.macro isFEmpty (%return) #$1: Receves 0 if FIFO List is empty and 1 otherwise;
	beq $t8 0x10000000 empty
	nop
	ori %return $0 0x1
	j end
	nop
empty:
	and %return $0 $0
end:
.end_macro

#Saves data to the FIFO List
.macro pushFWord (%dado) #$1: Data to be saved;
	addi $t8 $t8 4
	sw %dado ($t8)
.end_macro

#Get a data from the FIFO List
.macro popFWord (%dado) #$s1 recives the data
	pushWord $t0
	isFEmpty $t0
	beq $t0 $0 return #Does nothing if FIFO List is empty
	nop
	lw %dado 4($t7)
	pushWord %dado
	pushWord $t7
loopPopF: #loop to move the elements in the FIFO List
	lw $t0 8($t7) #Get Next Value
	sw $t0 4($t7) #Store here
	addi $t7 $t7 4
	blt $t7 $t8 loopPopF
	nop
return:
	addi $t8 $t8 -4 #Updates the last FIFO List position
	popWord $t7
	popWord %dado
	popWord $t0
.end_macro

##############################
# Macros para mover ponteiro #
##############################

#Moves the pointer to the next 'n' square horizontaly
.macro nextSquareHorizontal (%ponteiro, %range) #$1: Memori Poniter; $2: Quantity of Squares to jump
	pushWord $t0
	and $t0 $0 $0
loop:
	addi %ponteiro %ponteiro 64 # 16*4
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

#####################
# Move Piece Macros #
#####################

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
.macro mover(%pointer) #$1: Pointer to the piece to move
	pushWord $t2
	isFEmpty $t2
	beq $t2 $0 end #No moviment in FIFO List
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

.macro moveDown (%pointer)
	pushWord $t2

	lw $t2 (%pointer) #Get Color
	paintSquare $0 %pointer 0
	nextSquareVertical %pointer 1
	paintSquare $t2 %pointer 0

	popWord $t2
.end_macro

.macro moveRight (%pointer)
	pushWord $t2

	lw $t2 (%pointer) #Get Color
	paintSquare $0 %pointer 0
	nextSquareHorizontal %pointer 1
	paintSquare $t2 %pointer 0

	popWord $t2
.end_macro

.macro moveLeft (%pointer)
	pushWord $t2

	lw $t2 (%pointer) #Get color
	paintSquare $0 %pointer 0
	previousSquareHorizontal %pointer 1
	paintSquare $t2 %pointer 0

	popWord $t2
.end_macro
#############
# Main Code #
#############
.text

MovePiece:
	la $s0 0x797979
	and $s1 $gp $gp
	and $s7 $0 $0
	startFila

	# nextSquareHorizontal $s1 5
	# nextSquareVertical $s1 5
	# paintSquare $s0 $s1 0
	# previousSquareHorizontal $s1 3
	# paintSquare $s0 $s1 0
	# previousSquareVertical $s1 3
	# paintSquare $s0 $s1 0

	paintSquare $s0 $s1 0

loop:

	salvarMovimento
	addi $s7 $s7 1
	beq $s7 99999 autoMove #Time to move
	nop
	salvarMovimento
	mover $s1
	salvarMovimento
	j loop
	nop
autoMove:
	salvarMovimento
	add $s7 $0 $0
	moveDown $s1
	salvarMovimento
	j loop
	nop
#dontMove:

end:
