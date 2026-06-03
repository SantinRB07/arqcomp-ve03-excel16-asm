;==============================================================================
; VE03 - EXEMPLO 2: Conversao de pixels RGB para escala de cinza
; Traducao do programa C (ex2.c) para Excel-ASM16.
;
; ALGORITMO ORIGINAL (em C):
;   int pixels[] = { 0x00010000, 0x010101, 0x6, 0x3333,
;                    0x030c, 0x700853, 0x294999, -1 };
;   int rgb_to_gray(int red, int green, int blue) {
;       return (red + green + blue) / 3;
;   }
;   while (pixels[i] != -1) {
;       rgb   = pixels[i];
;       blue  =  rgb        & 0xff;
;       green = (rgb >> 8)  & 0xff;
;       red   = (rgb >> 16) & 0xff;
;       gray  = rgb_to_gray(red, green, blue);
;       printf("%d\n", gray);
;       i++;
;   }
;
; ADAPTACOES PARA A CPU EXCEL-16:
;   1. Pixels de 24 bits em CPU de 16 bits: cada pixel ocupa 2 palavras
;      consecutivas. Para um pixel com cor 0xRRGGBB, usamos:
;          word_HI = $00RR     (R no byte baixo, byte alto zerado)
;          word_LO = $GGBB     (G no byte alto, B no byte baixo)
;      Equivalente a separar o int de 32 bits em high16 e low16.
;   2. Sentinela "-1" (= 0xFFFFFFFF em 32 bits): basta marcar word_HI = $FFFF.
;      Distinguivel sem ambiguidade pois pixels validos tem word_HI <= $00FF.
;   3. printf nao existe na Excel-16: as 7 saidas de cinza sao gravadas em
;      RAM em enderecos consecutivos a partir de $0100, e tambem como pixels
;      no display ($F000+) para visualizacao no video (bonus).
;   4. Shift logico (>>) nao existe: simulamos com ROR (rotacao) + AND com
;      mascara $00FF para zerar os bits que voltaram pelo topo.
;   5. Soma e divisao usam ADD/DIV em hardware. CLC antes de cada ADD porque
;      ADD na Excel-16 inclui o carry: "Ra <- Ra + Rb + C".
;   6. DIV destroi o segundo operando (resto fica em Rb), entao recarregamos
;      o divisor 3 a cada iteracao.
;
; LAYOUT DE MEMORIA (apos auto-JMP de .CODE):
;   $0000-$0001  JMP automatico (pula a area de dados)
;   $0002-$000F  Array de 7 pixels (14 words: P0HI, P0LO, ..., P6HI, P6LO)
;   $0010        SENT - sentinela ($FFFF)
;   $0011...     Codigo do programa
;   $0100-$0106  Resultados gray[0..6] - escritos em runtime na RAM
;   $F000-$F006  Mesmos resultados como pixels no display (bonus visual)
;
; SAIDAS ESPERADAS (gray[0..6] em $0100..$0106):
;   pixel 0  0x00010000  R=1   G=0   B=0    -> (1+0+0)/3     = 0
;   pixel 1  0x00010101  R=1   G=1   B=1    -> (1+1+1)/3     = 1
;   pixel 2  0x00000006  R=0   G=0   B=6    -> (0+0+6)/3     = 2
;   pixel 3  0x00003333  R=0   G=51  B=51   -> (0+51+51)/3   = 34
;   pixel 4  0x0000030C  R=0   G=3   B=12   -> (0+3+12)/3    = 5
;   pixel 5  0x00700853  R=112 G=8   B=83   -> (112+8+83)/3  = 67
;   pixel 6  0x00294999  R=41  G=73  B=153  -> (41+73+153)/3 = 89
;==============================================================================

