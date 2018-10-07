; Author : Matthew Romleski
; Tech ID: 12676184
; Program that reads a 40 element 8-bit array, swaps the low bits with the high bits,
; stores that value in data memory if it's > 38 && < 118 (writing 0 otherwise), then
; adds all those numbers together while storing the result in r1:r0.

			.include <atxmega128A1Udef.inc>

			.dseg
			.def	resultLow	= r0
			.def	resultHigh	= r1
			.def	storeReg	= r16
			.def	loopConReg	= r17
			.def	zeroReg		= r18

			.cseg
			.org	0x00
			rjmp	start
			.org	0xF6

start:		ldi		ZL, low(array << 1) ; Gets the byte address of the program memory.
			ldi		ZH, high(array << 1) ; ^^
			ldi		XL, 0x00 ; Sets the start point to store info in data memory.
			ldi		XH, 0x20 ; ^^
			ldi		zeroReg, 0 ; Sets the zero register.
			ldi		loopConReg, 1 ; Initial value for the loop condition.

swapLoop:	cpi		loopConReg, 41 ; Checks if the loop has gone through all the elements.
			breq	addLpSetup ; Branches if it has.
			lpm		storeReg, Z+ ; Loads an element into the register.
			swap	storeReg ; Swaps the nibbles of the element (bits 0-3 get swapped with bits 4-7).
			jmp		test39 ; Jump to our tests for the swapped number.
			
test39:		cpi		storeReg, 39 ; Compares the swapped number with 39.
			brlt	storeZero ; If that number is < 39, we store a zero.
			jmp		test117 ; Else, we test if it's <= 117.

test117:	cpi		storeReg, 118 ; Compares the swapped number with 39.
			brlt	storeReal ; If storeReg < 118 (<= 117), then we store it.
			jmp		storeZero ; Else we store a zero.

storeZero:	ldi		storeReg, 0 ; Load a 0 to be stored.
			st		X+, storeReg ; Stores said value.
			jmp		loopInc

storeReal:  st		X+, storeReg ; Stores the swapped number.
			jmp		loopInc

loopInc:	inc		loopConReg ; Increments the condition.
			jmp		swapLoop ; Loops.

addLpSetup:	ldi		loopConReg, 1 ; Resets the loop condition.
			ldi		XL, 0x00 ; Reset the data memory pointer (X pointer, in this case).
			ldi		XH, 0x20 ; ^^
			jmp		addLoop ; Starts the addition loop.

addLoop:	cpi		loopConReg, 41 ; Checks if the loop has gone through all the elements.
			breq	done ; Ends the program if it has.
			ld		storeReg, X+ ; Loads the element from data memory.
			add		resultLow, storeReg ; Adds that element to the result.
			adc		resultHigh, zeroReg ; Preforms any carry.
			inc		loopConReg ; Increments the condition.
			jmp		addLoop ; Loops.

done:		rjmp	done

array:		.db		 1,  2,  3,  4,  5,  6,  7,  8,  9, 10
			.db		11, 12, 13, 14, 15, 16, 17, 18, 19, 20
			.db		21, 22, 23, 24, 25, 26, 27, 28, 29, 30
			.db		31, 32, 33, 34, 35, 36, 37, 38, 39, 40