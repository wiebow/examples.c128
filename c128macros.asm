
#importonce // and import AFTER c128system.asm

/*----------------------------------------------------------
 BasicUpstart for C128

 Syntax:    :BasicUpstart(address)
 Usage example: :BasicUpstart($2000)
             Creates a basic program that sys' the address
------------------------------------------------------------*/
.macro BasicUpstart128(address) {
    .pc = $1c01 "C128 Basic"
    .word upstartEnd  // link address
    .word 10   // line num
    .byte $9e  // sys
    .text toIntString(address)
    .byte 0
upstartEnd:
    .word 0  // empty link signals the end of the program
    .pc = $1c0e "Basic End"
}

/*----------------------------------------------------------
 Banking, RAM configurations

 bits:
 0:   $d000-$dfff (i/o block, ram or rom)
 1:   $4000-$7fff (lower basic rom)
 2-3: $8000-$bfff (upper basic rom, monitor, internal/external ROM)
 4-5: $c000-$ffff (char ROM, kernal, internal/external ROM, RAM)
 6:   select RAM block

 Setting a bit means RAM, clearing means ROM.
 Use the BASIC Bank configuration numbers.

 Syntax:		:SetBankConfiguration(number)
----------------------------------------------------------*/
.macro SetBankConfiguration(id) {
	.if(id==0) {
		lda #%00111111 	// no roms, RAM 0
	}
	.if(id==1) {
		lda #%01111111 	// no roms, RAM 1
	}
	.if(id==12) {
		lda #%00000110 	// internal function ROM, Kernal and IO, RAM 0
	}
	.if(id==14) {
		lda #%00000001 	// all roms, char ROM, RAM 0
	}
	.if(id==15) {
		lda #%00000000  // all roms, RAM 0. default setting.
	}
	.if(id==99) {
		lda #%00001110  // IO, kernal, RAM0. No basic,48K RAM.
	}
	sta MMUCR
}


/*----------------------------------------------------------
Configure common RAM amount.

RAM Bank 0 is always the visible RAM bank.
Valid values are 1,4,8 and 16.

Syntax:		:SetCommonRAM(1)
----------------------------------------------------------*/
.macro SetCommonRAM(amount) {
	lda MMURCR
	and #%11111100 			// clear bits 0 and 1. this is also option 1
	.if(amount==4) {
		ora #%00000001
	}
	.if(amount==8) {
		ora #%00000010
	}
	.if(amount==16) {
		ora #%00000011
	}
	sta MMURCR
}

/*----------------------------------------------------------
Configure where common RAM is enabled. Top, bottom, or both.
Valid options are 1, 2 or 3.
1 = bottom (default)
2 = top
3 = bottom and top

Syntax:		:SetCommonEnabled(1)
----------------------------------------------------------*/
.macro SetCommonEnabled(option) {
	lda MMURCR
	and #%11110011 			// clear bits 2 and 3
	ora #option*4
	sta MMURCR
}

/*----------------------------------------------------------
 Set RAM block that the VIC chip will use, bit 6 of MMUCR.
 Only useful for text display. Pretty useless, really.
 Kernal routines use RAM0, so you need to roll your own routines.

 Use SetVICBank() to set the 16k block that the VIC will use in that block.

 Syntax:		:SetVICRamBank(0 or 1)
 ----------------------------------------------------------*/
.macro SetVICRAMBank(value) {
	lda MMURCR
	and #%10111111 			// clear bit 6
	.if(value==1) {
		ora #%01111111 		// enable bit 6
	}
	sta MMURCR
}

/*----------------------------------------------------------
 Sets 16K block that VIC is looking at.
 0 = $0000 - $3fff
 1 = $4000 - $7fff
 2 = $8000 - $bfff
 3 = $c000 - $ffff

 Syntax:		:SetVICBank(1)
----------------------------------------------------------*/
.macro SetVICBank (bank) {
	lda $dd00
	and #%11111100
	ora #3-bank
	sta $dd00
}

/*----------------------------------------------------------
 Sets the 2K offset in the VIC 16K block where the character set
 is read from. The offset must be an even number from 0 to 14.

 Syntax:		:SetVICCharacterOffset(2)
 If the VIC chip is using $4000-$7fff then character
 data is read from $4800  ($800 = 2048 bytes)
----------------------------------------------------------*/
.macro SetVICCharacterOffset (offset) {
	lda $d018
	and #%11110001 		// clear the 3 offset control bits
	ora	#offset
	sta $d018
}

/*----------------------------------------------------------
 Sets the 1K offset in the VIC 16K block where the screen
 memory is read from. The value can be 0-15.

 Syntax:		:SetVICMatrixOffset(1)
 If the VIC chip is using $0000-$3fff then screen
 data is read from $0400 (1k = 1024 bytes = $400 offset)
----------------------------------------------------------*/
.macro SetVICMatrixOffset (offset) {
	lda $d018
	and #%00001111 		// clear the 4 offset control bits
	.if(offset > 0) {
		ora #offset*16
	}
	sta $d018
}

/*----------------------------------------------------------
 Sets the 8k offset in the VIC 16K block where the bitmap
 data is read from. The value can be 0 or 1.
 This is only valid when bitmap mode is enabled.

 Syntax:		:SetVICBitmapOffset(1)
 If the VIC chip is using $0000-$3fff then bitmap
 data is read from $2000
----------------------------------------------------------*/
.macro SetVICBitmapOffset (offset) {
	lda $d018
	and #%11110111 		// clear bit 3. no offset.
	.if(offset==1) {
		ora #%00001000
	}
	sta $d018
}

