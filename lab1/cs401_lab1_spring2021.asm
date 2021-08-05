.data

array1: .word 9, 8, 7, 6, 5, 4, 3, 2, 1, 0 # final 0 indicates the end of the array; 0 is excluded; it should return TRUE for this array
array2: .word 8, 9, 6, 7, 5, 4, 3, 2, 1, 0 # final 0 indicates the end of the array; 0 is excluded; it should return FALSE for this array

true: .asciiz "TRUE\n"
false: .asciiz "FALSE\n"
default: .asciiz "This is just a template. It always returns "

.text

main:
      la $a0, array2 # $a0 has the address of the A[0]
      jal lenArray  # Find the lenght of the array
      
      move $a1, $v0  # $a1 has the length of A
      
      jal Descending

      bne $v0, 0,  yes
      la  $a0, false
      li $v0, 4
      syscall
      j exit

yes:  la    $a0, true
      li $v0, 4
      syscall

exit:
      li $v0, 10
      syscall


Descending:
###############################################
#   Your code goes here
###############################################
      
      la  $a0, default 
      li $v0, 4
      syscall
      addi $v0, $zero, 1
      
###############################################
# Everything in between should be deleted
###############################################
      jr $ra	

lenArray:       #Fn returns the number of elements in an array
      addi $sp, $sp, -8
      sw $ra,0($sp)
      sw $a0,4($sp)
      li $t1, 0

laWhile:       
      lw $t2, 0($a0)
      beq $t2, $0, endLaWh
      addi $t1,$t1,1
      addi $a0, $a0, 4
      j laWhile

endLaWh:
      move $v0, $t1
      lw $ra, 0($sp)
      lw $a0, 4($sp)
      addi $sp, $sp, 8
      jr $ra
