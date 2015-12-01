# Assignment:           4
# Due Date:             November, 16 2015
# Name:                 Ismail Mare
# Unix ID:              imare
# StudentID:            1388973
# Lecture Section:      B1
# Instructor:           Ionis Nikolaidis
# Lab Section:          D06 (Thursday 1700 - 2150)
# Teaching Assistant:   Parisa Mohebbi

#============================================================

# Main Functions all others are small loops or not important
#
# kernanl
# main: Prints Seconds: prompt 
# continue: Waits for the user to enter numbers and will quit loop with enter
# timer: calculates minutes and seconds from users input of seconds
# display: will display the minutes and seconds and will quit when the timer
#		   runs out or the user enters q

# t1 used for various tasks
# t2 used for various tasks
# t3 used to hold the value of time in seconds
# t4 holds the last second ie 00:00<-- 
# t5 holds the second second ie 00:0 <--0
# t6 holds the second minute ie 00<--:00
# t7 holds ascii char 0 ie 0x30
# t8 holds the first minute ie -->00:00
# t9 used as a flag to check if an interupt occured
# s1 used for various tasks
# s2 used to hold the ascii values of the numbers the user enters  
# s3 used for various tasks
# s4 used for various tasks

#============================================================

#kernal data
.kdata
flag=0x00000000
temp: .space 16


#kernal text
.ktext 0x80000180

	.set noat
	
	move $k0 $at
	.set at

	#saving values to memory
	la $k1 temp
	sw $v0 0($k1)
	sw $a0 4($k1)
	sw $a1 8($k1)
	sw $ra 12($k1)
	
	mfc0 $a0 $13	# Cause Register
	andi $v0 $a0 0x7C
	beq $v0 $zero check
	j return

# Interupt was a timer interupt
check:
	mfc0 $v0 $13	# Cause
	andi $v0 $v0 0x8000	# Mask
	
	# Handle timer interupt
	xor $a0 $a0 $v0
	mfc0 $a0 $13	# Coprocessor Cause Register
	mtc0 $zero $9   # Reset Cause	
	li $a0 100
	mtc0 $a0 $11
	j return

#quit and return
return:
	la $k1 temp
	lw $v0 0($k1)
	lw $a0 4($k1)
	lw $a1 8($k1)
	lw $ra 12($k1)

	.set noat	
	move $at $k0 	# Restore at
	.set at

	mtc0 $k0 $12 	# Clear Cause Register
	
	ori $k0 0x8801	#Interupts enabled 
	mtc0 $k0 $12
	addi $t9 $zero 1
	# Return from exception
	eret
	
#data values needed
.data
input: .asciiz "Seconds="  #String prompt
new:   .asciiz "\n"        #New line character
time: .byte  8,8,8,8,8,48,48,58,48,48,0
keycontrol=0xffff0000      #keyboard control register
keydata=0xffff0004         #keyboard data register
discontrol=0xffff0008      #display control register
disdata=0xffff000C         #display data register
mask=0x01                  #useful mask

.text
.globl __start
__start:
	    lw $a0 0($sp)           # argc
        addiu $a1 $sp 4         # argv
        addiu $a2 $a1 4         # envp
        sll $v0 $a0 2
        addu $a2 $a2 $v0
        jal main
        nop

        li $v0 10
        syscall  

    
