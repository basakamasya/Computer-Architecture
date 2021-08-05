#Basak Amasya
.data
input: .asciiz "C:\\Users\\Lenovo\\Documents\\SABANCI\\CS401\\input.txt"
output_insertionsort: .asciiz "C:\\Users\\Lenovo\\Documents\\SABANCI\\CS401\\insertion_sort_out.txt"
output_selectionsort: .asciiz "C:\\Users\\Lenovo\\Documents\\SABANCI\\CS401\\selection_sort_out.txt"
buffer: .space 1024
output_buffer_insertion: .space 1024
output_buffer_selection: .space 1024
array_buffer: .space 1024
address: .space 1024

.text

main:
	# Open Input File
	la $a0, input # getting the file name   
	li $a1, 0 # 0 for read flag       
	li $a2, 0  # ignore mode
	li $v0, 13 # 13 for the code of open_file syscall
	syscall
	move $s0,$v0 # save file descriptor to s0
	
	li $v0,14 # 14 for the code of read_file syscall
	move $a0, $s0 # get the file descriiptor
	la $a1, buffer # assuming file won't be bigger than 1024 bytes
	la $a2, 1024
	syscall
	
	la $s3, array_buffer # save array buffer
	la $s4, buffer # save file buffer
	
	#to be commented out
	#li $v0, 4 #print the contents of the file
	#la $a0, buffer
	#syscall
	
	move $t0, $zero # starting index to the buffer
	move $s2, $zero # number of lines in the file
	li $s5, 10     # ASCII newline
	jal CountLines
	
	add $s1, $zero, $zero # 0 for insertion sort, 1 for selection sort
	
	jal PrepareArray
		
	# Close Input File
	move $a0,$s0
	li $v0,16
	syscall
		
CountLines:	
	lb $t1, buffer($t0)  # load the current byte from the buffer
	seq $t3, $s5, $t1 # t3 = 1 if newline is read, else 0
	add $s2, $s2, $t3
	addi $t0, $t0, 1 # go to the next byte
	bne $t1, 0, CountLines # until the end of file, countlines
	
	#to be commented out
	#li $v0, 1 #print out the number of the lines
	#la $a0, ($s2)
	#syscall
	
PrepareArray:
	#la $s3, array_buffer # save array buffer
	#la $s4, buffer # save file buffer
	move $t1,$zero # counting
	move $t2,$zero # keeping the word itself
	move $t3,$zero # keeping the address
	jal MakeArray
	jr $ra	
	
MakeArray:	
	sw $s3, address($t3)
	jal GetWordFromFile
	addi $t2,$t2,12 # max 10 characters, 12 to be word alligned
	addi $t3,$t3,4 # adress is 1 byte, 1 integer
	la $s3, array_buffer # take the pointer to the beginning
	add $s3,$s3,$t2 # go to the next word's place
	addi $t1,$t1,1 # counting each word
	bne $t1, $s2, MakeArray
	beq $s1, $zero, InsertionSort
	jal SelectionSort
	jr $ra
	
# Insertion Sort Algorithm
# for (j=2; j<=n; j=j+1)
	# num = A[j];
    	# i = j-1;
    	# while (i>0 and A[i]>num) {
        	# A[i+1] = A[i];
        	# i=i-1;
     	 #}
    	#A[i+1] = num; 
	
