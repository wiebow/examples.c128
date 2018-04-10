
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

		:SetVDCUpdateAddress($0800)
		ldy #0
		lda #%01110101
		ldx #31
!:
		jsr WRITE_VDC
		ror 			// crazy stuff
		dey
		bne !-

		ldx #25 			// write to this VDC register
		jsr READ_VDC
		ora #%01000000 		// enable attributes
		jsr WRITE_VDC
		rts

// assemble sub routines.

WRITE_VDC:
		:WriteVDC()
		rts
READ_VDC:
		:ReadVDC()
		rts

