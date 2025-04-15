# Team5: Cory Drangel, Adit Rao, Forrest VanDuren, Quinn Waxter
# EN605.204.81
# 04 MAY 2025
# Course Project  Library File
# Functions contained in this file: gcd, pow, modulo, cpubexp, cprivexp, encrypt, decrypt, findPrime


.global gcd
.global pow
.global modulo
.global cpubexp
.global cprivexp
.global encrypt
.global decrypt
.global findPrime 

#Function Name: gcd
#Author:        Cory Drangel
#Date:          April 12, 2025
#Purpose:       Determine the greatest common divisor for 2 numbers
#
# GCD(a, b) = 
#       while (b>0):
#           tmp = b
#           b = a % b
#           a = tmp
#       return a
.text
gcd:
    #Function dictionary
    #r4 - 1st number (a - in r0)
    #r5 - 2nd number (b - in r1)

    #Storing the value of the stack
    SUB sp, sp, #12
    STR lr, [sp, #0]
    STR r4, [sp, #4]
    STR r5, [sp, #8]

    #Loading the two numbers into r4 and r5
    MOV r4, r0
    MOV r5, r1
    
    #while b>0
    beginLoop:
    CMP r5, #0
    BLE endLoop
        #r0 = tmp
        #tmp = b
        MOV r0, r5
        MOV r1, r4

        modLoop:
        CMP r1, r5
        BLT endModLoop
            SUB r1, r1, r5
            B modLoop
        
        endModLoop:
        #b = a %b
        MOV r5, r1
        #a = tmp
        MOV r4, r0
        B beginLoop

    endLoop:
    MOV r0, r4

    #Pop the stack
    LDR lr, [sp, #0]
    LDR r4, [sp, #4]
    LDR r5, [sp, #8]
    ADD sp, sp, #12
    MOV pc, lr
.data
#END FUNCTION gcd

#
#pow
#Section 81 Team 5
#Takes in two numbers r0 and r1 and performs exponentiation r0 ^ r1

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
#END FUNCTION pow

#
#Function Name: modulo
#Author:        Forrest VanDuren
#Date:          03/06/2025
#Purpose:       Take modulo of two values and return
#
.text

#Set r0 to dividend and r1 to divisor before calling function
modulo:
    #Push the stack record
    SUB sp, sp, #12
    STR lr, [sp, #0]
    STR r4, [sp, #4]
    STR r5, [sp, #8]

    #Store divisor in r4, dividend in r5. Remainder is returned in r0
    MOV r4, r1
    MOV r5, r0
    BL __aeabi_idiv
    MUL r4, r0, r4
    SUB r0, r5, r4

    #Pop the stack record
    LDR lr, [sp, #0]
    LDR r4, [sp, #4]
    LDR r5, [sp, #8]
    ADD sp, sp, #12
    MOV pc, lr

.data
#END FUNCTION modulo

#
#Function Name: cpubexp
#Author:        Cory Drangel
#Date:          April 14, 2025
#Purpose:       Determine if public key exponent (e) is 1 < e < totient
#                   and that gcd(e, totient) = 1
#
.text
cpubexp:
     #Function dictionary
     #r4 - public key exponent (e)
     #r5 - totient

     #Push the stack
     SUB sp, sp, #12
     STR lr, [sp]
     STR r4, [sp, #4]
     STR r5, [sp, #8]

     #Save variables in r4 (e) and r5 (totient)
     MOV r4, r0
     MOV r5, r1

     #Logical variables for determing if e is valid
     MOV r2, #0
     #if e > 1
     CMP r4, #1
     ADDGT r2, r2, #1
     MOV r3, #0
     #if e < totient
     CMP r4, r5
     ADDLT r3, r3, #1
     AND r2, r2, r3

     MOV r0, r4
     MOV r1, r5
     BL gcd
     MOV r1, #0
     #if gcd(e, totient) = 1
     CMP r0, #1
     ADDEQ r1, r1, #1
     AND r0, r1, r2

     #Pop the stack
     LDR lr, [sp]
     LDR r4, [sp, #4]
     LDR r5, [sp, #8]
     ADD sp, sp, #12
     MOV pc, lr
.data
#END FUNCTION cpubexp


.text
cprivexp:
.data
#END FUNCTION cprivexp


.text
encrypt:
.data
#END FUNCTION encrypt


.text
decrypt:
.data
#END FUNCTION decrypt


.text
findPrime:
.data
#END FUNCTION findPrime
