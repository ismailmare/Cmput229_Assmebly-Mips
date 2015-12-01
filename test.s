#-------------------------------
# Tables lab Student Testbed
# Author: Taylor Lloyd
# Date: July 10, 2012
#
#-------------------------------

.data
	
oxStr:		.asciiz "0x"
nlStr:  	.asciiz "\n"
countStr1:	.asciiz " occurred "
countStr2: 	.asciiz " times.\n"
badHexStr:	.asciiz "Value entered is not a proper hexadecimal number.\n"
val:		.word 0x00
input:		.space 20

.text

main:
	#Initialize the counts table
	jal	createCountTable

nextNumber:	
	#Print '0x' as a prompt
	la	$a0 oxStr
	li	$v0 4
	syscall	

	#Read in a number
	la	$a0 input
	li	$a1 20
	li	$v0 8
	syscall
	
	#Call student code to parse it
	jal	readHex
	sw	$v0 val
	beq     $v1, $zero, goodHex

	#Bad hexdecimal value: print error message and go back for another number
	la      $a0, badHexStr
	li      $v0, 4
	syscall
	j       nextNumber
	
goodHex:	
	#Print the hex number using student code
	move	$a0 $v0
	jal printHex

	#Print the count info
	li	$v0 4
	la	$a0 countStr1
	syscall

	#Call student code to get the count for this one
	lw	$a0 val
	jal	countIntegerAccess	

	#Print out the remainder
	move	$a0 $v0
	li	$v0 1
	syscall
	
	li	$v0 4
	la 	$a0 countStr2
	syscall
	
	#Loop back for another go!
	j	nextNumber

