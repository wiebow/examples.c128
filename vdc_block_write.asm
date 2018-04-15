
// kick assembler, c128 tests

#import "c128system.asm"
#import "c128macros.asm"

:BasicUpstart128(MAIN) 		// I like to use : to indicate a macro call.

MAIN:
		:SetBankConfiguration(15) 	// set bank 15

// write to $0000 in VDC RAM

		ldx #18
		lda #00
		jsr WRITE_VDC
		inx
		jsr WRITE_VDC

		lda #$fe 			// write this value
		ldx #31 			// vdc data register

		ldx #24 			// select write option
		jsr READ_VDC 
		and #%01111111 		// by clearing bit 7 of reg 24
		jsr WRITE_VDC

		lda #$ff 			// how many bytes to write
		ldx #30
		jsr WRITE_VDC

// copy data in DCV RAM from $0000 to $0200

		// set destination address

		ldx #18
		lda #$02
		jsr WRITE_VDC
		inx	
		lda #$00
		jsr WRITE_VDC

		ldx #24 			// select block copy option
		jsr READ_VDC 
		ora #%10000000 		// by setting bit 7 of reg 24
		jsr WRITE_VDC

		// set source address

		ldx #32
		lda #$00
		jsr WRITE_VDC
		inx
		jsr WRITE_VDC

		lda #$a0 			// amount of bytes to copy
		ldx #30
		jsr WRITE_VDC
		rts

// assemble sub routines.

WRITE_VDC:
		:WriteVDC()
		rts
READ_VDC:
		:ReadVDC()
		rts
