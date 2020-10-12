; Simple example of using the playfield

    processor 6502
    include "vcs.h"
    include "macro.h"

    SEG
    ORG $F000       ; start of cartridge memory area

;;
PATTERN = $80       ; storage location 
TIMETOCHANGE = 80   ; 1/speed of the animation

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
    lda PATTERN
    sta PF1
    adc PATTERN
    adc PATTERN
    adc PATTERN
    sta PATTERN

    ldx #0
    stx WSYNC
    stx VBLANK ; end VBLANK

;--------------------------------------------------+
; start picture 
Picture
    stx COLUBK              ; set background color
    stx PF1                 ; set playfield1
    stx PF2                 ; set playfield2 (notice in the image how it's reversed)
    stx PF0                 ; set playfield0 (notice it's reversed and only the high nibble used)

    REPEAT 7        ; messing up with the playfield in the middle of the scanline
        nop         ; 
    REPEND          ; 
    inc PF1         ;

    inx                     ; increment x
    sta PATTERN
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

