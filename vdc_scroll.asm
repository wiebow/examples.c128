
// kick assembler, c128 tests

#import "c128system.asm"
#import "c128macros.asm"

:BasicUpstart128(MAIN)

MAIN:
        :SetBankConfiguration(15)   // set bank 15

        // place the screen ram area at $4000

        ldx #12
        lda #$40
        jsr WRITE_VDC
        inx
        lda #$00
        jsr WRITE_VDC

        // fill the screen ram with data

        :SetVDCUpdateAddress($4000)
        lda #$40        // page to start writing to
        sta $ff
        ldy #0          // page counter and char code
        ldx #31         // internal data register of the VCD.
!:
        tya
        jsr WRITE_VDC
        iny
        bne !-
        inc $ff
        lda $ff
        cmp #$49        // done $2000 - $28ff?
        bne !-

        // add some attributes

        :SetVDCUpdateAddress($0800)
        ldy #0
        lda #%01110101
        ldx #31
!:
        jsr WRITE_VDC
        ror                     // crazy stuff
        dey
        bne !-

        ldx #25                 // write to this VDC register
        jsr READ_VDC
        ora #%01000000          // enable attributes
        jsr WRITE_VDC

        // setup done. lets scroll
        // set display start address $4000
        // we use big endian, as used by the vdc

        lda #$40
        sta $fe
        lda #$00
        sta $ff

        // reset y-fine value

        lda #0
        sta $fd

        // do y-fine adjustment. register 24 is for this
        // the lower 4 bits (values 0-9)

yfine:
        inc $fd
        lda $fd
        cmp #8          // character is 8 pixels hi (by default)
        bne cont

        // reset the y-fine register

        lda #0
        sta $fd         // clear local value
        ldx #24
        jsr READ_VDC
        and #%11100000  // reset bits 4-0
        jsr WRITE_VDC

        // go to next row
        // ....
        lda $ff
        clc
        adc #80
        sta $ff
        bcc !+
        inc $fe
        lda $fe
        cmp #$48        // scrolled to $4800?
        beq done
!:
        // update VDC display start address

        ldx #12
        lda $fe
        jsr WRITE_VDC
        inx
        lda $ff
        jsr WRITE_VDC
        jmp yfine
done:
        rts

        // increment y-fine value

cont:
        ldx #24
        jsr READ_VDC
        and #%11100000
        adc $fd
        jsr WRITE_VDC

        jsr delay
        jmp yfine

        // delay loop
delay:
        ldx #$40
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

