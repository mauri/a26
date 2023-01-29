; Simple kernel that renders a rainbow 

; Based on the stella programming series with some adjustments for
; correct VBLANK handling
;
    processor 6502
    include "vcs.h"
    include "macro.h"

    SEG
    ORG $F000       ; start of cartridge memory area

Reset
    ; clear all memory and registers

    lda #0
    ldx #0
Clear
    sta 0,x
    inx
    bne Clear

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
    sta WSYNC
    inx
    cpx #37                 ; compare x with 37 sets zero flag if x equal 37
    bne VerticalBlank       ; branch to VerticalBlank if zero is clear 

    lda #0
    sta VBLANK ; end VBLANK

; start picture 
    ldx #0
Picture
    stx COLUBK              ; set background color to x

    sta WSYNC               ; wait for scanline to finish
    inx                     ; increment x
    cpx #192                ; compare and sets zero flag if x == 192
    bne Picture             ; jump if not zero
; end picture

    lda #%01000010
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

