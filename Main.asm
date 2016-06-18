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

################################
# Macros para a printar na tela#
################################

.macro paintSquare (%cor, %ponteiro, %flag) #$1 Color to paint; $2: start pixel pointer; $3 0 returns origal pointer, any other value dont; 
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


.macro paintFullLine (%cor, %ponteiro, %flag)
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

.macro paintColumn (%cor, %ponteiro, %quant, %flag)
	pushWord $t7
	pushWord %ponteiro
loopColuna:
	paintSquare %cor, %ponteiro, 1
	addi $t7 $t7 1
	blt $t7 %quant loopColuna
	nop
	beq $zero %flag StartPointer
	nop
	popWord $t7 #Descarda a posição antiga do ponteiro 
	popWord $t7
	j return
	nop	
StartPointer:
	popWord %ponteiro #Poniter returns at start position
	popWord $t7
return:
.end_macro

.text 
printInterface:
	la $s0 0x797979
	and $s1 $gp $gp
	#generateBorder($t3, 0, 5632, $t0, $t1)
	paintFullLine $s0 $s1 1
	paintColumn $s0 $s1 31 0