.DATA
; --- Array de pixels (formato 2-words-per-pixel) ---
P0HI = $0001     ; pixel 0 = 0x00010000 -> $0001 / $0000  (R=1, G=0, B=0)
P0LO = $0000
P1HI = $0001     ; pixel 1 = 0x00010101 -> $0001 / $0101  (R=1, G=1, B=1)
P1LO = $0101
P2HI = $0000     ; pixel 2 = 0x00000006 -> $0000 / $0006  (R=0, G=0, B=6)
P2LO = $0006
P3HI = $0000     ; pixel 3 = 0x00003333 -> $0000 / $3333  (R=0, G=51, B=51)
P3LO = $3333
P4HI = $0000     ; pixel 4 = 0x0000030C -> $0000 / $030C  (R=0, G=3, B=12)
P4LO = $030C
P5HI = $0070     ; pixel 5 = 0x00700853 -> $0070 / $0853  (R=112, G=8, B=83)
P5LO = $0853
P6HI = $0029     ; pixel 6 = 0x00294999 -> $0029 / $4999  (R=41, G=73, B=153)
P6LO = $4999
SENT = $FFFF     ; sentinela: word_HI = $FFFF marca fim do array

.CODE

;------------------------------------------------------------------------------
; Inicializacao - ponteiros e constantes em registradores
;------------------------------------------------------------------------------
LOAD R1 $0002    ; R1 = ponteiro no array de pixels (HI da iteracao atual)
LOAD R2 $0100    ; R2 = ponteiro de saida na RAM (gray results)
LOAD R3 $F000    ; R3 = ponteiro do display (visualizacao bonus)
LOAD R7 $FFFF    ; R7 = sentinela (constante para CMP)
LOAD R8 $00FF    ; R8 = mascara de byte (constante para AND)

;------------------------------------------------------------------------------
; Loop principal: enquanto pixels[i] != -1, converte para cinza
;------------------------------------------------------------------------------
LOOP:

; --- Le HI do pixel corrente e testa sentinela ---
LOAD R4 R1       ; R4 = MEM[R1] = pixel HI ($00RR ou $FFFF se sentinela)
CMP R4 R7        ; compara com $FFFF
JEQ DONE         ; se igual, fim do array -> sai do loop

; --- Le LO do pixel corrente, avanca o ponteiro ---
INC R1           ; R1 -> LO do pixel corrente
LOAD R5 R1       ; R5 = MEM[R1] = pixel LO ($GGBB)
INC R1           ; R1 -> HI do proximo pixel

; --- Extrai R, G, B ---
; R = HI & $00FF
AND R4 R8        ; R4 = R (red, 8 bits)

; G = (LO >> 8) & $00FF
; ROR rotaciona, entao precisamos da mascara para zerar os bits que voltaram
TRAN R5 R6       ; R6 = copia de LO ($GGBB)
ROR R6 #8        ; R6 = LO rotacionado 8 -> high<->low byte trocados
AND R6 R8        ; R6 = G (green, 8 bits)

; B = LO & $00FF
AND R5 R8        ; R5 = B (blue, 8 bits)

; --- soma = R + G + B ---
; ADD na Excel-16 e "Ra = Ra + Rb + C", entao CLC antes para zerar o carry.
; A soma maxima eh 3*255 = 765, cabe em 16 bits sem overflow.
CLC
ADD R4 R6        ; R4 = R + G
CLC
ADD R4 R5        ; R4 = R + G + B (= soma)

; --- gray = soma / 3 ---
; DIV destroi o segundo operando (Rb fica com o resto), entao recarregamos.
LOAD R9 #3       ; R9 = 3 (divisor)
DIV R4 R9        ; R4 = soma/3 (gray); R9 = soma%3 (descartado)

; --- Grava o resultado em RAM e no display ---
STORE R4 R2      ; MEM[R2] = gray  (saida principal em RAM, $0100+)
INC R2           ; proximo slot de resultado
STORE R4 R3      ; MEM[R3] = gray  (pixel no display, $F000+)
INC R3           ; proximo pixel do display

JMP LOOP

;------------------------------------------------------------------------------
; Fim do programa - loop infinito (Excel-16 nao tem HALT)
;------------------------------------------------------------------------------
DONE:
JMP DONE
