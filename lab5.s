#-------------------------------
# Student MIPStoARM Testing file
# Author: Taylor Lloyd
# Date: July 4, 2012
#
#-------------------------------

.data
	.align 2
binary:
	.space 2052
noFileStr:
	.asciiz "Couldn't open specified file.\n"

.align 2
code: .space 2000

op1: .asciiz "add"
op2: .asciiz "addi"
op3: .asciiz "and"
op4: .asciiz "andi"
op5: .asciiz "or"
op6: .asciiz "ori"
op7: .asciiz "sub"

.text
main:
	lw	$a0 4($a1)	# Put the filename pointer into $a0
	li	$a1 0		# Read Only
	li	$a2 0		# No Mode Specified
	li	$v0 13		# Open File
	syscall
	bltz	$v0 main_err	# Negative means open failed

	move	$a0 $v0		#point at open file
	la	$a1 binary	# write into my binary space
	li	$a2 2048	# read a file of at max 2kb
	li	$v0 14		# Read File Syscall
	syscall
	la	$t0 binary
	add	$t0 $t0 $v0	#point to end of binary space

	li	$t1 0xFFFFFFFF	#Place ending sentinel
	sw	$t1 0($t0)

	la	$a0 binary	#prepare pointer for assignment
	jal	MIPStoARM

	sll	$v0 $v0 2	# instructions are words (*4)
	add	$s0 $v0 $v1	# $s0 = last instruction

	main_parseLoop:
		bge	$v1 $s0 main_doneParse	# If we're done, jump to complete
		lw	$a0 0($v1)		# Load the word to parse

		addi	$sp $sp -8
		sw	$s0 4($sp)
		sw	$v1 0($sp)

		jal	parseARM

		lw	$s0 4($sp)
		lw	$v1 0($sp)
		addi	$sp $sp 8

		addi	$v1 $v1 4

		j	main_parseLoop

	main_doneParse:
		j	main_done
	main_err:
		la	$a0 noFileStr
		li	$v0 4
		syscall
	main_done:
		li	$v0 10
		syscall
.data
	andStr: .asciiz "AND"
	orStr: .asciiz "OR"
	addStr: .asciiz "ADD"
	subStr: .asciiz "SUB"
	movStr: .asciiz "MOV"
	cmpStr: .asciiz "CMP"
	bxStr: .asciiz "BX"
	bStr: .asciiz "B"
	balStr: .asciiz "BAL"
	unkStr: .asciiz "???"

	eqStr: .asciiz "EQ "
	geStr: .asciiz "GE "
	gtStr: .asciiz "GT "
	blankStr: .asciiz " "
	rStr: .asciiz "R"
	sStr: .asciiz "S "

	arStr: .asciiz " AR "
	lrStr: .asciiz " LR "
	llStr: .asciiz " LL "
	rorStr: .asciiz " ROR "
	
	sepStr: .asciiz ", "
	nlStr: .asciiz "\n"

.text

#-----------
# parseARM
#
# ARGS: a0=ARM instruction
#
# t8 = (0=data processing)/(1=branch)/(2=bx)
# s0 = instruction
#
#-----------
parseARM:
	move	$s0 $a0

	#ID Branches
	li	$t8 2

	sll	$t0 $a0 4
	srl	$t0 $t0 28

	#B
	la	$t9 bStr
	li	$t1 0x0A
	beq	$t0 $t1 parseARM_pOp
	
	#BAL
	la	$t9 balStr
	li	$t1 0x0A
	beq	$t0 $t1 parseARM_pOp

	#Isolate and identify DataProc OpCodes
	sll	$t0 $a0 7
	srl	$t0 $t0 28	#Isolate opCode

	li	$t8 0
	
	#AND
	la	$t9 andStr
	li	$t1 0x00
	beq	$t0 $t1 parseARM_pOp
	
	#OR
	la	$t9 orStr
	li	$t1 0x0C
	beq	$t0 $t1 parseARM_pOp

	#ADD
	la	$t9 addStr
	li	$t1 0x04
	beq	$t0 $t1 parseARM_pOp

	#SUB
	la	$t9 subStr
	li	$t1 0x02
	beq	$t0 $t1 parseARM_pOp

	#MOV
	la	$t9 movStr
	li	$t1 0x0D
	beq	$t0 $t1 parseARM_pOp

	#CMP
	la	$t9 cmpStr
	li	$t1 0x0A
	beq	$t0 $t1 parseARM_pOp

	li	$t8 1

	#BX
	la	$t9 bxStr
	li	$t1 0x09
	beq	$t0 $t1 parseARM_pOp

	li	$t8 0
	la	$t9 unkStr

	parseARM_pOp:
		move	$a0 $t9
		li	$v0 4
		syscall

