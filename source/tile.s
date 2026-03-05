
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
