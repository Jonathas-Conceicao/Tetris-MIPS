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

#Start the FIFO Struct
.macro startFila #Takes no argumento;
	la $t8 0x10000000 #Set Start of the List
	and $t7 $t8 $t8
.end_macro

#Teste of the FIFO is empty
.macro isFEmpty (%return) #$1: Receves 0 if FIFO is empty and 1 otherwise;
	beq $t8 0x10000000 empty
	nop
	ori %return $0 0x1
	j end
	nop
empty:
	and %return $0 $0
end: 
.end_macro

#Saves data to the FIFO
.macro pushFWord (%dado) #$1: Data to be saved;
	addi $t8 $t8 4
	sw %dado ($t8)
.end_macro

#Get a file from the FIFO
.macro popFWord (%dado) #$s1 recives the data
	pushWord $t0
	isFEmpty $t0
	beq $t0 $0 return #Does nothing if FIFO is empty
	nop
	lw %dado 4($t7)
	pushWord %dado
	pushWord $t7
loopPopF: #loop to move the elements in the FIFO
	lw $t0 8($t7) #Get Next Value
	sw $t0 4($t7) #Store here
	addi $t7 $t7 4
	blt $t7 $t8 loopPopF
	nop
return:
	addi $t8 $t8 -4 #Updates the last FIFO position
	popWord $t7
	popWord %dado
	popWord $t0
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