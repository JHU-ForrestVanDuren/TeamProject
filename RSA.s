# EN605.204.81: Course Project (RSA Encrypt/Decrypt Application)
# Team 5: 	Cory Drangel, Adit Rao, Forrest Van Duren, Quinn Waxter
# Purpose: 	Generate develop an implementation of RSA algorithm
#		Develop driver file RSA.s
#		Develop Library with supporting functions	 
# 04 MAY 2025

# This is the RSA driver file which will tie the other functions together
# ******************************************************************************


.global main
.text

main:

	# Dictionary
	# r4 is %4 result to verify correct selection
        # r5 - totient
	# r6 - n
	# r7 - e
	# r8 - Current file pointer
	# r9 - d
	# r11 = Initial choice
	
	#Push
	Sub sp, sp, #28
	STR lr, [sp]
	STR r4, [sp, #4]
	STR r5, [sp, #8]
	STR r6, [sp, #12]
	STR r7, [sp, #16]
	STR r8, [sp, #20]
	STR r11,[sp, #24] 
		
	# Prompt for initial selection
	LDR r0, =mainPrompt
	BL printf

	# Validates that user selection is between 1-3
	CheckEntry:

		#Prompt user to select a program to run
		LDR r0, =choices
		BL printf

		#Take user input
		LDR r0, =numFormat
		LDR r1, =mainSelection
		BL scanf

		# Store choice for safe-keeping
		LDR r11, =mainSelection
		LDR r11, [r11] 
		MOV r1, r11

		# Test > 0
		MOV r2, #0 // LogiBit1
		CMP r1, #0
	 	ADDGT r2, r2, #1

		# Test < 4
		MOV r3, #0 // LogiBit2
		CMP r1, #4
		ADDLT r3, r3, #1

		AND r0, r2, r3
		CMP r0, #1
		
		BEQ Proceed

			#Give invalid input prompt
  			LDR r0, =invalid
			BL printf
			
			#Clear stdin and branch back to CheckEntry
			LDR r0, =invalidformat
			BL scanf

			B CheckEntry
	
	Proceed:

		MOV r1, r11 // Restore selection to r1 (in case it was overwritten)
		MOV r2, #2

		#Branch to generate, encrypt or decrypt flow based on the user input
		CMP r1, r2
		BLT Generate
			BGT Decrypt
			B Encrypt

		Generate:

		#Prompt that user has selected the generate flow
		LDR r0, =generate
		BL printf
		
		primeLoop1:

			#Prompt for prime number
			LDR r0, =pprompt
			BL printf

			#Take user input for prime number
			LDR r0, =numFormat
			LDR r1, =p
			BL scanf
				
			#Initialize logical variables
			MOV r1, #0
			MOV r2, #0

			#Load user input into r0
			LDR r0, =p
			LDR r0, [r0]

			#Check if input is between 13 and 47 and branch to invalidp if not
			CMP r0, #13
			MOVGE r1, #1
			CMP r0, #47
			MOVLE r2, #1
			AND r1, r1, r2
			CMP r1, #1
			BNE invalidp

			#Check if number is prime, branch to invalid if not
			BL findPrime
			CMP r0, #1
			BEQ invalidp
			B endPrimeLoop1	

			invalidp:

				#Give invalid prompt
				LDR r0, =invalid
				BL printf

				#Clear stdin and loop
				LDR r0, =invalidformat
				BL scanf
				B primeLoop1

		endPrimeLoop1:

                primeLoop2:

			#Prompt for unique prime
                        LDR r0, =qprompt
                        BL printf

			#Read user input
                        LDR r0, =numFormat
                        LDR r1, =q
                        BL scanf

			#Initialize logical variables
                        MOV r1, #0
                        MOV r2, #0

			#Load user input into r0
                        LDR r0, =q
                        LDR r0, [r0]

			#Check if input between 13 and 47, branch to invalidq if not
                        CMP r0, #13
                        MOVGE r1, #1
                        CMP r0, #47
                        MOVLE r2, #1
                        AND r1, r1, r2
                        CMP r1, #1
			BNE invalidq

			#Load p into r3
			LDR r3, =p
			LDR r3, [r3]

			#If p = q branch to invalid
			CMP r0, r3
                        BEQ invalidq

			#Check if prime, branch to invalid if not
                        BL findPrime
                        CMP r0, #1
                        BEQ invalidq
                        B endPrimeLoop2


                        invalidq:

				#Give invalid prompt
                                LDR r0, =invalid
                                BL printf

				#Clear stdin and loop
                                LDR r0, =invalidformat
                                BL scanf
                                B primeLoop2

                endPrimeLoop2:

		#Load the input primes into r0 and r1
		LDR r0, =p
		LDR r0, [r0]
		LDR r1, =q
		LDR r1, [r1]

		#Calculate n and store in r6
		MUL r6, r0, r1

		#Determine the totient: totient = (p-1)(q-1)
		SUB r0, r0, #1
		SUB r1, r1, #1

        	#Store the totient in r5
        	MUL r5, r0, r1

		eloop:

			#Give prompt for e
			LDR r0, =eprompt
			MOV r1, r5
			MOV r2, r5
			BL printf

			#Take user input
			LDR r0, =numFormat
			LDR r1, =e
			BL scanf

			#Load user input into r7	
			LDR r7, =e
			LDR r7, [r7]

			#Check if user input is a valid public key exponent, branch to inavlid if not
			MOV r0, r7
			MOV r1, r5
			BL cpubexp
			CMP r0, #1
			BNE enotvalid
			B endeloop

			enotvalid:

				#Give invalid input prompt
				LDR r0, =invalid
				BL printf

				#Clear stdin and loop
				LDR r0, =invalidformat
				BL scanf
				B eloop

		endeloop:

		#Generate private key from e and the totient
	       	MOV r0, r5
		MOV r1, r7
		BL cprivexp

		#Store private key in r9
		MOV r9, r0

		#Open/Create public key file with write task
		LDR r0, =pubKeyFile
		LDR r1, =writeTask
		BL fopen
		
		#Store file pointer in r0
		MOV r8, r0

		#Write n to public key file
		LDR r1, =numFormatSpace
		MOV r2, r6
		BL fprintf

		#Write e to public key file
		LDR r1, =numFormatSpace
		MOV r0, r8
		MOV r2, r7
		BL fprintf

		#Close the file
		MOV r0, r8
		BL fclose

		#Open/create private key file with write task
		LDR r0, =privKeyFile
		LDR r1, =writeTask
		BL fopen
	
		#Save file pointer to r8
		MOV r8, r0

		#Write private key exponent to file
		LDR r1, =numFormat
		MOV r2, r9
		BL fprintf

		#Close the file
		MOV r0, r8
		BL fclose

		B End			

		Encrypt:

		#Prompt that user has chosen encrypt flow
		LDR r0, =encryptPrompt
		BL printf

		#Read the users input
		LDR r0, =messageFormat
		LDR r1, =message
		BL scanf
		
		#Open pubkey file with read task
		LDR r0, =pubKeyFile
		LDR r1, =readTask
		BL fopen

		#If no file pointer is returned, branch to noPublicKey
		CMP r0, #0
		BEQ noPublicKey 

		#Save file pointer to r8
		MOV r8, r0

		#Read n from pubkey file
		LDR r1, =numFormat
		LDR r2, =n
		BL fscanf

		#Move file pointer to r0
		MOV r0, r8

		#Read e from pubkey file
		LDR r1, =numFormat
		LDR r2, =e
		BL fscanf

		#Close file
		MOV r0, r8
		BL fclose

		#Load e and n into r1, and r3
		LDR r1, =e
		LDR r1, [r1]
		LDR r2, =n
		LDR r2, [r2]

		#Store message to encrypt in r0 and call encrypt
		LDR r0, =message
		BL encrypt
		B End

		noPublicKey:
			
			#Prompt that no key file exists and branch to end
			LDR r0, =noKeyFilePrompt
			BL printf
			B End

		Decrypt:

		#Prompt that user has selected decrypt flow
		LDR r0, =decryptPrompt
		BL printf
		
		# Open file with public key and store *file in r8
		LDR r0, =pubKeyFile
		LDR r1, =readTask
		BL fopen
		MOV r8, r0

		#If no file pointer is returned, branch to noPrivateKey
		CMP r0, #0
		BEQ noPrivateKey
		
		# Store 'n' for later use
		LDR r1, =numFormat
		LDR r2, =n
		BL fscanf
		
		# Open file with private key and store *file in r8
		LDR r0, =privKeyFile
		LDR r1, =readTask
		BL fopen
		MOV r8, r0
		
		# Store 'd' for later use
		LDR r1, =numFormat
		LDR r2, =d
		BL fscanf

		# Now store d,n to correct registers for decrypt function	
		LDR r1, =d
		LDR r1, [r1]
		LDR r2, =n
		LDR r2, [r2]

		BL decrypt
		B End

		noPrivateKey:
				
			#Prompt that no private key file exists and branch to end
			LDR r0, =noKeyFilePrompt
			BL printf
			B End

	End:
		#Pop	
		LDR lr, [sp,#0]
		LDR r4, [sp, #4]
		LDR r5, [sp, #8]
		LDR r6, [sp, #12]
		LDR r7, [sp, #16]
		LDR r8, [sp, #20]
		LDR r11,[sp,#24]
		ADD sp, sp, #28
		MOV pc, lr



.data

	mainPrompt: .asciz "\n\n***** WELCOME TO RSA ENCRYPT/DECRYPT APP *****"
	choices: .asciz "\n\n\tPlease choose from the following:\n\t[1] Generate Public & Private Keys\n\t[2] Encrypt\n\t[3] Decrypt\n\nMake your selection: "
	invalid: .asciz "\n\t!! ERROR: Invalid Entry !!\n"
	invalidformat: .asciz "%*[^\n]"
#	valid: .asciz "Ok you can continue...\n"
#	entry: .asciz "Entry is %d.\n"
	generate: .asciz "Here we will branch to the generate function flow.\n"
	encryptPrompt: .asciz "Input a message to be encrypted\n"
	decryptPrompt: .asciz "Here we will branch to the decrypt function flow.\n"
	noKeyFilePrompt: .asciz "No key file is present. Generate the keys before running encrypt\n"
	messageFormat: .asciz " %[^\n]"
	message: .space 50
	numFormat: .asciz "%d"
	numFormatSpace: .asciz "%d "
	mainSelection: .word 0
        p: .word 0
        q: .word 0
	e: .word 0
	n: .word 0
	d: .word 0
	pprompt: .asciz "Enter a prime number between 13 and 47 \n"
	qprompt: .asciz "Enter another prime number between 13 and 47 that is distinct from your last input\n"
	eprompt: .asciz "Enter a number greater then 1 and less then %d which is also co prime to %d\n"
	pubKeyFile: .asciz "pubkey.txt"
	privKeyFile: .asciz "privkey.txt"
	writeTask: .asciz "w"
	readTask:  .asciz "r"
