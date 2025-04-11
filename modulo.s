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
        SUB sp, sp, #12
        STR lr, [sp, #0]
	STR r4, [sp, #4]
	STR r5, [sp, #8]
		
	#Store divisor in r4, dividend in r5. Remainder is returned in r0.
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
