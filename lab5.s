# Assignment:           5
# Due Date:             December, 07 2015
# Name:                 Ismail Mare
# Unix ID:              imare
# StudentID:		1388973
# Lecture Section:      B1
# Instructor:           Ionis Nikolaidis
# Lab Section:          D06 (Thursday 1700 - 2150)
# Teaching Assistant:   Parisa Mohebbi
#---------------------------------------------------------------
# $t0
# $t1
# $t2
# $t3
# $t4
# $t5
# $t6
# $t7
# $s1
# $s2
# $s3
# $s4
#---------------------------------------------------------------

.data
.align 2
code: .space 1000

.text

#MIPStoARM:
main:
	li $t0 0  #The counter for the amount of arm instructions generated
   	move $t1 $a0 # Reading pointer to memory containing a MIPS function
	la $t2 code # Holds the address of the space to hold the arm instruc0on
	li $t1 0xe0000000

	condition_check:
		#lw $t3 0($t1) # Reading in the first four bytes. One mips instruction
		beq $t3 0xffffffff end
		move $t3 $t1
		srl $t4 $t3 16
		andi $t4 $t4 0xF000
		beq $t4 0x8000 add
		beq $t4 0x2000 addi
		beq $t4 0x9000 and
		beq $t4 0x6000 andi
		beq $t4 0x9400 or
		beq $t4 0x3400 ori
		beq $t4 0x8800 sub
		add $t0 $t0 1

		add:
			la	$a0 oxStr
			li	$v0 4
			syscall	

		addi:
			la	$a0 op
			li	$v0 4
			syscall	

		and:
			la	$a0 op
			li	$v0 4
			syscall

		andi:
			la	$a0 op
			li	$v0 4
			syscall

		or:
			la	$a0 op
			li	$v0 4
			syscall

		ori:
			la	$a0 op
			li	$v0 4
			syscall

		sub:
			la	$a0 op
			li	$v0 4
			syscall


		add $t0 $t0 1
		jr $ra
		
   	end:
		move $v0 $t7
		move $v1 $t8
		jr $ra




