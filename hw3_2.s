
.data	#data section of the program
	#message section of data
	prompt1:  		.asciiz "Enter a input line: "
	prompt2:		.asciiz	"Enter a pattern to search for: "
	msg:			.asciiz	"\n"
	fail_msg:		.asciiz "Line contains whitespace characters only!\n"
	results_msg:	.asciiz "Results:\n"
	countw_msg:		.asciiz "# of whitespace characters: "
	countnw_msg:	.asciiz	"# of non-whitespace characters: "
	words_msg:		.asciiz	"# of words: "
	yes_msg:		.asciiz	"The user pattern was found within the input line"
	no_msg:			.asciiz	"The user pattern was NOT found within the input line"
	#integer output section of data
	numWhite:		.word	0
	numNonWhite:	.word	0
	numWords:		.word	0
	#buffering
	buffer1:   		.space 100
	buffer2:	    .space 11
	
	
	.text # Text section of program
	.globl main
	
	main: 	#main program section
		#setting the main data values to stored addresses
		lw		$s0, numWhite
		lw		$s1, numNonWhite
		lw		$s2, numWords
		
		# Prompt user for a text string
		li   $v0, 4         # command for print string
		la   $a0, prompt1   # remember to load start addr.
		syscall             # of prompt string

		li   $v0, 8 		# inputing a string "8"
		la	 $a0, buffer1
		move $s4, $a0
		syscall   
		
		#check to see if the text string only has whitespace characters
		jal	check_onlywhites
		
		# Prompt user for a pattern string
		li   $v0, 4         # command for print string
		la   $a0, prompt2   # remember to load start addr.
		syscall             # of prompt string

		li   $v0, 8 		# inputing a string "8"
		la	 $a0, buffer2
		move $s5, $a0
		syscall   
		
		#counting the characters (whites or non-whties)
		move $t1, $s4	
		lb $t0, 0($t1)	
		char_count: beq $t0, 0, endccount
			beq	$t0, 32, addW	#checking for 'space' characters
			beq	$t0, 9, addW	#checking for 'tab' characters
			beq	$t0, 10, addW	#checking for 'new-line' characters
			addi $s1, $s1, 1	#incremanting # of non-white values
			add $t1, $t1, 1
			lb $t0, 0($t1)
			j	char_count		#loop back to beginning
			addW:
			addi $s0, $s0, 1	#incremanting # of white characters
			add $t1, $t1, 1
			lb $t0, 0($t1)
			b	char_count
		endccount:
		
		#print out first set of data
		li $v0, 4    
		la $a0, results_msg  #prints the results message
		syscall
		
		li $v0, 4    
		la $a0, countw_msg  #prints the white character message
		syscall
		move	$a0, $s0
		li		$v0, 1		#prints the number of white characters
		syscall
		li $v0, 4    
		la $a0, msg  		#prints a new-line
		syscall
		
		li $v0, 4    
		la $a0, countnw_msg #prints the non-white character message
		syscall
		move	$a0, $s1
		li		$v0, 1		#prints the number of non-white characters
		syscall
		li $v0, 4    
		la $a0, msg  		#prints a new-line
		syscall
		
		#counting the words
		move $t1, $s4
		lb $t0, 0($t1)
		li $t2, 0		#the boolean-style variable
		word_count: beq $t0, 0, endwcount
			beq	$t0, 32, non_word
			beq	$t0, 9, non_word
			beq	$t0, 10, non_word
			j	words	#go to words to make boolean statment change to 1
			non_word: 
			bne	$t2, 0, adds	#checking to see if boolean statement is 1, which means its a new word
			add $t1, $t1, 1
			lb $t0, 0($t1)
			j	word_count	#go back to the beginning of the loop
			adds:	
			li $t2, 0	#change the boolean statment back to 0 after the word has been counted
			addi	$s2, $s2, 1	#increment the # of words
			add $t1, $t1, 1
			lb $t0, 0($t1)
			j	word_count	#go back to the beginning of the loop
			words:
			li $t2, 1
			add $t1, $t1, 1
			lb $t0, 0($t1)
			b	word_count
		endwcount:
		
		li $v0, 4    
		la $a0, words_msg 	#prints the words message
		syscall
		move	$a0, $s2
		li		$v0, 1
		syscall
		li $v0, 4    
		la $a0, msg  		#prints the # of words
		syscall
		
		#searching for the input in the given text
		move $t1, $s4	#storing the text into a temp address
		lb $t0, 0($t1)	#loading the first chracter into a temp address
		li $t5, 0		#the boolean-style variable
		move $t2, $s5	#storing the search into a temp address
		lb $t3, 0($t2)	#loading the first chracter into a temp address
		search_input: beq $t0, 0, endsearch
			bne $t0, $t3, no_equals #if the first charactrs don't equal each other the next characters is tested
			li $t5, 1	#changes the boolean statment 
			move $t4, $t1 #stores the text so far into a temp address
			#tests to see if the entire search string is found in the text
			word_equals: beq $t3, 0, endsearch 
				beq $t3, 10, endsearch	#also checks to see if there is a new-line character in the search
				bne	$t0, $t3, endword
				add $t2, $t2, 1
				lb $t3, 0($t2)
				add $t4, $t4, 1
				lb $t0, 0($t4)
				b	word_equals
			endword:
			li $t5, 0 #if it fails then the boolean is changed back
			move $t2, $s5	#the search is then placed back at the first character
			lb $t3, 0($t2)
			no_equals:
			add $t1, $t1, 1
			lb $t0, 0($t1)
			b	search_input
		endsearch:
		
		#to determine if the search found was successful or not
		beq	$t5, 0, no
		
		yes:
		li $v0, 4    
		la $a0, yes_msg #prints the yes message
		syscall
		li   $v0, 10	#ends the program
		syscall
		no:
		li $v0, 4    
		la $a0, no_msg	#prints the no message 
		syscall
		li   $v0, 10	#ends the program
		syscall
	
	#function to check for only white characters
	check_onlywhites:
		move $t1, $s4	#storing the text into a temp address
		lb $t0, 0($t1)	#loading the first chracter into a temp address
		li $t2, 0 		#the boolean-style variable
		check: beq $t0, 0, endcheck	#checking to see if the temp address is NULL(0)
			beq	$t0, 32, true
			beq	$t0, 9, true
			beq	$t0, 10, true
			false:
				li $t2, 0
				j endcheck
			true:
				li $t2, 1
			#going through the text one character at a time
			add $t1, $t1, 1
			lb $t0, 0($t1)
			b	check #looping back to the beginning
		endcheck:
		#by determineing whether or not the boolean address is 0(doesn't have only whites) or 1(has only whites)
		beq $t2, 0, continue
		#if it is false prints out a fail message and exits the program
		li $v0, 4    
		la $a0, fail_msg 
		syscall
		li   $v0, 10
		syscall
		continue:
		jr	$ra
