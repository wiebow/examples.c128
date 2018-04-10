
// kick assembler, c128 tests

#import "c128system.asm"
#import "c128macros.asm"

:BasicUpstart128(MAIN) 		// I like to use : to indicate a macro call.

MAIN:
		:SetBankConfiguration(15) 	// set bank 15

		// check bit 4 of register 18
		// set means the VCD is configured to use a 64K RAM chip

		ldx #18
		jsr READ_VDC
		sta $fb
		lda #%00010000
		bit $fb

		bne big
		lda #$31
		jsr $ffd2
		rts
big:
		lda #$30
		jsr $ffd2
		rts

// assemble sub routines.

WRITE_VDC:
		:WriteVDC()
		rts
READ_VDC:
		:ReadVDC()
		rts

