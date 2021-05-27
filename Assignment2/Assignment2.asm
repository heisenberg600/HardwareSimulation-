.globl main
.text
    main:   

	li $v0,4 # print the message such that user inputs the postfix esxpression
	la $a0,postfix
	syscall

    li $v0,8 #read the input string 
    la $a0,stringspace
    li $a1,100000
    syscall

    la $t2,stringspace
    move $t0,$zero
    move $t7,$zero
    lb $t3,0($t2)
    beq $t3,10,empty
    j loop
loop: 
    add $t6,$t2,$t0#update the memory pointer
    lb $t3,0($t6)#get the char 
    beq $t3,10,answer#if newline then get the answer
    beq $t3,43,addition #compare with ascii value of +
    beq $t3,45,subtract #compare with ascii value of -
    beq $t3,42,multiply # compare with ascii value of *
    blt $t3,48,error # if any other charachter
    bgt $t3,57,error# if any other charachter 

    addi $t3,$t3,-48#get the decimal value from the ascii value 
    subu $sp,$sp,4#push onto the stack 
    sw $t3,0($sp)
    addi $t7,$t7,1
    j update #update the counter


addition: #branch for the addition
    blt $t7,2,IP2#if 2 elements not in stack raise an error
    lw $t4, 0($sp)
    lw $t5, 4($sp)
    addu $sp,$sp,8#pop two elements compute and push it on stcak
    add $t4,$t5,$t4
    sub $sp,$sp,4
    sw $t4,($sp)
    addi $t7,$t7,-1
    j update#update the counter 

subtract: #branch for the subtraction
    blt $t7,2,IP2#if 2 elements not in stack raise an error
    lw $t4, 0($sp)
    lw $t5, 4($sp)
    addu $sp,$sp,8
    sub $t4,$t5,$t4
    sub $sp,$sp,4
    sw $t4,($sp)
    addi $t7,$t7,-1
    j update#update the counter 

multiply: #branch for the multiplication
    blt $t7,2,IP2#if 2 elements not in stack raise an error
    lw $t4, 0($sp)
    lw $t5, 4($sp)
    addu $sp,$sp,8#pop two elements compute and push it on stcak
    mul $t4,$t5,$t4
    sub $sp,$sp,4
    sw $t4,($sp)
    addi $t7,$t7,-1
    j update #update the counter 


update: #branch to update the count and loop
    addi $t0,$t0,1
    j loop 

error:#branch to handle invalid input character 
    li $v0,4
    la $a0,chara1
    syscall
    li $v0,11
    move $a0,$t3
    syscall 
    li $v0,4
    la $a0,chara2
    syscall
    li $v0,1
    addi $t0,$t0,1
    move $a0,$t0
    syscall 
    li $v0,4
    la $a0,newline
    syscall 
    j main 

answer: #if we get the answer branch to handle this
    bgt $t7,1,IP1
    li $v0,4
    la $a0,ans
    syscall
    lw $a0,0($sp)
    li $v0,1
    syscall
    li $v0,4
    la $a0,newline
    syscall
    j main

empty: 
    li $v0,4
    la $a0,emp
    syscall
    j main
exit: #branch to smoothly exit out of the code 
    li $v0,10
    syscall    

IP1:#branch to handle invalid input expression
    li $v0,4
    la $a0,Ip1
    syscall
    j main
IP2:#branch to handle invalid expression
    li $v0,4
    la $a0,Ip2
    syscall
    j main
.data 
    ans: .asciiz "The postix expression evaluates to:"
    newline: .asciiz "\n"
    postfix: .asciiz "Enter the postfix expression which has to be evaluated:"
    invalid: .asciiz "Invalid Input No of operations cant be negative\n"
    chara1: .asciiz "Invalid charachter: "
    chara2: .asciiz " found in postfix expression at position "
    Ip1: .asciiz "Invalid Expression: More operators expected\n"
    Ip2: .asciiz "Invalid Expression: More operands expected\n"
    stringspace: .space 100000
    emp: .asciiz "Input expression is empty\n"




# An alternate approach which uses dynamic memory allocation in heap for operation using sbrk taking no of operation as input
# .globl main
# .text
#     main:
# 	li $v0,4 # print the message such that user inputs the no of operation
# 	la $a0,promt
# 	syscall
# 	li $v0,5 # store the no of operations
# 	syscall
# 	move $t0,$v0
#     blt $t0,$zero,InvalidI#if -1 is provided exit out of the function    

