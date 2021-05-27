.globl main 
.text 

main: 
	li $v0,4 # print the message such that user inputs the no of points
	la $a0,input_user
	syscall
	
	li $v0,5 # store the no of points n in t0
	syscall
	move $t0,$v0
	
	li $t1,0 # if 0 as the termination code is provided exit from the loop
	beq $t1,$t0,exit
	
	li $t1,1
	bgt $t1,$t0,wrong_input
	
	li $v0,4 #take the x cordinate of the first point from user in this block and store in t2
	la $a0,x_input
	syscall
	li $v0,1 
	move $a0,$t1
	syscall
	li $v0,4
	la $a0,colon
	syscall
	li $v0,5
	syscall
	move $t2,$v0
	
	li $v0,4 #take the y cordinate of the first point from user in this block and store in t3
	la $a0,y_input
	syscall	
	li $v0,1
	move $a0,$t1
	syscall	
	li $v0,4
	la $a0,colon
	syscall
	li $v0,5
	syscall
	move $t3,$v0
	
	add $t1,$t1,1#t1 is maintained as a counter so update the counter 
	
	l.d $f10,zero#initialse the area to 0
	s.d $f10,area
	while: #loop for taking the inputs and getting area
		bgt $t1,$t0,return #check if the no of inputs have been reached the required limit
		
		li $v0,4#take the x cordinate of the ith point from user in this block and store in t5
		la $a0,x_input
		syscall
		li $v0,1
		move $a0,$t1
		syscall
		li $v0,4
		la $a0,colon
		syscall		
		li $v0,5
		syscall
		move $t5,$v0
		
		bgt $t2, $t5,not_sorted# if the points arent provided in sorted x order raise an error and ask for it again
		
		li $v0,4#take the y cordinate of the ith point from user in this block and store in t6
		la $a0,y_input
		syscall	
		li $v0,1
		move $a0,$t1
		syscall	
		li $v0,4
		la $a0,colon
		syscall		
		li $v0,5
		syscall
		move $t6,$v0
		
		bgt $zero,$t3,branch #if the prev point is in the negative y domain then go to branch
		bgt $zero,$t6,load #if the current point is in the negative y domain and previous y was in positive domain use load branch
		# if current and past y both are in positive domain
		j compute_1

branch:#branch for the case where prev y in in negaitive y domain
	bgt $t6,$zero,load #if the current y is positive use load
	#if the current point is also in negative y domian use computation method 1
	j compute_1 
	
compute_2:#if some part in positive side and some other in negative side then use this computation method
	abs.d $f10,$f4#take the absolute value for area
	abs.d $f6,$f6
	add.d $f10,$f6,$f10

	div.d $f2,$f0,$f10#area of the first traingle 
	mul.d $f2,$f2,$f6
	mul.d $f2,$f2,$f6
	
	div.d $f8,$f0,$f10#area of the second traingle
	sub.d $f10,$f10,$f6
	mul.d $f8,$f8,$f10
	mul.d $f8,$f8,$f10
	l.d $f0,area #update the area
	add.d $f0,$f0,$f2
	add.d $f0,$f0,$f8
	s.d $f0,area		
	j update_count
	
load:#loading the value for negative and positive case
	mtc1.d $t2 ,$f0
	cvt.d.w $f0,$f0
	mtc1.d $t5 ,$f2
	cvt.d.w $f2,$f2	
	sub.d $f0,$f2,$f0
	l.d $f2,two
	div.d $f0,$f0,$f2
	mtc1.d $t3 ,$f6
	cvt.d.w $f6,$f6
	mtc1.d $t6 ,$f4
	cvt.d.w $f4,$f4
	j compute_2
	
	
compute_1:#  if all the area in positive side or negative use this computation mehtod
	mtc1.d $t3 ,$f0
	cvt.d.w $f0,$f0
	mtc1.d $t6 ,$f2
	cvt.d.w $f2,$f2
	add.d $f4,$f0,$f2 
	mtc1.d $t2 ,$f0
	cvt.d.w $f0,$f0
	mtc1.d $t5 ,$f2
	cvt.d.w $f2,$f2
	sub.d $f6,$f2,$f0
	mul.d $f0,$f4,$f6
	l.d $f2,two
	div.d $f2,$f0,$f2
	l.d $f0,area
	abs.d $f2,$f2
	add.d $f0,$f2,$f0
	s.d $f0,area
	j update_count
			
update_count:#branch to update the prev to next values and counter
	move $t2,$t5
	move $t3,$t6
		
	add $t1,$t1,1
	j while		
	
wrong_input: #branch to handle the worng n input
	li $v0,4
	la $a0,error_message
	syscall
	j main
	
not_sorted:#branch to handle the no sorted x probelm
	li $v0,4
	la $a0,notSort
	syscall
	j while	

return:#branch to return the final area after all the computation 
	l.d $f0,area
	mov.d $f12,$f0
	li $v0,4
	la $a0,result
	syscall
	li $v0,3
	syscall
	li $v0,4
	la $a0, nextline
	syscall
	j main 
	
exit:#branch to exit smoothly from the code
	li $v0,4
	la $a0,exits
	syscall
	li $v0,10 
	syscall
	

.data
	input_user: .asciiz "Please Enter the No of Points (Enter 0 to terminate):"
	error_message: .asciiz "Number of points can't be negative Please provide a positive n\n"
	x_input: .asciiz "Please enter the x cordinate of the point no."
	y_input: .asciiz "Please enter the y cordinate of the point no."
	colon: .asciiz ":"
	notSort: .asciiz "The x cordinates of the point need to be in sorted order\n"
	area: .double 0.0 
	two: .double 2.0
	result: .asciiz "The area under the curve for the given points is:"
	nextline: .asciiz "\n"
	zero: .double 0.0
	exits: .asciiz "The function is terminated by entering 0\n"
