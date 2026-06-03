; VE03 - Exemplo 1: area de um retangulo
; Traducao do ex1.asm (MIPS) para Excel-ASM16.
;
; No MIPS o programa le largura e altura do teclado (syscall 5), multiplica e
; imprime a area. A Excel-16 nao tem teclado nem saida de texto, entao adaptei:
;   - largura e altura vem da ROM (edito os valores antes de rodar)
;   - o resultado fica gravado na memoria, em $0004
;   - tirei os prints de texto (nao tem como imprimir string aqui)
; A multiplicacao usa MULT, que ja devolve o produto de 32 bits em dois
; registradores - no MIPS tinha que usar mult + mflo.

.DATA
WIDTH = #0     ; $0002 - entrada (edito na ROM antes de rodar)
HEIGHT = #0    ; $0003 - entrada
AREA = #0      ; $0004 - saida (parte baixa)
AREAHI = #0    ; $0005 - saida (parte alta, se passar de 65535)

.CODE
LOAD R1 WIDTH
LOAD R2 HEIGHT

; area = largura * altura
CLC              ; zera o carry antes (ADD/MULT levam o carry em conta)
MULT R1 R2       ; R1 = parte baixa, R2 = parte alta (R2 e sobrescrito)

; grava o resultado na memoria.
; uso R0 como ponteiro de proposito: testando, vi que carregar um endereco
; com LOAD #imediato num registrador alto (R8-R15) e logo usar no STORE nao
; funciona - o valor nao chega a tempo. com R0-R7 funciona normal.
LOAD R0 #4
STORE R1 R0      ; $0004 = area
LOAD R0 #5
STORE R2 R0      ; $0005 = parte alta

; nao existe HALT, entao travo num loop pra terminar
END:
JMP END