#     add $t1,$t0,$t0#this is the no of bytes we require for our input string 
#     addi $t1,$t1,3

#     li $v0,9 #create the memory and save address of it in t1
#     move $a0,$t1
#     syscall 
#     move $t2,$v0

# 	li $v0,4 # print the message such that user inputs the postfix esxpression
# 	la $a0,postfix
# 	syscall

#     li $v0,8 #read the input string 
#     la $a0,0($t2)
#     move $a1,$t1
#     syscall

#     addi $t1,$t1,-2#counters for the loop
#     li $t0,0
#     move $t7,$zero
#     j loop
# loop: 
#     beq $t0,$t1,answer #check if all the charchters are read from the input string and give out the answer
#     add $t6,$t2,$t0#update the memory pointer
#     lb $t3,0($t6)#get the char 
#     beq $t3,43,addition #compare with ascii value of +
#     beq $t3,45,subtract #compare with ascii value of -
#     beq $t3,42,multiply # compare with ascii value of *
#     blt $t3,48,error # if any other charachter
#     bgt $t3,57,error# if any other charachter 

#     addi $t3,$t3,-48#get the decimal value from the ascii value 
#     subu $sp,$sp,4#push onto the stack 
#     sw $t3,0($sp)
#     addi $t7,$t7,1
#     j update #update the counter


# addition: #branch for the addition
#     blt $t7,2,IP2#if 2 elements not in stack raise an error
#     lw $t4, 0($sp)
#     lw $t5, 4($sp)
#     addu $sp,$sp,8#pop two elements compute and push it on stcak
#     add $t4,$t5,$t4
#     sub $sp,$sp,4
#     sw $t4,($sp)
#     addi $t7,$t7,-1
#     j update#update the counter 

# subtract: #branch for the subtraction
#     blt $t7,2,IP2#if 2 elements not in stack raise an error
#     lw $t4, 0($sp)
#     lw $t5, 4($sp)
#     addu $sp,$sp,8
#     sub $t4,$t5,$t4
#     sub $sp,$sp,4
#     sw $t4,($sp)
#     addi $t7,$t7,-1
#     j update#update the counter 

# multiply: #branch for the multiplication
#     blt $t7,2,IP2#if 2 elements not in stack raise an error
#     lw $t4, 0($sp)
#     lw $t5, 4($sp)
#     addu $sp,$sp,8#pop two elements compute and push it on stcak
#     mul $t4,$t5,$t4
#     sub $sp,$sp,4
#     sw $t4,($sp)
#     addi $t7,$t7,-1
#     j update #update the counter 


# update: #branch to update the count and loop
#     addi $t0,$t0,1
#     j loop 

# error:#branch to handle invalid input character 
#     li $v0,4
#     la $a0,chara1
#     syscall
#     li $v0,11
#     move $a0,$t3
#     syscall 
#     li $v0,4
#     la $a0,chara2
#     syscall
#     li $v0,1
#     addi $t0,$t0,1
#     move $a0,$t0
#     syscall 
#     li $v0,4
#     la $a0,newline
#     syscall 
#     j main 

# answer: #if we get the answer branch to handle this
#     bgt $t7,1,IP1
#     li $v0,4
#     la $a0,ans
#     syscall
#     lw $a0,0($sp)
#     li $v0,1
#     syscall
#     li $v0,4
#     la $a0,newline
#     syscall
#     j main

# exit: #branch to smoothly exit out of the code 
#     li $v0,10
#     syscall    

# InvalidI: #branch to handle the invalid input of no of operation 
#     li $v0,4
#     la $a0,invalid
#     syscall
#     j main 
# IP1:#branch to handle invalid input expression
#     li $v0,4
#     la $a0,Ip1
#     syscall
#     j main
# IP2:#branch to handle invalid expression
#     li $v0,4
#     la $a0,Ip2
#     syscall
#     j main
# .data 
#     ans: .asciiz "The postix expression evaluates to:"
#     newline: .asciiz "\n"
#     postfix: .asciiz "Enter the postfix expression which has to be evaluated:"
#     promt: .asciiz "Please Input the no. of operation to be performed(non negative):"
#     invalid: .asciiz "Invalid Input No of operations cant be negative\n"
#     chara1: .asciiz "Invalid charachter: "
#     chara2: .asciiz " found in postfix expression at position "
#     Ip1: .asciiz "Invalid Expression: No of operations in exp dont match the provided ones\n"
#     Ip2: .asciiz "Invalid Expression: expected more operands than provided\n"
