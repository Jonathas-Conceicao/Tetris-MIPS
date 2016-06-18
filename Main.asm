
######################
# Macros para a Pilha#
######################

.macro pushWord (%dado)
	addi $sp $sp -4
	sw %dado ($sp)
.end_macro
.macro popWord (%dado)
	lw %dado ($sp)
	addi $sp $sp 4
.end_macro

############################
#Macros para mover ponteiro#
############################

#Moves the pointer to the next 'n' square horizontalçy
.macro nextSquareHorizontal (%ponteiro, %range) #$1: Memori Poniter; $2: Quantity of Squares to jump
	pushWord $t0
	and $t0 $0 $0
loop:
	addi %ponteiro %ponteiro 64 # 16*6
	addi $t0 $t0 1
	blt $t0 %range loop
	nop
.end_macro

#Moves the pointer to the next 'n' square vertically
.macro nextSquareVertical (%ponteiro, %range) #$1: Memori Poniter; $2: Quantity of Squares to jump
	pushWord $t0
	and $t0 $0 $0
loop:
	addi %ponteiro %ponteiro 32768 #64 * 32 * 16
	addi $t0 $t0 1
	blt $t0 %range loop
	nop
.end_macro

################################
# Macros para a printar na tela#
################################

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

.text
printBaseInterface:
	la $s0 0x797979
	and $s1 $gp $gp
	#generateBorder($t3, 0, 5632, $t0, $t1)
	paintFullLine $s0 $s1 0
	la $s0 0x71e392
	nextSquareVertical $s1 1
	paintLine $s0 $s1 16 0
	nextSquareHorizontal $s1 16
	la $s0 0x6110a2
	paintLine $s0 $s1 16 0
	#paintColumn $s0 $s1 32 0
	#paintSquare $s0 $s1 0
	#nextSquareHorizontal $s1
	#paintSquare $s0 $s1 0
	#nextSquareVertical $s1
	#paintSquare $s0 $s1 0