/*----------------------------------------------------------
 Sets RAM bank that will be involved in I/O.
 Also sets bank where the filename will be found.
 Use the Basic bank definitions. (0-15)

 Syntax:		:SetIOBank(15,15)
----------------------------------------------------------*/
.macro SetIOBank (bank, bankname) {
	lda #bank
	ldx #bankname
	jsr SETBNK
}

/*----------------------------------------------------------
 Opens IO channel.

 Syntax:		:OpenIOChannel(15,8,15)
----------------------------------------------------------*/
.macro OpenIOChannel (filenumber, devicenumber,secondary) {
	lda #filenumber
	ldx #devicenumber
	ldy #secondary
	jsr SETLFS
}

/*----------------------------------------------------------
 Sets IO filename

 Syntax:		:SetIOName(4,$2000)
----------------------------------------------------------*/
.macro SetIOName (length, address) {
	lda #length
	ldx #<address
	ldy #>address
	jsr SETNAM
}

/*----------------------------------------------------------
 Sets IO input channel. Use logical file number.

 Syntax:		:SetInputChannel(1)
----------------------------------------------------------*/
.macro SetInputChannel (parameter) {
	ldx #parameter
	jsr CHKIN
}

/*----------------------------------------------------------
 Sets IO output channel. Use logical file number.

 Syntax:		:SetOutputChannel(1)
----------------------------------------------------------*/
.macro SetOutputChannel (parameter) {
	ldx #parameter
	jsr CHKOUT
}

/*----------------------------------------------------------
 Performs the chosen escape code.

 Syntax:		:DoEscapeCode('X')
----------------------------------------------------------*/
.macro DoEscapeCode (code) {
	lda #code
	jsr JESCAPE
}


// Go to 80 columns mode
.macro Go80 () {
	lda MODE 		// are we in 80 columns mode?
	bmi !+ 			// bit 7 set? then yes
	jsr SWAPPER		// swap mode to 80 columns
!:
}

/*----------------------------------------------------------
 Returns the address start of VDC display memory data. This
 is stored in VDC register 12 and 13.
 The 16-bit value is stored in $FB and $FC.
 This assumes ReadVDC macro is assembled to READ_VDC

Syntax:		:GetVDCDisplayStart()
----------------------------------------------------------*/
.macro GetVDCDisplayStart() {
	ldx #12
	jsr READ_VDC
	sta $fb
	inx
	jsr READ_VDC
	sta $fc
}

/*----------------------------------------------------------
 Set the pointer to the RAM area that is to be updated.
 The update pointer is stored in VDC register 18 and 19.
  This assumes WriteVDC macro is assembled to WRITE_VDC

 Syntax:		:SetVDCUpdateAddress($1200)

 This will point register 18 and 19 to $1200. This area
 can then be written to using WriteVDCRAM()
---------------------------------------------------------*/
.macro SetVDCUpdateAddress (address) {
	ldx #18
	lda #>address
	jsr WRITE_VDC
	inx
	.var a1 = <address
	.var a2 = >address
	.if( a1 != a2) {
		lda #<address // include if different from hi-byte.
	}
	jsr WRITE_VDC
}

/*----------------------------------------------------------
 Translates between VIC and VDC color codes.

 Syntax:		:GetVDCColor(0)
 --------------------------------------------------------*/
.macro GetVDCColor(viccolor) {
	ldx viccolor
	lda COLOR80,x
}

/*----------------------------------------------------------
 Copies a character definition to the VDC ram.

 This macro re-uses the kernal routine DLCHR ($ff62) with
 a slight changes. We cannot copy directly, each character
 definition must be padded with 8 empty bytes.
 This assumes that definition ram is set at $2000 in the VDC.

 Syntax:		:CopyDefinitionsToVDC($1200, $1600)

 Will copy a 1k block to the VDC definitions space.
 To do: use blitter here??
---------------------------------------------------------*/
.macro CopyDefinitionsToVDC (address, address_end) {
	lda #<address
	ldy #>address
	sta $da 			// pointer to start of data
	sty $db
	lda #>address_end
	sta $de 			// high byte of data end

	ldx #$12  			// write to $2000 in VDC ram
	lda #$20
	jsr WRITE_VDC
	inx
	lda #$00
	jsr WRITE_VDC

	ldy #0
loop:
	ldx #31 			// VDC data register
!:
	lda ($da),y
	jsr WRITE_VDC
	iny
	cpy #8
	bcc !-

	lda #0 				// add 8 bytes as padding
!:
	jsr WRITE_VDC
	dey
	bne !-
	clc
	lda $da
	adc #8
	sta $da
	bcc loop
	inc $db
	lda $db
	cmp $de 			// done all?
	bne loop
}



// Optional: assemble subroutines with these. Add an RTS.
// set X and/or A before calling.
// page 294 and 324 of "128 Reference Guide" for registers

.macro WriteVDC () {
	stx VDCADR
!:	bit VDCADR
	bpl !-
	sta VDCDAT
}

.macro ReadVDC () {
	stx VDCADR
!:	bit VDCADR
	bpl !-
	lda VDCDAT
}


