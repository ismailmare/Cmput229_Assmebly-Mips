# Assignment:           2
# Due Date:             October, 4 2015
# Name:                 Ismail Mare
# Unix ID:              imare
# StudentID:		1388973
# Lecture Section:      B1
# Instructor:           Ionis Nikolaidis
# Lab Section:          D06 (Thursday 1700 - 2150)
# Teaching Assistant:   Parisa Mohebbi
#---------------------------------------------------------------

#---------------------------------------------------------------
# CreateCountTable: This table will intitalize a table that will
#                   hold 200 different integers and will also count
#                   the amount of times that paritcular integer was
#                   searched for. Returns nothing
#
# CountIntegerAcess: This function will search for the number given in
#                    the register $a0. If the number is founc, then the
#                    counter is incremented. If not the number is added
#                    to the table and its counter is also incremented.
# 
#
# ReadHex: This function will read a string of hexidecimal characters
#	   and will convert that value into binary. If there is a non-
#   	   hexidecimal character found it will quit and return a 1 in $v1
#
# PrintHex: This function will read a integer value and will determine
#	    for every four bits what hexidecimal character represents those
# 	    four bits. It will return a hexidecimal string.
# 
# Register Usage:
#
#
#	  $t1-9: Contains temporary values needed throughout the program
#            Use varies across differnet functions.
#---------------------------------------------------------------



.data
.align 2   #Holds four byte integers
intTable:   .space   800  #Allocate 1600 consecutive bytes. Array of integers.

.align 0   # Holds one byte counters 
countTable: .space   200                       # Space for 200 integers, 200 counters

nlStr:  	.asciiz "\n"
hex_final:   .byte 0, 0, 0, 0, 0, 0, 0, 0, 0 # This will hold the conversion from binary to hex in print hex
hex_chars:   .byte '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'
# Used this a reference to map characters in printhex
oxStr:		.asciiz "0x"
countStr1:      .asciiz " occurred "
countStr2:      .asciiz " times.\n"
badHexStr:      .asciiz "Value entered is not a proper hexadecimal number.\n"
val:            .word 0x00
input: 
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




createCountTable:
        #Initialie the table, holds a max of 200 integers
        jr  $ra


countIntegerAccess:
        #Returns the number of times this function has been called with this integer
        
	
	la $t8, intTable
        la $t9, countTable
	
        li  $t0, 200   	#The max space of integers in the table
	move $t1, $a0   #temp reg for integer fed to subroutine
	li $t2, 0

        check: 		#Checks if integer found or not found
                sll  $t3, $t2, 2
                add  $t4, $t8, $t3

		lw  $t6, 0($t4)
                beq  $t6, $t1, found # Comparing the integer in $a0 to the integer position of array $s0
		add $t2, $t2, 1

		beq $t2, $t0, not_found 
		j check		#Loop


        found:                  # If this function executes, The value is in the table
	
                add  $t3, $t9, $t2
                lb  $t4, 0($t3)
		addi $t5, $t4, 1
		sb  $t5, 0($t3)
		j exit	#loop


        not_found:              # Not found, means we need to find the first empty avalible slot

		li $t2, 0
                find_empty:         # searching

                        sll  $t3, $t2, 2
                        add  $t4, $t8, $t3
                        lw  $t5, 0($t4)

			addi $t2, $t2, 1
			bne  $t5, $zero, find_empty

                add  $t2, $t2, -1               # Loading in the integer
            

                sll $t3, $t2, 2                 # Loading in the integer
                add $t4, $t8, $t3
                sw  $t1, 0($t4)

		add $t4, $t9, $t2		#Loading in 1 as number of times searched
		li $t5, 1
		sb $t5, 0($t4)
		j exit


	exit:					#work is done, found or not found 
        	move 	$v0, $t5
		jr $ra


readHex:
# Determines whether the input string is valid or not
	addi $sp, $sp, -4 # save the return adress
	sw $ra, 0($sp)
	
	li  $t4, 0
	li  $t3, 0  # Will hold the value of the string
        li  $t6, 8 #Is the max amount of chars to read
        check_byte:
		
		sll $t3, $t3, 4
		li $t1, 0x30
		li $t2, 0x39
                add  $t5, $t4, $a0 # Gets each character in this loop
                lb  $t0 0($t5)
		
		blt $t0, $t1, notValid # Not valid hexi decimal
		bgt $t0, $t2, char  #character may be valid more checks
		 
	
		add $t0,$t0, -0x30 
		add $t3, $t3, $t0
		add $t4, $t4, 1
	
		beq $t4, $t6, valid 	# exit to valid hex chars if bounds are reached
		j check_byte		#loop
				
		char:			# all we know here is we are not dealing with an int
			li $t1, 0x41
			li $t2, 0x46	
			
			blt $t0, $t1, notValid
			bgt $t0, $t2, lower  #Lower case possibility 
			

			add $t0, $t0, -0x37	#it is uppercase letter
			add $t3, $t3, $t0
			add $t4, $t4, 1
		
			beq $t4, $t6, valid	# exit to valid hex chars if bounds are reached
			j check_byte
			
		lower:				# all we know here is possible lower case
			li $t1, 0x61
			li $t2, 0x66				
			
			blt $t0, $t1, notValid
			bgt $t0, $t2, notValid  #Lower case possibility 
				
			add $t0, $t0, -0x57	# Lower case letter
			add $t3, $t3, $t0
			
			add $t4, $t4, 1

			beq $t4, $t6, valid
			j check_byte
	
		notValid:			# all bounds check come up as not valid
			li $v1, 1
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			
			jr $ra	

		valid:				# valid bytes 
			li $v1, 0
			move $v0, $t3			
			lw $ra, 0($sp)
			addi $sp, $sp, 4
	
			jr $ra	


printHex:
#Returns the corisponding value of the integer in hexidecimal


	li  $t0, 8 # holds max amount of characters 
	
	la  $t1, hex_final +7  # Holds array of 8 bits 	
	la  $t2, hex_chars  # Holds the hex ascii characters

	
	loop:
		andi $t3, $a0, 15 # Masking
		add $t4, $t3, $t2  # Finding adress of equivelent value on hex char array
		lb $t4, 0($t4)     #
		sb $t4, 0($t1)     
	
		addi $t0, $t0, -1  	# update space left
		addi $t1, $t1, -1	# Shifting
		srl $a0, $a0, 4 	# Next four bits to mask
		
		bne $t0, $zero, loop	# If all eight spaces not filled loop agian
	

	
	la $a0 oxStr
	li $v0 4
	syscall

        la  $a0, hex_final
	li  $v0, 4
        syscall	

	jr $ra


