#
#Program Name:	Gcd.s
#Author:	Cory Drangel
#Date:		April 7, 2025
#Purpose:	Determine the greatest common divisor for 2 numbers
#
# GCD(a, b) =
#         while (b>0):
#             tmp = b
#             b = a % b
#             a = tmp 
#         return a
#
.global gcd
gcd:
    #Program dictionary
    #r4 - 1st number (a - in r0)
    #r5 - 2nd number (b - in r1)

    #Storing the value of the stack
    SUB sp, sp, #12
    STR lr, [sp, #0]
    STR r0, [sp, #4]
    STR r1, [sp, #8]

    #Loading the two numbers into r4 and r5
    MOV r4, r0
    MOV r5, r1

    #while (b>0)
    beginLoop:
    CMP r5, #0
    BEQ endLoop
        #r0 = tmp
        #tmp = b
        MOV r0, r5
        MOV r1, r4

        modLoop:
        CMP r1, r5
        BLE endModLoop
            SUB r1, r1, r5
            B modLoop

        endModLoop:
        #b = a % b
        MOV r5, r1
        #a = tmp
        MOV r4, r0
        B beginLoop
    
    endLoop:
    MOV r0, r4

    #Moving the stack pointer baack and going into main
    LDR lr, [sp, #0]
    LDR r0, [sp, #4]
    LDR r1, [sp, #8]
    ADD sp, sp, #12
    MOV pc, lr
.data

#END gcd
