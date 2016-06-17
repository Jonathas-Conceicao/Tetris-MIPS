# generic looping mechanism
.macro for (%regIterator, %from, %to)
	add %regIterator $zero %from
	Loop: print_int($a0)
	add %regIterator %regIterator 1
	blt %regIterator %to Loop
	nop
.end_macro

.macro print_int(%theInt)
	add $a0 $zero %theInt
	li $v0 1
	syscall
	nop
.end_macro

# printing 1 to 10:
for ($a0, 1, 10)	