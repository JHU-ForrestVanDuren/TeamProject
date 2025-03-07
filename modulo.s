#
# Program Name:     modulo.s
# Author:           Forrest VanDuren
# Date:             03/06/2025
# Purpose:          Take modulo of two values and return
#

.text
.global modulo

#Set r0 to dividend and r1 to divisor before calling function
modulo:
        #Push the stack record
        SUB sp, sp, #4
        STR lr, [sp, #0]
       	#MOV r1, #8 @Remove comment to test
	#MOV r0, #7 @Remove comment to test
		
	#Store divisor in r4, dividend goes to r3 after the __aeabi_idiv call. Remainder is returned in r1.
	MOV r4, r1
	BL __aeabi_idiv
	MUL r4, r0, r4
	SUB r1, r3, r4	

        #Pop the stack record
        LDR lr, [sp, #0]
        ADD sp, sp, #4
        MOV pc, lr

.data
