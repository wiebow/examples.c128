
// kick assembler, c128 tests

#import "c128system.asm"
#import "c128macros.asm"

:BasicUpstart128(MAIN)

MAIN:
		:SetBankConfiguration(15)
		:SetVDCUpdateAddress($0000)
		ldy #0 			// loop counter
		ldx #31 		// internal data register of the VCD.
						// all data to VDC must flow trough this register.
!:
		tya
		jsr WRITE_VDC
		iny
		bne !-

		:CopyDefinitionsToVDC(charset, charset_end)
		:Go80()
		rts

WRITE_VDC:
		:WriteVDC()
		rts
READ_VDC:
		:ReadVDC()
		rts

.pc = $2000 "character set"
charset:
.import binary "tetris_chars2.raw"
charset_end:
