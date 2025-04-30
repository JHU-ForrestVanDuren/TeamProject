# Team5: Cory Drangel, Adit Rao, Forrest VanDuren, Quinn Waxter
# EN605.204.81
# 04 MAY 2025
# Course Project  Library File
# Functions contained in this file: gcd, pow, modulo, cpubexp, cprivexp, encrypt, decrypt, findPrime


.global gcd
.global pow
.global modulo
.global modLarge
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
    BLE endGCDLoop
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

    endGCDLoop:
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
#Function Name: pow
#Authors:       Quinn Waxter, Forrest VanDuren
#Purpose:       To perform exponentiation on two numbers. Specifically for numbers that will be much larger then 32 bits long
#
.text
pow:
	# r4 stores the base number
	# r5 stores the product of the current power multiplication for each index
	# r6 holds value containing number of loop iterations remaining
	# r7 number to multiply index by to get to the appropriate memory location
	# r8 stores the memory location offset for numArray
	# r9 stores the inner loop counter
	# r10 Stores the number of indices for numArray
	# r11 Stores the carry value for each iteration

	#push stack
	SUB sp, sp, #36
	STR lr, [sp]
	STR r4, [sp, #4]
	STR r5, [sp, #8]
	STR r6, [sp, #12]
	STR r7, [sp, #16]
	STR r8, [sp, #20]
	STR r9, [sp, #24]
	STR r10, [sp, #28]
	STR r11, [sp, #32]

	# Store Values needed for Later
	MOV r4, r0
	MOV r6, r1
	MOV r7, #4
	MOV r9, #0
	MOV r10, #0

	# Check if exponent is 0
	CMP r1, #0
	MOVEQ r0, #1
	BEQ return
   
	# Stores initial base value in numArray
	LDR r0, =numArray
	STR r4, [r0]

	#Run loop
	multiplyLoop:

	
		CMP r6, #1
		BEQ endMultiplyLoop
		MOV r8, #0
		MOV r11, #0
	
		innerloop:

                        CMP r9, r10
                        BGT endinnerloop

			#Get numArray value at current index
                        MUL r8, r9, r7
                        LDR r1, [r0, r8]

			#Multiply base number and add cary from last index
                        MUL r5, r4, r1
                        ADD r5, r5, r11

			#Increase current index and compare r5 to the maximum number allowed before carrying. Branch to greater then if over this amount.
                        ADD r9, r9, #1
                        LDR r3, =#65535
                        CMP r5, r3
                        BGT greaterthan

				#Store new value for the current index in the array and iterate innerloop
                                STR r5, [r0, r8]
				MOV r11, #0
                                B innerloop

                        greaterthan:

				#Generate carry value	
                                MOV r11, r5
                                LSR r11, r11, #16

				#Remove carry value from the front of the current numArray index value
                                LDR r3, =#0x0000FFFF
                                AND r5, r5, r3

				#If r9 is greater then the current highest index branch to extend the array
                                CMP r9, r10
                                BGT extendarray

					#Store new value of current index
                                	STR r5, [r0, r8]
                                	B innerloop

                                extendarray:

					#Store new value of current index, add 4 to offset and store carry into that new offset
                                        STR r5, [r0, r8]
                                        ADD r8, r8, #4
                                        STR r11, [r0, r8]

					#Increase highest index number and end innerloop
                                        ADD r10, r10, #1
                                        B endinnerloop

                endinnerloop:

		#Reset inner loop counter, decrease outerloop counter, and branch back to the begining of the outerloop
                MOV r9, #0
                SUB r6, r6, #1
                B multiplyLoop

	endMultiplyLoop:

	return:
	
	#Return pointer to numArray in r0 and the size of the array in r1
	MOV r1, r10

        # return stack
        LDR lr, [sp]
	LDR r4, [sp, #4]
	LDR r5, [sp, #8]
	LDR r6, [sp, #12]
	LDR r7, [sp, #16]
	LDR r8, [sp, #20]
	LDR r9, [sp, #24]
	LDR r10, [sp, #28]
	LDR r11, [sp, #32]
        ADD sp, sp, #36
        MOV pc, lr

.data
    numArray: .space 10000
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
#Function Name: modLarge
#Auther:        Forrest VanDuren
#Date:          04/26/2025
#Purpose:       To create a function that's capable of finding the modulo of number much larger then 32 bits long
#
.text
modLarge:

	# r4 holds the divisor
	# r5 holds the dividend of the current array index
	# r6 holds the current index remainder
	# r7 holds the number to multiply the index by which gives the current array offset
	# r8 holds the current array index
	# r9 holds a pointer to the number array

	#Push the stack record
	Sub sp, sp, #28
	STR lr, [sp]
	STR r4, [sp, #4]
	STR r5, [sp, #8]
	STR r6, [sp, #12]
	STR r7, [sp, #16]
	STR r8, [sp, #20]
	STR r9, [sp, #24]

	#Initialize values
	MOV r4, r2
	MOV r6, #0
	MOV r7, #4
	MOV r8, r1
	MOV r9, r0

        modloop:

                CMP r8, #0
                BLT endmodloop

		#Get value of current index
                MUL r1, r7, r8
                LDR r0, [r9, r1]

		#Shift last iteration remainder into first 16 bits and combine with current index value to get this iterations dividend
                LSL r6, #16
                ORR r0, r0, r6

		#Store dividend in r5, move divisor to r1, and divide
                MOV r5, r0
                MOV r1, r4
                BL __aeabi_idiv

		#Calculate the remainder, decrease the array index and iterate the loop
                MUL r1, r0, r4
                SUB r6, r5, r1
		MUL r1, r7, r8
		MOV r2, #0
		STR r2, [r9, r1]
                SUB r8, r8, #1
                B modloop

        endmodloop:
	
	#Return final remainder in r0
	MOV r0, r6

	#Pop the stack record
	LDR lr, [sp,#0]
	LDR r4, [sp, #4]
	LDR r5, [sp, #8]
	LDR r6, [sp, #12]
	LDR r7, [sp, #16]
	LDR r8, [sp, #20]
	LDR r9, [sp, #24]
	ADD sp, sp, #28
	MOV pc, lr

.data
#END FUNCTION modLarge
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

#
# cprivexp(totient, e)
# This function calculates the RSA private key 'd' using the extended Euclidean algorithm.
# It takes two inputs: the totient and the public exponent (e), and computes the modular inverse
# of e modulo totient, which is the private key 'd'.
#
# The algorithm stores intermediate results of the extended Euclidean process:
#   - q -> Quotient
#   - rem -> Remainder
#   - s -> Coefficients for s (used in calculation of d)
#   - t -> Coefficients for t (used in calculation of d)
#
# A 1 index refers to the previous iteration, and a 2 index refers to two iterations ago.

.text
cprivexp:
	# Save the return address
	SUB sp, sp, #16
	STR lr, [sp, #0]
	STR r4, [sp, #4]
	STR r5, [sp, #8]
	STR r6, [sp, #12]

	# Initialize the loop variables
	LDR r5, =rem2
	LDR r4, =rem1
	LDR r6, =totient

	STR r0, [r5]
	STR r1, [r4]
	STR r0, [r6]
	MOV r1, #0
	MOV r2, #1

	LDR r5, =s1
	LDR r4, =s2
	STR r1, [r5]
	STR r2, [r4]

	LDR r5, =t1
	LDR r4, =t2
	STR r2, [r5]
	STR r1, [r4]
	B loopExtEuclidean

	loopExtEuclidean:
		# Load current remainders
		LDR r5, =rem2
		LDR r6, =rem1
		LDR r0, [r5]
		LDR r1, [r6]
		
		# Calculate quotient
		BL __aeabi_idiv
		LDR r5, =q1
		STR r0, [r5]
		
		# Update s coefficients
		LDR r5, =s1
		LDR r6, =s2
		LDR r1, [r5]
		LDR r2, [r6]
		MUL r3, r1, r0
		SUB r4, r2, r3
		STR r1, [r6]
		STR r4, [r5]
		
		# Update t coefficients
		LDR r5, =t1
		LDR r6, =t2
		LDR r1, [r5]
		LDR r2, [r6]
		MUL r3, r1, r0
		SUB r4, r2, r3
		STR r1, [r6]
		STR r4, [r5]
		
		# Calculate new remainder
		LDR r5, =rem2
		LDR r6, =rem1
		
		LDR r0, [r5]
		LDR r1, [r6]
		BL modulo
		LDR r1, [r6]
		STR r1, [r5]
		STR r0, [r6]
		
		# End loop if remainder is 0
		CMP r0, #0
		BNE loopExtEuclidean
		B returnCprivexp
		
	makePositive:
		LDR r3, =totient
		LDR r2, [r3]
		ADD r0, r0, r2
		STR r0, [r1]
		B returnCprivexp

    	returnCprivexp:
		# Return private key 'd' (stored in t2)
		LDR r1, =t2
		LDR r0, [r1]

		# add totient to t2 if not positive
		CMP r0, #0
		BLT makePositive

		# Restore and return
		LDR lr, [sp, #0]
		LDR r4, [sp, #4]
		LDR r5, [sp, #8]
		LDR r6, [sp, #12]
		ADD sp, sp, #16
		MOV pc, lr

.data
	rem1: .word 0
	rem2: .word 0
	t1: .word 0
	t2: .word 0
	s1: .word 0
	s2: .word 0
	q1: .word 0
	totient: .word 0

#END FUNCTION cprivexp


.text
encrypt:
	
	#Function Dictionary
	#r4 - Public key exponent
	#r5 - Modulus
	#r6 - Input string
	#r8 - Encrypt loop counter
	#r9 - encrypt.txt file pointer

	#Push the stack
	SUB sp, sp, #28
	STR lr, [sp]
	STR r4, [sp, #4]
	STR r5, [sp, #8]
	STR r6, [sp, #12]
	STR r7, [sp, #16]
	STR r8, [sp, #20]
	STR r9, [sp, #24]

	MOV r4, r1
	MOV r5, r2
	MOV r6, r0
	MOV r8, #0

	LDR r0, =filename
	LDR r1, =filetask
	BL fopen

	MOV r9, r0

	encryptloop:
		CMP r8, #50
		BEQ endencryptloop

		LDRB r2, [r6, r8]
		CMP r2, #0
		BEQ endencryptloop
		
		MOV r0, r2
		MOV r1, r4
		BL pow

		MOV r2, r5
		BL modLarge
		MOV r2, r0

		LDR r1, =numberformat
		MOV r0, r9
		BL fprintf
		
		ADD r8, r8, #1
		B encryptloop

	endencryptloop:	

	MOV r0, r9
	BL fclose

        #Pop the stack
        LDR lr, [sp]
        LDR r4, [sp, #4]
        LDR r5, [sp, #8]
	LDR r6, [sp, #12]
	LDR r7, [sp, #16]
	LDR r8, [sp, #20]
	LDR r9, [sp, #24]
        ADD sp, sp, #28
        MOV pc, lr
.data
	filename: .asciz "encrypted.txt"
	numberformat: .asciz "%d "
	filetask: .asciz "w"
#END FUNCTION encrypt


.text
decrypt:
    # AUTHOR: Adit Rao
    # PURPOSE: Read encrypted.txt, use private key exponent and modulus to produce decrypted.txt

    # Function dictionary
    # r4 - private key (d)
    # r5 - modulus (n)
    # r6 - decrypt.txt file ptr
    # r7 - encrypt.txt file ptr
    # r8 - numFormat
    # r9 - charFormat

    # Push
    SUB sp, sp, #20
    STR lr, [sp]
    STR r4, [sp,#4]
    STR r5, [sp,#8]
    STR r6, [sp,#12]
    STR r7, [sp,#16]

    # Vault key data
    MOV r4, r1 // assume 'd' initially stored in r1
    MOV r5, r2 // assume 'n' initially stored in r2

    # Open read filestream, store ptr in r7
    LDR r0, =in_File
    LDR r1, =r_FileTask
    BL fopen
    MOV r7, r0 

    # Check for correct file open
    CMP r7, #0
    BEQ openERR    

    # Open write filestream, store ptr in r6
    LDR r0, =out_File
    LDR r1, =w_FileTask
    BL fopen
    MOV r6, r0
   
    decryptLoop:
	# Load arguments to fscanf
        MOV r0, r7  
	LDR r1, =numFormat
	LDR r2, =next_in
	BL fscanf

	# Check for EOF	
	CMP r0, #-1
	BEQ endDecryptLoop

	LDR r0, =next_in
	LDR r0, [r0]

        MOV r1, r4 // move 'd' to r1 for POW function
        BL pow

        MOV r2, r5 // move 'n' into r1 for MODULO
        BL modLarge
        
	# Load arguments to fprintf
	MOV r2, r0
	MOV r0, r6
	LDR r1, =charFormat
	BL fprintf	

        B decryptLoop

    openERR:
 	LDR r0, =openError
	BL printf
	B end

    endDecryptLoop:
        MOV r0, r7
        BL fclose
    
        MOV r0, r6
        BL fclose

        LDR r0, =finish
        BL printf

    end:
        # Pop
        LDR lr, [sp]
        LDR r4, [sp,#4]
        LDR r5, [sp,#8]
        LDR r6, [sp,#12]
        LDR r7, [sp,#16]
        ADD sp, sp, #20
        MOV pc, lr

	
.data
    in_File: .asciz "encrypted.txt"
    out_File: .asciz "decrypted.txt"
    numFormat: .asciz "%d"
    charFormat: .asciz "%c"
    r_FileTask: .asciz "r"
    w_FileTask: .asciz "w"
    next_in: .word 0
    openError: .asciz "!! ERROR: File not opened !!"
    finish: .asciz "Your cipher was decrypted and stored in 'decrypted.txt'.\n"

#END FUNCTION decrypt


.text
findPrime:

        #Push the stack record
        SUB sp, sp, #20
        STR lr, [sp, #0]
        STR r4, [sp, #4]
        STR r5, [sp, #8]
        STR r6, [sp, #12]
        STR r7, [sp, #16]

        MOV r4, r0
	MOV r5, #2
	MOV r1, r5

	BL __aeabi_idiv

	MOV r6, r0
	MOV r7, #0

	
	primeCheckLoop:

		CMP r5, r6
		BGT endPrimeCheckLoop

		MOV r0, r4
		MOV r1, r5

		BL modulo

		CMP r0, #0
		BEQ notPrime
		ADD r5, r5, #1
		B primeCheckLoop

		notPrime:
			MOV r7, #1
			B endPrimeCheckLoop


	endPrimeCheckLoop:

	MOV r0, r7	

        #Pop the stack record
        LDR lr, [sp, #0]
        LDR r4, [sp, #4]
        LDR r5, [sp, #8]
        LDR r6, [sp, #12]
        LDR r7, [sp, #16]
        ADD sp, sp, #20
        MOV pc, lr	

.data
#END FUNCTION findPrime
