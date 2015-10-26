#Parsing and outputting user-inputted strings in MIPS assembly language (MAL)
#Authors: Noah Tebben and Ylonka Machado
#Inputs: A user-inputted integer
#Outputs: 
	#1. Number of zeros in right half of binary equivalent of integer inputted
	#2. Number of ones in left half of binary equivalent of integer inputted
	#3. The highest power of 4 that evenly divides the integer 
	#4. Smallest decimal digit in inputted integer
#Lab Section: 1 (Ylonka) + 2 (Noah)
#Revision History: 10/24 - File created and coded
#10/25 - Program checked and formatted

.data
	msg: .asciiz "Please enter a positive integer: "
	msg1: .asciiz "# of 0s in the right half = "
	msg2: .asciiz "# of 1s in the left half =  "
	msg3: .asciiz "Biggest power of 4 = "
	msg4: .asciiz "Smallest decimal digit = "
	br: .asciiz "\n"
	.text
	.globl main

	#getting user input
	main:
		li $v0, 4
		la $a0, msg
		syscall
		li $v0, 0

	#dividing user input into parts
	loop_numbers:	
		#if $v0 != 0, divide_num
		bne $v0, 0, divide_num
		li $v0, 5
		syscall
		j loop_numbers

	divide_num:
		move $t0, $v0
		move $t8, $t0
		#right half
		li $t2, 0
		#left half  
		li $t1, 0 
		#count
		li $t4, 0
		#const
		li $t9, 2
		li $v0, 0

	#finding # of 0s in right
	rightside:
		#check if 0, then first_left
		beq $t8, 0, first_left
		div $t8, $t9
		#integer quotient
		mflo $t8
		#remainder
		mfhi $t3
		#if $t4 >= 16
		bge $t4, 16, rightend
		#if $t3 != 0
		bne $t3, 0, rightend
		#increment num of 0s
		add $t2, $t2, 1

	rightend:
		add $t4, $t4, 1
		j rightside

	first_left:
		move $t8, $t0
		#if $t4 < 16
		blt $t4, 16, biggest_4_power
		li $t6, 0
	
	#finding # of 1s in left
	leftside:
		#check if $t4 == $t6, then biggest_4_power	
		beq $t4, $t6, biggest_4_power
		div $t8, $t9
		#integer quotient
		mflo $t8
		#remainder
		mfhi $t3
		#if $t6 < 16
		blt $t6, 16, last_left
		#$t3 != 1
		bne $t3, 1, last_left
		#increment num of 1s
		add $t1, $t1, 1
		
	last_left:
		add $t6, $t6, 1
		j leftside

	#power of 4
	biggest_4_power:
		move $t8, $t0
		#count
		li $t3, 0
		#remainder
		li $t4, 0 
		#constant
		li $t9, 4
		#4 to the power of
		li $t7, 4
	
	#finding highest power of 4
	four_power:	
		blt $t8, 4, smallest
		div $t8, $t7
		mfhi $t4
		#$t4 != 0
		bne $t4, 0, smallest
		mult $t7, $t9
		mflo $t7
		add $t3, $t3, 1
		j four_power
	
	smallest:
		move $t8, $t0
		li $t4, 9 
		#constant
		li $t9, 10

	#finding smallest digit
	dig_in_int:
		div $t8, $t9
		#integer quotient
		mflo $t8
		#remainder
		mfhi $t5
		#$t5 != 0
		bne $t5, 0, digskip
		#check if $t8 == 0
		beq $t8, 0, output

	digskip:
		blt $t4, $t5, dig_in_int
		move $t4, $t5
		j dig_in_int

	output:
		#number of 0s in right
		li $v0, 4
		la $a0, msg1
		syscall
		li $v0, 1
		move $a0, $t2
		syscall
		li $v0, 4
		la $a0, br
		syscall
		li $v0, 0

		#number of 1s in left
		li $v0, 4
		la $a0, msg2
		syscall
		li $v0, 1
		move $a0, $t1
		syscall
		li $v0, 4
		la $a0, br
		syscall
		li $v0, 0

		#highest power of 4
		li $v0, 4
		la $a0, msg3
		syscall
		li $v0, 1
		move $a0, $t3
		syscall
		li $v0, 4
		la $a0, br
		syscall
		li $v0, 0

		#smallest digit
		li $v0, 4
		la $a0, msg4
		syscall
		li $v0, 1
		move $a0, $t4
		syscall
		li $v0, 4
		la $a0, br
		syscall
		li $v0, 0

	#exit
	exit:
		li $v0, 10 # load call 10 = exit
		syscall # To the batmobile…
