.segment "HEADER"
    .byte "NES", $1A
    .byte 2          ; 32 KB PRG
    .byte 1          ; 8 KB CHR
    .res 10, $00     ; total = 16 bytes

.segment "CODE"

Reset:
    sei                   ; set interrupt dissable flag
    cld                   ; clear decimal mode

    ldx #$40
    stx $4017             ; disable APU IRQ

    ldx #$FF              ; init stack
    txs                   ; Transfer X to Stack pointer

    inx                   ; increment x by one, making it wrap to 0
    stx $2000             ; disable NMI
    stx $2001             ; disable rendering
    stx $4010             ; disable DMC(delta modulation chanel) IRQ

    ldx #$02              ; loop 2 times
    WaitVBlank:           ; wait for 2 vblanks (PPU warm-up)
    bit $2002             ; set N flag with bit 7(VBlank flag)
    bpl WaitVBlank        ; branch if N flag is positive(1)
    dex                   ; decrament x (x--)
    bne WaitVBlank        ; brahcn if z != 0

    ; now 2007 writes to $3F00 in VRAM, background palette
    lda $2002             ; clear PPU internal registers
    lda #$3F              ; background palette data at $3F00
    sta $2006             ; load high byte
    lda #$00              
    sta $2006             ; load low bit
    ; deffine colors for background palette 0
    lda #$30              ; background black
    sta $2007             ; write a to $3F00 (universal background)
    lda #$16              ; palette color 1: white
    sta $2007             ; write a to $3F01 (auto increments)
    lda #$21              ; palette color 2: blue
    sta $2007             ; write a to $3F02
    lda #$2A              ; palette color 3: lime green
    sta $2007             ; write a to $3F03

    ; now 2007 writes to $3F10 in VRAM, sprite palette
    lda $2002             ; clear PPU internal registers
    lda #$3F              ; sprite palette data at $3F10
    sta $2006             ; load high bit
    lda #$10              
    sta $2006             ; load low bit
    ; deffine colors for sprite palette 0
    lda #$30              ; byte 0 is default background
    sta $2007             ; write a to $3F10
    lda #$2A              ; palette color 1: green
    sta $2007             ; write a to $3F11
    lda #$16              ; palette color 2: brownish red
    sta $2007             ; write a to $3F12
    lda #$30              ; palette color 3: white
    sta $2007             ; write a to $3F13
    ; deffine colors for sprite palette 1
    lda #$27              ; palette color 0: orange
    sta $2007             ; write a to $3F10
    lda #$12              ; palette color 1: purple
    sta $2007             ; write a to $3F11
    lda #$11              ; palette color 2: blue
    sta $2007             ; write a to $3F12
    lda #$18              ; palette color 3: nasty green
    sta $2007             ; write a to $3F13

    ; set PPU adress to $2000, where the nametable starts
    lda $2002             ; clear PPU internal registers
    lda #$20              ; $2000 beginning of first nametable
    sta $2006             ; load high byte
    lda #$00
    sta $2006             ; load low bite
    ;clear the nametable. its full of garbage after reset
    ldx #$04              ; outer loop, 4 pages (4 x 256 = 1024 bytes total)
    ldy #$00              ; inner loop 256 itterations (0 wraps to 255) 
    lda #$00
    clearNametable:
    sta $2007
    dey                   ; y--
    bne clearNametable    ; loop untill y == 0
    dex                   ; x--
    bne clearNametable    ; loop untill x == 0

    ; now write to the nametable
    lda $2002             ; clear PPU internal registers
    lda #$20              ; $2000 beginning of first nametable
    sta $2006             ; load high byte
    lda #$00
    sta $2006             ; load low bite
    
    lda #$01              ; tile number 1 (second tile)
    sta $2007             ; write to nametable ($2001)

    ; initialize variables
    lda #$80              ; starting x pos
    sta player_x          ; player x
    lda #$70              ; starting y pos
    sta player_y          ; player y

    lda #%10000000        ; enable NMI
    sta $2000
    lda #%00011110        ; start rendering background an sprites
    sta $2001

