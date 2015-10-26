
#Parsing and outputting user-inputted strings in MIPS assembly language (MAL)
#Authors: Noah Tebben and Ylonka Machado
#Inputs: A user-inputted string of any length and a subsequent substring to search for within the first string
#Outputs: A results table with character tallies (white space and regular characters) and a word count as well
#as a success or failure message stating whether the substring was found or not
#Lab Section: 1 (Ylonka) + 2 (Noah)
#Revision History: 10/24 - File created and coded
#10/25 - Program checked and formatted


	.data	#Data section to hold all static text outputs
	inputline: .asciiz "Enter a string: "
	allWspc: .asciiz "Line only contains white space characters, program aborted.\n"
	substring: .asciiz	"Enter a substring to search for: "
	results: .asciiz "Results:\n"
	numWspc: .asciiz "# of white space characters: "
	numChrs: .asciiz	"# of regular characters: "
	numWrds: .asciiz	"# of words: "
	success: .asciiz	"The substring was found within the input line."
	failure: .asciiz	"The substring was not found within the input line."
	newline: .asciiz	"\n"
	#Spacing constants
	spacing1: .space 100
	spacing2: .space 10
	#Character and word tallies for text output
	numWhite: .word	0
	numChars: .word	0
	numWords: .word	0
	
	.text
	.globl main
	
	main: 	#MAIN
		#Initialize s0-s2 with our tallies
		lw $s0, numWhite
		lw $s1, numChars
		lw $s2, numWords
		
		#Print input prompt
		li $v0, 4 #4 = print string
		la $a0, inputline
		syscall
		#Take in user string
		li $v0, 8 		#8 = input string
		la $a0, spacing1
		move $s3, $a0
		syscall   
		#Check for 'only white space' case, tried to do this in main but MIPS fought every step of the way
		jal	checkAllWspc
		#Print substring prompt
		li $v0, 4         
		la $a0, substring 
		syscall  
		li $v0, 8
		la $a0, spacing2
		move $s4, $a0
		syscall   
		#Count all characters
		move $t1, $s3	
		lb $t0, 0($t1)	

		char_count: 
			beq $t0, 0, printResults
			beq	$t0, 9, addWspc	#Check for tab character
			beq	$t0, 10, addWspc	#Check for newline character
			beq	$t0, 32, addWspc	#Check for space character
			addi $s1, $s1, 1	#Otherwise, tally for regular character
			add $t1, $t1, 1
			lb $t0, 0($t1)
			j char_count		#Do it again!
			
		addWspc:
			addi $s0, $s0, 1	#Tally for white space character
			add $t1, $t1, 1
			lb $t0, 0($t1)
			b char_count 	#Back to the count

		printResults:
			#Print out the results messages
			li $v0, 4    
			la $a0, results
			syscall
			li $v0, 4    
			la $a0, numWspc
			syscall
			move $a0, $s0
			li $v0, 1	#Print the tally of white space chars
			syscall
			li $v0, 4    
			la $a0, newline #Newline
			syscall
			li $v0, 4    
			la $a0, numChrs #Print regular char message
			syscall
			move $a0, $s1
			li $v0, 1	#Print regular char tally
			syscall
			li $v0, 4    
			la $a0, newline
			syscall
		
		#Count the words
		move $t1, $s3 #Move the string into new temp
		lb $t0, 0($t1)
		li $t2, 0	#Set up a boolean for the wordCount loop

		wordCount: 
			beq $t0, 0, endCount
			beq	$t0, 9, whiteSpace
			beq	$t0, 10, whiteSpace
			beq	$t0, 32, whiteSpace
			j endWord	#Go to flag function
		
		whiteSpace: 
			bne	$t2, 0, newWord	#If we've flagged the end of a word through a white space char, tally a word!
			add $t1, $t1, 1
			lb $t0, 0($t1)
			j wordCount	#Back to parsing
		
		newWord:	
			li $t2, 0	#Reset our new word boolean
			addi $s2, $s2, 1	#Increment our word tally
			add $t1, $t1, 1
			lb $t0, 0($t1)
			j wordCount	#Back to parsing
		
		endWord: #Change the boolean to flag that we've just read a whitespace after a character (end of word)
			li $t2, 1
			add $t1, $t1, 1
			lb $t0, 0($t1)
			b wordCount

		endCount:
			li $v0, 4    
			la $a0, numWrds #Print the numWrds message
			syscall
			move $a0, $s2 #Print the words tally
			li $v0, 1
			syscall
			li $v0, 4    
			la $a0, newline  #Newline
			syscall
		
		#Substring Search
		move $t1, $s3	#Store the user string in a temp (t1)
		lb $t0, 0($t1)	#Load the first character into t0
		li $t5, 0		#Initialize a search boolean
		move $t2, $s4	#Store the substring in another temp
		lb $t3, 0($t2)	#Load the first substring char into yet another temp

		findString: 
			beq $t0, 0, foundSubstring 
			bne $t0, $t3, incrementFind #Check all characters in the substring for a first match
			li $t5, 1	#Change the boolean back
			move $t4, $t1 #Stores the compiled search in progress in....another temp
		#Check the search to see if it matches the substring
		stringPasses: 
			beq $t3, 0, foundSubstring 
			beq $t3, 10, foundSubstring 
			bne	$t0, $t3, endString
			add $t2, $t2, 1
			lb $t3, 0($t2)
			add $t4, $t4, 1
			lb $t0, 0($t4)
			b stringPasses
			
		endString:
			li $t5, 0 
			move $t2, $s4	
			lb $t3, 0($t2)
			
		incrementFind:
			add $t1, $t1, 1
			lb $t0, 0($t1)
			b findString

		foundSubstring:
			beq	$t5, 0, fail #Fails if our boolean has deemed it so
		
		succ:
			li $v0, 4    
			la $a0, success #Print the success message and exit
			syscall
			li $v0, 10
			syscall

		fail:
			li $v0, 4    
			la $a0, failure	#Print the failure message and exit
			syscall
			li   $v0, 10
			syscall
	
	#Check if only all white space characters
	checkAllWspc:
		move $t1, $s3	#Store text into second temp address
		lb $t0, 0($t1)	#Load the first character into first temp address
		li $t2, 0 		#Initialize boolean 
		check: 
			beq $t0, 0, endcheck	#Check if first character is 0 and break if true
			beq	$t0, 9, true
			beq	$t0, 10, true
			beq	$t0, 32, true #If t0 is any white space character, branch to true and set boolean to 1
			false:
				li $t2, 0
				j endcheck
			true:
				li $t2, 1
			#Iterate through rest of characters in t1 and do same check
			add $t1, $t1, 1
			lb $t0, 0($t1)
			b check #Loop back up 
		endcheck:
		#If t2 is still 0, continue on with the program
		beq $t2, 0, continue
		#If t2 is now 1, print the fail message and exit
		li $v0, 4    
		la $a0, allWspc 
		syscall
		li $v0, 10 #10 = exit
		syscall
		continue:
		jr $ra
