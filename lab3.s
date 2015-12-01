# Assignment:           3
# Due Date:             October, 26 2015
# Name:                 Ismail Mare
# Unix ID:              imare
# StudentID:		1388973
# Lecture Section:      B1
# Instructor:           Ionis Nikolaidis
# Lab Section:          D06 (Thursday 1700 - 2150)
# Teaching Assistant:   Parisa Mohebbi
#---------------------------------------------------------------
#
# startCache: Recieves an argument which indicates the associativity
#             of the cache. Initializes the cache with zeros on the tree 
#
#
#
#
# getLRU: Recives a stream of reference bits or labels to process 
#	  in the cache and return the LRU.
#
#
#
#---------------------------------------------------------------



.data
	.align 0
	cache1:   .space   1024  #Allocate a contigious block of memory

	.align 2
	offset:  .space	  4 # Allocate space for offset

.text


startCache:
	#offset is last five bits. Flip these bits
	li $t0 0				#initalize
	la $t2 cache1				#Loading the space to create the tree

	loop1:		
		add $t0 $t0 1			#t0 contains the entry identifier		
		srl $a0 $a0 1				
		bne $a0	$zero loop1		#loop
	add $t0 $t0 -1
	jr $ra


getLRU:

        lw $t0 offset                           #load offset
        la $t1 cache1                           #load cache table


        li $t3 0 
        and $t3 $a1 $t3                         # mask the bits of number of references

        loop3:
                and $t4 $a0 $a0                 # masking the offset bits 
                xor $t4 $t4 $t0

                add $a0 $a0 $t0                 # shifting by the offset
                sub $t3 $t3 1                  # one reference read
		
                bne $t3 $zero loop3                # loop 

	move $v0 $t4
	jr $ra	