#main body
main:
	
    mfc0 $t7 $12 	# Status
    ori $t7 0x8801   # interrupts enable
    mtc0 $t7 $12
    addi $t7 $zero, 100
    mtc0 $t7 $11
    addi $t8 $zero, 0
    mtc0 $t8 $9
    add $t9 $zero $zero
    la $t0 input # Loading a String
    li $s2 0 # Clearing register


    loop:   lb $t1 0($t0) # Loading byte from String
            beqz $t1 continue #jump
    poll:
            lw $t2 discontrol # Display control registers
            andi $t2 $t2 mask
            beqz $t2 poll #loop
            sw $t1 disdata # display data register
            addi $t0 $t0 1
            j loop # loop

    #The String has been outputted
    #time to read in the value
    continue:

            waitloop:
                    lw $t0 keycontrol # Keyboard control register
                    andi $t0 $t0 mask # and immidiate key control register
                    beqz $t0 waitloop # loop
                    lw  $t1 keydata # Keyboard data register
                    sw $t1 disdata # Display data register 
                    beq $t1 0x0a timer # Enter key has been pressed
                    sll $s2 $s2 8 # shifting to make room for byte
                    or $s2 $s2 $t1# Or ing the read byte 
                    
                    
                    j waitloop #loop
    
    #timer function
    timer: 
            li $t1 0 # Clearng registers
            li $t2 0 # Clearing registers
            li $t0 60 # 60 seconds in minute
	    	add $s1 $s2 $zero
	    	# Converting to ascii hex values to binary values
	    	# of minutes and seconds storing final values in t3,t6, and t7 
	    	int:
			li $t3 0
			andi $t4 $s2 0x0F
			srl $s2 $s2 8
			add $t3 $t4 $t3
		
			andi $t4 $s2 0x0F
			li $t5 10
			mult $t5 $t4
			mflo $t4
			add $t3 $t4 $t3
			srl $s2 $s2 8
		
			li $t5 100
			andi $t4 $s2 0x0F
			mult $t4 $t5
			mflo $t4
			add $t3 $t4 $t3
			srl $s2 $s2 8
		
			li $t5 1000
			andi $t4 $s2 0x0F
			mult $t5 $t4
			mflo $t4
			add $t3 $t4 $t3
	    
            divu $t3 $t0 # dividing the seconds from user by 60
            mfhi $t7 # The remainder from the division i.e the seconds
            mflo $t6 # The quotient from the division i.e the minutes
	    			 # Will want to print $t2:$t1

	la $t0 time
	li $t5 10
	li $t8 0
	li $t4 0

	loadsec:
		blt $t7 $t5 updatesec
		sub $t7 $t7 $t5
		addi $t8 $t8 1
		j loadsec
	# So now $t7 has the second digit number
	# And $t8 has the first digit number
	# storing in the array time
	updatesec:
		addi $t7 $t7 0x30
		addi $t8 $t8 0x30
		sb $t7 9($t0)
		sb $t8 8($t0)
		li $t8 0


	loadmin:
		blt $t6 $t5 updatemin
		sub $t6 $t6 $t5
		addi $t4 $t4 1
		j loadmin
	# So now $t6 has the second digit number
	# And $t8 has the first digit number
	# storing in array time
	updatemin:
		addi $t6 $t6 0x30
		addi $t4 $t4 0x30
		sb $t6 6($t0)
		sb $t4 5($t0)
		li $t4 0

	add $t9 $zero $zero
	addi $t3 $t3 1
	la $t0 time
	lb $t1 9($t0)
	addi $t1 $t1 1
	sb $t1 9($t0)
    display:
     	    waitloop2:
				bgtz $t9 interupt
           		lw $t0 keycontrol # Keyboard control register
           		andi $t0 $t0 mask # and immidiate key control register
               	beqz $t0 waitloop2 # loop
                lw  $t1 keydata # Keyboard data register
                beq $t1 0x71 quit # q key has been pressed
            	j waitloop #loop
	    quit:
	    	jr $ra

	    # An interupt has occured and a flag has been raised
	    interupt:
			la $t0 time # Loading a String
			li $t4 0
			li $t5 0
			li $t6 0
			li $t8 0
			li $t7 0x30

			# decrementing the seconds
			second:
				lb $t4 9($t0)
				beq $t4 $t7 resettensecond
				addi $t4 $t4 -1
				sb $t4 9($t0)
				j loop2
			#decrementing the ten seconds
			resettensecond:
				lb $t5 8($t0)
				lb $t4 9($t0)
				beq $t5 $t7 resetminute
				addi $t4 $t4 9
				sb $t4 9($t0)
				
				addi $t5 $t5 -1
				sb $t5 8($t0)
				j loop2
			#decrementing the first minute
			resetminute:
				lb $t5 8($t0)
				lb $t4 9($t0)
				lb $t6 6($t0)
				beq $t6 $t7 resettenminute
				
				addi $t6 $t6 -1
				addi $t5 $t5 5
				addi $t4 $t4 9

				sb $t6 6($t0)
				sb $t5 8($t0)
				sb $t4 9($t0)
				j loop2
			#decrementing the ten minute
			resettenminute:
				lb $t5 8($t0)
				lb $t4 9($t0)
				lb $t6 6($t0)
				lb $t8 5($t0)

				addi $t8 $t8 -1
				addi $t5 $t5 5
				addi $t4 $t4 9
				addi $t6 $t6 9

				sb $t8 5($t0)
				sb $t6 6($t0)
				sb $t5 8($t0)
				sb $t4 9($t0)
				j loop2
			#priting the time
    		loop2:  lb $t1 0($t0) # Loading byte from String
            		beqz $t1 display1 #jump
    		poll2:
            		lw $t2 discontrol # Display control registers
            		andi $t2 $t2 mask
            		beqz $t2 poll2 #loop
     			    sw $t1 disdata # display data register
            		addi $t0 $t0 1
            		j loop2 # loop
            display1:
            		add $t9 $zero $zero
            		addi $t3 $t3 -1
            		beq $t3 $zero quit 
            		j display
	