InsertionSort:
	la $s3, array_buffer 
	la $s4, address
	addi $t0, $zero, 1 # start from first index j = 1
	li $s5, 0 # for recursion
	OuterLoop:
		sll $t1, $t0, 2 	# 4*j
		la $s4, address	
		add $s4, $s4, $t1
		lw $t2, 0($s4)
		lb  $s6, ($t2) # s6 load the first byte of the address s6 = num = A[j]
		subi $t3, $t0, 1 # i = j-1; t3 = i
		subi $t4, $zero, 1 
		slt $t4, $t4, $t3 # t4 = 1 if -1 < i
		sll $t6, $t3, 2 	# 4*i
		la $s4, address
		add $s4, $s4, $t6
		lw $t9, 0($s4)		
		lb  $s7, ($t9) # s6 load the first byte of the address s7 = A[i]
		slt $t5, $s6, $s7 # t5 = 1 if A[i]>num
		and $t4, $t4, $t5 # i>0 and A[i]>num
		
		sw $t9, 4($sp) # save for recursion
		sw $t2, 8($sp)
		sw $s6, 12($sp)
		sw $s7, 16($sp)
		
		beq $s6, $s7, SameLetterFirstInsertionSort		
		beq $t4, 1, InnerLoop
		jal OutOfInnerLoop
		#jal CheckLoop
		
	OutOfInnerLoop:
		addi $t8, $t3, 1 # i + 1
		sll $t8, $t8, 2  # 4*i
		la $s4, address
		add $s4, $s4, $t8

		sw $t2, 0($s4)
		
		addi $t0, $t0, 1 # j=j+1
		blt $t0, $s2, OuterLoop
		
		# sorting finished
		li $s5, 10     # ASCII newline

		move $t1,$zero # counting
		add $t3, $zero, $zero # keeping the word itself
		move $t5,$zero # keeping the address
		
		la $s3, array_buffer
		la $s0, address
		la $s6, output_buffer_insertion			
		
		#Open Output File
		la $a0, output_insertionsort
		li $a1, 1 # 1 for write flag
		li $a2, 0
		
		li $v0, 13 # 13 for the code of open_file syscall
		syscall
		move $s7, $v0
		
		jal WriteInsertionSort
		
	InnerLoop:
		addi $t8, $t3, 1 # i + 1
		sll $t8, $t8, 2  # 4*i
		la $s4, address
		add $s4, $s4, $t8
		lw $s7 , 0($s4)
		sw $t9, 0($s4) # A[i+1] = A[i];
		la $s4, address
		add $s4, $s4, $t6
		sw $s7, 0($s4)
		#lb $t4, ($t9)
		#lb $t4, ($s7)
		subi $t3, $t3, 1 # i=i-1;
		subi $t4, $zero, 1 
		slt $t4, $t4, $t3 # t4 = 1 if -1 < i
		beq $t4, $zero, OutOfInnerLoop
		
		sll $t6, $t3, 2 	# 4*i
		la $s4, address
		add $s4, $s4, $t6
		
		jal CheckLoop
		
	CheckLoop:		
		lw $t9, 0($s4)
		lb  $s7, ($t9) # s7 load the first byte of the address s7 = A[i]
		slt $t5, $s6, $s7 # t5 = 1 if A[i]>num
		and $t4, $t4, $t5 # i>0 and A[i]>num
		#beq $t4, 1, InnerLoop

		sw $t9, 4($sp)
		sw $t2, 8($sp)
		sw $s6, 12($sp)
		sw $s7, 16($sp)
	
		beq $s6, $s7, SameLetterFirstInsertionSort	
		beq $t4, 1, InnerLoop	
		jal OutOfInnerLoop

GetWordFromFile:
	lb $t0, 0($s4) # a byte from the file buffer
	sb $t0, 0($s3) # store the byte to array buffer
	addi $s4, $s4, 1 # go to the next spot
	addi $s3, $s3, 1
	bne $t0, $s5, GetWordFromFile # until newline character is reached
	jr $ra # return to the caller

GetWordFromArray:
	lb $t0, 0($s3) # a byte from the array buffer
	sb $t0, 0($s6) # store the byte to output buffer
	addi $s6, $s6, 1 # go to the next spot
	addi $s3, $s3, 1
	addi $t5, $t5, 1 #number of characters
	bne $t0, $s5, GetWordFromArray # until newline character is reached
	
	#to be commented out
	#li $v0, 4 #print the contents of the file
	#la $a0, output_buffer_selection
	#syscall
	
	jr $ra # return to the caller
	
WriteInsertionSort:
	la $s0, address		
    	add $s0,$s0,$t1
    	lw $s3,($s0)
    	jal GetWordFromArray
	
    	addi $t1, $t1, 4 #next address
    	addi $t3,$t3,1 #count the words
    	bne $t3,$s2, WriteInsertionSort
    	
	li $v0, 15 # code of write mode	
	move $a0, $s7 # file descriptor
	la $a1, output_buffer_insertion
	la $a2, 1024		
	syscall
	
	#close
	li $v0, 16
	move $a0,$s7
	syscall
	
	addi $s1, $s1, 1 # insertion sort has finished, now selection sort's turn
	
	la $s3, array_buffer # save array buffer
	la $s4, buffer # save file buffer

	j PrepareArray
	
# Selection Sort Algorithm
#for i in range(len(A)):
    #min_idx = i
    #for j in range(i+1, len(A)):
    #    if A[min_idx] > A[j]:
    #        min_idx = j     
    #A[i], A[min_idx] = A[min_idx], A[i]
    
