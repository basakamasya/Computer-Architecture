##
## template for your assembly programs
##
##

#################################################
#					 	#
#		text segment			#
#						#
#################################################

	.text		
       .globl __start 
__start:		# execution starts here

	
	# say hello
	la $a0,starting
	li $v0,4
	syscall
	
		
	#############################
	# load the fp number in a fp register (just for printing)
	l.d $f0, X
	jal message5a
	# print X
	mov.d $f12, $f0
	li $v0, 3
	syscall
	

	# load the fp number in an integer register $t0 and $t1 (the operations must be performed on $t0 and $t1)
	mfc1 $t0, $f0
	mfc1 $t1, $f1
	
	
	# YOUR CODE GOES HERE
	
	#double precision
	# -8 = - 2^3 --> divide by -8 = multiply -2^-3, add -3 to the exponent part
	
	#prepare the sign bit
	srl $t2,$t1,31 # 000000...x
	and $t2,$t2,1 # first and with 1 and then not because we will be dividing to a negative number
	not $t2,$t2
	sll $t2,$t2,11 # carry the sign bit, rest all zeros, ..x000...
	
	#prepare the fraction part
	sll $t3, $t1,12 # xxx...0000...
	srl $t3 , $t3 ,12 # 000...xxx...
	
	#prepare the exponent part
	sll $t1, $t1 ,1 # xx...0
	srl $t1, $t1, 21 # 000..xxxxxxxxxxx
	add $t1 , $t1, -3 # dividing by -8 equals to multiplying with 2^-3, so we will add -3 to the exponent part
	
	xor $t1 ,$t1, $t2 # xor with sign bit, t2 used for setting most signifact bit
	sll $t1 ,$t1, 20 # integer part is ready
	add $t1 , $t1, $t3 # add the fraction part
	
	#
	
	mtc1 $t0,$f0
	mtc1 $t1,$f1
	
	jal message5b
	
	
	# store the $f0 result in memory
	# print X/(-4)
	mov.d $f12, $f0
	li $v0, 3
	syscall
	
	
	#######################
	#######################
	# say good bye
	la $a0,endl
	li $v0,4
	syscall

	# exit call
	li $v0,10
	syscall		# au revoir...


############## messages


message5a:
	la $a0,mes5a
	j message	

message5b:
	la $a0,mes5b
	j message

message:
	li $v0,4
	syscall
	jr $ra

#################################################
#					 	#
#     	 	data segment			#
#						#
#################################################

	.data
starting:	.asciiz "\n\nProgram Starts Here ...\n"
endl:	.asciiz "\n\nexiting ..."


X: .double 10.00


mes5a:	.asciiz "\n\nX: "
mes5b:	.asciiz "\n\nX/4: "
##
## end of file fib.a