Main:                     ; end of reset
    jmp Main              ; idle loop

ReadController:
    lda #$01
    sta $4016             ; enable register strobe
    lda #$00
    sta $4016

    ldx #$08              ; loop counter(loop 8 times)    
    lda #$00              ; clear accumulator to store button bits
    sta buttons           ; also clear buttons
    ReadBits:
    lda $4016             ; read controller
    and #$01              ; only keep bit 0
    lsr a                 ; shift bit 1 of a into carry
    rol buttons           ; shift all bits to the left with carry at bit 0

    dex                   ; decrament x, set Z flag if x is 0
    bne ReadBits          ; branch if Z not equal to 0
    rts                   ; retrun from subroutine

NMI:                      ; non maskable interrupt
    jsr ReadController    ; get controller status to buttons
    
    checkUp:
    lda buttons
    and #%00000100        ; test left button. set z flag if 0
    beq checkDown         ; branch if z == 0. 
    inc player_y          ; x++ if z == 1

    checkDown:            
    lda buttons           ; reset z flag
    and #%00001000        ; test down button
    beq checkRight
    dec player_y

    checkRight:
    lda buttons           ; reset z flag
    and #%00000001        ; test right button
    beq checkLeft
    inc player_x

    checkLeft:
    lda buttons           ; reset z flag
    and #%00000010        ; test left button
    beq done
    dec player_x

    done:         

    ; draw sprites. write to OAM (Objet Atribute Memory)
    ; sprite 0 ($0200 - $0203)
    lda player_y
    sta $0200             ; byte 0: Y position
    lda #$01
    sta $0201             ; byte 1: tile 1
    lda #$00
    sta $0202             ; byte 2: sprite attrubutes
    lda player_x
    sta $0203             ; byte 3: X position
    ; sprite 1 ($0204 - $0207)
    lda #$0F
    sta $0204             ; byte 0, Y position
    lda #$03
    sta $0205             ; byte 1: tile 3
    lda #$00
    sta $0206             ; byte 2: sprite attrubutes
    lda #$0F
    sta $0207             ; byte 3: X position
    ; sprite 2 ($0208 - $020B)
    lda #$90
    sta $0208             ; byte 0, Y position
    lda #$03
    sta $0209             ; byte 1: tile 3
    lda #$00
    sta $020A             ; byte 2: sprite attrubutes
    lda #$90
    sta $020B             ; byte 3: X position

    ; DMA (direct memory access) transfer to PPU
    lda #$00              ; write $00 to OAM to use OAMDMA (automatic)
    sta $2003             ; OAM adress
    lda #$02              ; high bite of soure adress to transfer
    sta $4014             ; sprite DMA

    rti

IRQ:
    rti

.segment "VECTORS"        ; vector table, at $FFFA - $FFFF
    .word NMI             ; $FFFA - $FFFB
    .word Reset           ; $FFFC - $FFFD
    .word IRQ             ; $FFFE - $FFFF


.segment "CHR"
    ; tile 0, bitplane 0
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    ; bitplane 1
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000

    ; tile 1, bitplane 0
    .byte %11111111
    .byte %10000001
    .byte %10000001
    .byte %10000001
    .byte %10000001
    .byte %10000001
    .byte %10000001
    .byte %11111111
    ; bitplane 1
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000

    ; tile 2, bitplane 0
    .byte %11111111
    .byte %10000001
    .byte %10111101
    .byte %10100101
    .byte %10100101
    .byte %10111101
    .byte %10000001
    .byte %11111111
    ; bitplane 1
    .byte %00000000
    .byte %00000000
    .byte %00111100
    .byte %00100100
    .byte %00100100
    .byte %00111100
    .byte %00000000
    .byte %00000000

    ; tile 3, bitplane 0
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    ; bitplane 1
    .byte %00000000
    .byte %00000000
    .byte %11111111
    .byte %11111111
    .byte %00000000
    .byte %00000000
    .byte %11111111
    .byte %11111111

    .res 8128, $00 

.segment "ZEROPAGE"
    buttons: .res 1
    player_x: .res 1
    player_y: .res 1
