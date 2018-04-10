
// kick assembler, c128 tests

#import "c128system.asm"
#import "c128macros.asm"

:BasicUpstart128(MAIN) 		// I like to use : to indicate a macro call.

MAIN:
		:SetBankConfiguration(15) 	// set bank 15

		:SetVDCUpdateAddress($0000)
		ldy #0 			// loop counter
		lda #$01 		// char code 01
		ldx #31 		// internal data register of the VCD.
						// all data to VDC must flow trough this register.
!:
		jsr WRITE_VDC
		dey
		bne !-

// char display ok

		ldx #22
		jsr READ_VDC
		and #%11110000
		ora #%00000100      // set horizontal display to 4
		jsr WRITE_VDC

		ldx #23
		lda #3 				// vertical display to 4
		jsr WRITE_VDC
		rts

// assemble sub routines.

WRITE_VDC:
		:WriteVDC()
		rts
READ_VDC:
		:ReadVDC()
		rts

