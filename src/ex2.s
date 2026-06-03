; VE03 - Exemplo 2: converte pixels RGB para tons de cinza
; Traducao do ex2.c para Excel-ASM16.
;
; O C percorre um array de pixels ate achar o -1, e pra cada pixel faz
; gray = (R + G + B) / 3 e imprime. Os pontos chatos da traducao:
;
;   - Os pixels tem 24 bits (0xRRGGBB) e a CPU e de 16 bits. Entao guardei
;     cada pixel em 2 palavras: a primeira so com o R ($00RR), a segunda com
;     G e B juntos ($GGBB). E so quebrar o numero em parte alta e parte baixa.
;   - O sentinela -1 do C virou $FFFF na palavra alta (pixel valido nunca passa
;     de $00FF na palavra alta, entao da pra diferenciar).
;   - Nao tem printf: gravo os 7 resultados na RAM a partir de $0100, e tambem
;     mando pro display ($F000) so pra aparecer algo na tela.
;   - Nao tem shift logico (>>). Pra pegar o G eu uso ROR (que e rotacao) e
;     depois mascaro com $00FF pra limpar os bits que deram a volta.
;   - DIV deixa o resto no segundo registrador, entao recarrego o 3 toda vez.
;
; Registradores: R0=divisor  R1=ponteiro do array  R2=saida RAM  R3=display
;                R4=R/soma/gray  R5=B  R6=G  R7=sentinela($FFFF)  R8=mascara($00FF)
;
; Resultados esperados (confere com o ex2.c rodando no PC): 0,1,2,34,5,67,89

.DATA
; cada pixel = 2 palavras (parte alta = R, parte baixa = GB)
P0HI = $0001     ; 0x00010000  R=1  G=0  B=0
P0LO = $0000
P1HI = $0001     ; 0x00010101  R=1  G=1  B=1
P1LO = $0101
P2HI = $0000     ; 0x00000006  R=0  G=0  B=6
P2LO = $0006
P3HI = $0000     ; 0x00003333  R=0  G=51 B=51
P3LO = $3333
P4HI = $0000     ; 0x0000030C  R=0  G=3  B=12
P4LO = $030C
P5HI = $0070     ; 0x00700853  R=112 G=8 B=83
P5LO = $0853
P6HI = $0029     ; 0x00294999  R=41 G=73 B=153
P6LO = $4999
SENT = $FFFF     ; marca o fim do array (o -1 do C)

.CODE
; ponteiros e constantes
LOAD R1 $0002    ; comeco do array
LOAD R2 $0100    ; onde vou gravar os resultados
LOAD R3 $F000    ; display
LOAD R7 $FFFF    ; sentinela pra comparar
LOAD R8 $00FF    ; mascara de 1 byte

LOOP:
LOAD R4 R1       ; le a parte alta do pixel
CMP R4 R7        ; chegou no $FFFF?
JEQ DONE         ; entao acabou

INC R1
LOAD R5 R1       ; le a parte baixa ($GGBB)
INC R1           ; ja deixa apontando pro proximo pixel

; separa R, G, B
AND R4 R8        ; R = parte alta & 0xFF

TRAN R5 R6       ; copia $GGBB
ROR R6 #8        ; gira 8 bits pra trocar os bytes
AND R6 R8        ; G = byte que sobrou

AND R5 R8        ; B = parte baixa & 0xFF

; soma = R + G + B  (no maximo 765, cabe em 16 bits)
CLC              ; ADD soma o carry junto, entao zero ele antes
ADD R4 R6
CLC
ADD R4 R5

; gray = soma / 3
; divisor em R0 (registrador baixo) - mesmo problema do ex1: LOAD #imediato
; em registrador alto e usar na hora seguinte nao funciona no simulador
LOAD R0 #3
DIV R4 R0        ; R4 = soma/3 (o resto vai pro R0 e eu ignoro)

; grava o cinza na RAM e no display
STORE R4 R2
INC R2
STORE R4 R3
INC R3

JMP LOOP

DONE:
JMP DONE
