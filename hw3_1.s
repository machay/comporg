#Ylonka Machado
#Noah Tebben

.data
	msg: .asciiz "Enter an integer: "
	msg1: .asciiz "# of 0s in the right half = "
	msg2: .asciiz "# of 1s in the left half =  "
	msg3: .asciiz "Biggest power of 4 = "
	msg4: .asciiz "Smallest decimal digit = "
	linebreak: .asciiz "\n"
	.text

	#getting user input
	main:
		li $v0, 4
		la $a0, msg
		syscall
		li $v0, 0

	#dividing user input into parts
	loop_numbers:	
		bne $v0, 0, divide_num
		li $v0, 5
		syscall
		j loop_numbers

	divide_num:
		move $t0, $v0
		move $t9, $t0
		#right half
		li $t2, 0
		#left half  
		li $t1, 0 
		#count
		li $t4, 0
		#const
		li $t8, 2

	#finding # of 0s in right
	rightside:	
		beq $t9, 0, first_left
		div $t9, $t8
		mflo $t9
		mfhi $t3
		bge $t4, 16, rightend
		bne $t3, 0, rightend
		add $t2, $t2, 1

	rightend:
		add $t4, $t4, 1
		j rightside

	first_left:
		move $t9, $t0
		blt $t4, 16, biggest_4_power
		li $t6, 0

	#finding # of 1s in left
	leftside:	
		beq $t4, $t6, biggest_4_power
		div $t9, $t8
		mflo $t9
		mfhi $t3
		blt $t6, 16, last_left
		bne $t3, 1, last_left
		add $t1, $t1, 1
		last_left:
		add $t6, $t6, 1
		j leftside
	
	#power of 4
	biggest_4_power:
		move $t9, $t0
		#count
		li $t3, 0
		#remainder
		li $t4, 0 
		#constant
		li $t8, 4
		#4 to the power of
		li $t7, 4
	
	#finding highest power of 4
	four_power:	
		blt $t9, 4, smallest #if 4^0
		div $t9, $t7
		mfhi $t4
		bne $t4, 0, smallest
		mult $t7, $t8
		mflo $t7
		add $t3, $t3, 1
		j four_power
	
	smallest:
		move $t9, $t0
		li $t4, 9 
		#constant
		li $t8, 10

	#finding smallest digit
	dig_in_int:
		div $t9, $t8
		mfhi $t5
		mflo $t9
		bne $t5, 0, digskip
		beq $t9, 0, output

	digskip:
		blt $t4, $t5, dig_in_int
		move $t4, $t5
		j dig_in_int

	#printing output
	output:
	#number of 0s in right
		li $v0, 4
		la $a0, msg1
		syscall
		li $v0, 1
		move $a0, $t2
		syscall
		li $v0, 4
		la $a0, linebreak
		syscall

	#number of 1s in left
		li $v0, 4
		la $a0, msg2
		syscall
		li $v0, 1
		move $a0, $t1
		syscall
		li $v0, 4
		la $a0, linebreak
		syscall

	#highest power of 4
		li $v0, 4
		la $a0, msg3
		syscall
		li $v0, 1
		move $a0, $t3
		syscall
		li $v0, 4
		la $a0, linebreak
		syscall

	#smallest digit
		li $v0, 4
		la $a0, msg4
		syscall
		li $v0, 1
		move $a0, $t4
		syscall
		li $v0, 4
		la $a0, linebreak
		syscall

	#exit
	exit:
		li $v0, 10 # load call 10 = exit
		syscall # To the batmobile…
