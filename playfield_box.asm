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

;-------------------------------------------------- one time initialization
PF_BACKGROUND_WALL = $ff            ; pattern of the playfield when we want the top of the box
PF_BACKGROUND_SIDE = %00010000      ; pattern of the playfield when we want the side of the box
CTRLPF_MIRROR = %00000001

    lda #$46        ; 
    sta COLUPF      ; set playfield color to red-ish $46
;-------------------------------------------------- one time initialization


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

;; some frame logic before turning on the video
    lda #CTRLPF_MIRROR
    sta CTRLPF
;; 
    ldx #0
    stx WSYNC
    stx VBLANK ; turned on video, ended VBLANK

;-------------------------------------------------- start picture


Picture
    ; 76 cycles per scanline 
    
    lda #PF_BACKGROUND_WALL
    sta PF0                 ; set playfield0 (notice it's reversed and only the high nibble used)
    sta PF1                 ; set playfield1
    sta PF2                 ; set playfield2 (notice how the image is reversed)
Top
    inx
    stx COLUBK
    sta WSYNC
    cpx #8
    bne Top

    lda #PF_BACKGROUND_SIDE
    sta PF0
    lda #0
    sta PF1
    sta PF2   
Middle
    inx
    stx COLUBK
    sta WSYNC
    cpx #176
    bne Middle
    
    lda #PF_BACKGROUND_WALL
    sta PF0
    sta PF1
    sta PF2
Bottom
    inx
    stx COLUBK
    sta WSYNC               ; wait for scanline to finish
    cpx #192                ; compare and sets zero flag if x == 192
    bne Bottom              ; jump if not zero

;------------------------------------------------- end picture

    lda #2
    sta VBLANK  ; start VBLANK period

    ; 30 scanlines for overscan
    REPEAT 30
        sta WSYNC
    REPEND

    jmp StartOfFrame
;-------------------------------------------------- end frame

    ORG $FFFA

    .word Reset     ; NMI
    .word Reset     ; RESET
    .word Reset     ; IRQ

