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
#
#
#
#
#
#
#
#
#---------------------------------------------------------------


.data
.align 2
code= .space 1000

.text

main:
   	move $t0 $a0
	
	loop1:
		lw $t1 0($t0)
		beq $t1 0xFFFFFFFF end
		






   	end:
		move $v0 $t7
		move $v1 $t8
		jr $ra
