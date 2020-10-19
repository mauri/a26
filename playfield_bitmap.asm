; Simple example that draws a box using the playfield 
    processor 6502
    include "vcs.h"
    include "macro.h"

;; Segments
    SEG.U data;
    ORG $80         ; start of ram

life    ds 1        ; 1 byte
health  ds 1        ; 1 byte
score   ds 2        ; 2 bytes

    SEG code;
    ORG $F000       ; start of cartridge rom area

Reset
    ; clear all memory and registers
    lda #0
    ldx #0
Clear
    sta 0,x
    inx
    bne Clear

;-------------------------------------------------- one time initialization
C_PF_BACKGROUND_WALL = $ff            ; pattern of the playfield when we want the top of the box
C_PF_BACKGROUND_SIDE = %00010000      ; pattern of the playfield when we want the side of the box
CTRLPF_MIRROR = %00000000

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
    inc life
    lda #CTRLPF_MIRROR
    sta CTRLPF
;; 
    ldx #0
    stx WSYNC
    stx VBLANK ; turned on video, ended VBLANK

;-------------------------------------------------- start picture

    ldy #0
Picture
    ; 76 cycles per scanline 
   
    lda ImagePF0,y
    sta PF0                 ; set playfield0
    lda ImagePF1,y
    sta PF1
    lda ImagePF2,y
    sta PF2

    inx

    txa

    and #7
    cmp #7
    bne noIncy   ; here we could generate a one or cero (base if we need to improve or not) and use that to increment y ? 
    iny
noIncy

    sta WSYNC
    cpx #192
    bne Picture
 
 ;------------------------------------------------- end picture

    lda #2
    sta VBLANK  ; start VBLANK period

    ; 30 scanlines for overscan
    REPEAT 30
        sta WSYNC
    REPEND

    jmp StartOfFrame
;-------------------------------------------------- end frame


;; Data Tables
    include "image1.asm"


;-------------------------------------------------- pointers
    ORG $FFFA

    .word Reset     ; NMI
    .word Reset     ; RESET
    .word Reset     ; IRQ