# ID the condition
	srl	$t0 $s0 28

	#Always
	la	$t9 blankStr
	li	$t1 0x0E
	beq	$t0 $t1 parseARM_pCond

	#Equals
	la	$t9 eqStr
	li	$t1 0x00
	beq	$t0 $t1 parseARM_pCond

	#GreaterThan
	la	$t9 gtStr
	li	$t1 0x0C
	beq	$t0 $t1 parseARM_pCond

	#GreaterThan
	la	$t9 geStr
	li	$t1 0x0A
	beq	$t0 $t1 parseARM_pCond

	la	$t9 unkStr

	parseARM_pCond:
		move	$a0 $t9
		li	$v0 4
		syscall
	
	beqz	$t8 parseARM_DataProc
	li	$t0 2
	beq	$t8 $t0 parseARM_Branch
	j	parseARM_BX

parseARM_DataProc:
	lui	$t0 0x0010
	and	$t0 $t0 $s0	#mask out sign bit
	beqz	$t0 padp_noStat
	
	la	$a0 sStr
	li	$v0 4
	syscall	
	
	padp_noStat:

	#If CMP, don't print Dest
	sll	$t0 $s0 7
	srl	$t0 $t0 28
	li	$t1 0x0A
	beq	$t0 $t1 padp_noDest
	#Otherwise go ahead

	sll	$t0 $s0 16
	srl	$t0 $t0 28	#isolate Destination
	
	la	$a0 rStr
	li	$v0 4
	syscall

	move	$a0 $t0
	li	$v0 1
	syscall			#print register

	la	$a0 sepStr
	li	$v0 4
	syscall			#space for next
	
	padp_noDest:

	#If MOV, don't print Operand 1
	sll	$t0 $s0 7
	srl	$t0 $t0 28
	li	$t1 0x0D
	beq	$t0 $t1 padp_noOp1
	#Otherwise go ahead

	sll	$t0 $s0 12
	srl	$t0 $t0 28	#isolate operand 1
	
	la	$a0 rStr
	li	$v0 4
	syscall

	move	$a0 $t0
	li	$v0 1
	syscall			#print register

	la	$a0 sepStr
	li	$v0 4
	syscall			#space for next

	padp_noOp1:
	lui	$t0 0x0200	#mask out immediate indicator
	and	$t0 $t0 $s0
	
	bnez	$t0 padp_imm
	j	padp_reg


	padp_imm:
		andi	$t0 $s0 0x00FF	#immediate value
		srl	$t1 $s0 8	
		andi	$t1 $t1 0x0F	#Rotation value
		sll	$t1 $t1 1	#double it
		
		ror	$a0 $t0 $t1
		li	$v0 1
		syscall
		j	parseARM_done

	padp_reg:
		andi	$t0 $s0 0x0F	#mask out last register
		la	$a0 rStr
		li	$v0 4
		syscall

		move	$a0 $t0
		li	$v0 1
		syscall			#print register
		
		sll	$t0 $s0 25	#isolate shift type
		srl	$t0 $t0 30

		li	$t1 0x00	#logical left
		la	$a0 llStr
		beq	$t0 $t1 padp_shift

		li	$t1 0x01	#logical right
		la	$a0 lrStr
		beq	$t0 $t1 padp_shift

		li	$t1 0x02	#arithmetic right
		la	$a0 arStr
		beq	$t0 $t1 padp_shift

		li	$t1 0x03	#rotate right
		la	$a0 rorStr
		beq	$t0 $t1 padp_shift

		la	$a0 unkStr	

	padp_shift:
		#Don't print if we're shifting 0
		andi	$t0 $s0 0x0010	#isolate reg/imm
		bnez	$t0 padp_pShift	#always print if register
		sll	$t0 $s0 20	#isolate shift amount
		srl	$t0 $t0 27
		beqz	$t0 parseARM_done

	padp_pShift:
		#Now we definitely want to print
		li	$v0 4		#print rotation type
		syscall

		andi	$t0 $s0 0x0010	#isolate reg/imm
		bnez	$t0 padp_shiftReg

	padp_shiftVal:
		sll	$t0 $s0 20	#isolate shift amount
		srl	$a0 $t0 27

		li	$v0 1
		syscall

		j	parseARM_done

	padp_shiftReg:
		la	$a0 rStr
		li	$v0 4
		syscall			#print register 'R'

		sll	$t0 $s0 20	#isolate shift register
		srl	$a0 $t0 28

		li	$v0 1
		syscall			#print register value

		j	parseARM_done

