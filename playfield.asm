; Simple example of using the playfield

    processor 6502
    include "vcs.h"
    include "macro.h"

    SEG.U data
    ORG $80

pattern ds 1

    SEG code
    ORG $F000       ; start of cartridge memory area

;;

;;
Reset
    ; clear all memory and registers
    lda #0
    ldx #0
Clear
    sta 0,x
    inx
    bne Clear

    lda #$E0 ; #$46
    sta COLUPF      ; playfield color

StartOfFrame

    lda #2
    sta VSYNC ; set D1 to 1 in VSYNC for 3 scanlines

    sta WSYNC
    sta WSYNC
    sta WSYNC

    lda #0
    sta VSYNC

    ldx #0
VerticalBlank
    sta WSYNC               ; some logic can be added here
    inx
    cpx #37                 ; compare x with 37 sets zero flag if x equal 37
    bne VerticalBlank       ; branch to VerticalBlank if zero is clear 

; horsing around to check the WSYNC is needed before resetting VBLANK
    lda pattern
    sta PF1
    adc pattern
    adc pattern
    adc pattern
    sta pattern

    ldx #0
    stx WSYNC
    stx VBLANK ; end VBLANK

;--------------------------------------------------+
; start picture      (228 color-cycles per scanline)
Picture
    stx COLUBK              ; set background color

    stx PF1                 ; set playfield1
    stx PF2                 ; set playfield2 (notice in the image how it's reversed)
    stx PF0                 ; set playfield0 (notice it's reversed and only the high nibble used)

    REPEAT 11               ; 
        nop                 ; 
    REPEND                  ;
    
    lda #0                  ; clear the playfield registers in the middle of the scanline
    sta PF1
    sta PF0
    sta PF2                 ; here we are at 46 cpu-cycles into the scanline ~> 138 color-cycles
                            ; efectively before reaching half the screen

    inx                     ; increment x
    sta pattern
    sta WSYNC               ; wait for scanline to finish
    cpx #192                ; compare and sets zero flag if x == 192
    bne Picture             ; jump if not zero
; end picture
;---------------------------------------------------+

    lda #2
    sta VBLANK  ; start VBLANK period

    ; 30 scanlines for overscan
    REPEAT 30
        sta WSYNC
    REPEND

    jmp StartOfFrame

    ORG $FFFA

    .word Reset     ; NMI
    .word Reset     ; RESET
    .word Reset     ; IRQ

