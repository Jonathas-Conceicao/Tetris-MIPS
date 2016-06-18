.macro pushWord (%dado)
	addi $sp $sp -4
	sw %dado ($sp)
.end_macro

.macro popWord (%dado)
	lw %dado ($sp)
	addi $sp $sp 4
.end_macro

		

.macro paintSquare (%cor) (%ponteiro)
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
	popWord %ponteiro #Poniter returns at start position
	popWord $t1
	popWord $t0
.end_macro


.macro paintFullLine (%cor, %ponteiro)
	pushWord $t0
	pushWord $t1
	pushWord %ponteiro
	and $t0 $zero $zero
	and $t1 $zero $zero
loopLinha:
	sw %cor (%ponteiro)
	addi %ponteiro %ponteiro 4 #Next Pixel 
	add $t0 $t0 1
	blt $t0 8192 loopLinha #8192(512*16)
	nop
.end_macro

.text 
printInterface:
	la $s0 0x797979
	and $s1 $gp $gp
	#generateBorder($t3, 0, 5632, $t0, $t1)
	paintFullLine $s0 $s1
	paintSquare $s0 $s1