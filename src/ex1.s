;==============================================================================
; VE03 - EXEMPLO 1: Area de um retangulo
; Traducao do programa MIPS (ex1.asm) para Excel-ASM16.
;
; ALGORITMO ORIGINAL (em MIPS):
;   1. Le a largura (width) da entrada padrao
;   2. Le a altura (height) da entrada padrao
;   3. Calcula area = width * height
;   4. Imprime "Rectangle's area is <area>"
;
; ADAPTACOES PARA A CPU EXCEL-16:
;   - A Excel-16 nao tem mecanismo de I/O em runtime (sem stdin/stdout/teclado).
;     Como a CPU eh uma planilha, a "entrada do usuario" eh feita editando as
;     celulas de RAM em CPU.xlsx ANTES de iniciar a simulacao; a "saida" eh
;     observada lendo a celula correspondente apos a execucao.
;   - As mensagens de prompt foram omitidas (sem saida textual no Excel-16).
;   - A multiplicacao usa a instrucao MULT em hardware (16x16 -> 32 bits),
;     diferente do MIPS que usa "mult" + "mflo".
;
; LAYOUT DE MEMORIA (apos a injecao automatica do JMP de .CODE):
;   $0000-$0001  JMP automatico que pula a area de dados
;   $0002        WIDTH   - largura  (entrada do usuario)
;   $0003        HEIGHT  - altura   (entrada do usuario)
;   $0004        AREA    - area, low16  (saida)
;   $0005        AREAHI  - area, high16 (saida; bits altos do produto 32-bit)
;   $0006...     codigo do programa
;
; COMO USAR:
;   1. Compilar:    py compileExcelASM16.py ex1.s ROM-ex1.xlsx
;   2. Abrir CPU.xlsx, importar a ROM, e editar as celulas $0002 (width) e
;      $0003 (height) com os valores desejados.
;   3. Rodar a simulacao. O resultado fica em $0004 (low16) e $0005 (high16).
;==============================================================================

.DATA
WIDTH = #0   ; entrada: largura (usuario edita em CPU.xlsx, endereco $0002)
HEIGHT = #0  ; entrada: altura  (usuario edita em CPU.xlsx, endereco $0003)
AREA = #0    ; saida: area low16  (endereco $0004)
AREAHI = #0  ; saida: area high16 (endereco $0005)

.CODE

;--- Carrega largura e altura da memoria ---
LOAD R1 WIDTH    ; R1 <- MEM[WIDTH]
LOAD R2 HEIGHT   ; R2 <- MEM[HEIGHT]

;--- Calcula area = width * height ---
; MULT Ra Rb : produto 32-bit. Ra recebe os 16 bits baixos e Rb recebe os
; 16 bits altos (Rb eh SOBRESCRITO). CLC antes por precaucao.
CLC              ; C <- 0
MULT R1 R2       ; R1 = low16(WIDTH*HEIGHT); R2 = high16(WIDTH*HEIGHT)

;--- Grava o resultado de volta na memoria ---
; STORE nao aceita nome de variavel diretamente: so aceita STORE Ra Rb
; (Rb ponteiro) ou STORE Ra @hex (endereco absoluto). Como conhecemos o
; layout de memoria, usamos enderecos absolutos.
STORE R1 @0004   ; MEM[AREA]   <- low16
STORE R2 @0005   ; MEM[AREAHI] <- high16

;--- Fim do programa ---
; A Excel-16 nao tem instrucao HALT. Convencao: loop infinito sobre si mesmo.
END:
JMP END
