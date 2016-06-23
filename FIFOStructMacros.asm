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

.text
main:
	startFila

	ori $s0 $0 0x1
	pushFWord $s0

	ori $s0 $0 0x2
	pushFWord $s0

	ori $s0 $0 0x3
	pushFWord $s0

	popFWord $s1
	popFWord $s2
	popFWord $s3
