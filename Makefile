# Team 5 - Cory Drangel, Adit Rao, Forrest VanDuren, Quinn Waxter
# EN605.204.81
# 04 MAY 2025
# Course Project  - Makefile

all: RSA gcd pow modulo cpubexp cprivexp encrypt decrypt

LIB = RSALib.o
CC = gcc


RSA: RSA.o $(LIB)
	$(CC) $@.o $(LIB) -g -o $@
	./$@

gcd: gcd.o $(LIB)
	$(CC) $@.o $(LIB) -g -o $@
	./$@

pow: pow.o $(LIB)
	$(CC) $@.o $(LIB) -g -o $@
	./$@

modulo: modulo.o $(LIB)
	$(CC) $@.o $(LIB) -g -o $@
	./$@

cpubexp: cpubexp.o $(LIB)
	$(CC) $@.o $(LIB) -g -o $@
	./$@

cprivexp: cprivexp.o $(LIB)
	$(CC) $@.o $(LIB) -g -o $@
	./$@

encrypt: encrypt.o $(LIB)
	$(CC) $@.o $(LIB) -g -o $@
	./$@

decrypt: decrypt.o $(LIB)
	$(CC) $@.o $(LIB) -g -o $@
	./$@

findPrime: findPrime.o $(LIB)
	$(CC) $@.o $(LIB) -g -o $@
	./$@



.s.o:
	$(CC) $(@:.o=.s) -g -c -o $@


clean:
	rm *.o 


