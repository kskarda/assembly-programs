.global p4_add_skarda

p4_add_skarda:

// prologue
    sub sp, sp, #16         // space for fp, lr
    str fp, [sp, #0]        // save fp
    str lr, [sp, #8]        // save lr
    add fp, sp, #8          // set our frame pointer
    sub sp, sp, #16         // space for locals
//end of prologue

    ldr x6, [fp, #8]        // user input from the stack
    ldr x9, [fp, #16]       // input size from the stack

    mov x3, #0		            // addition result, used later
    mov x4, #0                  // negative number holder, used later

getNumber:
    mov x10, #48
    mov x11, #48
    mov x12, #48
    mov x13, #48
    sub x9, x9, #1          // remove \n or comma from length
getOnes:    
    sub x9, x9, #1		    // x9 is ofsetting to end of user input
    ldrb w10, [x6, x9]	    //x10 is temporary for 1s digit
    cbz x9, asciiToInt      //check if done with input
getTens:   
    sub x9, x9, #1 
    ldrb w11, [x6, x9]      //x11 temp 10s digit
    cmp x11, #32		    // check for space
    beq asciiToInt
    cmp x11, #45		    // check for negative
    beq negative
    cbz x9, asciiToInt
getHundreds:
    sub x9, x9, #1		
    ldrb w12, [x6, x9]      //x12 temp 100s digit
    cmp x12, #32
    beq asciiToInt
    cmp x12, #45		    
    beq negative
    cbz x9, asciiToInt
getThousands:
    sub x9, x9, #1		
    ldrb w13, [x6, x9]      //x13 temp 1000s digit
    cbz x9, asciiToInt
    cmp x13, #32
    beq asciiToInt
    cmp x13, #45		    
    beq negative
    sub x9, x9, #1          

asciiToInt:
	sub x10, x10, #48
	add x3, x3, x10    
    cmp x11, #32
    beq getNumber
	sub x11, x11, #48
    mov x8, #10
	mul x11, x11, x8
	add x3, x3, x11
    cmp x12, #32
    beq getNumber
    sub x12, x12, #48
    mov x8, #100
	mul x12, x12, x8
	add x3, x3, x12
    cmp x13, #32
    beq getNumber
	sub x13, x13, #48
    mov x8, #1000
	mul x13, x13, x8
	add x3, x3, x13
	cbz x9, storeResult
	b getNumber

negative:
    sub x10, x10, #48
    add x4, x4, x10
    cmp x11, #45
    beq subtract
    sub x11, x11, #48
    mov x8, #10
	mul x11, x11, x8
    add x4, x4, x11
    cmp x12, #45
    beq subtract
    sub x12, x12, #48
    mov x8, #100
	mul x12, x12, x8
    add x4, x4, x12

subtract:
    sub x3, x3, x4
    mov x4, #0
    cbz x9, storeResult
    sub x9, x9, #1
    cbnz x9, getNumber

storeResult:
    
    //epilogue
    add     sp, sp, #16
    ldr     fp, [sp, #0]
    ldr     lr, [sp, #8]
    add     sp, sp, #16

    //pass result back here
    str x3, [sp, #0]

    ret
    

