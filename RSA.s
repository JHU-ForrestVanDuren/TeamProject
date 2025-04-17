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
	# r11 = Initial choice
	
	#Push
	Sub sp, sp, #4
	STR lr, [sp]
	STR r11,[sp, #4] 
		
	# Prompt for initial selection
	LDR r0, =mainPrompt
	BL printf

	# Validates that user selection is between 1-3
	CheckEntry:
		LDR r0, =choices
		BL printf
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
	 	ADDGE r2, r2, #1

		# Test < 4
		MOV r3, #0 // LogiBit2
		CMP r1, #4
		ADDLT r3, r3, #1

		AND r0, r2, r3
		CMP r0, #1
		
		BEQ Proceed
			LDR r0, =invalid
			BL printf
			B CheckEntry
	

	Proceed:

		MOV r1, r11 // Restore selection to r1 (in case it was overwritten)
		MOV r2, #2

		CMP r1, r2
		BLT Generate
			BGT Decrypt
			B Encrypt

		Generate:
		LDR r0, =generate
		BL printf
		B End			

		Encrypt:
		LDR r0, =encryptPrompt
		BL printf

		#Read the users input
		LDR r0, =messageFormat
		LDR r1, =message
		BL scanf

		#Store message to encrypt in r0 and call encrypt
		LDR r0, =message
		BL encrypt
		B End

		Decrypt:
		LDR r0, =decrypt
		BL printf
		B End


	End:
		#Pop	
		LDR lr, [sp,#0]
		LDR r11,[sp,#4]
		ADD sp, sp, #8
		MOV pc, lr



.data

	mainPrompt: .asciz "\n\n***** WELCOME TO RSA ENCRYPT/DECRYPT APP *****"
	choices: .asciz "\n\n\tPlease choose from the following:\n\t[1] Generate Public & Private Keys\n\t[2] Encrypt\n\t[3] Decrypt\n\nMake your selection: "
	invalid: .asciz "\n\t!! ERROR: Invalid Entry !!"
#	valid: .asciz "Ok you can continue...\n"
#	entry: .asciz "Entry is %d.\n"
	generate: .asciz "Here we will branch to the generate function flow.\n"
	encryptPrompt: .asciz "Input a message to be encrypted\n"
	decrypt: .asciz "Here we will branch to the decrypt function flow.\n"
	messageFormat: .asciz " %[^\n]"
	message: .space 50
	numFormat: .asciz "%d"
	mainSelection: .word 0