parseARM_Branch:
	li	$t0 0x00FFFFFF		#mask lower 24 bits
	and	$t0 $t0 $s0		#branch offset

	sll	$t0 $t0 8
	sra	$a0 $t0 6		#sign extend, *4

	li	$v0 1
	syscall				#print the branch offset

	j	parseARM_done
parseARM_BX:
	la	$a0 rStr
	li	$v0 4
	syscall			#print register 'R'

	andi	$a0 $s0 0x0F	#isolate the register
	li	$v0 1
	syscall

	j	parseARM_done
parseARM_done:
	la	$a0 nlStr
	li	$v0 4
	syscall

	jr	$ra

######################### Student Code Begins Here #########################























































# Assignment:           5
# Due Date:             December, 07 2015
# Name:                 Ismail Mare
# Unix ID:              imare
# StudentID:			1388973
# Lecture Section:      B1
# Instructor:           Ionis Nikolaidis
# Lab Section:          D06 (Thursday 1700 - 2150)
# Teaching Assistant:   Parisa Mohebbi
#---------------------------------------------------------------
# $t0: Used to count the values of 
# $t1: Used to hold the current mips line
# $t2: Holds the place in memory we store the arm code
# $t3: Holds the opcode
# $t4:
# $t5
# $t6
# $t7
# $s1: The opcode
# $s2: The instruction 
# $s3: The Source Operand
# $s4: The Target Operand 
# $s5: The Destination Operand
# $s6: The Register Format
# $s7: The Immidiate Format
#---------------------------------------------------------------


MIPStoARM:
	

	li $t0 0  #The counter for the amount of arm instructions generated
      # Reading pointer to memory containing a MIPS function
	la $t2 code # Holds the address of the space to hold the arm instruc0on
	condition_check:

		li $s0 0
		li $s1 0
		li $s2 0
		li $s3 0
		li $s4 0
		li $s5 0
		li $s6 0
		li $s7 0
		#lw $t1 0($a0) # Reading in the first four bytes. One mips instruction
		
		lw $t1 0($a0)
		add $a0 $a0 4
		beq $t1 0xffffffff end

		srl $t4 $t1 26  	 #Shifting to get OPcode
		li $s1 0xE
		bne $t4 $zero Itype
		beq $t4 $zero Rtype

		j condition_check

		Rtype:
			srl $t4 $t1 6
			ori $s2 $t4 0x1F	# Shift amt 
			srl $t4 $t4 5
			ori $s5 $t4  0xF	# The destination operand
			srl $t4 $t4 5
			ori $s4 $t4  0xF	# The Target operand
			srl $t4 $t4 5
			ori $s3 $t4  0xF	# The source operand
			srl $t4 $t4 5
			ori $t4 $t1 0x3F
		   	  			      #Reading function code 0-6
			beq $t4 0x22 sub_ #Function Rtype
			beq $t4 0x25 or_ #Function Rtype
			beq $t4 0x24 and_  #Function Rtype
			beq $t4 0x20 add_ #Function Rtype
			beq $t4 0x00 sll_ #Function Rtype
			beq $t4 0x04 sllv_ #Function Rtype
			beq $t4 0x03 srl_ #Function Rtype
			beq $t4 0x06 srlv_ #Function Rtype
			beq $t4 0x03 sra_  #Function Rtype
			beq $t4 0x20 add_ #Function Rtype
			j condition_check

		Itype:
			ori $s2 $t1 0xFF    # The instruction value
			srl $t4 $t1 16
			ori $s3 $t4  0xF	# The source operand
			srl $t4 $t4 5		
			ori $s4 $t4 0xF	# The target operand
			srl $t4 $t4 5
			

			srl $t4 $t1 26		#Shifting to get OPcode
			beq $t4 0x8 addi_ #OPcode Itype
			beq $t4 0xC andi_ #OPcode Itype
			beq $t4 0xd ori_ #OPcode Itype
			j condition_check