SelectionSort:
	la $s3, array_buffer 
	la $s4, address
	add $t0, $zero, $zero # start from first index i = 0	
	OuterLoopSelect:
		la $s3, array_buffer 
		move $t3, $t0 # min idx = i
		addi $t4, $t0, 1 # j
		#beq $t3, $s2, ExitSelectionSort
		beq $t4, $s2, ExitSelectionSort
		jal InnerLoopSelect

	OutOfInnerLoopSelect:
		la $s3, array_buffer 
		sll $t7, $t0, 2 # 4 *i
		la $t1, address
		add $t1, $t1, $t7
		lw $t7, 0($t1) #A[i]
		sll $t8, $t3, 2 # 4 * min_idx
		la $s4, address
		add $s5, $s4, $t8
		lw $t9, 0($s5)	#A[min idx]
		#move $t1, $t9 # save for swap
		
		sw $t9, ($t1) # A[i] = A[min idx]
		sw $t7, ($s5)	# A[min idx] = A[i]		
		
		#to be commented out
		#lb $s5, 0($t9)
		#lb $s5, 0($t7)
		
		addi $t0, $t0, 1 #i + 1
		bne $t0, $s2, OuterLoopSelect #go on to loop
		
		move $t3, $t0 # min idx = i
		addi $t4, $t0, 1 # j	
		jal ExitSelectionSort
		
	ExitSelectionSort:
		move $t1,$zero # counting
		add $t3, $zero, $zero # keeping the word itself
		move $t5,$zero # keeping the address
		
		la $s3, array_buffer # degistir, pointeri basa cekip ekliyoruz
		la $s0, address
		la $s6, output_buffer_selection	
		
		li $s5, 10     # ASCII newline
		
		#Open Output File
		la $a0, output_selectionsort
		li $a1, 1 # 1 for write flag
		li $a2, 0
		
		li $v0, 13 # 13 for the code of open_file syscall
		syscall
		move $s7, $v0
		
		jal WriteSelectionSort
			
	InnerLoopSelect:
		sll $t5, $t4, 2 	# 4*j
		la $s4, address
		add $s4, $s4, $t5	
		lw $t5, 0($s4)		# $t5=A[j]
		lb  $s6, ($t5) # s6 load the first byte of the address s6 = A[j]
		sll $t6, $t3, 2 # 4*min_idx
		la $s4, address
		add $s4, $s4, $t6
		lw $t6, 0($s4)		# $t5=A[min_idx]
		lb  $s7, ($t6) # s7 load the first byte of the address s7 = A[min_idx]
		blt $s7, $s6, Else
		li $s5, 0 #for recursion
		beq $s6, $s7, SameLetterFirstSelectionSort
		jal If		
	If:
		move $t3, $t4 # min idx = j
		addi $t4, $t4, 1 #j + 1
		bne $t4, $s2, InnerLoopSelect	
		jal OutOfInnerLoopSelect
	Else:
		addi $t4, $t4, 1
		bne $t4, $s2, InnerLoopSelect
		jal OutOfInnerLoopSelect
				
WriteSelectionSort:

	la $s0, address		
    	add $s0,$s0,$t1
    	lw $s3,($s0)
    	jal GetWordFromArray
    	
    	addi $t1, $t1, 4 #next address
    	addi $t3,$t3,1 #count the words
    	bne $t3,$s2, WriteSelectionSort
    	
	li $v0, 15 # code of write mode	
	move $a0, $s7 # file descriptor
	la $a1, output_buffer_selection
	la $a2, 1024		
	syscall
	
	#close
	li $v0, 16
	move $a0,$s7
	syscall

	j Exit
	
SameLetterFirstInsertionSort:
	add $t9, $t9, 1
	lb  $s7, ($t9) # s6 load the next byte of the address s7 = num = A[j]
	add $t2, $t2, 1
	lb  $s6, ($t2) # s6 load the next byte of the address s6 = num = A[j]
	slt $t4, $s6, $s7 # t4 = 1 if A[i]>num
	
	beq $s6, $s7, SameLetterFirstInsertionSort

	lw $t9, 4($sp)
	lw $t2, 8($sp)
	lw $s6, 12($sp)
	lw $s7, 16($sp)
	
	beq $t4, 1, InnerLoop
	jal OutOfInnerLoop

SameLetterFirstSelectionSort:
	addi $s5,$s5, 1
	sll $t5, $t4, 2 	# 4*j
	la $s4, address
	add $s4, $s4, $t5	
	lw $t5, 0($s4)		# $t5=A[j]
	add $t5, $t5, $s5 # initially 1
	lb  $s6, ($t5) # s6 load the second byte of the address s6 = A[j]
	sll $t6, $t3, 2 # 4*min_idx
	la $s4, address
	add $s4, $s4, $t6
	lw $t6, 0($s4)		# $t5=A[min_idx]
	add $t6, $t6, $s5
	lb  $s7, ($t6) # s7 load the first byte of the address s7 = A[min_idx]
		
	sub $t2, $t2, $s5
	sub $t9, $t9, $s5
		
	blt $s7, $s6, Else
	beq $s6, $s7, SameLetterFirstSelectionSort
	jal If
	
Exit:

