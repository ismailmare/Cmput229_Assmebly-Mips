#---------------------------------------------------------------
# Assignment:           1
# Due Date:             September 21 2015
# Name:                 Ismail Mare
# Unix ID:              imare
# Lecture Section:      B1
# Instructor:           Ionis Nikolaidis
# Lab Section:          D06 (Thursday 1700 - 2150)
# Teaching Assistant:   Parisa Mohebbi
#---------------------------------------------------------------

#---------------------------------------------------------------
# The main program loads v0 using the read_int syscall.  
# The Least significant byte is then masked out and shifted
# into a new register. This is repeated until bytes are swapped.
#
# Register Usage:
#
#     
#	  v0: Contains the number read from console       
#	  t0: Use this as temp register
#	  $s4: This register holds the big endian value
#---------------------------------------------------------------

.text
main:
	li 	$v0, 5
	syscall
	move 	$t0, $v0

	li 	$s0, 0
	li 	$s1, 0
	li      $s2  0

	srl	$s0, $t0, 8
	sll 	$s0, $s0, 16

	sll	$s1, $t0, 24
	 
	or 	$s2, $s1, $s2
	
	
	li	$v0, 1
	move 	$a0, $s2
	syscall