########################################################
#RTYPE
	
		sll_:
			li $s0 0xd
			la	$a0 op1
			li	$v0 4
			syscall
			li $t8 0x0

			j R_shift

		sllv:
			li $s0 0xd
			la	$a0 op1
			li	$v0 4
			syscall
			li $t8 0x0
			j R_shift

		srl:
			li $s0 0xd
			la	$a0 op1
			li	$v0 4
			syscall
			li $t8 0x1
			j R_shift

		srlv:
			li $s0 0xd
			la	$a0 op1
			li	$v0 4
			syscall
			li $t8 0x1
			j R_shift

		sra:
			li $s0 0xd
			la	$a0 op1
			li	$v0 4
			syscall
			li $t8 0x2
			j R_shift


		add_:
			li $s0 0x4
			la	$a0 op1
			li	$v0 4
			syscall

			j R_continue
		

		and_:

			li $s0 0x0
			la	$a0 op3
			li	$v0 4
			syscall

			j R_continue
			
		sub_:
			li $s0 0x2
			la	$a0 op7
			li	$v0 4
			syscall
			j R_continue
			

		or_:
			li $s0 0xC
			la	$a0 op5
			li	$v0 4
			syscall	

			j R_continue

			
########################################################
#ITYPE

		andi_:
			bltz $s2 sub_
			li $s0 0x0
			
			la	$a0 op4
			li	$v0 4
			syscall

			j I_continue	
	
			
			
		ori_:
			li $s0 0xC
			
			la	$a0 op6
			li	$v0 4
			syscall	
	
			j I_continue

		addi_:
			li $s0 0x4

			la	$a0 op2
			li	$v0 4
			syscall

			j I_continue
			

		R_continue:
			sll $s1 $s1 11
			or $s1 $s0 $s1
			sll $s1 $s1 5
			or $s1 $s1 $s3
			sll $s1 $s1 4
			or $s1 $s1 $s4
			sll $s1 $s1 12
			or $s1 $s1 $s5
			or $s6 $s1 $s6

			sw $s6 0(t2)
			add $t2 $t1 4
			j condition_check

		I_continue:
			sll $s1 $s1 11
			or $s1 $s0 $s1
			ori $s1 $s1 0x10
			sll $s1 $s1 5
			or $s1 $s1 $s3
			sll $s1 $s1 4
			or $s1 $s1 $s4
			sll $s1 $s1 12
			or $s1 $s1 $s2
			or $s7 $s7 $s1

			sw $s6 0(t2)
			add $t2 $t2 4
			j condition_check


		R_shift:
			beq $s3 $zero R_imm

			sll $s1 $s1 11
			or $s1 $s0 $s1
			sll $s1 $s1 5
			or $s1 $s1 $s4
			sll $s1 $s1 4
			or $s1 $s1 $s5
			sll $s1 $s1 4
			or $s1 $s1 $s3
			sll $s1 $s1 3
			or $s1 $s1 $t8
			sll $s1 $s1 1
			or $s1 $s1 0x1	   ##Shift amount and direction
 
			sll $s1 $s1 4
			or $s1 $s1 $s5
			or $s6 $s1 $s6

			sw $s6 0(t2)
			add $t2 $t1 4
			j condition_check



		R_imm:
			sll $s1 $s1 11
			or $s1 $s0 $s1
			sll $s1 $s1 5
			or $s1 $s1 $s3
			sll $s1 $s1 4
			or $s1 $s1 $s5
			sll $s1 $s1 8
			sll $s2 $s2 2
			or $s2 $s2 $t8
			sll $s2 $s2 1	   ##Shift amount and direction
			or $s1 $s1 $s2
			or $s1 $s1 $s5
			or $s6 $s1 $s6

			sw $s6 0(t2)
			add $t2 $t1 4
			j condition_check


   	end:
		move $v0 $t0
		move $v1 $t2
		jr $ra


