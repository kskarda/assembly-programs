//Consts
.equ BUFFERSIZE,   100
.equ STDIN,  0                // linux input console
.equ STDOUT, 1                // linux output console
.equ READ,   63 
.equ WRITE,  64 
.equ EXIT,   93 

.data
enterText:		.asciz "Give me some numbers seperated by a comma and a space: "
exitText:       .asciz "The sum is: "
carriageReturn:  	.asciz "\n"
num:			.word 0

//Read Buffer
.bss 
buffer:    .skip    BUFFERSIZE

.text
.global _start 

quadEnterText:        	.quad  enterText
quadExitText:           .quad  exitText
quadBuffer:          	.quad  buffer
quadCarriageReturn:	    .quad  carriageReturn

writeMessage:
    mov x2,0                   // reset size counter to 0

checkSize:                     // get size of input
    ldrb w1,[x0,x2]            // load char with offset of x2
    add x2,x2,#1               // add 1 char read legnth
    cbz w1,output              // if char found
    b checkSize              

output:
    mov x1,x0                  // move string address into system call func parm
    mov x0,STDOUT              
    mov x8,WRITE               
    svc 0                      // trigger system write
    ret       

negIntToAsc:
    mov x8, #-1
    mul x7, x7, x8
    ldr x0, =num
    mov x8, #45
    str x8, [x0]
    mov x2, #2
    mov x1, x0
    mov x0, #1
    mov x8, #64
    svc 0
    ret                 

_start:
    //prologue
    sub sp, sp, #16             //space for fp, lr
    str fp, [sp, #0]            //save fp
    str lr, [sp, #8]            //save lr
    add fp, sp, #8              //set our fp
    sub sp, sp, #16             //allocate space for locals and argSz
    //end of prologue

    //Output enter text
    ldr x0,quadEnterText	    // load enter message
    bl writeMessage		        // output enter message

    //Output newline
    ldr x0,quadCarriageReturn   
    bl writeMessage

    //Read User Input
    mov x0,STDIN           	    // linux input console
    ldr x1,quadBuffer      	    // load buffer address 
    mov x2,BUFFERSIZE      	    // load buffer size 
    mov x8,READ            	    // request to read data
    svc 0                  	    // trigger system read input

    //store input in registers to stack
    str x1, [sp, #0]            // store the input arg on the stack to be picked up by the callee;
    str x0, [sp, #8]            // store int input length on the stack

    //Output exit Message
    ldr x0,quadExitText	        // load enter message
    bl writeMessage		        // output enter message
    ldr x0,quadCarriageReturn   // Output newline
    bl writeMessage
 
    //pass to function
    bl  p4_add_skarda

    //recover result from function here !!!
    ldr x7, [sp,#0]

intToAscii:                 //x7=dividend (input)
    cmp x7, #0
    blt negIntToAsc
	mov	x10, #10	        //divisor
	mov	x11, #100	        //divisor
	mov	x12, #1000	        //divisor
	mov	x13, #0		        //remainder
	mov	x14, #0		        //quotient
	udiv x14, x7, x12
	msub x13, x14, x12, x7
	add	x14, x14, #48   	//to ascii
	ldr	x5, =num
	str	x14, [x5]           //store thousands digit
	udiv x14, x13, x11
    msub x13, x14, x11, x13
	add	x14, x14, #48
	str	x14, [x5, #1]       //store hundreds digit
	udiv x14, x13, x10
    msub x13, x14, x10, x13
	add	x14, x14, #48
	str	x14, [x5, #2]       //store tens digit
    add x13, x13, #48
	str	x13, [x5, #3]       //store ones digit (remainder)

    mov w0, 0               //remove leading zeros
    ldrb w1, [x5]
    cmp w1, #48
    bne outputResult
    strb w0, [x5]
    ldrb w1, [x5, #1]
    cmp w1, #48
    bne outputResult
    strb w0, [x5, #1]
    ldrb w1, [x5, #2]
    cmp w1, #48
    bne outputResult
    strb w0, [x5, #2]
  
outputResult:
    mov x0, x5
    mov x2, #4
    bl output

    //Output newline
    ldr x0,quadCarriageReturn   
    bl writeMessage

    //epilogue
    add sp, sp, #16             //deallocate locals and argSz to sp
    ldr fp, [sp, #0]            //restore fp
    ldr lr, [sp, #8]            //restore lr
    add sp, sp, #16             //restore sp
 
    //End Program
    mov x0, #0             	// return code
    mov x8, #EXIT          	// request to exit program
    svc 0                 	// trigger end of program


