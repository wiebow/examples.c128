
// kick assembler, c128 tests

#import "c128system.asm"
#import "c128macros.asm"

:BasicUpstart128(MAIN) 		// I like to use : to indicate a macro call.

MAIN:
		:SetBankConfiguration(15) 	// set bank 15
		:Go80()

		:SetVDCUpdateAddress($0000)
		ldy #0 			// loop counter
		lda #0
		sta $fb
		ldx #31 		// internal data register of the VCD.
						// all data to VDC must flow trough this register.
!:
		lda $fb
		jsr WRITE_VDC
		inc $fb
		dey
		bne !-

		ldx #9
		lda #8
		jsr WRITE_VDC

		// we change the vertical character display from 7 to 0.

		lda #7
		sta $fb
!:
		ldx #23
		lda $fb
		jsr WRITE_VDC
		jsr DELAY
		dec $fb
		bpl !-
		rts
DELAY:
		ldx #50
		ldy #0
!:
		dey
		bne !-
		dex
		bne !-
		rts


// assemble sub routines.

WRITE_VDC:
		:WriteVDC()
		rts
READ_VDC:
		:ReadVDC()
		rts

