#
# pow
# Section 81 Team 5
# Takes in two numbers r0 and r1 and preforms exponentiation r0 ^ r1

.text
pow:
    # r4 stores the base number
    # r5 stores power
    # r6 holds value containing number of loop iterations remaining

    #push stack
    SUB sp, sp, #4
    STR lr, [sp]

    # Store Values needed for Later
    MOV r4, r0
    MOV r5, r1

    # Check if exponent is 0
    CMP r1, #0
    MOVEQ r0, #1
    BEQ return

    # Run Loop
    MOV r0, #1
    MOV r6, r5

    multiplyLoop:
	CMP r6, #0
	    BEQ return
	MUL r0, r0, r4
	SUB r6, r6, #1
	B multiplyLoop	

    return:
        # return stack
        LDR lr, [sp]
        ADD sp, sp, #4
        MOV pc, lr

.data
#END pow
